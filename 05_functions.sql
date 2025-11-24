create or replace function get_count_user_tasks(p_user_id int)
    returns int
as
$$
begin
    return (select count(t.id)
            from tasks t
            where t.owner_id = p_user_id);
end;
$$ language plpgsql;


create or replace function delete_all_user_tasks(p_user_id int)
    returns boolean
as
$$
declare
    deleted_rows int;
begin
    delete from tasks t where t.owner_id = p_user_id;
    get diagnostics deleted_rows = row_count;
    return deleted_rows > 0;
end;
$$ language plpgsql;


create or replace function get_projects_comments(p_project_id int)
    returns table
            (
                comment_id  int,
                task_id     int,
                author_id   int,
                author_name varchar,
                content     varchar,
                created_at  timestamp
            )
as
$$
begin
    return query select c.id,
                        c.task_id,
                        u.id,
                        u.name,
                        c.content,
                        c.created_at
                 from comments c
                          join tasks t on c.task_id = t.id
                          join users u on c.user_id = u.id
                 where t.project_id = p_project_id
                 order by c.created_at desc;
end;
$$ language plpgsql;


create or replace function get_project_members(p_project_id int)
    returns table
            (
                user_id      int,
                user_name    varchar,
                user_surname varchar,
                role_name    varchar,
                joined_at    timestamp
            )
as
$$
begin
    return query select u.id,
                        u.name,
                        u.surname,
                        r.name,
                        pm.joined_at
                 from project_members pm
                          join users u on pm.user_id = u.id
                          join project_roles r on pm.role_id = r.id
                 where pm.project_id = p_project_id
                 order by pm.joined_at;
end;
$$ language plpgsql;


create or replace function get_user_tasks(p_user_id int)
    returns table
            (
                task_id       integer,
                title         varchar,
                description   varchar,
                status_name   varchar,
                category_name varchar,
                project_name  varchar,
                deadline      timestamp,
                assigned      boolean
            )
AS
$$
begin
    return query
        select t.id,
               t.title,
               t.description,
               s.name                                                    AS status_name,
               c.name                                                    AS category_name,
               p.name                                                    AS project_name,
               t.deadline,
               CASE WHEN ta.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS assigned
        from tasks t
                 join statuses s on t.status_id = s.id
                 join categories c on t.category_id = c.id
                 join projects p on t.project_id = p.id
                 join task_assignees ta on t.id = ta.task_id and ta.user_id = p_user_id;
end;
$$ language plpgsql;
