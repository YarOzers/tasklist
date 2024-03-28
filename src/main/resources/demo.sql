CREATE OR REPLACE FUNCTION public.after_insert()
    RETURNS trigger AS
$BODY$
BEGIN
    --     NEW.name = concat(new.first_name,' ', new.last_name);
    if new.category_id > 0 and new.completed = 1 then
        update tasklist.public.category set completed_count = completed_count + 1 where category.id = new.category_id;
    end if;
    if NEW.category_id > 0 and NEW.completed = 0 then
        update tasklist.public.category c set uncompleted_count = uncompleted_count + 1 where id = NEW.category_id;
        RETURN new;
    end if;
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

CREATE TRIGGER "update_users_name_on_insert_trigger"
    after insert
    ON tasklist.public.task
    FOR EACH ROW
EXECUTE PROCEDURE "after_insert"();

-- CREATE OR REPLACE FUNCTION public.after_apdate()
--     RETURNS trigger AS
-- $BODY$
-- BEGIN
--     --     NEW.name = concat(new.first_name,' ', new.last_name);
--     if new.category_id > 0 and new.completed = 1 then
--         update tasklist.public.category set completed_count = completed_count + 1 where category.id = new.category_id;
--     end if;
--     if NEW.category_id > 0 and NEW.completed = 0 then
--         update tasklist.public.category c set uncompleted_count = uncompleted_count + 1 where id = NEW.category_id;
--         RETURN new;
--     end if;
--     if new.completed = 1 then
--         update tasklist.public.stat set completed_total = completed_total + 1 where  id=1;
--     else
--         update tasklist.public.stat set uncompleted_total = uncompleted_total +1 where id=1;
--     end if;
-- end
-- $BODY$
--     LANGUAGE plpgsql VOLATILE
--                      COST 100;


