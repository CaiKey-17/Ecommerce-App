package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "order_details")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Order_detail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "price", nullable = true)
    private Double price;

    @Column(name = "quantity", nullable = true)
    private Integer quantity;

    @Column(name = "total", nullable = true)
    private Double total;

    @Column( nullable = true)
    private Integer fk_orderId;

    @Column( nullable = true)
    private Integer fk_productId;

    @Column( nullable = true)
    private Integer fk_colorId;

}
