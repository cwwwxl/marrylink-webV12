package com.marrylink.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.marrylink.dto.HostRegisterRequest;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 主持人注册功能测试
 */
@SpringBootTest
@AutoConfigureMockMvc
public class HostRegisterTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("主持人注册 - 正常注册成功")
    void testHostRegisterSuccess() throws Exception {
        HostRegisterRequest request = new HostRegisterRequest();
        request.setPhone("13800138099");
        request.setPassword("123456");
        request.setName("测试主持人");
        request.setGender("男");
        request.setYearsOfExperience(5);
        request.setPrice(new BigDecimal("3000.00"));
        request.setServiceAreas("[\"北京\",\"上海\"]");
        request.setDescription("专业婚礼主持人，从业5年");

        mockMvc.perform(post("/api/v1/auth/register/host")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("00000"))
                .andExpect(jsonPath("$.data").isNotEmpty());
    }

    @Test
    @DisplayName("主持人注册 - 手机号为空校验")
    void testHostRegisterPhoneEmpty() throws Exception {
        HostRegisterRequest request = new HostRegisterRequest();
        request.setPhone("");
        request.setPassword("123456");
        request.setName("测试主持人");
        request.setGender("男");

        mockMvc.perform(post("/api/v1/auth/register/host")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("主持人注册 - 手机号格式错误")
    void testHostRegisterPhoneInvalid() throws Exception {
        HostRegisterRequest request = new HostRegisterRequest();
        request.setPhone("12345");
        request.setPassword("123456");
        request.setName("测试主持人");
        request.setGender("男");

        mockMvc.perform(post("/api/v1/auth/register/host")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("主持人注册 - 重复手机号注册")
    void testHostRegisterDuplicatePhone() throws Exception {
        HostRegisterRequest request = new HostRegisterRequest();
        request.setPhone("13900139000"); // 已存在的主持人手机号
        request.setPassword("123456");
        request.setName("重复测试");
        request.setGender("女");

        mockMvc.perform(post("/api/v1/auth/register/host")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("B0001"));
    }

    @Test
    @DisplayName("主持人注册 - 姓名为空校验")
    void testHostRegisterNameEmpty() throws Exception {
        HostRegisterRequest request = new HostRegisterRequest();
        request.setPhone("13800138088");
        request.setPassword("123456");
        request.setName("");
        request.setGender("男");

        mockMvc.perform(post("/api/v1/auth/register/host")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("主持人注册 - 仅必填字段")
    void testHostRegisterMinimalFields() throws Exception {
        HostRegisterRequest request = new HostRegisterRequest();
        request.setPhone("13800138077");
        request.setPassword("123456");
        request.setName("最简注册");
        request.setGender("女");

        mockMvc.perform(post("/api/v1/auth/register/host")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("00000"));
    }
}
