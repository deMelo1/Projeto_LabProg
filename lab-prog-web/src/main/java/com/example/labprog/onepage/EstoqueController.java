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

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class EstoqueController {

    private final EstoqueRepository estoqueRepository;
    private final ItemEstoqueRepository itemEstoqueRepository;
    private final LogService logService;

    public EstoqueController(EstoqueRepository estoqueRepository, ItemEstoqueRepository itemEstoqueRepository, LogService logService) {
        this.estoqueRepository = estoqueRepository;
        this.itemEstoqueRepository = itemEstoqueRepository;
        this.logService = logService;
    }

    @PostMapping("/form-estoque")
    public ResponseEntity<?> salvar(@RequestBody Map<String, Object> payload, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        try {
            Long itemId = Long.valueOf(payload.get("itemId").toString());
            String tipoStr = payload.get("tipo").toString();
            Integer quantidade = Integer.valueOf(payload.get("quantidade").toString());
            String data = payload.get("data").toString();
            String obs = payload.get("obs") != null ? payload.get("obs").toString() : "";

            ItemEstoque item = itemEstoqueRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item não encontrado"));

            TipoMovimentacao tipo = TipoMovimentacao.valueOf(tipoStr.toUpperCase());

            if (tipo == TipoMovimentacao.SAIDA) {
                if (item.getQuantidadeAtual() < quantidade) {
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false, 
                        "message", "Estoque insuficiente! Disponível: " + item.getQuantidadeAtual()
                    ));
                }
                item.setQuantidadeAtual(item.getQuantidadeAtual() - quantidade);
            } else {
                item.setQuantidadeAtual(item.getQuantidadeAtual() + quantidade);
            }

            itemEstoqueRepository.save(item);
            Estoque estoque = new Estoque();
            estoque.setUsuario(usuario);
            estoque.setItem(item);
            estoque.setTipo(tipo);
            estoque.setQuantidade(quantidade);
            estoque.setData(data);
            estoque.setObs(obs);

            Estoque salvo = estoqueRepository.save(estoque);
            
            String tipoTexto = tipo == TipoMovimentacao.ENTRADA ? "ENTRADA" : "SAÍDA";
            logService.registrar(usuario, 
                "Registrou " + tipoTexto + " de estoque", 
                item.getNome() + " - Qtd: " + quantidade + " - Nova quantidade: " + item.getQuantidadeAtual(),
                "ESTOQUE", 
                salvo.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("movimentacao", salvo);
            response.put("quantidadeAtual", item.getQuantidadeAtual());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping("/estoque")
    public ResponseEntity<?> listar(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        List<Estoque> movimentacoes = estoqueRepository.findAll();
        
        List<Map<String, Object>> resultado = movimentacoes.stream().map(mov -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", mov.getId());
            map.put("membro", mov.getMembro());
            map.put("itemNome", mov.getItem() != null ? mov.getItem().getNome() : "");
            map.put("tipo", mov.getTipo().name());
            map.put("quantidade", mov.getQuantidade());
            map.put("data", mov.getData());
            map.put("obs", mov.getObs());
            return map;
        }).collect(Collectors.toList());
        
        return ResponseEntity.ok(resultado);
    }

    @DeleteMapping("/estoque/{id}")
    public ResponseEntity<?> deletar(@PathVariable Long id, HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Não autenticado"));
        }

        if (usuario.getTipo() != TipoUsuario.MASTER && usuario.getTipo() != TipoUsuario.ADMIN) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Acesso negado"));
        }

        Estoque movimentacao = estoqueRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Registro não encontrado"));

        if (movimentacao.getObs() != null && movimentacao.getObs().equals("Cadastro inicial do item")) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Não é possível excluir a movimentação de cadastro inicial do item \"" + 
                           movimentacao.getItem().getNome() + "\". " +
                           "Esta movimentação representa a criação do item no sistema e garante a integridade do histórico. " +
                           "Você pode excluir outras movimentações de entrada/saída, mas não o registro de criação."
            ));
        }

        ItemEstoque item = movimentacao.getItem();
        
        if (movimentacao.getTipo() == TipoMovimentacao.ENTRADA) {
            item.setQuantidadeAtual(item.getQuantidadeAtual() - movimentacao.getQuantidade());
        } else {
            item.setQuantidadeAtual(item.getQuantidadeAtual() + movimentacao.getQuantidade());
        }

        itemEstoqueRepository.save(item);
        String tipoTexto = movimentacao.getTipo() == TipoMovimentacao.ENTRADA ? "ENTRADA" : "SAÍDA";
        logService.registrar(usuario,
            "Deletou movimentação de " + tipoTexto,
            item.getNome() + " - Qtd: " + movimentacao.getQuantidade() + " - Quantidade após reversão: " + item.getQuantidadeAtual(),
            "ESTOQUE",
            id);

        estoqueRepository.deleteById(id);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        
        if (item.getQuantidadeAtual() < 0) {
            response.put("warning", true);
            response.put("message", "Atenção! O estoque de '" + item.getNome() + "' ficou negativo: " + item.getQuantidadeAtual());
        }
        
        return ResponseEntity.ok(response);
    }
}
