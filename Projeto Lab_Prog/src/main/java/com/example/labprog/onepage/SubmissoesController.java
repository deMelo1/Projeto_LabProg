package com.example.labprog.onepage;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.labprog.onepage.entity.Submissoes;
import com.example.labprog.onepage.repository.SubmissoesRepository;


@RestController
@CrossOrigin(origins = "*")
public class SubmissoesController {

    private final SubmissoesRepository submissoesRepository;

    public SubmissoesController(SubmissoesRepository submissoesRepository) {
        this.submissoesRepository = submissoesRepository;
    }

    @PostMapping("/form-cautela")
    public ResponseEntity<Submissoes> salvar(@RequestBody Submissoes submissoes) {
        // só pra conferir no console do back-end
        System.out.println("Recebido do front: " + submissoes.getMembro() + " - " + submissoes.getArtigo());

        Submissoes salvo = submissoesRepository.save(submissoes);
        return ResponseEntity.ok(salvo); // o fetch faz resp.json() em cima disso
    }

    // opcional: pra listar tudo depois e testar
    @GetMapping("/submissoes")
    public ResponseEntity<?> listar() {
        return ResponseEntity.ok(submissoesRepository.findAll());
    }
}
