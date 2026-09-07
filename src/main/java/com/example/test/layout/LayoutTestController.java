package com.example.test.layout;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * /layout-test 요청 시 layout/test.jsp를 layout/base.jsp에 포함시켜 출력
 */
@Controller
public class LayoutTestController {

    @GetMapping("/layout-test")
    public String showLayoutTest(Model model) {
        model.addAttribute("page", "layout/base"); // 실제 존재하는 jsp만 지정
        return "layout/base";
    }
    
}
