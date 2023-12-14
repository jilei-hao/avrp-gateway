create or replace function fn_create_study (
  _study_name varchar(50),
  _case_id int,
  _main_image_id int,
  _tp_start int,
  _tp_end int,
  _sys_propagation_seg_id int,
  _sys_propagation_tp_ref int,
  _sys_propagation_tp_start int,
  _sys_proapgation_tp_end int,
  _dias_propagation_seg_id int,
  _dias_propagation_tp_ref int,
  _dias_propagation_tp_start int,
  _dias_proapgation_tp_end int,
  _is_ready boolean, -- determines if the study is ready for processing
  _user_id int -- check if the user is allowed to create the study for the case
)
returns int
as
$$
declare
  new_study_id int;
  systolic_propagation_type_id int;
  diastolic_propagation_type_id int;
  study_status_id int;
begin
  -- validation
  if not exists (select 1 from surgery_case where case_id = _case_id) then
    raise exception 'Invalid case_id: %', _case_id;
  end if;

  if not exists (select 1 from image_header where image_id = _main_image_id) then
    raise exception 'Invalid main image: %', _main_image_id;
  end if;

  if not exists (select 1 from image_header where image_id = _sys_propagation_seg_id) then
    raise exception 'Invalid systolic propagation segmentation: %', _sys_propagation_seg_id;
  end if;

  if not exists (select 1 from image_header where image_id = _dias_propagation_seg_id) then
    raise exception 'Invalid diastolic propagation segmentation: %', _dias_propagation_seg_id;
  end if;

  if not exists (select 1 from user_case_connection where user_id = _user_id and case_id = _case_id) then
    raise exception 'Invalid user_id: % or user does not have access to this case', _user_id;
  end if;

  -- get status id
  select study_status_id into study_status_id
  from study_status_lut
  where (_is_ready and (study_status_name = 'ReadyForProcess')) or
  ((not _is_ready) and (study_status_name = 'WaitingForInput'))
  limit 1;

  -- create study
  insert into study(case_id, main_image_id, study_name, time_point_start, time_point_end, study_status_id)
  values(_case_id, _main_image_id, _study_name, _tp_start, _tp_end, study_status_id)
  returning study_id into new_study_id;
  
  -- create systolic propagation
  select propagation_type_id into systolic_propagation_type_id
  from propagation_type_lut
  where propagation_type_name = 'Systolic';

  select propagation_type_id into diastolic_propagation_type_id
  from propagation_type_lut
  where propagation_type_name = 'Diastolic';

  insert into propagation_config 
  (study_id, main_image_id, propagation_type_id, reference_segmentation_id,
    time_point_ref, time_point_start, time_point_end)
  values
  (new_study_id, _main_image_id, systolic_propagation_type_id,  _sys_propagation_seg_id,
    _sys_propagation_tp_ref, _sys_propagation_tp_start, _sys_proapgation_tp_end),
  (new_study_id, _main_image_id, diastolic_propagation_type_id, _dias_propagation_seg_id,
    _dias_propagation_tp_ref, _dias_propagation_tp_start, _dias_proapgation_tp_end);

  return new_study_id;
end;
$$
language plpgsql;