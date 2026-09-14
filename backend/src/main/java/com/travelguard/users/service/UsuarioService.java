package com.travelguard.users.service;

import com.travelguard.users.dto.ClienteRegisterDTO;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class UsuarioService {

    // Lista en memoria para simular registros existentes en base de datos
    private final List<String> registeredEmails = new ArrayList<>(List.of(
        "test@correo.com",
        "usuario@travelguard.com"
    ));

    public void registrarUsuario(ClienteRegisterDTO dto) {
        String emailClean = dto.getEmail().trim().toLowerCase();

        // Validación de unicidad de correo
        if (registeredEmails.contains(emailClean)) {
            throw new IllegalArgumentException("El correo electrónico ya está registrado");
        }

        // Si pasa la validación, simula el guardado agregándolo a la lista
        registeredEmails.add(emailClean);
    }
}