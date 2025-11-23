// Cadastrar novo item
document.getElementById('form-item').addEventListener('submit', async function(event) {
    event.preventDefault();
    
    const form = this;
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }

    const nome = document.getElementById('nome').value;
    const categoria = document.getElementById('categoria').value;
    const quantidadeInicial = parseInt(document.getElementById('quantidadeInicial').value, 10);
    const descricao = document.getElementById('descricao').value;

    const payload = {
        nome: nome,
        categoria: categoria,
        quantidadeAtual: quantidadeInicial,
        descricao: descricao
    };

    try {
        const response = await fetch('/itens-estoque', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include',
            body: JSON.stringify(payload)
        });

        const data = await response.json();

        if (data.success) {
            alert('Item cadastrado com sucesso!');
            form.reset();
            carregarItens();
        } else {
            alert(data.message || 'Erro ao cadastrar item');
        }
    } catch (error) {
        alert('Erro ao cadastrar item. Verifique se está logado.');
        console.error(error);
    }
});

// Deletar item
async function deletarItem(id, nome) {
    if (!confirm(`Tem certeza que deseja deletar o item "${nome}"? Esta ação é irreversível.`)) {
        return;
    }

    try {
        const response = await fetch(`/itens-estoque/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        if (response.ok) {
            alert('Item deletado com sucesso!');
            carregarItens();
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao deletar item');
        }
    } catch (error) {
        alert('Erro ao deletar item');
        console.error(error);
    }
}

// Carregar itens cadastrados
function carregarItens() {
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
            
            const tbody = document.getElementById('tabela-itens');
            tbody.innerHTML = '';

            if (itens.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #6b7280;">Nenhum item cadastrado</td></tr>';
                return;
            }

            itens.forEach(item => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${item.nome || ''}</td>
                    <td>${item.categoria || '-'}</td>
                    <td><strong>${item.quantidadeAtual || 0}</strong></td>
                    <td>${item.descricao || '-'}</td>
                    <td>
                        <button onclick="deletarItem(${item.id}, '${item.nome}')" 
                                style="background: #c62828; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer;">
                            Excluir
                        </button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        })
        .catch(err => console.error('Erro ao carregar itens:', err));
}

// Carregar ao iniciar página
window.addEventListener('load', carregarItens);

