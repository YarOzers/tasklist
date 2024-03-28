DROP TABLE IF EXISTS category cascade ;
DROP TABLE IF EXISTS priority cascade ;
DROP TABLE IF EXISTS task cascade ;
DROP TABLE IF EXISTS stat;

CREATE TABLE category (
                          id serial primary key ,
                          title varchar(45) NOT NULL,
                          completed_count bigint DEFAULT 0,
                          uncompleted_count bigint DEFAULT 0
)  ;

INSERT INTO category VALUES (167,'Семья',1,2),(168,'Работа',1,1),(170,'Отдых',NULL,3),(171,'Путешествия',1,0),(179,'Спорт',2,0),(180,'Здоровье',1,2),(182,'Новая категория',0,0);




CREATE TABLE priority (
                          id serial primary key ,
                          title varchar(45) NOT NULL,
                          color varchar(45) NOT NULL
)  ;

INSERT INTO priority VALUES (56,'Низкий','#caffdd'),(57,'Средний','#883bdc'),(58,'Высокий','#f05f5f');




CREATE TABLE stat (
                      id serial primary key ,
                      completed_total bigint DEFAULT 0,
                      uncompleted_total bigint DEFAULT 0
)  ;





CREATE TABLE task (
                      id serial primary key ,
                      title varchar(100) NOT NULL,
                      completed int DEFAULT 0,
                      date timestamp(0) DEFAULT NULL,
                      priority_id bigint DEFAULT NULL,
                      category_id bigint DEFAULT NULL,
                      CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE SET NULL ON UPDATE RESTRICT,
                      CONSTRAINT fk_priority FOREIGN KEY (priority_id) REFERENCES priority (id) ON DELETE SET NULL ON UPDATE RESTRICT
)  ;

CREATE INDEX fk_category_idx ON task (category_id);
CREATE INDEX fk_priority_idx ON task (priority_id);
CREATE INDEX index_title ON task (title);
CREATE INDEX index_completed ON task (completed);
CREATE INDEX index_date ON task (date);



INSERT INTO task VALUES (328,'Позвонить родителям',1,'2020-04-29 15:27:11',58,167),(331,'Посмотреть мультики',0,'2020-04-27 15:27:29',57,167),(333,'Пройти курсы по Java',0,'2020-04-30 09:38:39',56,NULL),(338,'Сделать зеленый коктейль',0,'2020-04-27 15:27:34',56,180),(339,'Купить буханку хлеба',0,'2020-04-28 07:03:03',57,NULL),(341,'Позвонить начальнику',0,'2020-05-06 09:38:23',NULL,168),(342,'Померить давление',0,'2020-05-01 09:38:46',NULL,180),(343,'Начать бегать по утрам',1,NULL,56,179),(344,'Отжаться 100 раз',1,NULL,58,179),(349,'Найти развивающие игры для детей',0,'2020-04-29 09:38:51',57,167),(350,'Купить лекарство',1,'2020-04-30 09:38:43',56,180),(351,'Выучить Kotlin',0,'2020-05-06 09:38:37',58,NULL),(352,'Посмотреть ролики как построить дом',1,NULL,NULL,NULL),(353,'Посмотреть сериал',0,'2020-04-29 09:38:29',NULL,170),(354,'Съездить на природу',0,'2020-04-15 18:00:00',NULL,170),(355,'Создать список стран для путешествий',1,'2020-04-29 09:38:26',NULL,171),(356,'Доделать отчеты',1,'2020-04-30 09:38:20',NULL,168),(358,'Задача по категории',0,'2020-05-01 12:01:18',58,170);



/*!50003 CREATE*/ /* SQLINES DEMO *** ot`@`localhost`*/ /* SQLINES DEMO *** sk_AFTER_INSERT` AFTER INSERT ON `task` FOR EACH ROW BEGIN

	/* можно было упаковать все условия в один if-else, но тогда он становится не очень читабельным */

    /* SQLINES DEMO *** я НЕПУСТАЯ                и       статус задачи ЗАВЕРШЕН */
    if (ifnull(NEW.category_id, 0)>0      &&      ifnull(NEW.completed, 0)=1) then
		update tasklist.category set completed_count = (ifnull(completed_count, 0)+1) where id = NEW.category_id;
	end if;

	/* SQLINES DEMO *** я НЕПУСТАЯ                 и       статус задачи НЕЗАВЕРШЕН */
    if (ifnull(NEW.category_id, 0)>0      &&      ifnull(NEW.completed, 0)=0) then
		update tasklist.category c set uncompleted_count = (ifnull(uncompleted_count, 0)+1) where id = NEW.category_id;
	end if;


    /* SQLINES DEMO *** тистика */
	case when ifnull(NEW.completed, 0)=1 then
		update tasklist.stat completed_total := (ifnull(completed_total, 0)+1)  where id=1;
	else
		update tasklist.stat set uncompleted_total = (ifnull(uncompleted_total, 0)+1)  where id=1;
    end if;

