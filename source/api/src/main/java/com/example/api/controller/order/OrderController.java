package com.example.api.controller.order;

import com.example.api.dto.OrderDetailProjection;
import com.example.api.dto.OrderSummaryDTO;
import com.example.api.model.Brand;
import com.example.api.model.Users;
import com.example.api.security.JwtTokenUtil;
import com.example.api.service.*;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private CartService cartService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private UserService userService;

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private OrderDetailService orderDetailService;


    private void sendHtmlEmail(String to, String subject, String htmlContent) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true); // true để bật HTML

            mailSender.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
            // Log lỗi nếu cần
        }
    }


    @PostMapping("/confirm")
    public ResponseEntity<?> confirmToCart(
            @RequestParam int orderId,
            @RequestParam String address,
            @RequestParam double couponTotal,
            @RequestParam String email,
            @RequestParam int fkCouponId,
            @RequestParam double pointTotal,
            @RequestParam double priceTotal,
            @RequestParam double ship,
            @RequestParam String tempId,
            @RequestParam int id
    ) {
        System.out.println("ID: " + id);

        Users u1 = userService.findById(id);
        Users u2 = null;
        try {
            u2 = userService.findByEmail(email);
        } catch (RuntimeException ex) {
        }

        if (u2 != null && !u2.getId().equals(u1.getId())) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email đã tồn tại"));
        } else {
            cartService.confirmToCart(orderId, address, couponTotal, email, fkCouponId, pointTotal, priceTotal, ship);
            List<OrderDetailProjection> list = orderDetailService.getOrderDetailsByCustomerIdAndOrderId(id, "dangdat", orderId);
            System.out.println(tempId);


            String subject = "Xác nhận đơn hàng #" + orderId;
            String htmlContent = generateOrderEmailHTML(orderId, address, list, priceTotal, couponTotal, pointTotal, ship);

            sendHtmlEmail(email, subject, htmlContent);

            return ResponseEntity.ok(Map.of("message", "Đã đặt đơn hàng thành công"));
        }


    }

    @PostMapping("/cancel")
    public ResponseEntity<?> cancelToCart(
            @RequestParam int orderId) {

        cartService.cancelToCart(orderId);
        return ResponseEntity.ok(Map.of("message", "Đã đặt đơn hàng thành công"));

    }

    @GetMapping("/pending")
    public ResponseEntity<List<OrderSummaryDTO>> findPendingOrdersByCustomerId(@RequestHeader("Authorization") String token) {
        int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", "")) != null ? JwtTokenUtil.getIdFromToken(token.replace("Bearer ", "")) : -1;

        return ResponseEntity.ok(orderService.findPendingOrdersByCustomerId(userId));
    }

    @GetMapping("/delivering")
    public ResponseEntity<List<OrderSummaryDTO>> findDeliveringOrdersByCustomerId(@RequestHeader("Authorization") String token) {
        int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", "")) != null ? JwtTokenUtil.getIdFromToken(token.replace("Bearer ", "")) : -1;
        return ResponseEntity.ok(orderService.findDeliveringOrdersByCustomerId(userId));
    }


    private String generateOrderEmailHTML(int orderId, String address, List<OrderDetailProjection> list,
                                          double priceTotal, double couponTotal, double pointTotal, double ship) {
        StringBuilder tableBuilder = new StringBuilder();
        tableBuilder.append(String.format("""
                <h2>🛒 Xác nhận đơn hàng #%d</h2>
                <p>Cảm ơn bạn đã đặt hàng tại cửa hàng của chúng tôi!</p>
                <p><strong>Địa chỉ giao hàng:</strong> %s</p>
                <table style="border-collapse: collapse; width: 100%%; font-family: Arial, sans-serif;">
                    <thead>
                        <tr style="background-color: #f2f2f2;">
                            <th style="border: 1px solid #ddd; padding: 8px;">Hình ảnh</th>
                            <th style="border: 1px solid #ddd; padding: 8px;">Sản phẩm</th>
                            <th style="border: 1px solid #ddd; padding: 8px;">Màu sắc</th>
                            <th style="border: 1px solid #ddd; padding: 8px;">Số lượng</th>
                            <th style="border: 1px solid #ddd; padding: 8px;">Giá</th>
                            <th style="border: 1px solid #ddd; padding: 8px;">Tổng</th>
                        </tr>
                    </thead>
                    <tbody>
                """, orderId, address));

        for (OrderDetailProjection item : list) {
            tableBuilder.append(String.format("""
                            <tr>
                                <td style="border: 1px solid #ddd; padding: 8px; text-align: center;">
                                    <img src="%s" alt="product" width="80" />
                                </td>
                                <td style="border: 1px solid #ddd; padding: 8px;">%s</td>
                                <td style="border: 1px solid #ddd; padding: 8px;">%s</td>
                                <td style="border: 1px solid #ddd; padding: 8px;">%d</td>
                                <td style="border: 1px solid #ddd; padding: 8px;">%,.0f VNĐ</td>
                                <td style="border: 1px solid #ddd; padding: 8px;">%,.0f VNĐ</td>
                            </tr>
                            """,
                    item.getImage(),
                    item.getNameVariant(),
                    (item.getColorName() != null && !item.getColorName().isBlank()) ? item.getColorName() : "—",
                    item.getQuantity(),
                    item.getPrice(),
                    item.getTotal()
            ));
        }

        double totalPayment = priceTotal - couponTotal - pointTotal + ship + priceTotal * 0.02;

        tableBuilder.append(String.format("""
                    </tbody>
                </table>
                <br/>
                <p><strong>Tổng cộng:</strong> %,.0f VNĐ</p>
                <p><strong>Giảm giá (Coupon):</strong> %,.0f VNĐ</p>
                <p><strong>Điểm sử dụng:</strong> %,.0f VNĐ</p>
                <p><strong>Phí vận chuyển:</strong> %,.0f VNĐ</p>
                <p><strong>Phí thuế:</strong> %,.0f VNĐ</p>
                <p><strong>Thành tiền:</strong> <span style="color: green; font-weight: bold;">%,.0f VNĐ</span></p>
                <p style="margin-top: 30px;">🎉 Chúng tôi sẽ xử lý và giao hàng cho bạn sớm nhất!</p>
                """, priceTotal, couponTotal, pointTotal, ship, priceTotal * 0.02, totalPayment));

        return tableBuilder.toString();
    }

}
