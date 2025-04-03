package com.example.api.controller.coupon;

import com.example.api.dto.CouponDTO;
import com.example.api.model.Brand;
import com.example.api.model.Coupon;
import com.example.api.repository.CouponRepository;
import com.example.api.service.BrandService;
import com.example.api.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/coupon")
public class CouponController {

    @Autowired
    private CouponService couponService;

    @Autowired
    private CouponRepository couponRepository;

    public CouponController(CouponService couponService) {
        this.couponService = couponService;
    }

    @GetMapping("/find")
    public ResponseEntity<?> findCoupon(@RequestParam String name) {
        Coupon coupon = couponRepository.findByName(name);

        if (coupon == null) {
            return ResponseEntity.badRequest().body(Map.of(
                    "code", 404,
                    "message", "Mã giảm giá không tồn tại"
            ));
        }

        if (coupon.getMaxAllowedUses() <= 0) {
            return ResponseEntity.badRequest().body(Map.of(
                    "code", 400,
                    "message", "Mã này đã hết lượt dùng"
            ));
        }

        CouponDTO couponDTO = couponService.findCouponByName(name);
        return ResponseEntity.ok(Map.of(
                "code", 200,
                "message", "Áp dụng mã thành công",
                "data", couponDTO
        ));
    }



}
