ALTER TABLE `book` ADD `download_count` INT DEFAULT 0;

CREATE TABLE `download_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` INT NOT NULL,
  `bookid` INT NOT NULL,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

alter table download_info add constraint download_info_user_foreign_key foreign key (userid) references user(id);
alter table download_info add constraint download_info_book_foreign_key foreign key (bookid) references book(id);
