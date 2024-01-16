-- language: plpgsql
-- function to insert new study config
create or replace function fn_create_study_config (
  p_study_id int,
  p_main_image_id bigint
) 
returns int
as $$
declare
  new_study_config_id int;
begin
  -- validate if study id exists
  if not exists (select 1 from study where study_id = p_study_id) then
    raise exception 'Invalid study_id: %', p_study_id;
  end if;

  -- validate if main image id exists
  if not exists (select 1 from image_header where image_header_id = p_main_image_id) then
    raise exception 'Invalid image_header_id: %', p_main_image_id;
  end if;

  -- insert new study config
  insert into study_config(study_id, main_image_id, created_at, last_modified_at)
  values(p_study_id, p_main_image_id, now(), now())
  returning study_config_id into new_study_config_id;
  return new_study_config_id;
end;
$$ language plpgsql;