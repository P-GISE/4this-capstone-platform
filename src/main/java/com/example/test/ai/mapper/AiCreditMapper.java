package com.example.test.ai.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.test.ai.AiCreditLogDto;
import com.example.test.ai.UserAiCreditDto;

@Mapper
public interface AiCreditMapper {
    
    /**
     * 사용자 크레딧 정보 조회
     */
    UserAiCreditDto selectUserCredit(@Param("userId") Long userId);
    
    /**
     * 사용자 크레딧 초기 생성
     */
    int insertUserCredit(UserAiCreditDto creditDto);
    
    /**
     * 크레딧 사용 (차감)
     */
    int useCredit(@Param("userId") Long userId, @Param("creditsToUse") Integer creditsToUse);
    
    /**
     * 크레딧 충전 (추가)
     */
    int rechargeCredit(@Param("userId") Long userId, @Param("creditsToAdd") Integer creditsToAdd);
    
    /**
     * 크레딧 사용 로그 저장
     */
    int insertCreditLog(AiCreditLogDto logDto);
    
    /**
     * 사용자의 크레딧 사용 내역 조회
     */
    java.util.List<AiCreditLogDto> selectCreditLogs(@Param("userId") Long userId, @Param("limit") Integer limit);
    
    /**
     * 남은 크레딧 확인
     */
    Integer getRemainingCredits(@Param("userId") Long userId);
}

