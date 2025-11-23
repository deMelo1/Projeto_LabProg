package com.example.labprog.onepage.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "log_atividades")
public class LogAtividade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    @Column(nullable = false)
    private String acao; // Ex: "Cadastrou item", "Deletou movimentação", "Registrou cautela"

    @Column(length = 1000)
    private String detalhes; // Detalhes da ação

    @Column(nullable = false)
    private LocalDateTime dataHora;

    private String tipoEntidade; // "ESTOQUE", "CAUTELA", "USUARIO", "ITEM"

    private Long entidadeId; // ID da entidade afetada

    public LogAtividade() {
        this.dataHora = LocalDateTime.now();
    }

    public LogAtividade(Usuario usuario, String acao, String detalhes, String tipoEntidade, Long entidadeId) {
        this.usuario = usuario;
        this.acao = acao;
        this.detalhes = detalhes;
        this.tipoEntidade = tipoEntidade;
        this.entidadeId = entidadeId;
        this.dataHora = LocalDateTime.now();
    }

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public String getAcao() { return acao; }
    public void setAcao(String acao) { this.acao = acao; }

    public String getDetalhes() { return detalhes; }
    public void setDetalhes(String detalhes) { this.detalhes = detalhes; }

    public LocalDateTime getDataHora() { return dataHora; }
    public void setDataHora(LocalDateTime dataHora) { this.dataHora = dataHora; }

    public String getTipoEntidade() { return tipoEntidade; }
    public void setTipoEntidade(String tipoEntidade) { this.tipoEntidade = tipoEntidade; }

    public Long getEntidadeId() { return entidadeId; }
    public void setEntidadeId(Long entidadeId) { this.entidadeId = entidadeId; }
}

