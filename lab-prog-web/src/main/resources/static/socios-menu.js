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

window.addEventListener('load', verificarAutenticacao);

