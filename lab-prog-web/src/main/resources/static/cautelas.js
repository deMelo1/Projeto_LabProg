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
                return;
            }
            
            // MEMBRO não pode ver histórico completo
            if (usuarioAtual.tipo === 'MEMBRO') {
                const cardHistorico = document.querySelector('.card:nth-child(5)');
                if (cardHistorico) {
                    cardHistorico.style.display = 'none';
                }
            }
        } else {
            window.location.href = '/login.html';
        }
    } catch (error) {
        window.location.href = '/login.html';
    }
}

window.addEventListener('load', verificarPermissao);

