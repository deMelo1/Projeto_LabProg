let autenticacaoVerificada = false;

async function verificarAutenticacao() {
    if (autenticacaoVerificada) return;

    try {
        const response = await fetch('/usuario-atual', {
            credentials: 'include'
        });
        
        if (!response.ok) {
            window.location.href = '/login.html';
            return;
        }

        const usuario = await response.json();
        if (!usuario || !usuario.id) {
            window.location.href = '/login.html';
            return;
        }
        
        autenticacaoVerificada = true;
        
        const nomeElement = document.getElementById('usuario-nome');
        if (nomeElement) {
            nomeElement.textContent = `Olá, ${usuario.nome}`;
        }
    } catch (error) {
        console.error('Erro na verificação:', error);
        window.location.href = '/login.html';
    }
}

// Máscara de CPF
document.addEventListener('DOMContentLoaded', () => {
    const cpfInput = document.getElementById('cpf');
    if (cpfInput) {
        cpfInput.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length <= 11) {
                value = value.replace(/(\d{3})(\d)/, '$1.$2');
                value = value.replace(/(\d{3})(\d)/, '$1.$2');
                value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
                e.target.value = value;
            }
        });
    }
});

async function cadastrarSocio(event) {
    event.preventDefault();

    const nome = document.getElementById('nome').value.trim();
    const cpf = document.getElementById('cpf').value.trim();
    const turma = document.getElementById('turma').value;
    const inicioFiliacao = document.getElementById('inicioFiliacao').value;
    const fimFiliacao = document.getElementById('fimFiliacao').value;

    if (!nome || !cpf || !turma || !inicioFiliacao || !fimFiliacao) {
        alert('Por favor, preencha todos os campos obrigatórios.');
        return;
    }

    try {
        const response = await fetch('/socios', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include',
            body: JSON.stringify({
                nome,
                cpf,
                turma,
                inicioFiliacao,
                fimFiliacao
            })
        });

        const result = await response.json();

        if (result.success) {
            alert('Sócio cadastrado com sucesso!');
            document.getElementById('form-cadastro').reset();
        } else {
            alert('Erro: ' + (result.message || 'Não foi possível cadastrar o sócio'));
        }
    } catch (error) {
        console.error('Erro ao cadastrar sócio:', error);
        alert('Erro ao cadastrar sócio. Verifique sua conexão e tente novamente.');
    }
}

window.addEventListener('load', verificarAutenticacao);

