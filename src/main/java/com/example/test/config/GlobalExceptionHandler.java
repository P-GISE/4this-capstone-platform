package com.example.test.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;

/**
 * 전역 예외 처리기
 * 애플리케이션에서 발생하는 모든 예외를 로깅합니다.
 */
@ControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * 모든 예외를 처리하여 로깅
     */
    @ExceptionHandler(Exception.class)
    public ModelAndView handleException(Exception ex, HttpServletRequest request) {
        // 로그 출력
        logger.error("예외 발생: {}", ex.getMessage(), ex);

        // 에러 페이지로 리다이렉트
        ModelAndView mav = new ModelAndView();
        mav.addObject("errorMessage", "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        mav.setViewName("error/500");
        
        return mav;
    }

    @ExceptionHandler(RuntimeException.class)
    public ModelAndView handleRuntimeException(RuntimeException ex, HttpServletRequest request) {
        logger.error("런타임 예외 발생: {}", ex.getMessage(), ex);

        ModelAndView mav = new ModelAndView();
        mav.addObject("errorMessage", "시스템 오류가 발생했습니다.");
        mav.setViewName("error/500");
        
        return mav;
    }

    @ExceptionHandler(NullPointerException.class)
    public ModelAndView handleNullPointerException(NullPointerException ex, HttpServletRequest request) {
        logger.error("NullPointerException 발생: {}", ex.getMessage(), ex);

        ModelAndView mav = new ModelAndView();
        mav.addObject("errorMessage", "데이터 처리 중 오류가 발생했습니다.");
        mav.addObject("errorDetails", "필수 데이터가 누락되었습니다.");
        mav.setViewName("error/500");

        return mav;
    }
}
