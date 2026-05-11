-- =============================================
-- marrylinkv2 缺失表补建脚本
-- 从 marrylinkv9.sql 中提取
-- =============================================

SET NAMES utf8mb4;

-- ----------------------------
-- 1. 结算记录表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `settlement`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `settlement_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '结算单号',
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '关联订单号',
  `host_id` bigint NOT NULL COMMENT '主持人ID',
  `host_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '主持人姓名',
  `amount` decimal(10, 2) NOT NULL COMMENT '结算金额',
  `commission_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '佣金金额',
  `net_amount` decimal(10, 2) NOT NULL COMMENT '实际到账金额(结算-佣金)',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1=待结算 2=已结算',
  `settle_time` datetime NULL DEFAULT NULL COMMENT '结算完成时间',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `settlement_no`(`settlement_no` ASC) USING BTREE,
  INDEX `idx_host_id`(`host_id` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '结算记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 2. 佣金支付订单表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `commission_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `commission_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '佣金单号',
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '关联订单号',
  `host_id` bigint NOT NULL COMMENT '主持人ID',
  `host_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '主持人姓名',
  `order_amount` decimal(10, 2) NOT NULL COMMENT '订单金额',
  `commission_rate` decimal(5, 2) NOT NULL COMMENT '佣金比例(%)',
  `commission_amount` decimal(10, 2) NOT NULL COMMENT '佣金金额',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1=待支付 2=已支付 3=逾期',
  `deadline` datetime NOT NULL COMMENT '支付截止时间',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '实际支付时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `commission_no`(`commission_no` ASC) USING BTREE,
  INDEX `idx_host_id`(`host_id` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '佣金支付订单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 3. 主持人钱包表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `host_wallet`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `host_id` bigint NOT NULL COMMENT '主持人ID',
  `balance` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '可用余额',
  `frozen_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '冻结金额(待支付佣金)',
  `total_income` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '累计收入',
  `total_commission` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '累计已付佣金',
  `total_withdrawn` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '累计已提现',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `host_id`(`host_id` ASC) USING BTREE,
  INDEX `idx_host_id`(`host_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '主持人钱包' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 4. 平台账户表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `platform_account`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `balance` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '可提现余额',
  `total_commission_income` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '累计佣金收入',
  `total_withdrawn` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '累计已提现',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- 初始化平台账户
INSERT IGNORE INTO `platform_account` VALUES (1, 0.00, 0.00, 0.00, NOW(), NOW());

-- ----------------------------
-- 5. 平台提现记录表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `platform_withdrawal`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `withdrawal_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '提现单号',
  `amount` decimal(12, 2) NOT NULL COMMENT '提现金额',
  `account_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '账户类型',
  `account_no` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '账号',
  `account_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '户名',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1=待处理 2=已完成',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '操作人',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- 6. 平台托管资金表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `platform_escrow`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单号',
  `amount` decimal(10, 2) NOT NULL COMMENT '托管金额',
  `total_order_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '订单全额（用于佣金计算）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1=托管中 2=已结算 3=已退款',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '用户支付时间',
  `settle_time` datetime NULL DEFAULT NULL COMMENT '结算时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_order_no`(`order_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '平台托管资金' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 7. 提现申请表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `withdrawal_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `withdrawal_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '提现单号',
  `host_id` bigint NOT NULL COMMENT '主持人ID',
  `host_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '主持人姓名',
  `amount` decimal(10, 2) NOT NULL COMMENT '提现金额',
  `account_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '账户类型(支付宝/微信/银行卡)',
  `account_no` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款账号',
  `account_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款人姓名',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1=待审核 2=已通过 3=已拒绝 4=已打款',
  `reject_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '打款时间',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `withdrawal_no`(`withdrawal_no` ASC) USING BTREE,
  INDEX `idx_host_id`(`host_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '提现申请' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 8. 平台设置表（如果不存在）
-- ----------------------------
CREATE TABLE IF NOT EXISTS `platform_settings`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设置键',
  `setting_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设置值',
  `description` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `setting_key`(`setting_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '平台设置' ROW_FORMAT = Dynamic;

-- 初始化平台设置
INSERT IGNORE INTO `platform_settings` (`id`, `setting_key`, `setting_value`, `description`) VALUES
(1, 'commission_rate', '10', '佣金比例(%)'),
(2, 'commission_deadline_days', '7', '佣金缴纳期限(天)');
