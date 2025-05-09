package com.example.api.repository;

import com.example.api.dto.OrderSummaryDTO;
import com.example.api.dto.TopSellingProductDTO;
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
              WHEN 'danggiao' IN (:processList) AND o.process = 'danggiao' THEN 'Đã xác nhận'
             WHEN 'hoantat' IN (:processList) AND o.process = 'hoantat' THEN 'Hoàn tất'
             ELSE 'Chờ xác nhận'
           END AS status
         FROM orders o
         JOIN order_details d ON o.id = d.fk_order_id
         JOIN product_variant v ON d.fk_product_id = v.id
         JOIN product p ON v.fk_variant_product = p.id
         WHERE o.id_fk_customer = :customerId AND o.process IN (:processList)
         GROUP BY o.id, o.created_at, o.total
         ORDER BY o.created_at DESC;
        """, nativeQuery = true)
    List<OrderSummaryDTO> findStatusOrdersByCustomerId(@Param("customerId") Integer customerId,@Param("processList") List<String> processList,@Param("status") String status );

    @Query("SELECT COUNT(o) FROM Order o WHERE o.process != 'giohang'")
    long countOrdersNotInCart();

    @Query("SELECT SUM(o.total) FROM Order o WHERE o.process = 'hoantat'")
    Long getTotalRevenue();

    @Query(value = """
        SELECT p.id AS productId,
               p.name AS productName,
               SUM(d.quantity) AS totalSold
        FROM product p
        JOIN product_variant v ON p.id = v.fk_variant_product
        JOIN order_details d ON d.fk_product_id = v.id
        JOIN orders o ON o.id = d.fk_order_id
        WHERE o.process = 'hoantat'
        GROUP BY p.id, p.name
        HAVING SUM(d.quantity) > 0
        ORDER BY SUM(d.quantity) DESC
        LIMIT 3
    """, nativeQuery = true)
    List<TopSellingProductDTO> findTopSellingProducts();

}
