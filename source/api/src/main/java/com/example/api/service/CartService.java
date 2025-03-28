package com.example.api.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;
@Service
public class CartService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public Map<String, Object> addToCart(int customerID, int productID,int colorID, int quantity) {
        String sql = "{CALL AddToCart(?, ?, ?,?)}";
        return jdbcTemplate.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(sql)) {
                cs.setInt(1, customerID);
                cs.setInt(2, productID);
                cs.setInt(3, colorID);
                cs.setInt(4, quantity);

                boolean hasResults = cs.execute();
                if (hasResults) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) {
                            Integer id = rs.getInt("id");
                            String tempID = rs.getString("temp_id");

                            Map<String, Object> result = new HashMap<>();
                            result.put("id", id);
                            result.put("temp_id", tempID);
                            return result;
                        }
                    }
                }
                return null;
            }
        });
    }
    public void minusToCart(int productId, int orderId) {
        String sql = "{CALL MinusToCart(?,?)}";

        jdbcTemplate.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(sql)) {
                cs.setInt(1, orderId);
                cs.setInt(2, productId);
                cs.execute();
            }
            return null;
        });
    }


}

