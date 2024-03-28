CREATE OR REPLACE FUNCTION public.after_insert()
    RETURNS trigger AS
$BODY$
BEGIN
--     категория непустая и статус задачи  завершен

    if new.category_id > 0 and new.completed = 1 then
        update tasklist.public.category set completed_count = completed_count + 1 where category.id = new.category_id;
    end if;
        -- категория непустая и статус задачи не завершен
    if NEW.category_id > 0 and NEW.completed = 0 then
        update tasklist.public.category c set uncompleted_count = uncompleted_count + 1 where id = NEW.category_id;
        RETURN new;
    end if;

        -- общая статистика
    if new.completed = 1 then
        update tasklist.public.stat set completed_total = completed_total + 1 where  id=1;
        else
        update tasklist.public.stat set uncompleted_total = uncompleted_total +1 where id=1;
        end if;
    end
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

-- СОЗДАНИЕ ТРИГГЕРА

CREATE TRIGGER "upd_task_aft_ins"
    after insert
    ON tasklist.public.task
    FOR EACH ROW
EXECUTE PROCEDURE "after_insert"();
------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
------task after update
CREATE OR REPLACE FUNCTION public.after_update()
    RETURNS trigger AS
$BODY$
    BEGIN
    /* изменили completed на 1, НЕ изменили категорию */
    if old.completed != new.completed  and  new.completed=1      and  old.category_id = new.category_id    THEN
        /* у категории кол-во незавершенных уменьшится на 1,  кол-во завершенных увеличится на 1 */
		update tasklist.public.category set uncompleted_count = uncompleted_count-1, completed_count = completed_count+1 where id = old.category_id;
        /* общая статистика */
		update tasklist.public.stat set uncompleted_total = uncompleted_total-1, completed_total = completed_total+1 where id=1;
	END IF;
    /* изменили completed на 0, НЕ изменили категорию */
    IF old.completed != new.completed    and   new.completed=0      and   old.category_id = new.category_id    then
		/* у категории кол-во завершенных уменьшится на 1, кол-во незавершенных увеличится на 1 */
		update tasklist.public.category set completed_count = completed_count-1, uncompleted_count = uncompleted_count+1 where id = old.category_id;
       /* общая статистика */
		update tasklist.public.stat set completed_total = completed_total-1, uncompleted_total = uncompleted_total+1  where id=1;
	END IF;

	/* изменили категорию для неизмененного completed=1 */
    IF old.completed = new.completed    and   new.completed=1       and   old.category_id != new.category_id   THEN
        /* у старой категории кол-во завершенных уменьшится на 1 */
		update tasklist.public.category set completed_count = completed_count-1 where id = old.category_id;
		/* у новой категории кол-во завершенных увеличится на 1 */
		update tasklist.public.category set completed_count = completed_count+1 where id = new.category_id;
		/* общая статистика не изменяется */
	END IF;

    /* изменили категорию для неизменнеого completed=0 */
    IF old.completed = new.completed     and   new.completed=0      and   old.category_id <> new.category_id      THEN
		/* у старой категории кол-во незавершенных уменьшится на 1 */
		update tasklist.public.category set uncompleted_count = uncompleted_count-1 where id = old.category_id;
		/* у новой категории кол-во незавершенных увеличится на 1 */
		update tasklist.public.category set uncompleted_count = uncompleted_count+1 where id = new.category_id;
       /* общая статистика не изменяется */
	END IF;

    /* изменили категорию, изменили completed с 1 на 0 */
    IF old.completed != new.completed     and   new.completed=0      and   old.category_id != new.category_id     THEN
		/* у старой категории кол-во завершенных уменьшится на 1 */
		update tasklist.public.category set completed_count = completed_count-1 where id = old.category_id;
		/* у новой категории кол-во незавершенных увеличится на 1 */
		update tasklist.public.category set uncompleted_count = uncompleted_count+1 where id = new.category_id;
	    /* общая статистика */
		update tasklist.public.stat set uncompleted_total = uncompleted_total+1, completed_total = completed_total-1  where id=1;
	END IF;

    /* изменили категорию, изменили completed с 0 на 1 */
    IF old.completed != new.completed     and   new.completed=1      and   old.category_id and new.category_id      THEN
		/* у старой категории кол-во незавершенных уменьшится на 1 */
		update tasklist.public.category set uncompleted_count = uncompleted_count-1 where id = old.category_id;
		/* у новой категории кол-во завершенных увеличится на 1 */
		update tasklist.public.category set completed_count = completed_count+1 where id = new.category_id;
        /* общая статистика */
		update tasklist.public.stat set uncompleted_total = uncompleted_total-1, completed_total = completed_total+1  where id=1;
	END IF;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
                     COST 100;


CREATE TRIGGER "upd_task_aft_upd"
    after insert
    ON tasklist.public.task
    FOR EACH ROW
EXECUTE PROCEDURE "after_update"();
----////////////////////////////////////////////////////////////////////////////////////////////////////////////
CREATE OR REPLACE FUNCTION public.after_delete()
    RETURNS  TRIGGER AS
$BODY$
    BEGIN
	/* можно было упаковать все условия в один if-else, но тогда он становится не очень читабельным */
    /*  категория НЕПУСТАЯ                 и        статус задачи ЗАВЕРШЕН */
    if old.category_id>0       and       old.completed=1 then
		update tasklist.public.category set completed_count = completed_count-1 where id = old.category_id;
	end if;
	/*  категория НЕПУСТАЯ                и         статус задачи НЕЗАВЕРШЕН */
    if old.category_id>0      and       old.completed=0 then
		update tasklist.public.category set uncompleted_count = uncompleted_count-1 where id = old.category_id;
	end if;
    /* общая статистика */
	if old.completed=1 then
		update tasklist.public.stat set completed_total = completed_total-1  where id=1;
	else
		update tasklist.public.stat set uncompleted_total = uncompleted_total-1  where id=1;
    end if;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE TRIGGER "upd_task_aft_del"
    after insert
    ON tasklist.public.task
    FOR EACH ROW
EXECUTE PROCEDURE "after_delete"();