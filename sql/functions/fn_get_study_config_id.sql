-- language: plpgsql
-- function to get the study-config id from a study id
-- returns 0 if study-config not found
-- (todo: change when one study can have multiple configs)

create or replace function fn_get_study_config_id(
  p_study_id int
)
returns int
as $$
declare
  v_study_config_id int;
begin
  -- validate study_id
  if p_study_id is null then
    raise exception 'study_id cannot be null';
  end if;

  -- get study_config_id
  select study_config_id into v_study_config_id from study_config where study_id = p_study_id;
  if v_study_config_id is null then
    return 0;
  end if;

  return v_study_config_id;
end;
$$ language plpgsql;
