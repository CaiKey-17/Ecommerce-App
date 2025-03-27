package com.example.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "customer")
@Data
public class Customer {
    @Id
    private Integer id;
    private Integer points = 0;

    public Customer() {
    }

    public Customer(Integer id, Integer points) {
        this.id = id;
        this.points = points;
    }
}