CREATE TABLE `referrals` (
	`id` int AUTO_INCREMENT NOT NULL,
	`code` varchar(96) NOT NULL,
	`role` enum('owner','admin') NOT NULL,
	`createdByUserId` int NOT NULL,
	`redeemedByUserId` int,
	`status` enum('active','redeemed','revoked') NOT NULL DEFAULT 'active',
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`redeemedAt` timestamp,
	CONSTRAINT `referrals_id` PRIMARY KEY(`id`),
	CONSTRAINT `referrals_code_unique` UNIQUE(`code`)
);
--> statement-breakpoint
ALTER TABLE `users` MODIFY COLUMN `accessStatus` enum('pending','active','revoked') NOT NULL DEFAULT 'pending';--> statement-breakpoint
ALTER TABLE `license_keys` ADD `createdByUserId` int;