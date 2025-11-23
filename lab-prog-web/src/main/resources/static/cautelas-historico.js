let usuarioAtual = null;
let todasCautelas = [];

function limparFiltros() {
    document.getElementById('filtro-busca').value = '';
    document.getElementById('filtro-status').value = '';
    document.getElementById('filtro-data-inicio').value = '';
    document.getElementById('filtro-data-fim').value = '';
    aplicarFiltros();
}

function aplicarFiltros() {
    const busca = document.getElementById('filtro-busca').value.toLowerCase();
    const statusFiltro = document.getElementById('filtro-status').value;
    const dataInicio = document.getElementById('filtro-data-inicio').value;
    const dataFim = document.getElementById('filtro-data-fim').value;

    let cautelasFiltradas = todasCautelas;

    if (busca) {
        cautelasFiltradas = cautelasFiltradas.filter(c => 
            c.itemNome.toLowerCase().includes(busca) ||
            c.paraQuem.toLowerCase().includes(busca) ||
            c.membro.toLowerCase().includes(busca)
        );
    }

    if (statusFiltro) {
        cautelasFiltradas = cautelasFiltradas.filter(c => c.status === statusFiltro);
    }

    if (dataInicio) {
        cautelasFiltradas = cautelasFiltradas.filter(c => c.dataCautela >= dataInicio);
    }

    if (dataFim) {
        cautelasFiltradas = cautelasFiltradas.filter(c => c.dataCautela <= dataFim);
    }

    renderizarCautelas(cautelasFiltradas);
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
    if (!confirm('Você tem certeza? Essa exclusão é irreversível.')) {
        return;
    }

    try {
        const response = await fetch(`/cautelas/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        if (response.ok) {
            alert('Cautela deletada com sucesso!');
            carregarSubmissoes();
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao deletar');
        }
    } catch (error) {
        alert('Erro ao deletar cautela');
        console.error(error);
    }
}

function carregarSubmissoes() {
    fetch("/cautelas", { credentials: 'include' })
      .then(resp => {
          if (resp.status === 401) {
              window.location.href = '/login.html';
              return;
          }
          return resp.json();
      })
      .then(lista => {
          if (!lista) return;
          todasCautelas = lista;
          aplicarFiltros();
      })
      .catch(err => console.error("Erro ao carregar cautelas:", err));
  }

function renderizarCautelas(lista) {
        const tbody = document.querySelector("#tabela-submissoes") || document.querySelector("tbody");
        if (!tbody) return;

        tbody.innerHTML = "";

        if (lista.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9" style="text-align: center; color: #6b7280; padding: 32px;">Nenhuma cautela registrada</td></tr>';
            return;
        }

        lista.forEach(item => {
          const tr = document.createElement("tr");
          
          // Estilo para status
          const statusStyle = item.status === 'ATIVA' 
            ? 'background: #ffebee; color: #c62828; padding: 4px 8px; border-radius: 4px; font-weight: 600;' 
            : 'background: #e8f5e9; color: #2e7d32; padding: 4px 8px; border-radius: 4px; font-weight: 600;';
          
          const statusTexto = item.status === 'ATIVA' ? 'ATIVA' : 'DEVOLVIDA';
          
          let acoes = '';
          if (usuarioAtual && usuarioAtual.tipo === 'MASTER') {
            const thAcoes = document.querySelector('#th-acoes-cautelas');
            if (thAcoes) thAcoes.style.display = 'table-cell';
            acoes = `<td><button onclick="deletarItem(${item.id})" style="background: #c62828; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer;">Excluir</button></td>`;
          }

          tr.innerHTML = `
            <td>${item.membro || ""}</td>
            <td><strong>${item.itemNome || ""}</strong></td>
            <td>${item.quantidade || 1}</td>
            <td><strong style="color: #750000;">${item.paraQuem || ""}</strong></td>
            <td>${item.dataCautela || ""}</td>
            <td><span style="${statusStyle}">${statusTexto}</span></td>
            <td>${item.dataDevolucao || "-"}</td>
            <td>${item.obs || "-"}</td>
            ${acoes}
          `;

          tbody.appendChild(tr);
        });
  }

  // Event listeners para filtros
  document.getElementById('filtro-busca').addEventListener('input', aplicarFiltros);
  document.getElementById('filtro-status').addEventListener('change', aplicarFiltros);
  document.getElementById('filtro-data-inicio').addEventListener('change', aplicarFiltros);
  document.getElementById('filtro-data-fim').addEventListener('change', aplicarFiltros);

  window.addEventListener("load", async () => {
    await verificarPermissao();
    carregarSubmissoes();
  });
