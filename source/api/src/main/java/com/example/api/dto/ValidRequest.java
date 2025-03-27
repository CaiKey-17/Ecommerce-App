package com.example.api.dto;

import lombok.Data;

@Data
public class ValidRequest {
    private String email;
    private String password;

    private String address;
    private String otp;

    private String fullname;

}
