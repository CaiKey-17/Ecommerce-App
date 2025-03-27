package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "product_color")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product_color {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "color_name", length = 50, nullable = false)
    private String colorName;

    @Column(name = "color_price", nullable = false)
    private Double colorPrice;

    private Integer quantity=0;
    private String image;

    private Integer fkVariantProduct;
}
