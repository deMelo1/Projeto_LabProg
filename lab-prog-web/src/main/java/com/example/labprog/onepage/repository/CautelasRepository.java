package com.example.labprog.onepage.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.labprog.onepage.entity.Cautelas;
import com.example.labprog.onepage.entity.ItemCautela;
import com.example.labprog.onepage.entity.StatusCautela;
import com.example.labprog.onepage.entity.Usuario;

import java.util.List;

@Repository
public interface CautelasRepository extends JpaRepository<Cautelas, Long> {
    // Buscar cautelas ativas (não devolvidas)
    List<Cautelas> findByStatus(StatusCautela status);
    
    // Buscar cautelas de um usuário específico
    List<Cautelas> findByUsuario(Usuario usuario);
    
    // Buscar cautelas ativas de um usuário
    List<Cautelas> findByUsuarioAndStatus(Usuario usuario, StatusCautela status);
    
    // Buscar cautelas de um item com status específico
    List<Cautelas> findByItemAndStatus(ItemCautela item, StatusCautela status);
}
