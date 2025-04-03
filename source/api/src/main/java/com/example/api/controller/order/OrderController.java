package com.example.api.controller.order;

import com.example.api.model.Brand;
import com.example.api.service.BrandService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private BrandService brandService;

    public OrderController(BrandService brandService) {
        this.brandService = brandService;
    }

    @GetMapping("/list")
    public ResponseEntity<List<Brand>> getAllCategory() {
        List<Brand> brands = brandService.getAll();
        return ResponseEntity.ok(brands);
    }
}
