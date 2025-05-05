package com.example.api.luan.controller;

import com.example.api.luan.service.BrandAdminService;
import com.example.api.model.Brand;
import com.example.api.model.Order;
import com.example.api.service.OrderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/orders")
public class OrderAdminController {

    @Autowired
    private OrderService orderService;

    @GetMapping("/customer/{customerId}")
    public List<Order> getOrdersByCustomer(@PathVariable Integer customerId) {
        return orderService.getOrdersByCustomerId(customerId);
    }
}
