CREATE TABLE user_book(
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` INT NOT NULL,
  `bookid` INT NOT NULL,
  constraint fk_userid foreign key(userid) references user(id),
  constraint fk_bookid foreign key(bookid) references book(id),
  PRIMARY KEY (`id`)
);
