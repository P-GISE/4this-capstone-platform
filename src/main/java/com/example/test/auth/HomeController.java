package com.example.test.auth;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    /** 
     * 루트 경로 ("/") 로 접속하면 /auth/login 으로 리다이렉트 
     */
    @GetMapping("/")
    public String redirectToLogin() {
        return "redirect:/auth/login";
    }
}
