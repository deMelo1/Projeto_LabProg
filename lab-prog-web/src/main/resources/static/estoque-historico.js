let usuarioAtual = null;
let todasMovimentacoes = [];

function limparFiltros() {
    document.getElementById('filtro-busca').value = '';
    document.getElementById('filtro-tipo').value = '';
    document.getElementById('filtro-data-inicio').value = '';
    document.getElementById('filtro-data-fim').value = '';
    aplicarFiltros();
}

function aplicarFiltros() {
    const busca = document.getElementById('filtro-busca').value.toLowerCase();
    const tipoFiltro = document.getElementById('filtro-tipo').value;
    const dataInicio = document.getElementById('filtro-data-inicio').value;
    const dataFim = document.getElementById('filtro-data-fim').value;

    let movimentacoesFiltradas = todasMovimentacoes;

    if (busca) {
        movimentacoesFiltradas = movimentacoesFiltradas.filter(mov => 
            mov.itemNome.toLowerCase().includes(busca) ||
            mov.membro.toLowerCase().includes(busca)
        );
    }

    if (tipoFiltro) {
        movimentacoesFiltradas = movimentacoesFiltradas.filter(mov => mov.tipo === tipoFiltro);
    }

    if (dataInicio) {
        movimentacoesFiltradas = movimentacoesFiltradas.filter(mov => mov.data >= dataInicio);
    }

    if (dataFim) {
        movimentacoesFiltradas = movimentacoesFiltradas.filter(mov => mov.data <= dataFim);
    }

    renderizarMovimentacoes(movimentacoesFiltradas);
}

async function verificarPermissao() {
    try {
        const response = await fetch('/usuario-atual', {
            credentials: 'include'
        });
        if (response.ok) {
            usuarioAtual = await response.json();
            if (!usuarioAtual || !usuarioAtual.id) {
                window.location.href = '/login.html';
            }
        } else {
            window.location.href = '/login.html';
        }
    } catch (error) {
        window.location.href = '/login.html';
    }
}

async function deletarItem(id) {
    if (!confirm('Você tem certeza? Essa exclusão é irreversível e reverterá a movimentação no estoque.')) {
        return;
    }

    try {
        const response = await fetch(`/estoque/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        if (response.ok) {
            const data = await response.json();
            
            // Verificar se há aviso de estoque negativo
            if (data.warning) {
                alert('⚠️ AVISO:\n\n' + data.message);
            } else {
                alert('Movimentação deletada com sucesso! O estoque foi atualizado.');
            }
            
            carregarSubmissoes();
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao deletar');
        }
    } catch (error) {
        alert('Erro ao deletar movimentação');
        console.error(error);
    }
}

function carregarSubmissoes() {
    fetch("/estoque", { credentials: 'include' })
      .then(resp => {
          if (resp.status === 401) {
              window.location.href = '/login.html';
              return;
          }
          return resp.json();
      })
      .then(lista => {
          if (!lista) return;
          todasMovimentacoes = lista;
          aplicarFiltros();
      })
      .catch(err => console.error("Erro ao carregar submissões:", err));
  }

function renderizarMovimentacoes(lista) {
        const tbody = document.getElementById("tabela-submissoes");
        tbody.innerHTML = "";
  
        if (lista.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #6b7280; padding: 32px;">Nenhuma movimentação registrada</td></tr>';
            return;
        }

        lista.forEach(item => {
          const tr = document.createElement("tr");
          
          // Estilo para tipo de movimentação
          const tipoStyle = item.tipo === 'ENTRADA' 
            ? 'background: #e8f5e9; color: #2e7d32; padding: 4px 8px; border-radius: 4px; font-weight: 600;' 
            : 'background: #ffebee; color: #c62828; padding: 4px 8px; border-radius: 4px; font-weight: 600;';
          
          const tipoTexto = item.tipo === 'ENTRADA' ? '↑ Entrada' : '↓ Saída';
          
          let acoes = '';
          if (usuarioAtual && usuarioAtual.tipo === 'MASTER') {
            document.getElementById('th-acoes').style.display = 'table-cell';
            acoes = `<td><button onclick="deletarItem(${item.id})" style="background: #c62828; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer;">Excluir</button></td>`;
          }

          tr.innerHTML = `
            <td>${item.membro || ""}</td>
            <td><strong>${item.itemNome || ""}</strong></td>
            <td><span style="${tipoStyle}">${tipoTexto}</span></td>
            <td>${item.quantidade || 0}</td>
            <td>${item.data || ""}</td>
            <td>${item.obs || "-"}</td>
            ${acoes}
          `;

          tbody.appendChild(tr);
        });
  }

  // Event listeners para filtros
  document.getElementById('filtro-busca').addEventListener('input', aplicarFiltros);
  document.getElementById('filtro-tipo').addEventListener('change', aplicarFiltros);
  document.getElementById('filtro-data-inicio').addEventListener('change', aplicarFiltros);
  document.getElementById('filtro-data-fim').addEventListener('change', aplicarFiltros);

  // chama quando a página carregar
  window.addEventListener("load", async () => {
    await verificarPermissao();
    carregarSubmissoes();
  });
