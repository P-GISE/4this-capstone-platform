package com.example.test.equipmentreservation;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EquipmentReservationService {

    @Autowired
    private EquipmentReservationDao equipmentReservationDao;

    // 예약 등록
    public int createReservation(Long userId, Long equipmentId, String note) {
        EquipmentReservationDto reservation = new EquipmentReservationDto();
        reservation.setUserId(userId);
        reservation.setEquipmentId(equipmentId);
        reservation.setNote(note);
        reservation.setReservedAt(LocalDateTime.now());
        return equipmentReservationDao.insertReservation(reservation);
    }

    // 특정 기자재의 모든 예약 조회
    public List<EquipmentReservationDto> getReservationsByEquipment(Long equipmentId) {
        return equipmentReservationDao.selectReservationsByEquipment(equipmentId);
    }



    // 해당 유저가 해당 기자재를 이미 예약했는지 여부
    public boolean isAlreadyReserved(Long userId, Long equipmentId) {
        return equipmentReservationDao.existsByUserAndEquipment(userId, equipmentId);
    }

    // 예약 취소
    public int cancelReservation(Long reservationId) {
        return equipmentReservationDao.deleteReservationById(reservationId);
    }

    public int countActiveReservationsByUser(Long userId) {
        return equipmentReservationDao.countActiveReservationsByUser(userId);
    }

    public List<EquipmentReservationDto> getReservationsByUser(Long userId) {
        List<EquipmentReservationDto> reservations = equipmentReservationDao.selectReservationsByUser(userId);

        for (EquipmentReservationDto dto : reservations) {
            if (dto.getReservedAt() != null) {
                long days = ChronoUnit.DAYS.between(LocalDate.now(), dto.getReservedAt().toLocalDate());
                dto.setRemainingDays((int) days);
            } else {
                dto.setRemainingDays(null);
            }
        }

        return reservations;
    }   
}
