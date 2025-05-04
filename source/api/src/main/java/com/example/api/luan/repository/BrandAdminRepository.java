package com.example.api.luan.repository;

import com.example.api.model.Brand;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BrandAdminRepository extends JpaRepository<Brand, String> {
}
