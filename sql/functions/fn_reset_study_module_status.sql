-- language: plpgsql
-- reset all module status to "waiting" for a given study
-- if the study module status record does not exist, create it

create or replace function fn_reset_study_module_status(
  _study_id int
)
returns void as $$
declare
  _waiting_status_id int;
begin
  -- validate study_id
  if not exists (select 1 from study where study_id = _study_id) then
    raise exception 'study_id % does not exist', _study_id;
  end if;

  select study_module_status_id into _waiting_status_id
  from study_module_status_lut
  where study_module_status_name = 'waiting'
  limit 1;

  delete from study_module_status
  where study_id = _study_id;

  -- insert new records (for all modules)
  insert into study_module_status (study_id, module_id, study_module_status_id)
  select _study_id, m.module_id, _waiting_status_id
  from module m;
end;
$$ language plpgsql;