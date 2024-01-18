create or replace function fn_get_studies_by_case (
  _case_id int,
  _user_id int
)
returns table (
  study_id int,
  study_name varchar(50),
  main_image_id int,
  main_image_path varchar,
  time_point_start int,
  time_point_end int,
  days_since_last_study int,
  study_status varchar(50),
  sys_propa_seg_image_id int,
  sys_propa_seg_image_path varchar,
  sys_propa_tp_ref int,
  sys_propa_tp_start int,
  sys_propa_tp_end int,
  dias_propa_seg_image_id int,
  dias_propa_seg_image_path varchar,
  dias_propa_tp_ref int,
  dias_propa_tp_start int,
  dias_propa_tp_end int
)
as
$$
begin
  -- validation
  if not exists (
    select 1 from surgery_case
    where case_id = _case_id
  ) then
    raise exception 'Invalid case_id: %', _case_id;
  end if;

  if not exists (
    select 1 from user_case_connection
    where user_id = _user_id and case_id = _case_id
  ) then
    raise exception 'Invalid user_id: % or user does not have access to this case', _user_id;
  end if;

  -- get studies
  create temporary table temp_studies as
  select study_id
  from study
  where case_id = _case_id;

  create temporary table temp_sys_propa as
  select study_id, pc.reference_segmentation_id, ih.file_server_path, time_point_reference,
    time_point_start, time_point_end
  from propagation_config pc
  join temp_studies ts on pc.study_id = ts.study_id
  join image_header ih on pc.reference_segmentation_id = ih.image_id
  join propagation_type_lut ptLUT on pc.propagation_type_id = ptLUT.propagation_type_id
  where ptLUT.propagation_type_name = 'Systolic';

  create temporary table temp_sys_propa as
  select study_id, pc.reference_segmentation_id, ih.file_server_path, time_point_reference,
    time_point_start, time_point_end
  from propagation_config pc
  join temp_studies ts on pc.study_id = ts.study_id
  join image_header ih on pc.reference_segmentation_id = ih.image_id
  join propagation_type_lut ptLUT on pc.propagation_type_id = ptLUT.propagation_type_id
  where ptLUT.propagation_type_name = 'Diastolic';

  
  return query
  select s.study_id, s.study_name, s.main_image_id, mi.file_server_path as main_image_path,
    s.time_point_start, s.time_point_end, s.days_since_last_study, ss.study_status_name,
    pcSys.reference_segmentation_id as sys_propa_seg_image_id, pcSys.file_server_path as sys_propa_seg_image_path,
    pcSys.time_point_reference as sys_propa_tp_ref, pcSys.time_point_start as sys_propa_tp_start, pcSys.time_point_end as sys_propa_tp_end,
    pcDias.reference_segmentation_id as dias_propa_seg_image_id, pcDias.file_server_path as dias_propa_seg_image_path,
    pcDias.time_point_reference as dias_propa_tp_ref, pcDias.time_point_start as dias_propa_tp_start, pcDias.time_point_end as dias_propa_tp_end
  from study as s
  join image_header as mi on s.main_image_id = i.image_id
  join study_status_lut as ss on s.study_status_id = ss.study_status_id
  join temp_sys_propa as pcSys on s.study_id = pcSys.study_id
  join temp_dias_propa as pcDias on s.study_id = pcDias.study_id
  where s.case_id = _case_id;
end;
$$
language plpgsql;