package com.example.api.repository;

import com.example.api.model.Message;
import com.example.api.model.Order_detail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Integer> {

    @Query("SELECT m FROM Message m WHERE (m.sender_id = :userId AND m.receiver_id = :otherUserId) OR (m.sender_id = :otherUserId AND m.receiver_id = :userId) ORDER BY m.sentAt ASC")
    List<Message> findMessagesByUserIds(@Param("userId") Integer userId, @Param("otherUserId") Integer otherUserId);



}
