package com.example.labprog.onepage.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "cautelas") //nome da tabela no banco
public class Cautelas {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //meus atributos
    private String membro;
    private String item;
    private int quantidade;
    private String data;      // pode mudar pra LocalDate depois
    private String aluno;
    private String categoria;
    private String obs;

    public Cautelas() {}

    // getters e setters

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getMembro() { return membro; }
    public void setMembro(String membro) { this.membro = membro; }

    public String getItem() { return item; }
    public void setItem(String item) { this.item = item; }

    public int getQuantidade() { return quantidade; }
    public void setQuantidade(int quantidade) { this.quantidade = quantidade; }

    public String getData() { return data; }
    public void setData(String data) { this.data = data; }

    public String getAluno() { return aluno; }
    public void setAluno(String aluno) { this.aluno = aluno; }

    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }

    public String getObs() { return obs; }
    public void setObs(String obs) { this.obs = obs; }
}
