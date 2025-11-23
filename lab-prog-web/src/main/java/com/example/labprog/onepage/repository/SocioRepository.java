package com.example.labprog.onepage.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.example.labprog.onepage.entity.Socio;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface SocioRepository extends JpaRepository<Socio, Long> {
    
    // Buscar por CPF
    Optional<Socio> findByCpf(String cpf);
    
    // Verificar se CPF já existe
    boolean existsByCpf(String cpf);
    
    // Buscar por nome (autocomplete)
    List<Socio> findByNomeContainingIgnoreCase(String nome);
    
    // Buscar por turma
    List<Socio> findByTurma(String turma);
    
    // Buscar sócios com filiação próxima ao vencimento (30 dias)
    List<Socio> findByFimFiliacaoBetween(LocalDate inicio, LocalDate fim);
    
    // Buscar sócios atrasados
    List<Socio> findByFimFiliacaoBefore(LocalDate data);
}

