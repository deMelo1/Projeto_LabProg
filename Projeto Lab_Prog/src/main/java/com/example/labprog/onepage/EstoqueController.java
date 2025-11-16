package com.example.labprog.onepage;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.labprog.onepage.entity.Estoque;
import com.example.labprog.onepage.repository.EstoqueRepository;


@RestController
@CrossOrigin(origins = "*")
public class EstoqueController {

    private final EstoqueRepository submissoesRepository;

    public EstoqueController(EstoqueRepository submissoesRepository) {
        this.submissoesRepository = submissoesRepository;
    }

    @PostMapping("/form-estoque")
    public ResponseEntity<Estoque> salvar(@RequestBody Estoque submissoes) {
        // só pra conferir no console do back-end
        System.out.println("Recebido do front: " + submissoes.getMembro() + " - " + submissoes.getArtigo());

        Estoque salvo = submissoesRepository.save(submissoes);
        return ResponseEntity.ok(salvo); // o fetch faz resp.json() em cima disso
    }

    // opcional: pra listar tudo depois e testar
    @GetMapping("/estoque")
    public ResponseEntity<?> listar() {
        return ResponseEntity.ok(submissoesRepository.findAll());
    }
}
