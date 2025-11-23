let itensCautela = [];

async function carregarItens() {
    try {
        const response = await fetch('/itens-cautela', {
            credentials: 'include'
        });

        if (response.status === 401) {
            window.location.href = '/login.html';
            return;
        }

        itensCautela = await response.json();
        const select = document.getElementById('item');
        
        if (itensCautela.length === 0) {
            select.innerHTML = '<option value="">Nenhum item cadastrado</option>';
            return;
        }

        select.innerHTML = '<option value="">Selecione um item...</option>';
        itensCautela.forEach(item => {
            const option = document.createElement('option');
            option.value = item.id;
            option.textContent = `${item.nome} (Total: ${item.quantidadeTotal})`;
            option.dataset.quantidadeTotal = item.quantidadeTotal;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Erro ao carregar itens:', error);
        alert('Erro ao carregar itens cauteláveis');
    }
}

async function verificarDisponibilidade() {
    const itemSelect = document.getElementById('item');
    const quantidade = parseInt(document.getElementById('quantidade').value, 10);
    const aviso = document.getElementById('aviso-disponibilidade');

    if (!itemSelect.value || !quantidade) {
        aviso.style.display = 'none';
        return;
    }

    try {
        // Buscar cautelas ativas para verificar disponibilidade
        const response = await fetch('/cautelas-ativas', {
            credentials: 'include'
        });

        const cautelasAtivas = await response.json();
        const itemId = parseInt(itemSelect.value, 10);
        const quantidadeTotal = parseInt(itemSelect.selectedOptions[0].dataset.quantidadeTotal, 10);

        // Calcular quantas unidades já estão cauteladas
        const cauteladas = cautelasAtivas
            .filter(c => c.itemNome === itemSelect.selectedOptions[0].text.split(' (')[0])
            .reduce((sum, c) => sum + c.quantidade, 0);

        const disponiveis = quantidadeTotal - cauteladas;

        if (quantidade > disponiveis) {
            aviso.textContent = `⚠️ Atenção! Disponível: ${disponiveis} de ${quantidadeTotal}. ${cauteladas} já cautelado(s).`;
            aviso.style.display = 'block';
        } else {
            aviso.textContent = `✓ Disponível: ${disponiveis} de ${quantidadeTotal}`;
            aviso.style.backgroundColor = '#e8f5e9';
            aviso.style.color = '#2e7d32';
            aviso.style.display = 'block';
        }
    } catch (error) {
        console.error('Erro ao verificar disponibilidade:', error);
    }
}

document.getElementById('item').addEventListener('change', verificarDisponibilidade);
document.getElementById('quantidade').addEventListener('input', verificarDisponibilidade);

document.getElementById('btn').addEventListener('click', async function(event) {
    event.preventDefault();
    
    const form = document.querySelector('.form');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }

    const itemId = document.getElementById('item').value;
    const quantidade = parseInt(document.getElementById('quantidade').value, 10);
    const paraQuem = document.getElementById('paraQuem').value;
    const data = document.getElementById('data').value;
    const obs = document.getElementById('obs').value;

    if (!itemId) {
        alert('Por favor, selecione um item');
        return;
    }

    const payload = {
        itemId: itemId,
        quantidade: quantidade,
        paraQuem: paraQuem,
        data: data,
        obs: obs
    };

    try {
        const response = await fetch('/form-cautela', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include',
            body: JSON.stringify(payload)
        });

        const result = await response.json();

        if (result.success) {
            alert('Cautela registrada com sucesso!');
            window.location.href = 'cautelas.html';
        } else {
            alert(result.message || 'Erro ao registrar cautela');
        }
    } catch (error) {
        alert('Erro ao registrar cautela. Verifique se está logado.');
        console.error(error);
    }
});

// Definir data de hoje como padrão
document.getElementById('data').valueAsDate = new Date();

window.addEventListener('load', carregarItens);
