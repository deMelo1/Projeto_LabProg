package com.example.labprog.onepage;

import com.example.labprog.onepage.entity.Socio;
import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.SocioRepository;
import com.example.labprog.onepage.service.LogService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class SocioController {

    private final SocioRepository socioRepository;
    private final LogService logService;

    public SocioController(SocioRepository socioRepository, LogService logService) {
        this.socioRepository = socioRepository;
        this.logService = logService;
    }

    // Cadastrar novo sócio (Todos os usuários autenticados)
    @PostMapping("/socios")
    public ResponseEntity<?> cadastrar(@RequestBody Map<String, Object> payload, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        try {
            String nome = payload.get("nome").toString();
            String cpf = payload.get("cpf").toString();
            String turma = payload.get("turma").toString();
            String inicioStr = payload.get("inicioFiliacao").toString();
            String fimStr = payload.get("fimFiliacao").toString();

            // Validar CPF único
            if (socioRepository.existsByCpf(cpf)) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Já existe um sócio cadastrado com este CPF"
                ));
            }

            // Validar datas
            LocalDate inicio = LocalDate.parse(inicioStr);
            LocalDate fim = LocalDate.parse(fimStr);

            if (fim.isBefore(inicio)) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "A data de fim da filiação deve ser posterior à data de início"
                ));
            }

            Socio socio = new Socio();
            socio.setNome(nome);
            socio.setCpf(cpf);
            socio.setTurma(turma);
            socio.setInicioFiliacao(inicio);
            socio.setFimFiliacao(fim);
            socio.setCadastradoPor(usuario);

            Socio salvo = socioRepository.save(socio);

            // Registrar no log
            logService.registrar(usuario,
                "Cadastrou sócio",
                nome + " - CPF: " + cpf + " - Turma: " + turma,
                "SOCIO",
                salvo.getId());

            return ResponseEntity.ok(Map.of("success", true, "socio", salvo));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Erro ao cadastrar sócio: " + e.getMessage()
            ));
        }
    }

    // Listar todos os sócios
    @GetMapping("/socios")
    public ResponseEntity<?> listar(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<Socio> socios = socioRepository.findAll();

        List<Map<String, Object>> resultado = socios.stream().map(s -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", s.getId());
            map.put("nome", s.getNome());
            map.put("cpf", s.getCpf());
            map.put("turma", s.getTurma());
            map.put("inicioFiliacao", s.getInicioFiliacao().toString());
            map.put("fimFiliacao", s.getFimFiliacao().toString());
            map.put("status", s.getStatus());
            map.put("isAtrasado", s.isAtrasado());
            map.put("diasParaVencer", s.diasParaVencer());
            map.put("dataCadastro", s.getDataCadastro() != null ? s.getDataCadastro().toString() : null);
            map.put("dataUltimaRenovacao", s.getDataUltimaRenovacao() != null ? s.getDataUltimaRenovacao().toString() : null);
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(resultado);
    }

    // Buscar sócio por ID
    @GetMapping("/socios/{id}")
    public ResponseEntity<?> buscar(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        return socioRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    // Autocomplete de sócios (busca por nome)
    @GetMapping("/socios/autocomplete")
    public ResponseEntity<?> autocomplete(@RequestParam String query, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<Socio> socios = socioRepository.findByNomeContainingIgnoreCase(query);
        
        List<Map<String, Object>> resultado = socios.stream().map(s -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", s.getId());
            map.put("nome", s.getNome());
            map.put("cpf", s.getCpf());
            map.put("turma", s.getTurma());
            map.put("status", s.getStatus());
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(resultado);
    }

    // Renovar filiação
    @PostMapping("/socios/{id}/renovar")
    public ResponseEntity<?> renovar(@PathVariable Long id, @RequestBody Map<String, Object> payload, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        try {
            Socio socio = socioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Sócio não encontrado"));

            String novaDataFimStr = payload.get("novaDataFim").toString();
            LocalDate novaDataFim = LocalDate.parse(novaDataFimStr);

            // Validar que a nova data é posterior à atual
            if (novaDataFim.isBefore(socio.getFimFiliacao())) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "A nova data de vencimento deve ser posterior à atual"
                ));
            }

            socio.setFimFiliacao(novaDataFim);
            socio.setDataUltimaRenovacao(LocalDate.now());

            socioRepository.save(socio);

            // Registrar no log
            logService.registrar(usuario,
                "Renovou filiação de sócio",
                socio.getNome() + " - Nova data: " + novaDataFim.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")),
                "SOCIO",
                id);

            return ResponseEntity.ok(Map.of("success", true, "message", "Filiação renovada com sucesso"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Erro ao renovar filiação: " + e.getMessage()
            ));
        }
    }

    // Deletar sócio (apenas ADMIN e MASTER)
    @DeleteMapping("/socios/{id}")
    public ResponseEntity<?> deletar(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        if (usuario.getTipo() != TipoUsuario.MASTER && usuario.getTipo() != TipoUsuario.ADMIN) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        Socio socio = socioRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Sócio não encontrado"));

        // Registrar no log antes de deletar
        logService.registrar(usuario,
            "Deletou sócio",
            socio.getNome() + " - CPF: " + socio.getCpf() + " - Turma: " + socio.getTurma(),
            "SOCIO",
            id);

        socioRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("success", true));
    }

    // Buscar sócios atrasados
    @GetMapping("/socios/atrasados")
    public ResponseEntity<?> buscarAtrasados(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        // Apenas ADMIN e MASTER podem ver essa informação
        if (usuario.getTipo() != TipoUsuario.MASTER && usuario.getTipo() != TipoUsuario.ADMIN) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        List<Socio> atrasados = socioRepository.findByFimFiliacaoBefore(LocalDate.now());
        return ResponseEntity.ok(atrasados);
    }

    // Buscar sócios próximos ao vencimento (30 dias)
    @GetMapping("/socios/proximos-vencimento")
    public ResponseEntity<?> buscarProximosVencimento(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        // Apenas ADMIN e MASTER podem ver essa informação
        if (usuario.getTipo() != TipoUsuario.MASTER && usuario.getTipo() != TipoUsuario.ADMIN) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        LocalDate hoje = LocalDate.now();
        LocalDate daqui30Dias = hoje.plusDays(30);

        List<Socio> proximos = socioRepository.findByFimFiliacaoBetween(hoje, daqui30Dias);
        return ResponseEntity.ok(proximos);
    }
}

