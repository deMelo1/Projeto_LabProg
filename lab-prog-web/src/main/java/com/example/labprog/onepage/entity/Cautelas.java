package com.example.labprog.onepage.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "cautelas")
public class Cautelas {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String membro; // Nome do usuário responsável
    
    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario; // Quem registrou/é responsável
    
    @ManyToOne
    @JoinColumn(name = "item_id")
    private ItemCautela item; // Item sendo cautelado
    
    @Column(nullable = false)
    private Integer quantidade = 1; // Quantidade deste item
    
    private String dataCautela; // Data do empréstimo
    
    private String dataDevolucao; // Data da devolução (null se ainda não devolveu)
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusCautela status = StatusCautela.ATIVA; // ATIVA ou DEVOLVIDA
    
    private String paraQuem; // Nome de quem está com o item
    
    private String obs;

    public Cautelas() {}

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getMembro() { return membro; }
    public void setMembro(String membro) { this.membro = membro; }

    public ItemCautela getItem() { return item; }
    public void setItem(ItemCautela item) { this.item = item; }

    public Integer getQuantidade() { return quantidade; }
    public void setQuantidade(Integer quantidade) { this.quantidade = quantidade; }

    public String getDataCautela() { return dataCautela; }
    public void setDataCautela(String dataCautela) { this.dataCautela = dataCautela; }

    public String getDataDevolucao() { return dataDevolucao; }
    public void setDataDevolucao(String dataDevolucao) { this.dataDevolucao = dataDevolucao; }

    public StatusCautela getStatus() { return status; }
    public void setStatus(StatusCautela status) { this.status = status; }

    public String getParaQuem() { return paraQuem; }
    public void setParaQuem(String paraQuem) { this.paraQuem = paraQuem; }

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
