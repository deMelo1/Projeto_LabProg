package com.example.labprog.onepage.repository;

import com.example.labprog.onepage.entity.LogAtividade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LogAtividadeRepository extends JpaRepository<LogAtividade, Long> {
    // Buscar logs ordenados por data decrescente (mais recentes primeiro)
    List<LogAtividade> findAllByOrderByDataHoraDesc();
    
    // Buscar logs de um tipo específico
    List<LogAtividade> findByTipoEntidadeOrderByDataHoraDesc(String tipoEntidade);
}

