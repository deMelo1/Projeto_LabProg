package com.example.labprog.onepage.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "estoque")
public class Estoque {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String membro; // Nome do usuário responsável (preenchido automaticamente)
    
    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @ManyToOne
    @JoinColumn(name = "item_id")
    private ItemEstoque item; // Relacionamento com o item do estoque
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoMovimentacao tipo; // ENTRADA ou SAIDA
    
    @Column(nullable = false)
    private Integer quantidade;
    
    private String data;
    private String obs;

    public Estoque() {}

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getMembro() { return membro; }
    public void setMembro(String membro) { this.membro = membro; }

    public ItemEstoque getItem() { return item; }
    public void setItem(ItemEstoque item) { this.item = item; }

    public TipoMovimentacao getTipo() { return tipo; }
    public void setTipo(TipoMovimentacao tipo) { this.tipo = tipo; }

    public Integer getQuantidade() { return quantidade; }
    public void setQuantidade(Integer quantidade) { this.quantidade = quantidade; }

    public String getData() { return data; }
    public void setData(String data) { this.data = data; }

    public String getObs() { return obs; }
    public void setObs(String obs) { this.obs = obs; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { 
        this.usuario = usuario;
        if (usuario != null) {
            this.membro = usuario.getNome();
        }
    }
}
