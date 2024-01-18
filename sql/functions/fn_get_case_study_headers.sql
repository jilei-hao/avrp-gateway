create or replace function fn_get_case_study_headers (
  _user_id int
)
returns table (
  case_id int, 
  case_name varchar(50), 
  mrn varchar, 
  study_id int, 
  study_name varchar(50)
) 
as
$$
begin
  -- validation
  if not exists (
    select 1 from users
    where user_id = _user_id
  ) then
    raise exception 'Invalid user: %', _user_id;
  end if;
  
  return query
  select c.case_id, c.case_name, c.mrn, s.study_id, s.study_name
  from surgery_case as c
  join user_case_connection ucx on c.case_id = ucx.case_id
  left join study s on c.case_id = s.case_id
  where ucx.user_id = _user_id;
end;
$$
language plpgsql;