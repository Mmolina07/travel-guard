package com.travelguard.trips.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "viajes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Trip {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private String origen;
    private String destino;

    @Column(name = "usuario_id", nullable = false)
    private Long usuarioId;

    @Builder.Default
    @Column(nullable = false)
    private Boolean archivado = false;

    // Campos para HU-11 (Resumen de viaje)
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
    private Integer cantidadPersonas;

    // Desglose de presupuesto estimado
    @Builder.Default
    private Double presupuestoHospedaje = 0.0;

    @Builder.Default
    private Double presupuestoTransporte = 0.0;

    @Builder.Default
    private Double presupuestoComidas = 0.0;

    @Builder.Default
    private Double presupuestoActividades = 0.0;

    @Builder.Default
    private Double presupuestoEmergencias = 0.0;

    // Método para calcular el presupuesto total
    public Double getPresupuestoTotal() {
        return (presupuestoHospedaje != null ? presupuestoHospedaje : 0.0) +
               (presupuestoTransporte != null ? presupuestoTransporte : 0.0) +
               (presupuestoComidas != null ? presupuestoComidas : 0.0) +
               (presupuestoActividades != null ? presupuestoActividades : 0.0) +
               (presupuestoEmergencias != null ? presupuestoEmergencias : 0.0);
    }
}