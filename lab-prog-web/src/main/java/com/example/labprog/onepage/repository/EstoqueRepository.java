package com.example.labprog.onepage.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.labprog.onepage.entity.Estoque;

@Repository
public interface EstoqueRepository extends JpaRepository<Estoque, Long> {
    // se precisar, você pode criar métodos de busca depois
}
