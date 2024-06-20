-- language: plpgsql

CREATE OR REPLACE FUNCTION fn_update_study_status(
  p_study_id int
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
  _module_waiting_status_id int;
  _module_running_status_id int;
  _module_error_status_id int;
  _first_module_status_id int;
begin
  -- get study status ids
  select study_status_id into _waiting_status_id
  from study_status_lut
  where study_status_name = 'waiting';

  select study_status_id into _ready_status_id
  from study_status_lut
  where study_status_name = 'ready';

  select study_status_id into _running_status_id
  from study_status_lut
  where study_status_name = 'running';

  select study_status_id into _completed_status_id
  from study_status_lut
  where study_status_name = 'completed';

  select study_status_id into _error_status_id
  from study_status_lut
  where study_status_name = 'error';

  select study_module_status_id into _module_completed_status_id
  from study_module_status_lut
  where study_module_status_name = 'completed';

  select study_module_status_id into _module_waiting_status_id
  from study_module_status_lut
  where study_module_status_name = 'waiting';

  select study_module_status_id into _module_running_status_id
  from study_module_status_lut
  where study_module_status_name = 'running';

  select study_module_status_id into _module_error_status_id
  from study_module_status_lut
  where study_module_status_name = 'error';

  -- get the very first module status
  select sm.study_module_status_id into _first_module_status_id
  from study_module_status sm
  join module m on m.module_id = sm.module_id
  where sm.study_id = p_study_id
  order by m.module_precedence_rank
  limit 1;

  -- if the first module is waiting, then study is waiting
  if _first_module_status_id = _module_waiting_status_id then
    update study
    set study_status_id = _waiting_status_id,
        last_modified_at = now()
    where study_id = p_study_id;
    return;
  end if;

  -- if all modules are completed, then study is completed
  if not exists (
    select 1
    from study_module_status
    where study_id = p_study_id
    and study_module_status_id != _module_completed_status_id
  ) then
    update study
    set study_status_id = _completed_status_id,
        last_modified_at = now()
    where study_id = p_study_id;
    return;
  end if;


  -- if any module is running, then study is running
  if exists (
    select 1
    from study_module_status
    where study_id = p_study_id
    and study_module_status_id = _module_running_status_id
  ) then
    update study
    set study_status_id = _running_status_id,
        last_modified_at = now()
    where study_id = p_study_id;
    return;
  end if;

  -- if any module is error, then study is error
  if exists (
    select 1
    from study_module_status
    where study_id = p_study_id
    and study_module_status_id = _module_error_status_id
  ) then
    update study
    set study_status_id = _error_status_id,
        last_modified_at = now()
    where study_id = p_study_id;
    return;
  end if;

  -- if none of the above, then study is ready
  update study
  set study_status_id = _ready_status_id,
      last_modified_at = now()
  where study_id = p_study_id;
end
$$
LANGUAGE plpgsql;