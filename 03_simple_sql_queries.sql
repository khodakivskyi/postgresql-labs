select id, title from tasks where id in (1,3);
select * from tasks order by priority desc;
select content from comments where user_id = 1 and task_id < 10;
select name, surname from users where login like '%admin%';
select id, name from projects where end_date between '2025-11-03' and '2025-11-08';
select users.name, tasks.title from users join tasks on users.id = owner_id;
select users.name, projects.name from users join projects on users.id = owner_id;
select projects.id, tasks.owner_id from projects join tasks on projects.id = tasks.project_id;
select
    users.name as author,
    tasks.title as task_title,
    comments.content,
    comments.created_at
    from comments
    join users on comments.user_id = users.id
    join tasks on comments.task_id = tasks.id;
select
    users.name,
    users.surname,
    projects.name as project_name,
    count(tasks.id) as high_priority_tasks
    from users
    join tasks on tasks.owner_id = users.id
    join projects on projects.id = tasks.project_id
    where tasks.priority = 1 and tasks.created_at >= now() - interval '30 days'
    group by users.id, users.name, users.surname, projects.id, projects.name
    order by high_priority_tasks desc;
select
    users.name,
    users.surname,
    (select count(*) from projects p where p.owner_id = users.id) as own_projects,
    (select count(*) from project_members pm where pm.user_id = users.id) as member_projects
    from users
    where users.created_at < current_date - interval '1 year';
