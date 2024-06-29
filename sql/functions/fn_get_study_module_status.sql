-- language: plpgsql
-- function to get all the study_module_status for a given study

create or replace function fn_get_study_module_status(
  p_study_id int
)
returns table (
  module_id int,
  module_name varchar(50),
  study_module_status varchar(50)
)
as $$
declare
  v_module_status varchar(50);
begin
  -- validate study_id
  if not exists (select 1 from study where study_id = p_study_id) then
    raise exception 'study_id % does not exist', p_study_id;
  end if;

  -- get study_module_status
  return query
  select sms.module_id, m.module_name, sms_lut.study_module_status_name as study_module_status
  from study_module_status sms
  left join module m on sms.module_id = m.module_id
  left join study_module_status_lut sms_lut on sms.study_module_status_id = sms_lut.study_module_status_id
  where sms.study_id = p_study_id
  order by sms.module_id;
end;
$$ language plpgsql;