package com.example.api.repository;

import com.example.api.dto.OrderSummaryDTO;
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


    @Query(value = """
         SELECT
           o.id AS orderId,
           o.created_at AS createdAt,
           o.total AS total,
           COUNT(d.id) AS totalItems,
           (
             SELECT p.main_image
             FROM order_details d2
             JOIN product_variant v2 ON d2.fk_product_id = v2.id
             JOIN product p ON v2.fk_variant_product = p.id
             WHERE d2.fk_order_id = o.id
             ORDER BY d2.id ASC
             LIMIT 1
           ) AS firstProductImage,
           (
             SELECT p.name
             FROM order_details d2
             JOIN product_variant v2 ON d2.fk_product_id = v2.id
             JOIN product p ON v2.fk_variant_product = p.id
             WHERE d2.fk_order_id = o.id
             ORDER BY d2.id ASC
             LIMIT 1
           ) AS firstProductName,
           CASE
             WHEN 'dahuy' IN (:processList) AND o.process = 'dahuy' THEN 'Đã hủy'
             WHEN 'hoantat' IN (:processList) AND o.process = 'hoantat' THEN 'Hoàn tất'
             ELSE 'Chưa hoàn tất'
           END AS status
         FROM orders o
         JOIN order_details d ON o.id = d.fk_order_id
         JOIN product_variant v ON d.fk_product_id = v.id
         JOIN product p ON v.fk_variant_product = p.id
         WHERE o.id_fk_customer = :customerId AND o.process IN (:processList)
         GROUP BY o.id, o.created_at, o.total
        """, nativeQuery = true)
    List<OrderSummaryDTO> findStatusOrdersByCustomerId(@Param("customerId") Integer customerId,@Param("processList") List<String> processList,@Param("status") String status );



}
