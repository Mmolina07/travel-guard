package com.travelguard.trips.controller;

import com.travelguard.trips.domain.Viaje;
import com.travelguard.trips.service.ViajeService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/viajes")
public class ViajeController {

    private final ViajeService viajeService;

    public ViajeController(ViajeService viajeService) {
        this.viajeService = viajeService;
    }

    @PostMapping
    public ResponseEntity<Viaje> crearViaje(@RequestBody Viaje viaje) {
        Viaje nuevoViaje = viajeService.crearViaje(viaje);
        return ResponseEntity.status(HttpStatus.CREATED).body(nuevoViaje);
    }

    @GetMapping
    public ResponseEntity<List<Viaje>> obtenerViajes(@RequestParam Long usuarioId) {
        List<Viaje> viajes = viajeService.obtenerViajesPorUsuario(usuarioId);
        return ResponseEntity.ok(viajes);
    }

    @PatchMapping("/{id}/archivar")
    public ResponseEntity<Viaje> archivarViaje(@PathVariable Long id) {
        Viaje viajeArchivado = viajeService.archivarViaje(id);
        return ResponseEntity.ok(viajeArchivado);
    }
}