-- 主持人注册功能 - 数据库迁移脚本
-- 为 host 表新增 gender, years_of_experience, certificate 字段

ALTER TABLE `host` ADD COLUMN `gender` varchar(10) NULL DEFAULT NULL COMMENT '性别：男/女' AFTER `name`;
ALTER TABLE `host` ADD COLUMN `years_of_experience` int NULL DEFAULT NULL COMMENT '从业年限' AFTER `gender`;
ALTER TABLE `host` ADD COLUMN `certificate` varchar(255) NULL DEFAULT NULL COMMENT '资质证明图片URL' AFTER `avatar`;
