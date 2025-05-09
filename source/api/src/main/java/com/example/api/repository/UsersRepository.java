package com.example.api.repository;

import com.example.api.model.Users;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Map;
import java.util.Optional;

public interface UsersRepository extends JpaRepository<Users, Integer> {
    Optional<Users> findByEmail(String email);

    @Query("SELECT u.id FROM Users u WHERE u.email = :email")
    Optional<Integer> findIdByEmail(@Param("email") String email);

    boolean existsByEmail(String email);

    Users findByResetToken(String resetToken);

    Optional<Users> findByTempId(String tempId);

    Optional<Users> findById(Integer id);


    @Query("SELECT " +
            "COUNT(u) AS total_users, " +
            "SUM(CASE " +
            "WHEN FUNCTION('MONTH', u.createdAt) = FUNCTION('MONTH', CURRENT_DATE) " +
            "AND FUNCTION('YEAR', u.createdAt) = FUNCTION('YEAR', CURRENT_DATE) THEN 1 " +
            "ELSE 0 " +
            "END) AS new_users " +
            "FROM Users u " +
            "JOIN u.roles r " +
            "WHERE r.id = 2")
    Map<String, Long> getTotalUsersAndNewUsers();

}

