CREATE TABLE `licenses` (
	`id` int AUTO_INCREMENT NOT NULL,
	`license_key` varchar(128) NOT NULL,
	`status` enum('active','expired','revoked','unused') NOT NULL DEFAULT 'unused',
	`expires_at` timestamp NOT NULL,
	`bound_device_id` varchar(128),
	`created_by_user_id` int,
	`created_at` timestamp NOT NULL DEFAULT (now()),
	`updated_at` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `licenses_id` PRIMARY KEY(`id`),
	CONSTRAINT `licenses_license_key_unique` UNIQUE(`license_key`)
);
