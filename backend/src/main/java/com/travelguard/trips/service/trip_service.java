package com.travelguard.trips.service;

import com.travelguard.trips.domain.Viaje;
import com.travelguard.trips.repository.ViajeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ViajeService {

    private final ViajeRepository viajeRepository;

    public ViajeService(ViajeRepository viajeRepository) {
        this.viajeRepository = viajeRepository;
    }

    @Transactional
    public Viaje crearViaje(Viaje nuevoViaje) {
        nuevoViaje.setArchivado(false); // Garantiza que nazca activo
        return viajeRepository.save(nuevoViaje);
    }

    @Transactional(readOnly = true)
    public List<Viaje> obtenerViajesPorUsuario(Long usuarioId) {
        return viajeRepository.findByUsuarioIdAndArchivadoFalse(usuarioId);
    }

    @Transactional
    public Viaje archivarViaje(Long id) {
        Viaje viaje = viajeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Viaje no encontrado con el id: " + id));

        viaje.setArchivado(true);
        return viajeRepository.save(viaje);
    }
}