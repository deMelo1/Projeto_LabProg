package com.example.labprog.onepage;

import com.example.labprog.onepage.entity.ItemCautela;
import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.CautelasRepository;
import com.example.labprog.onepage.repository.ItemCautelaRepository;
import com.example.labprog.onepage.service.LogService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class ItemCautelaController {

    private final ItemCautelaRepository itemCautelaRepository;
    private final CautelasRepository cautelasRepository;
    private final LogService logService;

    public ItemCautelaController(ItemCautelaRepository itemCautelaRepository, CautelasRepository cautelasRepository, LogService logService) {
        this.itemCautelaRepository = itemCautelaRepository;
        this.cautelasRepository = cautelasRepository;
        this.logService = logService;
    }

    @PostMapping("/itens-cautela")
    public ResponseEntity<?> cadastrarItem(@RequestBody ItemCautela item, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        if (itemCautelaRepository.existsByNome(item.getNome())) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Já existe um item com este nome"));
        }

        if (item.getQuantidadeTotal() == null || item.getQuantidadeTotal() < 1) {
            item.setQuantidadeTotal(1);
        }

        ItemCautela salvo = itemCautelaRepository.save(item);

        // Registrar no log
        logService.registrar(usuario,
            "Cadastrou item cautelável",
            salvo.getNome() + " - Quantidade total: " + salvo.getQuantidadeTotal(),
            "ITEM",
            salvo.getId());

        return ResponseEntity.ok(Map.of("success", true, "item", salvo));
    }

    @GetMapping("/itens-cautela")
    public ResponseEntity<?> listarItens(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<ItemCautela> itens = itemCautelaRepository.findAll();
        return ResponseEntity.ok(itens);
    }

    @GetMapping("/itens-cautela/{id}")
    public ResponseEntity<?> buscarItem(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        return itemCautelaRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/itens-cautela/{id}")
    public ResponseEntity<?> atualizarItem(@PathVariable Long id, @RequestBody ItemCautela itemAtualizado, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        return itemCautelaRepository.findById(id)
            .map(item -> {
                item.setNome(itemAtualizado.getNome());
                item.setQuantidadeTotal(itemAtualizado.getQuantidadeTotal());
                item.setCategoria(itemAtualizado.getCategoria());
                item.setDescricao(itemAtualizado.getDescricao());
                ItemCautela salvo = itemCautelaRepository.save(item);
                return ResponseEntity.ok(Map.of("success", true, "item", salvo));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/itens-cautela/{id}")
    public ResponseEntity<?> deletarItem(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        if (usuario.getTipo() != TipoUsuario.MASTER && usuario.getTipo() != TipoUsuario.ADMIN) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        ItemCautela item = itemCautelaRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Item não encontrado"));

        // Verificar se há cautelas relacionadas a este item
        long quantidadeCautelas = cautelasRepository.findAll().stream()
            .filter(c -> c.getItem() != null && c.getItem().getId().equals(id))
            .count();

        if (quantidadeCautelas > 0) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Não é possível excluir o item \"" + item.getNome() + "\" pois existem " + 
                           quantidadeCautelas + " cautela(s) no histórico relacionadas a ele. " +
                           "Isso garante a integridade do histórico de cautelas."
            ));
        }

        // Registrar no log antes de deletar
        logService.registrar(usuario,
            "Deletou item cautelável",
            item.getNome() + " - Quantidade total: " + item.getQuantidadeTotal(),
            "ITEM",
            id);

        itemCautelaRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("success", true));
    }
}

