create or replace function fn_create_user (
  _email varchar(50),
  _password_hash varchar,
  _role_name varchar(50) default 'EndUser'
)
returns int
as
$$
declare
  new_user_id int;
  user_role_id int;
begin
  if _email = '' or _email is null then
    raise exception 'Email cannot be empty or null!';
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

  insert into users (email, user_role_id, password_hash)
  values(_email, user_role_id, _password_hash)
  returning user_id into new_user_id;

  return new_user_id;
end;
$$
language plpgsql;