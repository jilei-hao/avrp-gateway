-- language: plpgsql

CREATE OR REPLACE FUNCTION fn_update_study_status(
  p_study_id int,
)
RETURNS void AS
$$
declare
  _waiting_status_id int;
  _ready_status_id int;
  _running_status_id int;
  _completed_status_id int;
  _error_status_id int;
  _module_completed_status_id int;
  _first_module_id int; -- the very first module
begin
  -- get study status ids
  select study_status_id into _waiting_status_id
  from study_status_lut
  where study_status_name = 'waiting'

  select study_status_id into _ready_status_id
  from study_status_lut
  where study_status_name = 'ready'

  select study_status_id into _running_status_id
  from study_status_lut
  where study_status_name = 'running'

  select study_status_id into _completed_status_id
  from study_status_lut
  where study_status_name = 'completed'

  select study_status_id into _error_status_id
  from study_status_lut
  where study_status_name = 'error'

  select study_module_status_id into _module_completed_status_id
  from study_module_status_lut
  where study_module_status_name = 'completed'

  select module_id into _first_module_id
  from module
  order by module_precedence_rank
  limit 1;

  -- if first module is waiting, then study is waiting

  -- if all modules are completed, then study is completed

  -- if any module is running, then study is running

  -- if any module is error, then study is error



  -- update study status
  update study
  set study_status_id = v_study_status_id,
      last_modified_at = now()
  where study_id = p_study_id;
end
$$
LANGUAGE plpgsql;