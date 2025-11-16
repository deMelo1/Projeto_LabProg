package com.example.labprog.onepage.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "submissoes") //nome da tabela no banco
public class Submissoes {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //meus atributos
    private String membro;
    private String artigo;
    private int quantidade;
    private String data;      // pode mudar pra LocalDate depois
    private String receptor;
    private String obs;

    public Submissoes() {}

    // getters e setters

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getMembro() { return membro; }
    public void setMembro(String membro) { this.membro = membro; }

    public String getArtigo() { return artigo; }
    public void setArtigo(String artigo) { this.artigo = artigo; }

    public int getQuantidade() { return quantidade; }
    public void setQuantidade(int quantidade) { this.quantidade = quantidade; }

    public String getData() { return data; }
    public void setData(String data) { this.data = data; }

    public String getReceptor() { return receptor; }
    public void setReceptor(String receptor) { this.receptor = receptor; }

    public String getObs() { return obs; }
    public void setObs(String obs) { this.obs = obs; }
}
