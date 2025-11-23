package com.example.labprog.onepage.repository;

import com.example.labprog.onepage.entity.ItemEstoque;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ItemEstoqueRepository extends JpaRepository<ItemEstoque, Long> {
    Optional<ItemEstoque> findByNome(String nome);
    boolean existsByNome(String nome);
}

