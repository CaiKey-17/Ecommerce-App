package com.example.api.controller;

import com.example.api.dto.RegisterRequest;
import com.example.api.dto.ValidRequest;
import com.example.api.service.UserService;
import com.example.api.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api/auth")
public class RegisterController {

    @Autowired
    private UserService userService;

    @Autowired
    private EmailService emailService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest registerRequest ){
        if (userService.existsByEmail(registerRequest.getEmail())) {
            return ResponseEntity.badRequest().body(Map.of(
                    "code", 400,
                    "message", "Email đã được sử dụng"
            ));
        }

        String otp = generateOTP();
        userService.saveOtp(registerRequest.getEmail(), otp);

        emailService.sendOtpEmail(registerRequest.getEmail(), otp);

        return ResponseEntity.ok(Map.of(
                "code", 200,
                "message", "OTP đã được gửi đến email. Vui lòng xác nhận!"
        ));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody ValidRequest validRequest) {
        boolean isValid = userService.verifyOtp(validRequest.getEmail(), validRequest.getOtp());
        if (!isValid) {
            return ResponseEntity.badRequest().body(Map.of(
                    "code", 400,
                    "message", "OTP không hợp lệ hoặc đã hết hạn"
            ));
        }

        userService.registerUser(validRequest.getEmail(),validRequest.getPassword(),validRequest.getAddress(),validRequest.getFullname());

        return ResponseEntity.ok(Map.of(
                "code", 200,
                "message", "Xác thực thành công, tài khoản đã được tạo"
        ));
    }

    private String generateOTP() {
        return String.valueOf(100000 + new Random().nextInt(900000));
    }
}
