package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "quantity_total", nullable = true)
    private Integer quantityTotal;

    @Column(name = "price_total", nullable = true)
    private Double priceTotal;

    @Column(name = "coupon_total", nullable = true, columnDefinition = "DOUBLE DEFAULT 0")
    private Double couponTotal;

    @Column(name = "point_total", nullable = true, columnDefinition = "DOUBLE DEFAULT 0")
    private Double pointTotal;

    @Column(name = "ship", nullable = true)
    private Double ship;

    @Column(name = "tax", nullable = true)
    private Double tax;

    @Column(name = "created_at", nullable = true)
    private Timestamp createdAt;

    @Column(name = "address", length = 255)
    private String address;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "total", nullable = true, columnDefinition = "DOUBLE DEFAULT 0")
    private Double total;

    @Column(name = "process", length = 100)
    private String process;

    @Column(name = "id_fk_customer",  nullable = true)
    private Integer id_fk_customer;


    @Column(name = "id_fk_product_variant", nullable = true)
    private Integer id_fk_product_variant;

    @Column( nullable = true)
    private Integer fk_couponId;
}
