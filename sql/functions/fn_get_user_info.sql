create or replace function fn_get_user_info (
  _email varchar(50)
)
returns table (user_id int, password_hash varchar, role_name varchar(50))
as
$$
begin
  -- validation
  if not exists (
    select 1 from users
    where email = _email
  ) then
    raise exception 'Invalid email: %', _email;
  end if;
  
  return query
  select u.user_id, u.password_hash, ur.role_name
  from users as u
  join user_role as ur
  on u.user_role_id = ur.user_role_id
  where u.email = _email;
end;
$$
language plpgsql;