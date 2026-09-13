package com.travelguard.trips.domain;

import jakarta.persistence.*;
import lombok.*;

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

    private String origen;
    private String destino;

    @Builder.Default
    @Column(nullable = false)
    private Boolean archivado = false; // Flag para soft delete
}