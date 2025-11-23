package com.example.labprog.onepage.controller;

import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.service.AuthService;
import com.example.labprog.onepage.service.LogService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class AuthController {

    @Autowired
    private AuthService authService;
    
    @Autowired
    private LogService logService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credenciais, HttpSession session) {
        String login = credenciais.get("login");
        String senha = credenciais.get("senha");

        Optional<Usuario> usuario = authService.autenticar(login, senha);
        
        if (usuario.isPresent()) {
            session.setAttribute("usuario", usuario.get());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("usuario", Map.of(
                "id", usuario.get().getId(),
                "nome", usuario.get().getNome(),
                "tipo", usuario.get().getTipo().name()
            ));
            return ResponseEntity.ok(response);
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Login ou senha inválidos, ou usuário não aprovado");
            return ResponseEntity.status(401).body(response);
        }
    }

    @PostMapping("/cadastro")
    public ResponseEntity<?> cadastro(@RequestBody Map<String, String> dados) {
        try {
            String login = dados.get("login");
            String senha = dados.get("senha");
            String nome = dados.get("nome");
            String tipoStr = dados.get("tipo");

            if (login == null || senha == null || nome == null || tipoStr == null) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Todos os campos são obrigatórios"));
            }

            TipoUsuario tipo = TipoUsuario.valueOf(tipoStr.toUpperCase());
            Usuario novoUsuario = authService.cadastrar(login, senha, nome, tipo);

            // Registrar no log (sem usuário logado, pois é um cadastro novo)
            logService.registrar(null,
                "Novo cadastro solicitado",
                "Login: " + login + " - Nome: " + nome + " - Tipo: " + tipo,
                "USUARIO",
                novoUsuario.getId());

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Cadastro realizado! Aguarde aprovação do administrador.");
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Tipo de usuário inválido"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping("/usuario-atual")
    public ResponseEntity<?> getUsuarioAtual(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario != null) {
            Map<String, Object> response = new HashMap<>();
            response.put("id", usuario.getId());
            response.put("nome", usuario.getNome());
            response.put("tipo", usuario.getTipo().name());
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(401).body(Map.of("message", "Não autenticado"));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/cadastros-pendentes")
    public ResponseEntity<?> listarPendentes(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getTipo() != TipoUsuario.MASTER) {
            return ResponseEntity.status(403).body(Map.of("message", "Acesso negado"));
        }
        List<Usuario> pendentes = authService.listarPendentes();
        return ResponseEntity.ok(pendentes);
    }

    @PostMapping("/aprovar-cadastro/{id}")
    public ResponseEntity<?> aprovarCadastro(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getTipo() != TipoUsuario.MASTER) {
            return ResponseEntity.status(403).body(Map.of("message", "Acesso negado"));
        }
        
        Usuario aprovado = authService.buscarPorId(id).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        authService.aprovarUsuario(id);
        
        // Registrar no log
        logService.registrar(usuario,
            "Aprovou cadastro",
            "Login: " + aprovado.getLogin() + " - Nome: " + aprovado.getNome() + " - Tipo: " + aprovado.getTipo(),
            "USUARIO",
            id);
        
        return ResponseEntity.ok(Map.of("success", true));
    }

    @DeleteMapping("/rejeitar-cadastro/{id}")
    public ResponseEntity<?> rejeitarCadastro(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getTipo() != TipoUsuario.MASTER) {
            return ResponseEntity.status(403).body(Map.of("message", "Acesso negado"));
        }
        
        Usuario rejeitado = authService.buscarPorId(id).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        // Registrar no log antes de deletar
        logService.registrar(usuario,
            "Rejeitou cadastro",
            "Login: " + rejeitado.getLogin() + " - Nome: " + rejeitado.getNome() + " - Tipo: " + rejeitado.getTipo(),
            "USUARIO",
            id);
        
        authService.rejeitarUsuario(id);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/usuarios")
    public ResponseEntity<?> listarUsuarios(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getTipo() != TipoUsuario.MASTER) {
            return ResponseEntity.status(403).body(Map.of("message", "Acesso negado"));
        }
        List<Usuario> usuarios = authService.listarTodos();
        return ResponseEntity.ok(usuarios);
    }

    @DeleteMapping("/usuarios/{id}")
    public ResponseEntity<?> deletarUsuario(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getTipo() != TipoUsuario.MASTER) {
            return ResponseEntity.status(403).body(Map.of("message", "Acesso negado"));
        }
        
        // Não permitir deletar a si mesmo
        if (usuario.getId().equals(id)) {
            return ResponseEntity.badRequest().body(Map.of("message", "Não é possível deletar seu próprio usuário"));
        }

        Usuario deletado = authService.buscarPorId(id).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        // Registrar no log antes de deletar
        logService.registrar(usuario,
            "Deletou usuário",
            "Login: " + deletado.getLogin() + " - Nome: " + deletado.getNome() + " - Tipo: " + deletado.getTipo(),
            "USUARIO",
            id);

        authService.deletarUsuario(id);
        return ResponseEntity.ok(Map.of("success", true));
    }
}

