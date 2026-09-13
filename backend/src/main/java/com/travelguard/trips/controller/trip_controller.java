package com.travelguard.trips.controller;

import com.travelguard.trips.domain.Viaje;
import com.travelguard.trips.service.ViajeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/viajes")
public class ViajeController {

    private final ViajeService viajeService;

    public ViajeController(ViajeService viajeService) {
        this.viajeService = viajeService;
    }

    @PatchMapping("/{id}/archivar")
    public ResponseEntity<Viaje> archivarViaje(@PathVariable Long id) {
        Viaje viajeArchivado = viajeService.archivarViaje(id);
        return ResponseEntity.ok(viajeArchivado);
    }
}