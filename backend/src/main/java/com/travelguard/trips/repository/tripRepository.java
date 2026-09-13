package com.travelguard.trips.repository;

import com.travelguard.trips.domain.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {
    
    List<Trip> findByUsuarioIdAndArchivadoFalse(Long usuarioId);
}