/*!50003 CREATE*/ /* SQLINES DEMO *** ot`@`localhost`*/ /* SQLINES DEMO *** sk_AFTER_UPDATE` AFTER UPDATE ON `task` FOR EACH ROW BEGIN


  /* изменили completed на 1, НЕ изменили категорию */
    IF (   ifnull(old.completed,0) <> ifnull(new.completed,0)  &&   new.completed=1      &&   ifnull(old.category_id,0) = ifnull(new.category_id,0)     ) THEN

		/* SQLINES DEMO *** ии кол-во незавершенных уменьшится на 1,  кол-во завершенных увеличится на 1 */
		update tasklist.category set uncompleted_count = (ifnull(uncompleted_count, 0)-1), completed_count = (ifnull(completed_count,0)+1) where id = old.category_id;

        /* SQLINES DEMO *** тистика */
		update tasklist.stat set uncompleted_total = (ifnull(uncompleted_total,0)-1), completed_total = (ifnull(completed_total,0)+1)  where id=1;


	END IF;


    /* SQLINES DEMO *** completed на 0, НЕ изменили категорию */
    IF (   ifnull(old.completed,0) <> ifnull(new.completed,0)    &&   new.completed=0       &&   ifnull(old.category_id,0) = ifnull(new.category_id,0)   ) THEN

		/* SQLINES DEMO *** ии кол-во завершенных уменьшится на 1, кол-во незавершенных увеличится на 1 */
		update tasklist.category set completed_count = (ifnull(completed_count,0)-1), uncompleted_count = (ifnull(uncompleted_count,0)+1) where id = old.category_id;

       /* SQLINES DEMO *** тистика */
		update tasklist.stat set completed_total = (ifnull(completed_total,0)-1), uncompleted_total = (ifnull(uncompleted_total,0)+1)  where id=1;


	END IF;



	/* SQLINES DEMO *** категорию для неизмененного completed=1 */
    IF (   ifnull(old.completed,0) = ifnull(new.completed,0)    &&   new.completed=1       &&   ifnull(old.category_id,0) <> ifnull(new.category_id,0)    ) THEN

		/* SQLINES DEMO *** �атегории кол-во завершенных уменьшится на 1 */
		update tasklist.category set completed_count = (ifnull(completed_count,0)-1) where id = old.category_id;


		/* SQLINES DEMO *** �тегории кол-во завершенных увеличится на 1 */
		update tasklist.category set completed_count = (ifnull(completed_count,0)+1) where id = new.category_id;


		/* SQLINES DEMO *** тистика не изменяется */

	END IF;





    /* SQLINES DEMO *** категорию для неизменнеого completed=0 */
    IF (   ifnull(old.completed,0) = ifnull(new.completed,0)     &&   new.completed=0      &&   ifnull(old.category_id,0) <> ifnull(new.category_id,0)     ) THEN

		/* SQLINES DEMO *** �атегории кол-во незавершенных уменьшится на 1 */
		update tasklist.category set uncompleted_count = (ifnull(uncompleted_count,0)-1) where id = old.category_id;

		/* SQLINES DEMO *** �тегории кол-во незавершенных увеличится на 1 */
		update tasklist.category set uncompleted_count = (ifnull(uncompleted_count,0)+1) where id = new.category_id;

       /* SQLINES DEMO *** тистика не изменяется */

	END IF;






    /* SQLINES DEMO *** категорию, изменили completed с 1 на 0 */
    IF (   ifnull(old.completed,0) <> ifnull(new.completed,0)     &&   new.completed=0      &&   ifnull(old.category_id,0) <> ifnull(new.category_id,0)     ) THEN

		/* SQLINES DEMO *** �атегории кол-во завершенных уменьшится на 1 */
		update tasklist.category set completed_count = (ifnull(completed_count,0)-1) where id = old.category_id;

		/* SQLINES DEMO *** �тегории кол-во незавершенных увеличится на 1 */
		update tasklist.category set uncompleted_count = (ifnull(uncompleted_count,0)+1) where id = new.category_id;


		/* SQLINES DEMO *** тистика */
		update stat set uncompleted_total = (ifnull(uncompleted_total,0)+1), completed_total = (ifnull(completed_total,0)-1)  where id=1;


	END IF;



    /* SQLINES DEMO *** категорию, изменили completed с 0 на 1 */
    IF (   ifnull(old.completed,0) <> ifnull(new.completed,0)     &&   new.completed=1      &&   ifnull(old.category_id,0) <> ifnull(new.category_id,0)     ) THEN

		/* SQLINES DEMO *** �атегории кол-во незавершенных уменьшится на 1 */
		update tasklist.category set uncompleted_count = (ifnull(uncompleted_count,0)-1) where id = old.category_id;

		/* SQLINES DEMO *** �тегории кол-во завершенных увеличится на 1 */
		update tasklist.category set completed_count = (ifnull(completed_count,0)+1) where id = new.category_id;

        /* SQLINES DEMO *** тистика */
		update tasklist.stat set uncompleted_total = (ifnull(uncompleted_total,0)-1), completed_total = (ifnull(completed_total,0)+1)  where id=1;

	END IF;

