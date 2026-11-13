CREATE TABLE `device_bindings` (
	`id` int AUTO_INCREMENT NOT NULL,
	`licenseKeyId` int NOT NULL,
	`deviceHash` varchar(128) NOT NULL,
	`firstSeenAt` timestamp NOT NULL DEFAULT (now()),
	`lastSeenAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `device_bindings_id` PRIMARY KEY(`id`),
	CONSTRAINT `device_bindings_deviceHash_unique` UNIQUE(`deviceHash`)
);
--> statement-breakpoint
CREATE TABLE `license_keys` (
	`id` int AUTO_INCREMENT NOT NULL,
	`keyValue` varchar(128) NOT NULL,
	`status` enum('active','banned') NOT NULL DEFAULT 'active',
	`expiresAt` timestamp NOT NULL,
	`maxDevices` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `license_keys_id` PRIMARY KEY(`id`),
	CONSTRAINT `license_keys_keyValue_unique` UNIQUE(`keyValue`)
);
