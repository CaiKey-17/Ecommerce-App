package com.example.api.luan.repository;

import com.example.api.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryAdminRepository extends JpaRepository<Category, String> {
}
