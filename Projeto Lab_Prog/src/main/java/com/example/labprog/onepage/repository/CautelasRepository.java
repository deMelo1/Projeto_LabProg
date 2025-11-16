package com.example.labprog.onepage.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.labprog.onepage.entity.Cautelas;

@Repository
public interface CautelasRepository extends JpaRepository<Cautelas, Long> {
    // se precisar, você pode criar métodos de busca depois
}
