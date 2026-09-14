package com.travelguard.trips.domain;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "viajes")
public class Trip {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String origin;
    private String destination;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer peopleCount;

    private Double lodgingBudget;
    private Double transportBudget;
    private Double foodBudget;
    private Double activitiesBudget;
    private Double emergencyBudget;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public Integer getPeopleCount() { return peopleCount; }
    public void setPeopleCount(Integer peopleCount) { this.peopleCount = peopleCount; }

    public Double getLodgingBudget() { return lodgingBudget; }
    public void setLodgingBudget(Double lodgingBudget) { this.lodgingBudget = lodgingBudget; }

    public Double getTransportBudget() { return transportBudget; }
    public void setTransportBudget(Double transportBudget) { this.transportBudget = transportBudget; }

    public Double getFoodBudget() { return foodBudget; }
    public void setFoodBudget(Double foodBudget) { this.foodBudget = foodBudget; }

    public Double getActivitiesBudget() { return activitiesBudget; }
    public void setActivitiesBudget(Double activitiesBudget) { this.activitiesBudget = activitiesBudget; }

    public Double getEmergencyBudget() { return emergencyBudget; }
    public void setEmergencyBudget(Double emergencyBudget) { this.emergencyBudget = emergencyBudget; }
}
