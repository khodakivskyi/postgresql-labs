create or replace function update_task_timestamp()
    returns trigger
    language plpgsql
as
$$
begin
    new.updated_at := now();
    return new;
end;
$$;


create or replace function trg_set_default_task_status()
    returns trigger
    language plpgsql
as $$
declare
    new_status_id int;
begin
    if new.status_id is null then
        select id into new_status_id
        from statuses
        where name = 'new';

        if new_status_id is null then
            raise exception 'статус "new" не знайдено!';
        end if;

        new.status_id := new_status_id;
    end if;

    return new;
end;
$$;


create table task_status_log (
                                 id serial primary key,
                                 task_id int not null,
                                 old_status int,
                                 new_status int,
                                 changed_at timestamp default now()
);

create or replace function trg_log_task_status_change()
    returns trigger
    language plpgsql
as $$
begin
    if new.status_id != old.status_id then
        insert into task_status_log(task_id, old_status, new_status)
        values (old.id, old.status_id, new.status_id);
    end if;

    return new;
end;
$$;


create or replace function trg_cleanup_user_memberships()
    returns trigger
    language plpgsql
as $$
begin
    delete from project_members where user_id = old.id;
    return old;
end;
$$;


create or replace function trg_update_task_timestamp()
    returns trigger
    language plpgsql
as $$
begin
    new.updated_at := now();
    return new;
end;
$$;



create trigger update_task_timestamp
    before update on tasks
    for each row
execute function trg_update_task_timestamp();

create trigger cleanup_user_memberships
    before delete on users
    for each row
execute function trg_cleanup_user_memberships();

create trigger log_task_status_change
    after update on tasks
    for each row
execute function trg_log_task_status_change();

create trigger set_default_task_status
    before insert on tasks
    for each row
execute function trg_set_default_task_status();

create trigger trg_update_task_timestamp
    before update
    on tasks
    for each row
execute function update_task_timestamp();