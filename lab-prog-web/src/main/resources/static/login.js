function mostrarLogin() {
    document.querySelectorAll('.auth-tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.auth-form').forEach(form => form.classList.remove('active'));
    document.querySelector('.auth-tab').classList.add('active');
    document.getElementById('login-form').classList.add('active');
    limparMensagens();
}

function mostrarCadastro() {
    document.querySelectorAll('.auth-tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.auth-form').forEach(form => form.classList.remove('active'));
    document.querySelectorAll('.auth-tab')[1].classList.add('active');
    document.getElementById('cadastro-form').classList.add('active');
    limparMensagens();
}

function limparMensagens() {
    const errorDiv = document.getElementById('error-message');
    const successDiv = document.getElementById('success-message');
    if (errorDiv) errorDiv.classList.remove('show');
    if (successDiv) successDiv.classList.remove('show');
}

function mostrarErro(mensagem) {
    const errorDiv = document.getElementById('error-message');
    if (errorDiv) {
        errorDiv.textContent = mensagem;
        errorDiv.classList.add('show');
    }
    const successDiv = document.getElementById('success-message');
    if (successDiv) successDiv.classList.remove('show');
}

function mostrarSucesso(mensagem) {
    const successDiv = document.getElementById('success-message');
    if (successDiv) {
        successDiv.textContent = mensagem;
        successDiv.classList.add('show');
    }
    const errorDiv = document.getElementById('error-message');
    if (errorDiv) errorDiv.classList.remove('show');
}

async function fazerLogin(event) {
    event.preventDefault();
    limparMensagens();

    const login = document.getElementById('login-username').value;
    const senha = document.getElementById('login-password').value;

    try {
        const response = await fetch('/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include',
            body: JSON.stringify({ login, senha })
        });

        const data = await response.json();

        if (data.success) {
            // Redireciona imediatamente após login bem-sucedido
            window.location.href = '/index.html';
        } else {
            mostrarErro(data.message || 'Login ou senha inválidos');
        }
    } catch (error) {
        mostrarErro('Erro ao fazer login. Tente novamente.');
        console.error(error);
    }
}

async function fazerCadastro(event) {
    event.preventDefault();
    limparMensagens();

    const nome = document.getElementById('cadastro-nome').value;
    const login = document.getElementById('cadastro-login').value;
    const senha = document.getElementById('cadastro-password').value;
    const senhaConfirm = document.getElementById('cadastro-password-confirm').value;
    const tipo = document.getElementById('cadastro-tipo').value;

    if (senha !== senhaConfirm) {
        mostrarErro('As senhas não coincidem');
        return;
    }

    if (senha.length < 4) {
        mostrarErro('A senha deve ter pelo menos 4 caracteres');
        return;
    }

    try {
        const response = await fetch('/cadastro', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ nome, login, senha, tipo })
        });

        const data = await response.json();

        if (data.success) {
            mostrarSucesso(data.message || 'Cadastro realizado! Aguarde aprovação.');
            document.getElementById('cadastro-form').reset();
            setTimeout(() => {
                mostrarLogin();
            }, 2000);
        } else {
            mostrarErro(data.message || 'Erro ao realizar cadastro');
        }
    } catch (error) {
        mostrarErro('Erro ao realizar cadastro. Tente novamente.');
        console.error(error);
    }
}

// Verificar se já está logado - NÃO faz nada se já estiver na página de login
if (!sessionStorage.getItem('onLoginPage')) {
    sessionStorage.setItem('onLoginPage', 'true');
    
    window.addEventListener('load', async () => {
        try {
            const response = await fetch('/usuario-atual', {
                credentials: 'include'
            });
            
            if (response.ok) {
                const usuario = await response.json();
                if (usuario && usuario.id) {
                    // Usuário já está logado, redireciona para index
                    sessionStorage.removeItem('onLoginPage');
                    window.location.href = '/index.html';
                }
            }
        } catch (error) {
            // Não autenticado, permanece no login
        }
    });
}

// Limpa a flag quando sair da página
window.addEventListener('beforeunload', () => {
    sessionStorage.removeItem('onLoginPage');
});
