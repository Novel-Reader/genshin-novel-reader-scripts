CREATE DATABASE IF NOT EXISTS novel CHARACTER SET utf8mb4;

USE novel;

CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `book` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `cover_photo` varchar(255) DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `brief` varchar(300) DEFAULT NULL,
  `detail` longtext DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `price` decimal(11,2) DEFAULT NULL,
  `size` int unsigned NOT NULL DEFAULT 0 COMMENT 'Content length in UTF-16 code units (JavaScript String.length)',
  `tag` varchar(50) DEFAULT NULL,
  `download_count` int DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `comment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `book_id` int DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `detail` longtext DEFAULT NULL,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `user_book` (
  `userid` int NOT NULL,
  `bookid` int NOT NULL,
  UNIQUE KEY `uk_user_book` (`userid`, `bookid`),
  CONSTRAINT `fk_userid` FOREIGN KEY (`userid`) REFERENCES `user` (`id`),
  CONSTRAINT `fk_bookid` FOREIGN KEY (`bookid`) REFERENCES `book` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `download_info` (
  `userid` int NOT NULL,
  `bookid` int NOT NULL,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_download_info_user_book` (`userid`, `bookid`),
  CONSTRAINT `download_info_user_foreign_key` FOREIGN KEY (`userid`) REFERENCES `user` (`id`),
  CONSTRAINT `download_info_book_foreign_key` FOREIGN KEY (`bookid`) REFERENCES `book` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
