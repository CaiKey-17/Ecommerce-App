package com.example.api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "address")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String address;
    private String codes;

    private Integer userId;
    private Integer status=0;

    public Address(String address, int id_fk,String codes) {
        this.address = address;
        this.userId = id_fk;
        this.codes = codes;
    }
}
