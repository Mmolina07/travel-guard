package com.travelguard.users.service;

import com.travelguard.users.dto.ClienteRegisterDTO;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class UsuarioService {

    private final List<String> registeredEmails = new ArrayList<>(List.of(
        "test@correo.com",
        "usuario@travelguard.com"
    ));

    public void registrarUsuario(ClienteRegisterDTO dto) {
        String emailClean = dto.getEmail().trim().toLowerCase();

        // Lanza una excepcion de conflicto si el correo ya existe
        if (registeredEmails.contains(emailClean)) {
            throw new IllegalStateException("El correo electrónico ya se encuentra registrado");
        }

        registeredEmails.add(emailClean);
    }
}
