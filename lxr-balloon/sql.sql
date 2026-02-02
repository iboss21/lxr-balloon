CREATE TABLE IF NOT EXISTS `balloon_buy` (
  `identifier` varchar(40) NOT NULL,
  `charid` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `balloon_rentals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `character_id` int(11) NOT NULL,
  `duration` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `balloon_passengers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `balloon_owner_id` varchar(50) NOT NULL,
  `balloon_owner_charid` int(11) NOT NULL,
  `passenger_id` varchar(50) NOT NULL,
  `passenger_charid` int(11) NOT NULL,
  `balloon_net_id` int(11) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_balloon_net_id` (`balloon_net_id`),
  KEY `idx_owner` (`balloon_owner_id`, `balloon_owner_charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;