package com.example.api.service;

import com.example.api.model.Bill;
import com.example.api.model.Order;
import com.example.api.repository.BillRepository;
import com.example.api.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;
@Service
public class CartService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private BillRepository billRepository;

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
    public void minusToCart(int productId, int orderId,int colorId) {
        String sql = "{CALL MinusToCart(?,?,?)}";

        jdbcTemplate.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(sql)) {
                cs.setInt(1, orderId);
                cs.setInt(2, productId);
                cs.setInt(3, colorId);
                cs.execute();
            }
            return null;
        });
    }

    public void deleteToCart(int productDetailId) {
        String sql = "{CALL DeleteToCart(?)}";
        jdbcTemplate.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(sql)) {
                cs.setInt(1, productDetailId);
                cs.execute();
            }
            return null;
        });
    }


    public void confirmToCart(int orderId,String address, double couponTotal,String email,int fkCouponId, double pointTotal,double priceTotal,double ship) {
        String sql = "{CALL Confirm(?,?,?,?,?,?,?,?)}";
        jdbcTemplate.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(sql)) {
                cs.setInt(1, orderId);
                cs.setString(2, address);
                cs.setDouble(3, couponTotal);
                cs.setString(4, email);
                cs.setInt(5, fkCouponId);
                cs.setDouble(6, pointTotal);
                cs.setDouble(7, priceTotal);
                cs.setDouble(8, ship);
                cs.execute();
            }
            return null;
        });
    }

    public void cancelToCart(int orderId) {
        String sql = "{CALL Cancel(?)}";
        jdbcTemplate.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(sql)) {
                cs.setInt(1, orderId);
                cs.execute();
            }
            return null;
        });
    }

    public void receiveOrder(int orderId) {
        Order o = orderRepository.findById(orderId).orElse(null);
        if (o != null) {
            o.setProcess("hoantat");
            orderRepository.save(o);
        }
        Bill b = billRepository.findByFkOrderId(orderId);
        if (b != null) {
            b.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            b.setStatusOrder("dathanhtoan");
            billRepository.save(b);
        }
    }

    public void acceptOrder(int orderId) {
        Order o = orderRepository.findById(orderId).orElse(null);
        if (o != null) {
            o.setProcess("danggiao");
            orderRepository.save(o);
        }
    }





}

