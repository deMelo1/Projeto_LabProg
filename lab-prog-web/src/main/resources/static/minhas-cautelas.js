async function devolverMinhaCautela(id, itemNome) {
    if (!confirm(`Confirmar devolução de: ${itemNome}?`)) {
        return;
    }

    try {
        const response = await fetch(`/devolver-cautela/${id}`, {
            method: 'POST',
            credentials: 'include'
        });

        if (response.ok) {
            alert('Devolução registrada com sucesso!');
            carregarMinhasCautelas();
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao registrar devolução');
        }
    } catch (error) {
        alert('Erro ao registrar devolução');
        console.error(error);
    }
}

function carregarMinhasCautelas() {
    fetch("/minhas-cautelas", { credentials: 'include' })
      .then(resp => {
          if (resp.status === 401) {
              window.location.href = '/login.html';
              return;
          }
          return resp.json();
      })
      .then(lista => {
          if (!lista) return;
          
        const tbody = document.getElementById("tabela-minhas-cautelas");
        tbody.innerHTML = "";
  
        if (lista.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #6b7280; padding: 32px;">Você não possui cautelas ativas no momento</td></tr>';
            return;
        }

        lista.forEach(item => {
          const tr = document.createElement("tr");

          tr.innerHTML = `
            <td><strong>${item.itemNome || ""}</strong></td>
            <td>${item.quantidade || 1}</td>
            <td><strong style="color: #750000;">${item.paraQuem || ""}</strong></td>
            <td>${item.dataCautela || ""}</td>
            <td>${item.obs || "-"}</td>
            <td>
                <button onclick="devolverMinhaCautela(${item.id}, '${item.itemNome}')" 
                        style="background: #2e7d32; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: 600;">
                    ✓ Devolver
                </button>
            </td>
          `;

          tbody.appendChild(tr);
        });
      })
      .catch(err => console.error("Erro ao carregar cautelas:", err));
  }

  window.addEventListener("load", carregarMinhasCautelas);

