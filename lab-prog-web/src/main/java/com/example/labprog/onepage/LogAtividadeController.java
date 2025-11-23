package com.example.labprog.onepage;

import com.example.labprog.onepage.entity.LogAtividade;
import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.LogAtividadeRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class LogAtividadeController {

    private final LogAtividadeRepository logRepository;

    public LogAtividadeController(LogAtividadeRepository logRepository) {
        this.logRepository = logRepository;
    }

    @GetMapping("/log-atividades")
    public ResponseEntity<?> listar(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        // Apenas MASTER pode ver logs
        if (usuario.getTipo() != TipoUsuario.MASTER) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        List<LogAtividade> logs = logRepository.findAllByOrderByDataHoraDesc();
        
        List<Map<String, Object>> resultado = logs.stream().map(log -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", log.getId());
            map.put("usuario", log.getUsuario() != null ? log.getUsuario().getNome() : "Sistema");
            map.put("acao", log.getAcao());
            map.put("detalhes", log.getDetalhes());
            map.put("tipoEntidade", log.getTipoEntidade());
            map.put("entidadeId", log.getEntidadeId());
            map.put("dataHora", log.getDataHora().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(resultado);
    }
}

