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
            if (usuarioAtual.tipo !== 'MASTER') {
                window.location.href = '/index.html';
            }
        } else {
            window.location.href = '/login.html';
        }
    } catch (error) {
        window.location.href = '/login.html';
    }
}

function mostrarSecao(secao) {
    document.getElementById('secao-aprovacoes').style.display = 'none';
    document.getElementById('secao-usuarios').style.display = 'none';
    
    if (secao === 'aprovacoes') {
        document.getElementById('secao-aprovacoes').style.display = 'block';
        carregarPendentes();
    } else if (secao === 'usuarios') {
        document.getElementById('secao-usuarios').style.display = 'block';
        carregarUsuarios();
    }
}

function carregarPendentes() {
    fetch('/cadastros-pendentes', {
        credentials: 'include'
    })
    .then(resp => {
        if (!resp.ok) {
            if (resp.status === 403) {
                window.location.href = '/index.html';
            } else if (resp.status === 401) {
                window.location.href = '/login.html';
            }
            throw new Error('Erro ao carregar pendentes');
        }
        return resp.json();
    })
    .then(lista => {
        if (!lista) return;
        renderizarPendentes(lista);
    })
    .catch(err => {
        console.error("Erro ao carregar pendentes:", err);
    });
}

function renderizarPendentes(lista) {
    const tbody = document.getElementById("tabela-pendentes");
    const semPendentes = document.getElementById("sem-pendentes");
    
    if (lista.length === 0) {
        tbody.innerHTML = "";
        semPendentes.style.display = "block";
        return;
    }

    semPendentes.style.display = "none";
    tbody.innerHTML = "";
    
    lista.forEach(usuario => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
            <td>${usuario.id}</td>
            <td>${usuario.nome}</td>
            <td>${usuario.login}</td>
            <td>${usuario.tipo}</td>
            <td>
                <button onclick="aprovar(${usuario.id})" style="background: #2e7d32; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; margin-right: 8px;">Aprovar</button>
                <button onclick="rejeitar(${usuario.id})" style="background: #c62828; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer;">Rejeitar</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

async function aprovar(id) {
    try {
        const response = await fetch(`/aprovar-cadastro/${id}`, {
            method: 'POST',
            credentials: 'include'
        });

        if (response.ok) {
            alert('Usuário aprovado com sucesso!');
            carregarPendentes();
            carregarUsuarios(); // Atualizar lista de usuários também
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao aprovar usuário');
        }
    } catch (error) {
        alert('Erro ao aprovar usuário');
        console.error(error);
    }
}

async function rejeitar(id) {
    if (!confirm('Tem certeza que deseja rejeitar este cadastro?')) {
        return;
    }

    try {
        const response = await fetch(`/rejeitar-cadastro/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        if (response.ok) {
            alert('Cadastro rejeitado!');
            carregarPendentes();
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao rejeitar cadastro');
        }
    } catch (error) {
        alert('Erro ao rejeitar cadastro');
        console.error(error);
    }
}

function carregarUsuarios() {
    fetch('/usuarios', {
        credentials: 'include'
    })
    .then(resp => {
        if (!resp.ok) {
            if (resp.status === 403) {
                window.location.href = '/index.html';
            } else if (resp.status === 401) {
                window.location.href = '/login.html';
            }
            throw new Error('Erro ao carregar usuários');
        }
        return resp.json();
    })
    .then(lista => {
        if (!lista) return;
        renderizarUsuarios(lista);
    })
    .catch(err => {
        console.error("Erro ao carregar usuários:", err);
    });
}

function renderizarUsuarios(lista) {
    const tbody = document.getElementById("tabela-usuarios");
    tbody.innerHTML = "";
    
    if (lista.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #6b7280; padding: 32px;">Nenhum usuário cadastrado</td></tr>';
        return;
    }
    
    lista.forEach(usuario => {
        const tr = document.createElement("tr");
        
        const statusTexto = usuario.aprovado ? 
            '<span style="color: #2e7d32; font-weight: 600;">✓ Aprovado</span>' : 
            '<span style="color: #f57c00; font-weight: 600;">⏳ Pendente</span>';
        
        let acoes = '';
        if (usuarioAtual && usuarioAtual.id !== usuario.id) {
            acoes = `<button onclick="deletarUsuario(${usuario.id}, '${usuario.nome}')" style="background: #c62828; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer;">Excluir</button>`;
        } else {
            acoes = '<span style="color: #6b7280; font-size: 12px;">Você</span>';
        }
        
        tr.innerHTML = `
            <td>${usuario.id}</td>
            <td>${usuario.nome}</td>
            <td>${usuario.login}</td>
            <td>${usuario.tipo}</td>
            <td>${statusTexto}</td>
            <td>${acoes}</td>
        `;
        tbody.appendChild(tr);
    });
}

async function deletarUsuario(id, nome) {
    if (!confirm(`Tem certeza que deseja excluir o usuário "${nome}"?\n\nEssa ação é irreversível!`)) {
        return;
    }

    try {
        const response = await fetch(`/usuarios/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        if (response.ok) {
            alert('Usuário excluído com sucesso!');
            carregarUsuarios();
        } else {
            const data = await response.json();
            alert(data.message || 'Erro ao excluir usuário');
        }
    } catch (error) {
        alert('Erro ao excluir usuário');
        console.error(error);
    }
}

window.addEventListener("load", async () => {
    await verificarPermissao();
    // Mostrar aprovações por padrão
    mostrarSecao('aprovacoes');
});

