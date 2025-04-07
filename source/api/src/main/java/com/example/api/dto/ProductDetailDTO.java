package com.example.api.dto;
import lombok.Data;

import java.util.List;

@Data
public class ProductDetailDTO {
    private int id;
    private String name;

    private String brand;
    private String category;

    private String description;
    private List<ImageDTO> images;
    private List<VariantDTO> variants;

}
