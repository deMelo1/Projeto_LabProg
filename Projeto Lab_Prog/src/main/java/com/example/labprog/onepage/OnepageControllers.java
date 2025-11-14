package com.example.labprog.onepage;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


class Aeste {
    public String nota;
    public boolean termos;
    public String email;
};

@RestController
@CrossOrigin(origins = "*")
public class OnepageControllers {
    @PostMapping(value="/forms")
    public Map<String, Object> forms(@RequestBody Aeste teste) {
        Map<String, Object> resp = new HashMap<>();
    resp.put("nota", teste.nota);
    resp.put("termos", teste.termos);
    resp.put("email", teste.email);
    return resp;
    }


    @PostMapping(value="/add-nota")
    public Map<String, Object> addNota(
        @RequestParam String nome,
        @RequestParam Integer idade,
        @RequestParam String nota,
        @RequestParam(defaultValue = "false") boolean favorito,
        @RequestParam(required = false) List<String> interesses) {
    Map<String, Object> resp = new HashMap<>();
    resp.put("nome", nome);
    resp.put("idade", idade);
    resp.put("nota", nota);
    resp.put("favorito", favorito);
    resp.put("interesses", interesses);
    return resp;
}

    @GetMapping("/soma")
	public String home(@RequestParam int a, @RequestParam int b) {
		return "Resultado: "+(a+b);
	}
    @GetMapping("/quadrado/{n}")
    public Map<String, Integer> quadrado(@PathVariable int n) {
        Map<String, Integer> response = new HashMap<>();
        response.put("numero", n);
        response.put("quadrado", n*n);
        return response;
    }
    @PostMapping("/usuarios")
    public Map<String, String> usuarios(@RequestBody Usuario usuario) {
        ArrayList<Usuario> users = new ArrayList<>();
        users.add(usuario);
        Map<String, String> response = new HashMap<>();
        response.put("status", "Ok");
        response.put("mensagem", "Usuário " + usuario.getNome() + " cadastrado com sucesso!");
        return response;
    }

    
}
