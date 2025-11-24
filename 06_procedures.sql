create or replace procedure delete_user(p_user_id int)
    language plpgsql
as
$$
begin
    delete from tasks where owner_id = p_user_id;
    delete from project_members where user_id = p_user_id;
    delete from users where id = p_user_id;

    commit;
end;
$$;


create or replace function transfer_tasks_to_user(
    p_old_user_id int,
    p_new_user_id int
)
    language plpgsql
as
$$
begin
    update tasks
    set owner_id = p_new_user_id
    where owner_id = p_old_user_id;

    update task_assignees
    set user_id = p_new_user_id
    where user_id = p_old_user_id;

    commit;
end;
$$;


create or replace procedure mark_project_tasks_as_done(p_project_id int)
    language plpgsql
as
$$
begin
    update tasks
    set status_id = (select id from statuses where name = 'Done')
    where project_id = p_project_id;

    commit;
end;
$$;


create or replace procedure proc_archive_expired_tasks(out updated_count int)
    language plpgsql
as
$$
declare
    archived_status_id int;
begin
    select id into archived_status_id from statuses where name = 'archived';

    update tasks
    set status_id = archived_status_id
    where deadline < now()
      and status_id != archived_status_id;

    get diagnostics updated_count = ROW_COUNT;
end;
$$;


create or replace procedure mark_project_tasks_as_done(
    p_project_id int,
    out updated_count int
)
    language plpgsql
as
$$
declare
    done_status_id int;
begin
    begin
        select id
        into done_status_id
        from statuses
        where name = 'done';

        if done_status_id is null then
            raise exception 'статус "done" не знайдено!';
        end if;

        update tasks
        set status_id = done_status_id
        where project_id = p_project_id
          and status_id != done_status_id;

        get diagnostics updated_count = row_count;

        if updated_count = 0 then
            raise notice 'задач для оновлення не знайдено.';
            rollback;
            return;
        end if;

        commit;
        raise notice 'позначено як done % задач', updated_count;

    exception
        when others then
            rollback;
            raise notice 'сталася помилка, операція скасована';
    end;
end;
$$;


create or replace procedure increase_project_tasks_priority(
    p_project_id int,
    out updated_count int
)
    language plpgsql
as
$$
begin
    begin
        update tasks
        set priority = least(priority + 1, 5)
        where project_id = p_project_id
          and priority < 5;

        get diagnostics updated_count = row_count;

        if updated_count = 0 then
            raise notice 'задач для підвищення пріоритету не знайдено.';
            rollback;
            return;
        end if;

        commit;
        raise notice 'підвищено пріоритет % задач', updated_count;

    exception
        when others then
            rollback;
            raise notice 'сталася помилка, операція скасована';
    end;
end;
$$;
