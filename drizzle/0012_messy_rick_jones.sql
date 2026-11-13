CREATE TABLE `system_announcements` (
	`id` int NOT NULL,
	`version` int NOT NULL DEFAULT 1,
	`enabled` boolean NOT NULL DEFAULT false,
	`title` varchar(80) NOT NULL DEFAULT 'SYSTEM ANNOUNCEMENT',
	`message` varchar(300) NOT NULL DEFAULT '',
	`start_at` timestamp,
	`end_at` timestamp,
	`display_mode` enum('every_login','once_per_day') NOT NULL DEFAULT 'every_login',
	`text_size` enum('small','normal','large','festival_large') NOT NULL DEFAULT 'normal',
	`updated_by_user_id` int,
	`created_at` timestamp NOT NULL DEFAULT (now()),
	`updated_at` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `system_announcements_id` PRIMARY KEY(`id`)
);
