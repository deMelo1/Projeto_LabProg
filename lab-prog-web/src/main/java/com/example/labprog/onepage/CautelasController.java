package com.example.labprog.onepage;

import com.example.labprog.onepage.entity.Cautelas;
import com.example.labprog.onepage.entity.ItemCautela;
import com.example.labprog.onepage.entity.StatusCautela;
import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.CautelasRepository;
import com.example.labprog.onepage.repository.ItemCautelaRepository;
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
public class CautelasController {

    private final CautelasRepository cautelasRepository;
    private final ItemCautelaRepository itemCautelaRepository;
    private final LogService logService;

    public CautelasController(CautelasRepository cautelasRepository, ItemCautelaRepository itemCautelaRepository, LogService logService) {
        this.cautelasRepository = cautelasRepository;
        this.itemCautelaRepository = itemCautelaRepository;
        this.logService = logService;
    }

    @PostMapping("/form-cautela")
    public ResponseEntity<?> salvar(@RequestBody Map<String, Object> payload, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        try {
            Long itemId = Long.valueOf(payload.get("itemId").toString());
            Integer quantidade = Integer.valueOf(payload.get("quantidade").toString());
            String dataCautela = payload.get("data").toString();
            String paraQuem = payload.get("paraQuem").toString();
            String obs = payload.get("obs") != null ? payload.get("obs").toString() : "";

            ItemCautela item = itemCautelaRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item não encontrado"));

            // Verificar quantas unidades já estão cauteladas (ativas)
            List<Cautelas> cautelasAtivasItem = cautelasRepository.findByItemAndStatus(item, StatusCautela.ATIVA);
            long quantidadeCautelada = cautelasAtivasItem.stream()
                .mapToInt(Cautelas::getQuantidade)
                .sum();

            long disponiveis = item.getQuantidadeTotal() - quantidadeCautelada;

            if (quantidade > disponiveis) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Quantidade insuficiente! Disponível: " + disponiveis + " de " + item.getQuantidadeTotal()
                ));
            }

            Cautelas cautela = new Cautelas();
            cautela.setUsuario(usuario);
            cautela.setItem(item);
            cautela.setQuantidade(quantidade);
            cautela.setDataCautela(dataCautela);
            cautela.setParaQuem(paraQuem);
            cautela.setObs(obs);
            cautela.setStatus(StatusCautela.ATIVA);

            Cautelas salva = cautelasRepository.save(cautela);

            // Registrar no log
            logService.registrar(usuario,
                "Registrou cautela",
                item.getNome() + " - Qtd: " + quantidade + " - Para: " + paraQuem,
                "CAUTELA",
                salva.getId());

            return ResponseEntity.ok(Map.of("success", true, "cautela", salva));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping("/cautelas")
    public ResponseEntity<?> listar(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<Cautelas> cautelas = cautelasRepository.findAll();

        List<Map<String, Object>> resultado = cautelas.stream().map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", c.getId());
            map.put("membro", c.getMembro());
            map.put("itemNome", c.getItem() != null ? c.getItem().getNome() : "");
            map.put("quantidade", c.getQuantidade());
            map.put("dataCautela", c.getDataCautela());
            map.put("dataDevolucao", c.getDataDevolucao());
            map.put("status", c.getStatus().name());
            map.put("paraQuem", c.getParaQuem());
            map.put("obs", c.getObs());
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(resultado);
    }

    @GetMapping("/minhas-cautelas")
    public ResponseEntity<?> minhasCautelas(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<Cautelas> cautelas = cautelasRepository.findByUsuarioAndStatus(usuario, StatusCautela.ATIVA);

        List<Map<String, Object>> resultado = cautelas.stream().map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", c.getId());
            map.put("itemNome", c.getItem() != null ? c.getItem().getNome() : "");
            map.put("quantidade", c.getQuantidade());
            map.put("dataCautela", c.getDataCautela());
            map.put("paraQuem", c.getParaQuem());
            map.put("obs", c.getObs());
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(resultado);
    }

    @GetMapping("/cautelas-ativas")
    public ResponseEntity<?> cautelasAtivas(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<Cautelas> cautelas = cautelasRepository.findByStatus(StatusCautela.ATIVA);

        List<Map<String, Object>> resultado = cautelas.stream().map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", c.getId());
            map.put("membro", c.getMembro());
            map.put("itemNome", c.getItem() != null ? c.getItem().getNome() : "");
            map.put("quantidade", c.getQuantidade());
            map.put("dataCautela", c.getDataCautela());
            map.put("paraQuem", c.getParaQuem());
            map.put("obs", c.getObs());
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(resultado);
    }

    @PostMapping("/devolver-cautela/{id}")
    public ResponseEntity<?> devolver(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        Cautelas cautela = cautelasRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Cautela não encontrada"));

        // Apenas o dono da cautela ou ADMIN/MASTER pode marcar como devolvida
        if (!cautela.getUsuario().getId().equals(usuario.getId()) &&
            usuario.getTipo() != TipoUsuario.ADMIN &&
            usuario.getTipo() != TipoUsuario.MASTER) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        cautela.setStatus(StatusCautela.DEVOLVIDA);
        cautela.setDataDevolucao(LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE));
        cautelasRepository.save(cautela);

        // Registrar no log
        logService.registrar(usuario,
            "Devolveu cautela",
            cautela.getItem().getNome() + " - Qtd: " + cautela.getQuantidade() + " - De: " + cautela.getParaQuem(),
            "CAUTELA",
            id);

        return ResponseEntity.ok(Map.of("success", true, "message", "Cautela marcada como devolvida"));
    }

    @DeleteMapping("/cautelas/{id}")
    public ResponseEntity<?> deletar(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        if (usuario.getTipo() != TipoUsuario.MASTER && usuario.getTipo() != TipoUsuario.ADMIN) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        Cautelas cautela = cautelasRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Cautela não encontrada"));

        if (cautela.getStatus() == StatusCautela.ATIVA) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Não é possível excluir uma cautela ainda ATIVA (não devolvida). " +
                           "O item \"" + cautela.getItem().getNome() + "\" está com " + cautela.getParaQuem() + ". " +
                           "Para excluir este registro, primeiro marque a cautela como devolvida. " +
                           "Isso garante a integridade do histórico e do controle de itens emprestados."
            ));
        }

        // Registrar no log antes de deletar
        logService.registrar(usuario,
            "Deletou cautela",
            cautela.getItem().getNome() + " - Qtd: " + cautela.getQuantidade() + " - Para: " + cautela.getParaQuem() + " - Status: " + cautela.getStatus(),
            "CAUTELA",
            id);

        cautelasRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/cautelas-ativas-por-item/{itemId}")
    public ResponseEntity<?> quantidadeCauteladaPorItem(@PathVariable Long itemId, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        ItemCautela item = itemCautelaRepository.findById(itemId)
            .orElseThrow(() -> new RuntimeException("Item não encontrado"));

        List<Cautelas> cautelasAtivas = cautelasRepository.findByItemAndStatus(item, StatusCautela.ATIVA);
        int quantidadeCautelada = cautelasAtivas.stream()
            .mapToInt(Cautelas::getQuantidade)
            .sum();

        return ResponseEntity.ok(quantidadeCautelada);
    }
}
