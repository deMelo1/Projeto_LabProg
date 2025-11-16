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


class formsCautela {
    public String membro;
    public String artigo;
    public int quantidade;
    public String data;
    public String receptor;
    public String obs;
};

@RestController
@CrossOrigin(origins = "*")
public class OnepageControllers {
    @PostMapping(value="/form-cautela")
    public Map<String, Object> forms_cautela(@RequestBody formsCautela form) {
        Map<String, Object> resp = new HashMap<>();
        resp.put("membro", form.membro);
        resp.put("artigo", form.artigo);
        resp.put("quantidade", form.quantidade);
        resp.put("data", form.data);
        resp.put("receptor", form.receptor);
        resp.put("obs", form.obs);
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
}
