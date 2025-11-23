// Carregar inventário
function carregarInventario() {
    fetch('/itens-estoque', { credentials: 'include' })
        .then(resp => {
            if (resp.status === 401) {
                window.location.href = '/login.html';
                return;
            }
            return resp.json();
        })
        .then(itens => {
            if (!itens) return;
            
            const tbody = document.getElementById('tabela-inventario');
            tbody.innerHTML = '';

            if (itens.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #6b7280; padding: 32px;">Nenhum item cadastrado. <a href="cadastro-itens.html" style="color: #750000; text-decoration: underline;">Cadastre o primeiro item</a></td></tr>';
                return;
            }

            itens.forEach(item => {
                const tr = document.createElement('tr');
                
                // Estilo para destacar quantidade
                const qtdStyle = item.quantidadeAtual === 0 
                    ? 'color: #c62828; font-weight: 600;' 
                    : 'font-weight: 600; color: #2e7d32;';
                
                tr.innerHTML = `
                    <td><strong>${item.nome || ''}</strong></td>
                    <td>${item.categoria || '-'}</td>
                    <td style="${qtdStyle}">${item.quantidadeAtual || 0}</td>
                    <td>${item.descricao || '-'}</td>
                `;
                tbody.appendChild(tr);
            });
        })
        .catch(err => console.error('Erro ao carregar inventário:', err));
}

// Carregar ao iniciar página
window.addEventListener('load', carregarInventario);

