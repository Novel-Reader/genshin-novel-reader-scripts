CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `book` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `cover_photo` varchar(255) DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `brief` varchar(300) DEFAULT NULL,
  `detail` longtext DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `price` decimal(11,2) DEFAULT NULL,
  `size` int NOT NULL,
  `tag` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `comment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `book_id` int DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `detail` longtext DEFAULT NULL,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
