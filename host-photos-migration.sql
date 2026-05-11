-- 添加个人照片字段到 host 表
ALTER TABLE `host` ADD COLUMN `photos` JSON DEFAULT NULL COMMENT '个人照片（JSON数组，存放多张照片URL）' AFTER `certificate`;
