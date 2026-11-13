-- =============================================
-- TOOL PANEL - FRESH CLEAN DATABASE SCHEMA
-- =============================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actorUserId` int DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `entityType` varchar(32) NOT NULL,
  `entityId` int DEFAULT NULL,
  `keyPreview` varchar(64) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `device_bindings`;
CREATE TABLE `device_bindings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `licenseKeyId` int NOT NULL,
  `deviceHash` varchar(128) NOT NULL,
  `firstSeenAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastSeenAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_bindings_license_device_hash_unique` (`licenseKeyId`,`deviceHash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `license_keys`;
CREATE TABLE `license_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `keyValue` varchar(128) NOT NULL,
  `status` enum('active','banned') NOT NULL DEFAULT 'active',
  `expiresAt` timestamp NOT NULL,
  `maxDevices` int NOT NULL DEFAULT '1',
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdByUserId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_keys_keyValue_unique` (`keyValue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `licenses`;
CREATE TABLE `licenses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `license_key` varchar(128) NOT NULL,
  `status` enum('active','expired','revoked','unused') NOT NULL DEFAULT 'unused',
  `durationMinutes` int NOT NULL,
  `maxDevices` int NOT NULL DEFAULT '1',
  `boundDeviceId` varchar(128) DEFAULT NULL,
  `usedDevices` int NOT NULL DEFAULT '0',
  `activatedAt` timestamp NULL DEFAULT NULL,
  `expiresAt` timestamp NULL DEFAULT NULL,
  `createdByUserId` int NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `licenses_license_key_unique` (`license_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `referrals`;
CREATE TABLE `referrals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(96) NOT NULL,
  `role` enum('admin','owner') NOT NULL DEFAULT 'admin',
  `createdByUserId` int NOT NULL,
  `redeemedByUserId` int DEFAULT NULL,
  `status` enum('active','redeemed','revoked') NOT NULL DEFAULT 'active',
  `expiresAt` timestamp NOT NULL,
  `redeemedAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `referrals_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `server_maintenance`;
CREATE TABLE `server_maintenance` (
  `id` int NOT NULL,
  `version` int NOT NULL DEFAULT '1',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(80) NOT NULL DEFAULT 'SERVER MAINTENANCE',
  `message` varchar(300) NOT NULL DEFAULT '',
  `start_at` timestamp NULL DEFAULT NULL,
  `end_at` timestamp NULL DEFAULT NULL,
  `updated_by_user_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `system_announcements`;
CREATE TABLE `system_announcements` (
  `id` int NOT NULL,
  `version` int NOT NULL DEFAULT '1',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(80) NOT NULL DEFAULT 'SYSTEM ANNOUNCEMENT',
  `message` varchar(300) NOT NULL DEFAULT '',
  `start_at` timestamp NULL DEFAULT NULL,
  `end_at` timestamp NULL DEFAULT NULL,
  `display_mode` enum('every_login','once_per_day') NOT NULL DEFAULT 'every_login',
  `text_size` enum('small','normal','large','festival_large') NOT NULL DEFAULT 'normal',
  `updated_by_user_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `telegram_account_scopes`;
CREATE TABLE `telegram_account_scopes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner_user_id` int NOT NULL,
  `account_user_id` int NOT NULL,
  `source_referral_id` int DEFAULT NULL,
  `status` enum('active','review','revoked') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `telegram_account_scopes_account_user_id_unique` (`account_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `telegram_channels`;
CREATE TABLE `telegram_channels` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `channel_url` varchar(256) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `telegram_channels_user_id_unique` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `telegram_key_mappings`;
CREATE TABLE `telegram_key_mappings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `license_id` int NOT NULL,
  `account_user_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `telegram_key_mappings_license_id_unique` (`license_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `telegram_settings`;
CREATE TABLE `telegram_settings` (
  `id` int NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `updated_by_user_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `telegram_tickets`;
CREATE TABLE `telegram_tickets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token_hash` varchar(128) NOT NULL,
  `license_id` int NOT NULL,
  `account_user_id` int NOT NULL,
  `channel_url` varchar(256) NOT NULL,
  `device_hash` varchar(128) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `redeemed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `telegram_tickets_token_hash_unique` (`token_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `openId` varchar(64) NOT NULL,
  `name` text DEFAULT NULL,
  `email` varchar(320) DEFAULT NULL,
  `loginMethod` varchar(64) DEFAULT NULL,
  `role` enum('super_owner','owner','admin') NOT NULL DEFAULT 'admin',
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `lastSignedIn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `operatorUid` varchar(32) DEFAULT NULL,
  `accessStatus` enum('pending','active','revoked') NOT NULL DEFAULT 'pending',
  `accessExpiresAt` timestamp NULL DEFAULT NULL,
  `username` varchar(32) DEFAULT NULL,
  `usernameChangedAt` timestamp NULL DEFAULT NULL,
  `passwordHash` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_openId_unique` (`openId`),
  UNIQUE KEY `users_username_unique` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Default Settings Rows
INSERT INTO `system_announcements` (`id`, `version`, `enabled`, `title`, `message`) VALUES (1, 1, 0, 'SYSTEM ANNOUNCEMENT', '');
INSERT INTO `server_maintenance` (`id`, `version`, `enabled`, `title`, `message`) VALUES (1, 1, 0, 'SERVER MAINTENANCE', '');
INSERT INTO `telegram_settings` (`id`, `enabled`) VALUES (1, 0);

-- Default Super Owner Account
-- Username: admin
-- Password: admin123
INSERT INTO `users` (`id`, `openId`, `name`, `role`, `createdAt`, `updatedAt`, `lastSignedIn`, `operatorUid`, `accessStatus`, `username`, `passwordHash`) 
VALUES (1, 'super-owner-admin', 'Super Admin', 'super_owner', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'UID-SUP-TOOLPANEL', 'active', 'admin', '97286160a885077211d89f7db2c2c570:1d66e1ce7106615559bb11d16ba9c2fa4a0894cbd2585bb8e166c37f39f35a0a5ebe4f48c101ca890c7f9f0dbcb761d704182cbc8e3015335419464ccc9817a7');

SET FOREIGN_KEY_CHECKS = 1;
