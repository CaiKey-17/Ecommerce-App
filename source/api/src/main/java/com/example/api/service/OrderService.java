package com.example.api.service;

import com.example.api.dto.OrderSummaryDTO;
import com.example.api.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    public Integer getOrderIdByCustomer(Integer customerId) {
        return orderRepository.findOrderIdByCustomerIdAndProcess(customerId).orElse(null);
    }

    public List<OrderSummaryDTO> findPendingOrdersByCustomerId(Integer customerId) {
        return orderRepository.findStatusOrdersByCustomerId(customerId,"dangdat","Chờ xác nhận");
    }

    public List<OrderSummaryDTO> findDeliveringOrdersByCustomerId(Integer customerId) {
        return orderRepository.findStatusOrdersByCustomerId(customerId,"danggiao","Đã xác nhận");
    }



}
