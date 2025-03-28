package com.example.api.dto;

import lombok.Data;

import java.util.List;

@Data
public class VariantDTO {
    private int id;
    private String name;
    private int discountPercent;
    private double oldPrice;
    private double price;
    private List<ColorDTO> colors;

}
