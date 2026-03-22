-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR Balloon System - Database Schema
-- ═══════════════════════════════════════════════════════════════════════════════
-- Compatible with MySQL 5.7+, MySQL 8.0+, MySQL 9.x, and MariaDB 10.x+
-- All identifier/charid columns use VARCHAR to support both numeric and
-- string-based character IDs across frameworks (VORP, LXRCore, RSG-Core, etc.)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `balloon_buy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `charid` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_owner` (`identifier`, `charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `balloon_rentals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `character_id` varchar(50) NOT NULL,
  `duration` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_rental_owner` (`user_id`, `character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `balloon_passengers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `balloon_owner_id` varchar(50) NOT NULL,
  `balloon_owner_charid` varchar(50) NOT NULL,
  `passenger_id` varchar(50) NOT NULL,
  `passenger_charid` varchar(50) NOT NULL,
  `balloon_net_id` int NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_balloon_net_id` (`balloon_net_id`),
  KEY `idx_owner` (`balloon_owner_id`, `balloon_owner_charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `balloon_damage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `balloon_owner_id` varchar(50) NOT NULL,
  `balloon_owner_charid` varchar(50) NOT NULL,
  `balloon_net_id` int NOT NULL,
  `hit_count` int DEFAULT 0,
  `is_damaged` tinyint(1) DEFAULT 0,
  `damage_time` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_balloon_net_id` (`balloon_net_id`),
  KEY `idx_owner` (`balloon_owner_id`, `balloon_owner_charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;