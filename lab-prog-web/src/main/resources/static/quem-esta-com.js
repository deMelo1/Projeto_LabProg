let usuarioAtual = null;

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

async function devolverCautela(id, itemNome) {
    if (!confirm(`Marcar como devolvido: ${itemNome}?`)) {
        return;
    }

    try {
        const response = await fetch(`/devolver-cautela/${id}`, {
            method: 'POST',
            credentials: 'include'
        });

        if (response.ok) {
            alert('Cautela marcada como devolvida!');
            carregarCautelas();
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao devolver');
        }
    } catch (error) {
        alert('Erro ao devolver cautela');
        console.error(error);
    }
}

function carregarCautelas() {
    fetch("/cautelas-ativas", { credentials: 'include' })
      .then(resp => {
          if (resp.status === 401) {
              window.location.href = '/login.html';
              return;
          }
          return resp.json();
      })
      .then(lista => {
          if (!lista) return;
          
        const tbody = document.getElementById("tabela-cautelas");
        tbody.innerHTML = "";
  
        if (lista.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #6b7280; padding: 32px;">Nenhum item cautelado no momento</td></tr>';
            return;
        }

        lista.forEach(item => {
          const tr = document.createElement("tr");
          
          let acoes = '';
          if (usuarioAtual && (usuarioAtual.tipo === 'MASTER' || usuarioAtual.tipo === 'ADMIN')) {
            document.getElementById('th-acoes').style.display = 'table-cell';
            acoes = `<td><button onclick="devolverCautela(${item.id}, '${item.itemNome}')" style="background: #2e7d32; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer;">Marcar Devolvido</button></td>`;
          }

          tr.innerHTML = `
            <td><strong>${item.itemNome || ""}</strong></td>
            <td>${item.quantidade || 1}</td>
            <td><strong style="color: #750000;">${item.paraQuem || ""}</strong></td>
            <td>${item.membro || ""}</td>
            <td>${item.dataCautela || ""}</td>
            <td>${item.obs || "-"}</td>
            ${acoes}
          `;

          tbody.appendChild(tr);
        });
      })
      .catch(err => console.error("Erro ao carregar cautelas:", err));
  }

  window.addEventListener("load", async () => {
    await verificarPermissao();
    carregarCautelas();
  });

