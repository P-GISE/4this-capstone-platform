package com.example.test.auth;

import lombok.Data;

@Data
public class ProfileUpdateDto {
    private String name;
    private String email;
    private String phone;
}
