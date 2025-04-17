package com.example.api.controller.order;

import com.example.api.dto.OrderSummaryDTO;
import com.example.api.model.Brand;
import com.example.api.model.Users;
import com.example.api.security.JwtTokenUtil;
import com.example.api.service.BrandService;
import com.example.api.service.CartService;
import com.example.api.service.OrderService;
import com.example.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private CartService cartService;

    @Autowired
    private OrderService orderService;

    @PostMapping("/confirm")
    public ResponseEntity<?> confirmToCart(
            @RequestParam int orderId,
            @RequestParam String address,
            @RequestParam double couponTotal,
            @RequestParam String email,
            @RequestParam int fkCouponId,
            @RequestParam double pointTotal,
            @RequestParam double priceTotal,
            @RequestParam double ship
    ) {
        cartService.confirmToCart(orderId, address, couponTotal, email, fkCouponId, pointTotal, priceTotal, ship);
        return ResponseEntity.ok(Map.of("message", "Đã đặt đơn hàng thành công"));
    }

    @PostMapping("/cancel")
    public ResponseEntity<?> cancelToCart(
            @RequestParam int orderId) {

        cartService.cancelToCart(orderId);
        return ResponseEntity.ok(Map.of("message", "Đã đặt đơn hàng thành công"));

    }

    @GetMapping("/pending")
    public ResponseEntity<List<OrderSummaryDTO>> findPendingOrdersByCustomerId(@RequestHeader("Authorization") String token) {
        int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
        return ResponseEntity.ok(orderService.findPendingOrdersByCustomerId(userId));
    }

    @GetMapping("/delivering")
    public ResponseEntity<List<OrderSummaryDTO>> findDeliveringOrdersByCustomerId(@RequestHeader("Authorization") String token) {
        int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
        return ResponseEntity.ok(orderService.findDeliveringOrdersByCustomerId(userId));
    }
}
