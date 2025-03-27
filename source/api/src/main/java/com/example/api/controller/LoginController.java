package com.example.api.controller;

import com.example.api.dto.LoginRequest;
import com.example.api.model.Users;
import com.example.api.security.JwtTokenUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.api.service.UserService;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class LoginController {
    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest request,
            HttpServletResponse response) {

        Users user = userService.findByEmail(request.getUsername());

        if (user == null || !userService.authenticateUser(request.getUsername(), request.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "code", 401,
                    "message", "Sai tài khoản hoặc mật khẩu"
            ));
        }

        if (user.getActive() == 0) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of(
                    "code", 403,
                    "message", "Người dùng đã bị cấm"
            ));
        }

        try {
            String role = userService.getUserRole(request.getUsername());
            int id = user.getId();
            String token = JwtTokenUtil.createToken(id, role);

            Cookie tokenCookie = new Cookie("token", token);
            tokenCookie.setHttpOnly(true);
            tokenCookie.setPath("/");
            tokenCookie.setMaxAge(60 * 60 * 24);
            tokenCookie.setAttribute("SameSite", "Strict");
            response.addCookie(tokenCookie);

            return ResponseEntity.ok(Map.of(
                    "code", 200,
                    "message", "Đăng nhập thành công",
                    "token", token,
                    "role", role
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi tạo token"
            ));
        }
    }


}
