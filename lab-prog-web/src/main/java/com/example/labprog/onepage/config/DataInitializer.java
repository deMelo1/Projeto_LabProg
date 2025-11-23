package com.example.labprog.onepage.config;

import com.example.labprog.onepage.entity.TipoUsuario;
import com.example.labprog.onepage.entity.Usuario;
import com.example.labprog.onepage.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    public void run(String... args) {
        // Criar usuário master se não existir
        if (!usuarioRepository.existsByLogin("grifo")) {
            Usuario master = new Usuario("grifo", "grifo1792", "Grifo", TipoUsuario.MASTER);
            master.setAprovado(true); // Master já vem aprovado automaticamente
            usuarioRepository.save(master);
            System.out.println("Usuário master criado: grifo / grifo1792");
        }
    }
}

