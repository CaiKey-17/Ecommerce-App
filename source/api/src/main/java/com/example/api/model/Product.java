package com.example.api.model;
import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Entity
@Table(name = "product")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(length = 255, nullable = true)
    private String name;

    @Column(name = "shortDescription", length = 255, nullable = true)
    private String shortDescription;

    @Column(name = "created_at", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
    private Timestamp createdAt;

    @Column(length = 255, nullable = true)
    private String mainImage;

    @Column(nullable = false, columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean hasColor = true;

    @Column(name = "fk_brand", length = 100, nullable = true)
    private String fkBrand;

    @Column(name = "fk_category", length = 100, nullable = true)
    private String fkCategory;
}