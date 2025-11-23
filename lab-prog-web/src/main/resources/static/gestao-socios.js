let autenticacaoVerificada = false;
let sociosTodos = [];
let usuarioTipo = '';

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
        
        // Verificar permissão
        if (usuario.tipo !== 'ADMIN' && usuario.tipo !== 'MASTER') {
            alert('Acesso negado. Apenas ADMIN e MASTER podem acessar esta página.');
            window.location.href = '/index.html';
            return;
        }

        autenticacaoVerificada = true;
        usuarioTipo = usuario.tipo;
        
        const nomeElement = document.getElementById('usuario-nome');
        if (nomeElement) {
            nomeElement.textContent = `Olá, ${usuario.nome}`;
        }

        carregarSocios();
    } catch (error) {
        console.error('Erro na verificação:', error);
        window.location.href = '/login.html';
    }
}

async function carregarSocios() {
    try {
        const response = await fetch('/socios', {
            credentials: 'include'
        });

        if (!response.ok) {
            throw new Error('Erro ao carregar sócios');
        }

        sociosTodos = await response.json();
        renderizarSocios(sociosTodos);
    } catch (error) {
        console.error('Erro ao carregar sócios:', error);
        document.getElementById('loading').textContent = 'Erro ao carregar sócios.';
    }
}

function renderizarSocios(socios) {
    const loading = document.getElementById('loading');
    const tabelaContainer = document.getElementById('tabela-container');
    const vazio = document.getElementById('vazio');
    const tbody = document.getElementById('lista-socios');

    loading.style.display = 'none';

    if (socios.length === 0) {
        vazio.style.display = 'block';
        tabelaContainer.style.display = 'none';
        return;
    }

    vazio.style.display = 'none';
    tabelaContainer.style.display = 'block';

    tbody.innerHTML = socios.map(socio => {
        const statusBadge = getStatusBadge(socio.status);
        const fim = new Date(socio.fimFiliacao + 'T00:00:00');
        const fimFormatado = fim.toLocaleDateString('pt-BR');

        return `
            <tr style="border-bottom: 1px solid #eee;">
                <td style="padding: 12px;">${socio.nome}</td>
                <td style="padding: 12px;">${socio.cpf}</td>
                <td style="padding: 12px;">${socio.turma}</td>
                <td style="padding: 12px;">${fimFormatado}</td>
                <td style="padding: 12px; text-align: center;">${statusBadge}</td>
                <td style="padding: 12px; text-align: center;">
                    <button onclick="deletarSocio(${socio.id}, '${socio.nome}')" 
                            class="btn-ghost" 
                            style="padding: 6px 12px; font-size: 12px; background-color: #dc3545; color: white; border: none; cursor: pointer; border-radius: 4px;">
                        Excluir
                    </button>
                </td>
            </tr>
        `;
    }).join('');
}

function getStatusBadge(status) {
    const styles = {
        'ATIVO': 'background-color: #28a745; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;',
        'PROXIMO_VENCIMENTO': 'background-color: #ffc107; color: #333; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;',
        'ATRASADO': 'background-color: #dc3545; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;'
    };

    const labels = {
        'ATIVO': 'ATIVO',
        'PROXIMO_VENCIMENTO': 'PRÓX. VENCER',
        'ATRASADO': 'ATRASADO'
    };

    return `<span style="${styles[status]}">${labels[status]}</span>`;
}

async function deletarSocio(id, nome) {
    if (!confirm(`Tem certeza que deseja excluir o sócio "${nome}"?`)) {
        return;
    }

    try {
        const response = await fetch(`/socios/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        const result = await response.json();

        if (result.success) {
            alert('Sócio excluído com sucesso!');
            carregarSocios();
        } else {
            alert('Erro: ' + (result.message || 'Não foi possível excluir o sócio'));
        }
    } catch (error) {
        console.error('Erro ao excluir sócio:', error);
        alert('Erro ao excluir sócio. Verifique sua conexão e tente novamente.');
    }
}

// Filtro de busca
document.addEventListener('DOMContentLoaded', () => {
    const busca = document.getElementById('busca');
    if (busca) {
        busca.addEventListener('input', (e) => {
            const termo = e.target.value.toLowerCase();
            const sociosFiltrados = sociosTodos.filter(socio => 
                socio.nome.toLowerCase().includes(termo) ||
                socio.cpf.includes(termo) ||
                socio.turma.toLowerCase().includes(termo)
            );
            renderizarSocios(sociosFiltrados);
        });
    }
});

window.addEventListener('load', verificarAutenticacao);

