package com.example.api.controller.chat;

import com.example.api.model.Message;
import com.example.api.repository.MessageRepository;
import com.example.api.repository.UsersRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
@Controller
@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final MessageRepository  messageRepository;

    public ChatController(MessageRepository messageRepository) {
        this.messageRepository = messageRepository;
    }

    @MessageMapping("/sendMessage")
    @SendTo("/topic/chat")
    public Message sendMessage(@Payload Message message) {
        System.out.println(message.getSender_id());
        System.out.println(message.getReceiver_id());
        message.setSentAt(new Date());
        messageRepository.save(message);
        return message;
    }

    @GetMapping("/messages/{userId}/{otherUserId}")
    public List<Message> getChatHistory(
            @PathVariable Integer userId,
            @PathVariable Integer otherUserId) {
        return messageRepository.findMessagesByUserIds(userId, otherUserId);
    }
}