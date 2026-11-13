ALTER TABLE `licenses` MODIFY COLUMN `expires_at` timestamp;--> statement-breakpoint
ALTER TABLE `licenses` ADD `activated_at` timestamp;--> statement-breakpoint
ALTER TABLE `licenses` ADD `duration_minutes` int;