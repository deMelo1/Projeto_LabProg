package com.example.labprog.onepage.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "socios")
public class Socio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false, unique = true, length = 14)
    private String cpf; // Formato: XXX.XXX.XXX-XX

    @Column(nullable = false, length = 10)
    private String turma; // XXV, XXVI, XXVII, XXVIII, XXIX

    @Column(nullable = false)
    private LocalDate inicioFiliacao;

    @Column(nullable = false)
    private LocalDate fimFiliacao;

    @ManyToOne
    @JoinColumn(name = "cadastrado_por_id")
    private Usuario cadastradoPor;

    @Column(name = "data_cadastro")
    private LocalDate dataCadastro;

    @Column(name = "data_ultima_renovacao")
    private LocalDate dataUltimaRenovacao;

    public Socio() {
        this.dataCadastro = LocalDate.now();
    }

    // Métodos auxiliares
    @Transient
    public boolean isAtrasado() {
        return LocalDate.now().isAfter(fimFiliacao);
    }

    @Transient
    public long diasParaVencer() {
        return java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), fimFiliacao);
    }

    @Transient
    public String getStatus() {
        if (isAtrasado()) {
            return "ATRASADO";
        } else if (diasParaVencer() <= 30) {
            return "PROXIMO_VENCIMENTO";
        }
        return "ATIVO";
    }

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getCpf() { return cpf; }
    public void setCpf(String cpf) { this.cpf = cpf; }

    public String getTurma() { return turma; }
    public void setTurma(String turma) { this.turma = turma; }

    public LocalDate getInicioFiliacao() { return inicioFiliacao; }
    public void setInicioFiliacao(LocalDate inicioFiliacao) { this.inicioFiliacao = inicioFiliacao; }

    public LocalDate getFimFiliacao() { return fimFiliacao; }
    public void setFimFiliacao(LocalDate fimFiliacao) { this.fimFiliacao = fimFiliacao; }

    public Usuario getCadastradoPor() { return cadastradoPor; }
    public void setCadastradoPor(Usuario cadastradoPor) { this.cadastradoPor = cadastradoPor; }

    public LocalDate getDataCadastro() { return dataCadastro; }
    public void setDataCadastro(LocalDate dataCadastro) { this.dataCadastro = dataCadastro; }

    public LocalDate getDataUltimaRenovacao() { return dataUltimaRenovacao; }
    public void setDataUltimaRenovacao(LocalDate dataUltimaRenovacao) { this.dataUltimaRenovacao = dataUltimaRenovacao; }
}

