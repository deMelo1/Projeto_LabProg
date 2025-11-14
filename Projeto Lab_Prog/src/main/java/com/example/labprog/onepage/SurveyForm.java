package com.example.labprog.onepage;

import java.util.ArrayList;
import java.util.List;

public class SurveyForm {
  private String nome;
  private String email;
  private Integer idade;
  private String perfil;
  private String recomendaria;
  private List<String> tecnologias = new ArrayList<>();
  private String comentarios;

  public String getNome() { return nome; }
  public void setNome(String nome) { this.nome = nome; }

  public String getEmail() { return email; }
  public void setEmail(String email) { this.email = email; }

  public Integer getIdade() { return idade; }
  public void setIdade(Integer idade) { this.idade = idade; }

  public String getPerfil() { return perfil; }
  public void setPerfil(String perfil) { this.perfil = perfil; }

  public String getRecomendaria() { return recomendaria; }
  public void setRecomendaria(String recomendaria) { this.recomendaria = recomendaria; }

  public List<String> getTecnologias() { return tecnologias; }
  public void setTecnologias(List<String> tecnologias) { this.tecnologias = tecnologias; }

  public String getComentarios() { return comentarios; }
  public void setComentarios(String comentarios) { this.comentarios = comentarios; }
}
