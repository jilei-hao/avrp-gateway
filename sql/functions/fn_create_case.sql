create or replace function fn_create_case (
  _case_name varchar(50),
  _user_id int,
  _mrn varchar = ''
  
)
returns int
as
$$
declare
  new_case_id int;
begin
  -- start inserting
  -- cases
  insert into surgery_case (case_name, mrn)
  values(_case_name, _mrn)
  returning case_id into new_case_id;

  -- user case connection
  insert into user_case_connection (user_id, case_id) 
  values(_user_id, new_case_id);

  return new_case_id;
end;
$$
language plpgsql;