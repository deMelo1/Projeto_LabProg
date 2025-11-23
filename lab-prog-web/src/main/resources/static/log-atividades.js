let todosLogs = [];

function carregarLogs() {
    fetch('/log-atividades', { credentials: 'include' })
        .then(resp => {
            if (resp.status === 401) {
                window.location.href = '/login.html';
                return;
            }
            if (resp.status === 403) {
                alert('Acesso negado. Apenas MASTER pode ver o log.');
                window.location.href = '/index.html';
                return;
            }
            return resp.json();
        })
        .then(logs => {
            if (!logs) return;
            todosLogs = logs;
            aplicarFiltros();
        })
        .catch(err => console.error('Erro ao carregar logs:', err));
}

function aplicarFiltros() {
    const busca = document.getElementById('filtro-busca').value.toLowerCase();
    const tipoFiltro = document.getElementById('filtro-tipo').value;

    let logsFiltrados = todosLogs;

    // Filtrar por tipo
    if (tipoFiltro) {
        logsFiltrados = logsFiltrados.filter(log => log.tipoEntidade === tipoFiltro);
    }

    // Filtrar por busca
    if (busca) {
        logsFiltrados = logsFiltrados.filter(log => 
            log.usuario.toLowerCase().includes(busca) ||
            log.acao.toLowerCase().includes(busca) ||
            (log.detalhes && log.detalhes.toLowerCase().includes(busca))
        );
    }

    renderizarLogs(logsFiltrados);
}

function renderizarLogs(logs) {
    const tbody = document.getElementById('tabela-logs');
    tbody.innerHTML = '';

    if (logs.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #6b7280; padding: 32px;">Nenhum log encontrado</td></tr>';
        return;
    }

    logs.forEach(log => {
        const tr = document.createElement('tr');
        
        // Cor por tipo
        let tipoCor = '#6b7280';
        if (log.tipoEntidade === 'ESTOQUE') tipoCor = '#2563eb';
        if (log.tipoEntidade === 'CAUTELA') tipoCor = '#059669';
        if (log.tipoEntidade === 'USUARIO') tipoCor = '#dc2626';
        if (log.tipoEntidade === 'ITEM') tipoCor = '#7c3aed';

        tr.innerHTML = `
            <td style="white-space: nowrap;"><small>${log.dataHora}</small></td>
            <td><strong>${log.usuario}</strong></td>
            <td>${log.acao}</td>
            <td style="max-width: 400px;">${log.detalhes || '-'}</td>
            <td><span style="background: ${tipoCor}; color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">${log.tipoEntidade || '-'}</span></td>
        `;
        tbody.appendChild(tr);
    });
}

// Event listeners para filtros
document.getElementById('filtro-busca').addEventListener('input', aplicarFiltros);
document.getElementById('filtro-tipo').addEventListener('change', aplicarFiltros);

window.addEventListener('load', carregarLogs);

