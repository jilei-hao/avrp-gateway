create or replace function fn_create_user (
  _username varchar(50),
  _password_hash varchar,
  _role_name varchar(50) default 'end-user'
)
returns int
as
$$
declare
  new_user_id int;
  user_role_id int;
begin
  if _username = '' or _username is null then
    raise exception 'Username cannot be empty or null!';
  end if;

  if _password_hash = '' or _password_hash is null then
    raise exception 'PasswordHash cannot be empty or null!';
  end if;

  -- validation
  if not exists (
    select 1 from user_role
    where role_name = _role_name
  ) then
    raise exception 'Invalid UserRole: %', _role_name;
  else
    select ur.user_role_id into user_role_id
    from user_role ur
    where ur.role_name = _role_name;
  end if;

  -- start inserting

  insert into users (username, user_role_id, password_hash)
  values(_username, user_role_id, _password_hash)
  returning user_id into new_user_id;

  return new_user_id;
end;
$$
language plpgsql;