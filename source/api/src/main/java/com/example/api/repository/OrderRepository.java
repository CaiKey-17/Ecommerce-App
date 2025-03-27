package com.example.api.repository;

import com.example.api.model.Address;
import com.example.api.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    @Query("SELECT o.id FROM Order o WHERE o.id_fk_customer = :customerId AND o.process = 'giohang'")
    Optional<Integer> findOrderIdByCustomerIdAndProcess(@Param("customerId") Integer customerId);
}
