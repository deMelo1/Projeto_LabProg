package com.example.labprog.onepage;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.labprog.onepage.entity.Cautelas;
import com.example.labprog.onepage.repository.CautelasRepository;


@RestController
@CrossOrigin(origins = "*")
public class CautelasController {

    private final CautelasRepository submissoesRepository;

    public CautelasController(CautelasRepository submissoesRepository) {
        this.submissoesRepository = submissoesRepository;
    }

    @PostMapping("/form-cautela")
    public ResponseEntity<Cautelas> salvar(@RequestBody Cautelas cautelas) {
        // só pra conferir no console do back-end
        System.out.println("Recebido do front: " + cautelas.getMembro() + " - " + cautelas.getItem());

        Cautelas salvo = submissoesRepository.save(cautelas);
        return ResponseEntity.ok(salvo); // o fetch faz resp.json() em cima disso
    }

    // opcional: pra listar tudo depois e testar
    @GetMapping("/cautelas")
    public ResponseEntity<?> listar() {
        return ResponseEntity.ok(submissoesRepository.findAll());
    }
}
