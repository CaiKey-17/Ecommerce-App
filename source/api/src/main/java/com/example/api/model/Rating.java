package com.example.api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "rating")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Rating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Integer rating;
    private String name;


    private String content;
    private Integer sentiment;
    @Column(name = "id_fk_customer",  nullable = true)
    private Integer id_fk_customer;

    @Column(name = "id_fk_product",  nullable = true)
    private Integer id_fk_product;

}
