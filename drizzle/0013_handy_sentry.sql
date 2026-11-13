CREATE TABLE `telegram_account_scopes` (
	`id` int AUTO_INCREMENT NOT NULL,
	`owner_user_id` int NOT NULL,
	`account_user_id` int NOT NULL,
	`source_referral_id` int,
	`status` enum('active','review') NOT NULL DEFAULT 'active',
	`created_at` timestamp NOT NULL DEFAULT (now()),
	`updated_at` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `telegram_account_scopes_id` PRIMARY KEY(`id`),
	CONSTRAINT `telegram_account_scopes_account_user_id_unique` UNIQUE(`account_user_id`)
);
--> statement-breakpoint
CREATE TABLE `telegram_channels` (
	`id` int AUTO_INCREMENT NOT NULL,
	`user_id` int NOT NULL,
	`channel_url` varchar(256) NOT NULL,
	`enabled` boolean NOT NULL DEFAULT true,
	`created_at` timestamp NOT NULL DEFAULT (now()),
	`updated_at` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `telegram_channels_id` PRIMARY KEY(`id`),
	CONSTRAINT `telegram_channels_user_id_unique` UNIQUE(`user_id`)
);
--> statement-breakpoint
CREATE TABLE `telegram_key_mappings` (
	`id` int AUTO_INCREMENT NOT NULL,
	`license_id` int NOT NULL,
	`account_user_id` int NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT (now()),
	`updated_at` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `telegram_key_mappings_id` PRIMARY KEY(`id`),
	CONSTRAINT `telegram_key_mappings_license_id_unique` UNIQUE(`license_id`)
);
--> statement-breakpoint
CREATE TABLE `telegram_settings` (
	`id` int NOT NULL,
	`enabled` boolean NOT NULL DEFAULT false,
	`updated_by_user_id` int,
	`created_at` timestamp NOT NULL DEFAULT (now()),
	`updated_at` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `telegram_settings_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `telegram_tickets` (
	`id` int AUTO_INCREMENT NOT NULL,
	`token_hash` varchar(128) NOT NULL,
	`license_id` int NOT NULL,
	`device_hash` varchar(128) NOT NULL,
	`expires_at` timestamp NOT NULL,
	`redeemed_at` timestamp,
	`created_at` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `telegram_tickets_id` PRIMARY KEY(`id`),
	CONSTRAINT `telegram_tickets_token_hash_unique` UNIQUE(`token_hash`)
);
