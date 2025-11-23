package com.example.labprog.onepage.service;

import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    public Optional<Usuario> autenticar(String login, String senha) {
        Optional<Usuario> usuario = usuarioRepository.findByLogin(login);
        if (usuario.isPresent() && usuario.get().getSenha().equals(senha) && usuario.get().getAprovado()) {
            return usuario;
        }
        return Optional.empty();
    }

    public Usuario cadastrar(String login, String senha, String nome, TipoUsuario tipo) {
        if (usuarioRepository.existsByLogin(login)) {
            throw new RuntimeException("Login já existe");
        }
        Usuario novoUsuario = new Usuario(login, senha, nome, tipo);
        return usuarioRepository.save(novoUsuario);
    }

    public List<Usuario> listarPendentes() {
        return usuarioRepository.findByAprovadoFalse();
    }

    public void aprovarUsuario(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        usuario.setAprovado(true);
        usuarioRepository.save(usuario);
    }

    public void rejeitarUsuario(Long id) {
        usuarioRepository.deleteById(id);
    }

    public Optional<Usuario> buscarPorId(Long id) {
        return usuarioRepository.findById(id);
    }

    public List<Usuario> listarTodos() {
        return usuarioRepository.findAll();
    }

    public void deletarUsuario(Long id) {
        usuarioRepository.deleteById(id);
    }
}

