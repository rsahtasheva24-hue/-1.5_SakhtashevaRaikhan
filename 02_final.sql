CREATE DATABASE college_db;
create schema if not exists college_management;
set search_path to college_management;

drop table if exists grade cascade;
drop table if exists enrollment cascade;
drop table if exists course cascade;
drop table if exists student cascade;
drop table if exists teacher cascade;

CREATE TABLE if not exists
