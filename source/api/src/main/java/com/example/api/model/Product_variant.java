package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Formula;

@Entity
@Table(name = "product_variant")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product_variant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column( length = 255)
    private String nameVariant;

    private Double importPrice;

    @Column(name = "quantity", nullable = true)
    private Integer quantity=0;

    private Double originalPrice;

    private Integer discountPercent;
    @Column(name = "price", nullable = true)
    private Double price;



    @Column(name = "fk_variant_product", nullable = true)
    private Integer fkVariantProduct;



}
