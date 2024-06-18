-- language: plpgsql
-- function to insert new study

create or replace function fn_create_study (
  p_case_id int,
  p_study_name varchar(50)
) 
returns int
as $$
declare
  new_study_id int;
  v_ready_status_id int;
begin
  -- validate if case id exists
  if not exists (select 1 from surgery_case where case_id = p_case_id) then
    raise exception 'Invalid case_id: %', p_case_id;
  end if;

  -- all study should start with ready-for-processing status
  select study_status_id into v_ready_status_id 
  from study_status_lut where study_status_name = 'ready-for-processing';


  -- insert new study
  insert into study(case_id, study_name, study_status_id, module_status, created_at, last_modified_at)
  values(p_case_id, p_study_name, v_ready_status_id, 0, now(), now())
  returning study_id into new_study_id;

  -- reset module status
  perform fn_reset_study_module_status(new_study_id);

  return new_study_id;
end;
$$ language plpgsql;