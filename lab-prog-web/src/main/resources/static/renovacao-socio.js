let autenticacaoVerificada = false;
let socioSelecionado = null;

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

        configurarAutocomplete();
    } catch (error) {
        console.error('Erro na verificação:', error);
        window.location.href = '/login.html';
    }
}

function configurarAutocomplete() {
    const input = document.getElementById('busca-socio');
    const sugestoesDiv = document.getElementById('sugestoes');
    let timeout;

    input.addEventListener('input', async (e) => {
        clearTimeout(timeout);
        const query = e.target.value.trim();

        if (query.length < 2) {
            sugestoesDiv.innerHTML = '';
            return;
        }

        timeout = setTimeout(async () => {
            try {
                const response = await fetch(`/socios/autocomplete?query=${encodeURIComponent(query)}`, {
                    credentials: 'include'
                });

                if (!response.ok) throw new Error('Erro ao buscar sócios');

                const socios = await response.json();

                if (socios.length === 0) {
                    sugestoesDiv.innerHTML = '<div style="padding: 12px; background: white; border: 1px solid #ddd; border-radius: 4px; margin-top: 4px;">Nenhum sócio encontrado</div>';
                    return;
                }

                sugestoesDiv.innerHTML = socios.map(socio => `
                    <div onclick="selecionarSocio(${JSON.stringify(socio).replace(/"/g, '&quot;')})" 
                         style="padding: 12px; background: white; border: 1px solid #ddd; cursor: pointer; margin-top: 4px; border-radius: 4px;"
                         onmouseover="this.style.backgroundColor='#f8f9fa'" 
                         onmouseout="this.style.backgroundColor='white'">
                        <strong>${socio.nome}</strong> - ${socio.cpf} (${socio.turma})
                    </div>
                `).join('');
            } catch (error) {
                console.error('Erro ao buscar sócios:', error);
            }
        }, 300);
    });

    document.addEventListener('click', (e) => {
        if (!sugestoesDiv.contains(e.target) && e.target !== input) {
            sugestoesDiv.innerHTML = '';
        }
    });
}

async function selecionarSocio(socio) {
    try {
        const response = await fetch(`/socios/${socio.id}`, {
            credentials: 'include'
        });

        if (!response.ok) throw new Error('Erro ao carregar sócio');

        socioSelecionado = await response.json();

        document.getElementById('busca-socio').value = socioSelecionado.nome;
        document.getElementById('sugestoes').innerHTML = '';
        
        document.getElementById('socio-id').value = socioSelecionado.id;
        document.getElementById('socio-nome').textContent = socioSelecionado.nome;
        document.getElementById('socio-cpf').textContent = socioSelecionado.cpf;
        document.getElementById('socio-turma').textContent = socioSelecionado.turma;
        
        const vencimento = new Date(socioSelecionado.fimFiliacao + 'T00:00:00');
        document.getElementById('socio-vencimento').textContent = vencimento.toLocaleDateString('pt-BR');
        
        const statusBadge = getStatusBadge(socioSelecionado.status);
        document.getElementById('socio-status').innerHTML = statusBadge;

        document.getElementById('info-socio').style.display = 'block';
        document.getElementById('campo-nova-data').style.display = 'block';
        document.getElementById('botoes-renovacao').style.display = 'flex';

        const hoje = new Date().toISOString().split('T')[0];
        document.getElementById('novaDataFim').setAttribute('min', hoje);
    } catch (error) {
        console.error('Erro ao selecionar sócio:', error);
        alert('Erro ao carregar informações do sócio.');
    }
}

function getStatusBadge(status) {
    const styles = {
        'ATIVO': 'background-color: #28a745; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600; display: inline-block;',
        'PROXIMO_VENCIMENTO': 'background-color: #ffc107; color: #333; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600; display: inline-block;',
        'ATRASADO': 'background-color: #dc3545; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600; display: inline-block;'
    };

    const labels = {
        'ATIVO': 'ATIVO',
        'PROXIMO_VENCIMENTO': 'PRÓXIMO AO VENCIMENTO',
        'ATRASADO': 'ATRASADO'
    };

    return `<span style="${styles[status]}">${labels[status]}</span>`;
}

async function renovarFiliacao(event) {
    event.preventDefault();

    if (!socioSelecionado) {
        alert('Por favor, selecione um sócio.');
        return;
    }

    const novaDataFim = document.getElementById('novaDataFim').value;

    if (!novaDataFim) {
        alert('Por favor, informe a nova data de vencimento.');
        return;
    }

    try {
        const response = await fetch(`/socios/${socioSelecionado.id}/renovar`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include',
            body: JSON.stringify({
                novaDataFim
            })
        });

        const result = await response.json();

        if (result.success) {
            alert('Filiação renovada com sucesso!');
            limparFormulario();
        } else {
            alert('Erro: ' + (result.message || 'Não foi possível renovar a filiação'));
        }
    } catch (error) {
        console.error('Erro ao renovar filiação:', error);
        alert('Erro ao renovar filiação. Verifique sua conexão e tente novamente.');
    }
}

function limparFormulario() {
    document.getElementById('form-renovacao').reset();
    document.getElementById('busca-socio').value = '';
    document.getElementById('info-socio').style.display = 'none';
    document.getElementById('campo-nova-data').style.display = 'none';
    document.getElementById('botoes-renovacao').style.display = 'none';
    socioSelecionado = null;
}

window.addEventListener('load', verificarAutenticacao);

