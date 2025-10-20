create table users
(
    id            serial primary key,
    name          varchar(255) not null,
    surname       varchar(255),
    login         varchar(255) not null,
    password_hash varchar(255) not null,
    salt          varchar(255) not null,
    created_at    timestamp not null default current_timestamp
);

create table statuses
(
    id    serial primary key,
    name  varchar(50) not null,
    color varchar(7)
);

create table categories
(
    id    serial primary key,
    name  varchar(50) not null,
    color varchar(7) not null
);

create table projects
(
    id          serial primary key,
    owner_id    integer not null,
    name        varchar(100) not null,
    description varchar(500),
    start_date  timestamp not null,
    end_date    timestamp not null,

    constraint fk_projects_owner foreign key (owner_id) references users(id)
);

create table project_roles
(
    id   serial primary key,
    name varchar(50) not null
);

create table project_members
(
    id         serial primary key,
    project_id integer not null,
    user_id    integer not null,
    role_id    integer not null,
    joined_at  timestamp not null default current_timestamp,

    constraint fk_project_members_user foreign key (user_id) references users(id),
    constraint fk_project_members_project foreign key (project_id) references projects(id),
    constraint fk_project_members_role foreign key (role_id) references project_roles(id)
);

create table tasks
(
    id              serial primary key,
    owner_id        integer not null,
    status_id       integer not null,
    category_id     integer,
    project_id      integer,
    title           varchar(50) not null,
    description     varchar(250),
    priority        integer,
    deadline        timestamp,
    created_at      timestamp not null default current_timestamp,
    updated_at      timestamp not null default current_timestamp,
    estimated_hours integer not null default 0,
    actual_hours    integer not null default 0,

    constraint fk_tasks_owner foreign key (owner_id) references users(id),
    constraint fk_tasks_status foreign key (status_id) references statuses(id),
    constraint fk_tasks_category foreign key (category_id) references categories(id),
    constraint fk_tasks_project foreign key (project_id) references projects(id),
    constraint check_priority check (priority between 1 and 5)
);

create table task_assignees
(
    id      serial primary key,
    task_id integer not null,
    user_id integer not null,

    constraint fk_task_assignees_user foreign key (user_id) references users(id),
    constraint fk_task_assignees_task foreign key (task_id) references tasks(id)
);

create table comments
(
    id         serial primary key,
    task_id    integer not null,
    user_id    integer not null,
    content    varchar(1000) not null,
    created_at timestamp not null default current_timestamp,

    constraint fk_comments_user foreign key (user_id) references users(id),
    constraint fk_comments_task foreign key (task_id) references tasks(id)
);

create index ix_tasks_project_status on tasks(project_id, status_id);
create index ix_tasks_owner on tasks(owner_id);
create index ix_tasks_deadline on tasks(deadline);
create index ix_comments_task on comments(task_id);
create index ix_project_members_project on project_members(project_id);
create index ix_task_assignees_task on task_assignees(task_id);