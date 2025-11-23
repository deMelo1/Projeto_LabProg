package com.example.labprog.onepage.service;

import com.example.labprog.onepage.entity.LogAtividade;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.LogAtividadeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class LogService {

    @Autowired
    private LogAtividadeRepository logRepository;

    public void registrar(Usuario usuario, String acao, String detalhes, String tipoEntidade, Long entidadeId) {
        LogAtividade log = new LogAtividade(usuario, acao, detalhes, tipoEntidade, entidadeId);
        logRepository.save(log);
    }

    public void registrar(Usuario usuario, String acao, String detalhes) {
        registrar(usuario, acao, detalhes, null, null);
    }
}

