package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Entity
@Table(name = "bills")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Bill {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "created_at", nullable = true)
    private Timestamp createdAt;

    @Column(name = "created_receive", nullable = true)
    private Timestamp createdReceive;

    @Column(name = "status_order", length = 255, nullable = true)
    private String statusOrder;

    @Column(name = "method_payment", length = 50, nullable = true)
    private String methodPayment;

    @Column(nullable = true)
    private Integer fk_orderId;
}
