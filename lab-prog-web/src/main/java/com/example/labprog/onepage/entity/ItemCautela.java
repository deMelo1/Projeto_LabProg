package com.example.labprog.onepage.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "itens_cautela")
public class ItemCautela {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nome;

    @Column(nullable = false)
    private Integer quantidadeTotal = 1; // Quantidade total de itens (ex: 3 violões)

    private String categoria;
    private String descricao;

    public ItemCautela() {}

    public ItemCautela(String nome, Integer quantidadeTotal, String categoria) {
        this.nome = nome;
        this.quantidadeTotal = quantidadeTotal;
        this.categoria = categoria;
    }

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public Integer getQuantidadeTotal() { return quantidadeTotal; }
    public void setQuantidadeTotal(Integer quantidadeTotal) { this.quantidadeTotal = quantidadeTotal; }

    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
}

