let itensEstoque = [];

// Carregar itens no select
async function carregarItens() {
    try {
        const response = await fetch('/itens-estoque', {
            credentials: 'include'
        });

        if (response.status === 401) {
            window.location.href = '/login.html';
            return;
        }

        itensEstoque = await response.json();
        const select = document.getElementById('item');
        
        if (itensEstoque.length === 0) {
            select.innerHTML = '<option value="">Nenhum item cadastrado</option>';
            return;
        }

        select.innerHTML = '<option value="">Selecione um item...</option>';
        itensEstoque.forEach(item => {
            const option = document.createElement('option');
            option.value = item.id;
            option.textContent = `${item.nome} (Estoque: ${item.quantidadeAtual})`;
            option.dataset.quantidadeAtual = item.quantidadeAtual;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Erro ao carregar itens:', error);
        alert('Erro ao carregar itens do estoque');
    }
}

// Verificar estoque disponível ao mudar item ou quantidade
function verificarEstoque() {
    const tipo = document.getElementById('tipo').value;
    const itemSelect = document.getElementById('item');
    const quantidade = parseInt(document.getElementById('quantidade').value, 10);
    const aviso = document.getElementById('aviso-estoque');

    if (tipo === 'SAIDA' && itemSelect.value && quantidade) {
        const quantidadeAtual = parseInt(itemSelect.selectedOptions[0].dataset.quantidadeAtual, 10);
        
        if (quantidade > quantidadeAtual) {
            aviso.textContent = `⚠️ Estoque insuficiente! Disponível: ${quantidadeAtual} unidades`;
            aviso.style.display = 'block';
        } else {
            aviso.style.display = 'none';
        }
    } else {
        aviso.style.display = 'none';
    }
}

// Event listeners para verificação
document.getElementById('tipo').addEventListener('change', verificarEstoque);
document.getElementById('item').addEventListener('change', verificarEstoque);
document.getElementById('quantidade').addEventListener('input', verificarEstoque);

// Submeter formulário
document.getElementById('btn').addEventListener('click', async function(event) {
    event.preventDefault();
    
    const form = document.querySelector('.form');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }

    const tipo = document.getElementById('tipo').value;
    const itemId = document.getElementById('item').value;
    const quantidade = parseInt(document.getElementById('quantidade').value, 10);
    const data = document.getElementById('data').value;
    const obs = document.getElementById('obs').value;

    if (!itemId) {
        alert('Por favor, selecione um item');
        return;
    }

    const payload = {
        tipo: tipo,
        itemId: itemId,
        quantidade: quantidade,
        data: data,
        obs: obs
    };

    try {
        const response = await fetch('/form-estoque', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include',
            body: JSON.stringify(payload)
        });

        const result = await response.json();

        if (result.success) {
            alert(`Movimentação registrada com sucesso!\nQuantidade atual: ${result.quantidadeAtual}`);
            window.location.href = 'estoque.html';
        } else {
            alert(result.message || 'Erro ao registrar movimentação');
        }
    } catch (error) {
        alert('Erro ao registrar movimentação. Verifique se está logado.');
        console.error(error);
    }
});

// Definir data de hoje como padrão
document.getElementById('data').valueAsDate = new Date();

// Carregar itens ao iniciar
window.addEventListener('load', carregarItens);
