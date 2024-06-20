-- language: plpgsql
-- function to update the given module status for a given study

create or replace function fn_update_module_status (
  p_study_id int,
  p_module_id int,
  p_module_status varchar(50)
)
returns void
as $$
declare
  _module_status_id int;
begin
  -- validate study_id
  if not exists (select 1 from study where study_id = p_study_id) then
    raise exception 'study_id % does not exist', p_study_id;
  end if;

  -- validate module_id
  if not exists (select 1 from module where module_id = p_module_id) then
    raise exception 'module_id % does not exist', p_module_id;
  end if;

  -- validate module_status
  if not exists (select 1 from study_module_status_lut where study_module_status_name = p_module_status) then
    raise exception 'module_status % does not exist', p_module_status;
  end if;

  -- get module status id
  select study_module_status_id into _module_status_id
  from study_module_status_lut
  where study_module_status_name = p_module_status;

  -- update module status
  update study_module_status
  set study_module_status_id = _module_status_id
  where study_id = p_study_id
  and module_id = p_module_id;
end;
$$ language plpgsql;