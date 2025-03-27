package com.example.api.repository;

import com.example.api.dto.OrderDetailProjection;
import com.example.api.model.Order_detail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderDetailRepository extends JpaRepository<Order_detail, Integer> {

    @Query("SELECT o.quantity FROM Order_detail o WHERE o.fk_orderId = :orderId AND o.fk_productId = :productId AND o.fk_colorId = :colorId")
    Integer getQuantityByOrderProductColor(
            @Param("orderId") Integer orderId,
            @Param("productId") Integer productId,
            @Param("colorId") Integer colorId
    );


    @Query("SELECT o.quantity FROM Order_detail o WHERE o.fk_orderId = :orderId AND o.fk_productId = :productId")
    Integer getQuantityByOrderAndProduct(
            @Param("orderId") Integer orderId,
            @Param("productId") Integer productId
    );

    @Query(value = "SELECT " +
            "  od.id AS order_id, " +
            "  o.id AS order_detail_id, " +
            "  COALESCE(o.fk_color_id, -1) AS fk_color_id, " +
            "  o.fk_product_id, " +
            "  CASE " +
            "    WHEN pc.color_price IS NOT NULL THEN pc.color_price " +
            "    ELSE v.price " +
            "  END AS price, " +
            "  o.quantity, " +
            "  o.total, " +
            "  COALESCE(pc.color_name, '') AS color_name, " +
            "  v.name_variant, " +
            "  CASE " +
            "    WHEN pc.image IS NOT NULL THEN pc.image " +
            "    ELSE p.main_image " +
            "  END AS image " +
            "FROM customer c " +
            "JOIN orders od ON c.id = od.id_fk_customer " +
            "JOIN order_details o ON od.id = o.fk_order_id " +
            "JOIN product_variant v ON o.fk_product_id = v.id " +
            "JOIN product p ON v.fk_variant_product = p.id " +
            "LEFT JOIN product_color pc ON o.fk_color_id = pc.id " +
            "WHERE c.id = :customerId AND od.process = 'giohang'",
            nativeQuery = true)
    List<OrderDetailProjection> findOrderDetailsByCustomerId(@Param("customerId") Integer customerId);
}
