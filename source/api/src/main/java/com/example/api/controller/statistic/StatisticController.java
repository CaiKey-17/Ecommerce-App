package com.example.api.controller.statistic;

import com.example.api.dto.ApiResponse;
import com.example.api.dto.OrderStatisticsDTO;
import com.example.api.dto.TopSellingProductDTO;
import com.example.api.service.OrderService;
import com.example.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/statistic")
public class StatisticController {

    @Autowired
    private UserService userService;

    @GetMapping("/user-stats")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUserStatistics() {
        Map<String, Long> statistics = userService.getUserStatistics();
        ApiResponse<Map<String, Long>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", statistics);
        return ResponseEntity.ok(response);
    }

    @Autowired
    private OrderService orderService;

    @GetMapping("/order-stats")
    public ResponseEntity<ApiResponse<OrderStatisticsDTO>> getOrderStatistics() {
        OrderStatisticsDTO statistics = orderService.getOrderStatistics();
        ApiResponse<OrderStatisticsDTO> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", statistics);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/top-selling-products")
    public ResponseEntity<ApiResponse<List<TopSellingProductDTO>>> getTopSellingProducts() {
        List<TopSellingProductDTO> topSellingProducts = orderService.getTopSellingProducts();
        ApiResponse<List<TopSellingProductDTO>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", topSellingProducts);
        return ResponseEntity.ok(response);
    }
}
