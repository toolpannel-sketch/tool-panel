CREATE TABLE `audit_logs` (
	`id` int AUTO_INCREMENT NOT NULL,
	`actorUserId` int,
	`action` varchar(64) NOT NULL,
	`entityType` varchar(32) NOT NULL,
	`entityId` int,
	`keyPreview` varchar(64),
	`details` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `audit_logs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `referrals` ADD `expiresAt` timestamp NULL;
--> statement-breakpoint
UPDATE `referrals` SET `expiresAt` = DATE_ADD(`createdAt`, INTERVAL 30 DAY) WHERE `expiresAt` IS NULL;
--> statement-breakpoint
ALTER TABLE `referrals` MODIFY `expiresAt` timestamp NOT NULL;
--> statement-breakpoint
ALTER TABLE `users` ADD `accessExpiresAt` timestamp NULL;
