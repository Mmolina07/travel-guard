package com.travelguard.trips.dto;

import com.travelguard.trips.domain.Trip;
import java.time.LocalDate;

public class TripSummaryResponse {

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
    private Double totalBudget;

    public TripSummaryResponse(Trip trip) {
        this.id = trip.getId();
        this.name = trip.getName();
        this.origin = trip.getOrigin();
        this.destination = trip.getDestination();
        this.startDate = trip.getStartDate();
        this.endDate = trip.getEndDate();
        this.peopleCount = trip.getPeopleCount();
        this.lodgingBudget = trip.getLodgingBudget() != null ? trip.getLodgingBudget() : 0.0;
        this.transportBudget = trip.getTransportBudget() != null ? trip.getTransportBudget() : 0.0;
        this.foodBudget = trip.getFoodBudget() != null ? trip.getFoodBudget() : 0.0;
        this.activitiesBudget = trip.getActivitiesBudget() != null ? trip.getActivitiesBudget() : 0.0;
        this.emergencyBudget = trip.getEmergencyBudget() != null ? trip.getEmergencyBudget() : 0.0;
        
        this.totalBudget = this.lodgingBudget + this.transportBudget + this.foodBudget + this.activitiesBudget + this.emergencyBudget;
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public String getOrigin() { return origin; }
    public String getDestination() { return destination; }
    public LocalDate getStartDate() { return startDate; }
    public LocalDate getEndDate() { return endDate; }
    public Integer getPeopleCount() { return peopleCount; }
    public Double getLodgingBudget() { return lodgingBudget; }
    public Double getTransportBudget() { return transportBudget; }
    public Double getFoodBudget() { return foodBudget; }
    public Double getActivitiesBudget() { return activitiesBudget; }
    public Double getEmergencyBudget() { return emergencyBudget; }
    public Double getTotalBudget() { return totalBudget; }
}
