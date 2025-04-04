package com.example.api.dto;

import lombok.Data;

@Data
public class RegisterRequest {
    private String email;
    private String password;

    private String address;
    private String codes;
    private String fullname;
}
