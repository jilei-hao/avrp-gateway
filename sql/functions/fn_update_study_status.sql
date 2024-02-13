-- language: plpgsql

CREATE OR REPLACE FUNCTION fn_update_study_status(
  p_study_id int,
  p_study_status_name varchar(50),
  p_module_status bigint
)
RETURNS void AS
$$
declare
  v_study_status_id int;
begin
  -- get study status id
  select study_status_id into v_study_status_id
  from study_status_lut
  where study_status_name = p_study_status_name;

  if (v_study_status_id is null) then
    raise exception 'Invalid study status name %', p_study_status_name;
  end if;

  -- update study status
  update study
  set study_status_id = v_study_status_id,
      module_status = p_module_status,
      last_modified_at = now()
  where study_id = p_study_id;
end
$$
LANGUAGE plpgsql;