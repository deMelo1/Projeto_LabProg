package com.example.labprog.onepage;

import com.example.labprog.onepage.entity.Estoque;
import com.example.labprog.onepage.entity.ItemEstoque;
import com.example.labprog.onepage.entity.TipoMovimentacao;
import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.EstoqueRepository;
import com.example.labprog.onepage.repository.ItemEstoqueRepository;
import com.example.labprog.onepage.service.LogService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class ItemEstoqueController {

    private final ItemEstoqueRepository itemEstoqueRepository;
    private final EstoqueRepository estoqueRepository;
    private final LogService logService;

    public ItemEstoqueController(ItemEstoqueRepository itemEstoqueRepository, EstoqueRepository estoqueRepository, LogService logService) {
        this.itemEstoqueRepository = itemEstoqueRepository;
        this.estoqueRepository = estoqueRepository;
        this.logService = logService;
    }

    @PostMapping("/itens-estoque")
    public ResponseEntity<?> cadastrarItem(@RequestBody ItemEstoque item, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        // Verificar se já existe item com esse nome
        if (itemEstoqueRepository.existsByNome(item.getNome())) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Já existe um item com este nome"));
        }

        // Garantir que quantidade inicial seja pelo menos 0
        if (item.getQuantidadeAtual() == null) {
            item.setQuantidadeAtual(0);
        }

        // Salvar o item
        ItemEstoque salvo = itemEstoqueRepository.save(item);

        // Se a quantidade inicial for maior que 0, criar uma movimentação de ENTRADA
        if (salvo.getQuantidadeAtual() > 0) {
            Estoque movimentacao = new Estoque();
            movimentacao.setUsuario(usuario);
            movimentacao.setItem(salvo);
            movimentacao.setTipo(TipoMovimentacao.ENTRADA);
            movimentacao.setQuantidade(salvo.getQuantidadeAtual());
            movimentacao.setData(LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE));
            movimentacao.setObs("Cadastro inicial do item");
            estoqueRepository.save(movimentacao);
            
            // Registrar no log
            logService.registrar(usuario,
                "Cadastrou item de estoque",
                salvo.getNome() + " - Quantidade inicial: " + salvo.getQuantidadeAtual(),
                "ITEM",
                salvo.getId());
        } else {
            // Registrar no log sem quantidade
            logService.registrar(usuario,
                "Cadastrou item de estoque",
                salvo.getNome() + " - Sem quantidade inicial",
                "ITEM",
                salvo.getId());
        }

        return ResponseEntity.ok(Map.of("success", true, "item", salvo));
    }

    @GetMapping("/itens-estoque")
    public ResponseEntity<?> listarItens(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<ItemEstoque> itens = itemEstoqueRepository.findAll();
        return ResponseEntity.ok(itens);
    }

    @GetMapping("/itens-estoque/{id}")
    public ResponseEntity<?> buscarItem(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        return itemEstoqueRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/itens-estoque/{id}")
    public ResponseEntity<?> atualizarItem(@PathVariable Long id, @RequestBody ItemEstoque itemAtualizado, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        return itemEstoqueRepository.findById(id)
            .map(item -> {
                item.setNome(itemAtualizado.getNome());
                item.setCategoria(itemAtualizado.getCategoria());
                item.setDescricao(itemAtualizado.getDescricao());
                // Não atualizar quantidade aqui, apenas através de movimentações
                ItemEstoque salvo = itemEstoqueRepository.save(item);
                return ResponseEntity.ok(Map.of("success", true, "item", salvo));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/itens-estoque/{id}")
    public ResponseEntity<?> deletarItem(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        if (usuario.getTipo() != TipoUsuario.MASTER && usuario.getTipo() != TipoUsuario.ADMIN) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        ItemEstoque item = itemEstoqueRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Item não encontrado"));

        // Verificar se há movimentações relacionadas a este item
        long quantidadeMovimentacoes = estoqueRepository.findAll().stream()
            .filter(mov -> mov.getItem() != null && mov.getItem().getId().equals(id))
            .count();

        if (quantidadeMovimentacoes > 0) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Não é possível excluir o item \"" + item.getNome() + "\" pois existem " + 
                           quantidadeMovimentacoes + " movimentação(ões) no histórico relacionadas a ele. " +
                           "Isso garante a integridade do histórico de estoque."
            ));
        }

        // Registrar no log antes de deletar
        logService.registrar(usuario,
            "Deletou item de estoque",
            item.getNome() + " - Quantidade: " + item.getQuantidadeAtual(),
            "ITEM",
            id);

        itemEstoqueRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("success", true));
    }
}

