create or replace function fn_get_user_info (
  _username varchar(50)
)
returns table (user_id int, password_hash varchar, role_name varchar(50))
as
$$
begin
  -- validation
  if not exists (
    select 1 from users
    where username = _username
  ) then
    raise exception 'Invalid username: %', _username;
  end if;
  
  return query
  select u.user_id, u.password_hash, ur.role_name
  from users as u
  join user_role as ur
  on u.user_role_id = ur.user_role_id
  where u.username = _username;
end;
$$
language plpgsql;