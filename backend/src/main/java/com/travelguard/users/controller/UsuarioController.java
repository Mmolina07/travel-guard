package com.travelguard.users.controller;

import com.travelguard.users.dto.ClienteRegisterDTO;
import com.travelguard.users.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/register")
    public ResponseEntity<String> registrarCliente(@Valid @RequestBody ClienteRegisterDTO registerDTO) {
        usuarioService.registrarUsuario(registerDTO);
        return ResponseEntity.ok("Usuario registrado exitosamente");
    }
}