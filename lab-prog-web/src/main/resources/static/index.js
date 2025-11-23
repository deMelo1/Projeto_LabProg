let autenticacaoVerificada = false;

async function verificarAutenticacao() {
    // Se já verificou, não verifica de novo
    if (autenticacaoVerificada) {
        return;
    }

    try {
        const response = await fetch('/usuario-atual', {
            credentials: 'include'
        });
        
        if (!response.ok) {
            // Não autenticado, redireciona para login
            window.location.href = '/login.html';
            return;
        }

        const usuario = await response.json();
        if (!usuario || !usuario.id) {
            // Usuário inválido, redireciona para login
            window.location.href = '/login.html';
            return;
        }
        
        // Marca como verificado para evitar loop
        autenticacaoVerificada = true;
        
        // Atualiza a interface
        const nomeElement = document.getElementById('usuario-nome');
        if (nomeElement) {
            nomeElement.textContent = `Olá, ${usuario.nome}`;
        }

        // Controlar exibição dos cards de sócios
        const sociosCardMembro = document.getElementById('socios-card-membro');
        const sociosCardAdmin = document.getElementById('socios-card-admin');
        
        if (usuario.tipo === 'MEMBRO') {
            // Membro vê apenas "Cadastro de Sócio"
            if (sociosCardMembro) sociosCardMembro.style.display = 'block';
            if (sociosCardAdmin) sociosCardAdmin.style.display = 'none';
        } else if (usuario.tipo === 'ADMIN' || usuario.tipo === 'MASTER') {
            // Admin/Master veem "Gestão de Sócios"
            if (sociosCardMembro) sociosCardMembro.style.display = 'none';
            if (sociosCardAdmin) sociosCardAdmin.style.display = 'block';
        }

        // Mostrar opções apenas para MASTER
        if (usuario.tipo === 'MASTER') {
            const gestaoCard = document.getElementById('gestao-card');
            const logCard = document.getElementById('log-atividades-card');
            if (gestaoCard) gestaoCard.style.display = 'block';
            if (logCard) logCard.style.display = 'block';
        }
    } catch (error) {
        console.error('Erro na verificação:', error);
        window.location.href = '/login.html';
    }
}

async function fazerLogout() {
    try {
        await fetch('/logout', {
            method: 'POST',
            credentials: 'include'
        });
        autenticacaoVerificada = false;
        window.location.href = '/login.html';
    } catch (error) {
        console.error('Erro no logout:', error);
        autenticacaoVerificada = false;
        window.location.href = '/login.html';
    }
}

// Executar verificação apenas uma vez quando a página carregar
window.addEventListener('load', verificarAutenticacao);
