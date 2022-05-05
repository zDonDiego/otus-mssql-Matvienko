create database [project_matvienko];
go

use project_matvienko;
go

create table route(
	id int not null identity(1, 1) primary key,
	Name varchar(50),
	DateLast date);
go

create table driver(
	id int not null identity(1, 1) primary key,
	Name varchar(50),
	Number varchar(11),
	idRoute int);
go

create table schedule(
	id int not null identity(1, 1) primary key,
	Date date,
	idRoute int,
	idDriver int);
go

create table curator(
	id int not null identity(1, 1) primary key,
	Name varchar(50),
	Number varchar(11));
go

alter table driver add constraint FK_v_rt foreign key(idRoute)
references route(id);
go

alter table schedule add constraint FK_v_rt2 foreign key(idRoute)
references route(id);
go

alter table schedule add constraint FK_v_drv foreign key(idDriver)
references driver(id);
go

create index idx_drv on driver (name);
go

create index idx_rt on route (name);
go




