package com.marrylink.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import java.math.BigDecimal;

/**
 * 主持人注册请求DTO
 */
@Data
public class HostRegisterRequest {

    /**
     * 手机号
     */
    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    /**
     * 密码
     */
    @NotBlank(message = "密码不能为空")
    private String password;

    /**
     * 真实姓名
     */
    @NotBlank(message = "姓名不能为空")
    private String name;

    /**
     * 性别：男/女
     */
    @NotBlank(message = "性别不能为空")
    private String gender;

    /**
     * 从业年限
     */
    private Integer yearsOfExperience;

    /**
     * 服务报价（每场）
     */
    private BigDecimal price;

    /**
     * 服务区域（JSON数组字符串，如 ["北京","上海"]）
     */
    private String serviceAreas;

    /**
     * 个人简介
     */
    private String description;

    /**
     * 个人照片URL（注册时上传后回填）
     */
    private String avatar;

    /**
     * 资质证明URL（注册时上传后回填）
     */
    private String certificate;
}
