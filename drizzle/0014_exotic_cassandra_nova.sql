CREATE TABLE `server_maintenance` (
	`id` int NOT NULL,
	`version` int NOT NULL DEFAULT 1,
	`enabled` boolean NOT NULL DEFAULT false,
	`title` varchar(80) NOT NULL DEFAULT 'SERVER MAINTENANCE',
	`message` varchar(300) NOT NULL DEFAULT '',
	`start_at` timestamp,
	`end_at` timestamp,
	`updated_by_user_id` int,
	`created_at` timestamp NOT NULL DEFAULT (now()),
	`updated_at` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `server_maintenance_id` PRIMARY KEY(`id`)
);
