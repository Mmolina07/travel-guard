package com.travelguard.trips.service;

import com.travelguard.trips.domain.Viaje;
import com.travelguard.trips.repository.ViajeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ViajeService {

    private final ViajeRepository viajeRepository;

    public ViajeService(ViajeRepository viajeRepository) {
        this.viajeRepository = viajeRepository;
    }

    @Transactional
    public Viaje archivarViaje(Long id) {
        Viaje viaje = viajeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Viaje no encontrado con el id: " + id));

        viaje.setArchivado(true);
        return viajeRepository.save(viaje);
    }
}