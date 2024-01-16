-- language: plpgsql
-- function to insert new study

create or replace function fn_create_study (
  p_case_id int,
  p_study_name varchar(50),
  days_since_last_study int = 0
) 
returns int
as $$
declare
  new_study_id int;
begin
  -- validate if case id exists
  if not exists (select 1 from surgery_case where case_id = p_case_id) then
    raise exception 'Invalid case_id: %', p_case_id;
  end if;

  -- insert new study
  insert into study(case_id, study_name, days_since_last_study, created_at, last_modified_at)
  values(p_case_id, p_study_name, days_since_last_study, now(), now())
  returning study_id into new_study_id;
  return new_study_id;
end;
$$ language plpgsql;