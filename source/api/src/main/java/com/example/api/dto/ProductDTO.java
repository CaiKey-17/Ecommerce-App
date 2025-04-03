package com.example.api.dto;
import lombok.Data;

@Data
public class ProductDTO {
    private int id;

    private String image;
    private String discountLabel;
    private String name;
    private String description;
    private double price;
    private double oldPrice;
    private int discountPercent;
    private int idVariant;
    private int idColor;

}
