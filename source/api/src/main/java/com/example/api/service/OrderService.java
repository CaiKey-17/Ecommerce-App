package com.example.api.service;

import com.example.api.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    public Integer getOrderIdByCustomer(Integer customerId) {
        return orderRepository.findOrderIdByCustomerIdAndProcess(customerId).orElse(null);
    }
}
