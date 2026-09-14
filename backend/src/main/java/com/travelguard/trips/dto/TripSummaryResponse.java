package com.travelguard.trips.dto;

import com.travelguard.trips.domain.Trip;
import java.time.LocalDate;

public class TripSummaryResponse {
    private Long id;
    private String nombre;
    private String origen;
    private String destino;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
    private Integer cantidadPersonas;
    private Double presupuestoTotal;
    
    // Desglose
    private Double hospedaje;
    private Double transporte;
    private Double comidas;
    private Double actividades;
    private Double emergencias;

    public TripSummaryResponse(Trip trip) {
        this.id = trip.getId();
        this.nombre = trip.getNombre() != null ? trip.getNombre() : (trip.getOrigen() + " a " + trip.getDestino());
        this.origen = trip.getOrigen();
        this.destino = trip.getDestino();
        this.fechaInicio = trip.getFechaInicio();
        this.fechaFin = trip.getFechaFin();
        this.cantidadPersonas = trip.getCantidadPersonas() != null ? trip.getCantidadPersonas() : 1;
        this.presupuestoTotal = trip.getPresupuestoTotal();
        this.hospedaje = trip.getPresupuestoHospedaje();
        this.transporte = trip.getPresupuestoTransporte();
        this.comidas = trip.getPresupuestoComidas();
        this.actividades = trip.getPresupuestoActividades();
        this.emergencias = trip.getPresupuestoEmergencias();
    }

    // Getters
    public Long getId() { return id; }
    public String getNombre() { return nombre; }
    public String getOrigen() { return origen; }
    public String getDestino() { return destino; }
    public LocalDate getFechaInicio() { return fechaInicio; }
    public LocalDate getFechaFin() { return fechaFin; }
    public Integer getCantidadPersonas() { return cantidadPersonas; }
    public Double getPresupuestoTotal() { return presupuestoTotal; }
    public Double getHospedaje() { return hospedaje; }
    public Double getTransporte() { return transporte; }
    public Double getComidas() { return comidas; }
    public Double getActividades() { return actividades; }
    public Double getEmergencias() { return emergencias; }
}