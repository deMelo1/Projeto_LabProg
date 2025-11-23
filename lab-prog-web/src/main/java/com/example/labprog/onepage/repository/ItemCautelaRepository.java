package com.example.labprog.onepage.repository;

import com.example.labprog.onepage.entity.ItemCautela;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ItemCautelaRepository extends JpaRepository<ItemCautela, Long> {
    Optional<ItemCautela> findByNome(String nome);
    boolean existsByNome(String nome);
}

