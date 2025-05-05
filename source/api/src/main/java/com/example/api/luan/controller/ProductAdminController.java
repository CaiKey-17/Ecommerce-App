package com.example.api.luan.controller;


import com.example.api.luan.dto.UserInfoDTO;
import com.example.api.luan.service.ProductAdminService;
import com.example.api.model.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/products")
public class ProductAdminController {
    @Autowired
    private ProductAdminService productService;

    @GetMapping
    public ResponseEntity<List<?>> getAllProducts() {
        List<Product> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }

}
