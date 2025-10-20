select count(*) as total_users from users;
select u.id, u.name, count(*) as users_projects from projects p
    join users u on p.owner_id = u.id
    group by u.id, u.name
    order by users_projects desc;
select p.name, count(*) as project_tasks, avg(t.estimated_hours) from projects p
    join tasks t on  p.id = t.project_id
    group by p.id, p.name;
select u.name, u.surname, count(t.id) as tasks_count from users u
    join tasks t on t.owner_id = u.id
    group by u.id, u.name, u.surname
    having count(t.id) > 5;
select u.login, p.name, pr.name from users u
    join project_members pm on u.id = pm.user_id
    join projects p on p.id = pm.project_id
    join project_roles pr on pm.user_id = pr.id
    order by p.name desc;
select s.name, t.title, avg(t.actual_hours) from statuses s
    join tasks t on t.status_id = s.id
    group by s.id, s.name, t.title
    having avg(t.actual_hours) > 1;
select u.name, u.surname, count(pm.project_id) as user_projects from users u
    join project_members pm on pm.user_id = u.id
    group by u.id
    having count(distinct pm.project_id) >= 2;
select t.title, t.description, u.login as task_owner from tasks t
    join users u on t.owner_id = u.id
    where t.actual_hours > t.estimated_hours;
update tasks
    set status_id = (
        select id from statuses where name = 'To Do'
        )
    where deadline < now() and status_id != (
        select id from statuses where name = 'Done'
        );
update tasks t
    set status_id = s_todo.id
    from statuses s_todo
    join statuses s_done on s_done.name = 'Done'
    where t.deadline < now() and  t.status_id != s_done.id and s_todo.name = 'To Do';
delete from comments where user_id = (
    select id from users where login = 'login'
    );
