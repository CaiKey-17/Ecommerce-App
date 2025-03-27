package com.example.api.service;

import com.example.api.dto.ProductDTO;
import com.example.api.model.Product;
import com.example.api.model.Product_color;
import com.example.api.model.Product_image;
import com.example.api.model.Product_variant;
import com.example.api.repository.ProductColorRepository;
import com.example.api.repository.ProductImageRepository;
import com.example.api.repository.ProductRepository;
import com.example.api.repository.ProductVariantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductVariantRepository productVariantRepository;

    @Autowired
    private ProductImageRepository productImageRepository;

    @Autowired
    private ProductColorRepository productColorRepository;

    public List<ProductDTO> getAllProducts() {
        List<Product> products = productRepository.findAll();
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                dto.setImage(product.getMainImage());
                dto.setDiscountLabel("TIẾT KIỆM\n" + (variant.getOriginalPrice() - variant.getPrice()) + " đ");
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice() + " đ");
                dto.setOldPrice(variant.getOriginalPrice() + " đ");
                dto.setDiscountPercent("-" + variant.getDiscountPercent() + "%");
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsByCategory(String fk_category) {
        List<Product> products = productRepository.findByFkCategory(fk_category);
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());
                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                dto.setImage(product.getMainImage());
                dto.setDiscountLabel("TIẾT KIỆM\n" + (variant.getOriginalPrice() - variant.getPrice()) + " đ");
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice() + " đ");
                dto.setOldPrice(variant.getOriginalPrice() + " đ");
                dto.setDiscountPercent("-" + variant.getDiscountPercent() + "%");
                dto.setIdVariant(variant.getId());
                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

}
