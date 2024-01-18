-- language: plpgsql
-- function to insert new study config
create or replace function fn_create_study_config (
  p_study_id int,
  p_main_image_dsid bigint,
  p_modality_name varchar(50),
  p_tp_start int,
  p_tp_end int,
  p_sys_refseg_dsid bigint,
  p_sys_tp_start int,
  p_sys_tp_end int,
  p_sys_tp_ref int,
  p_dias_refseg_dsid bigint,
  p_dias_tp_start int,
  p_dias_tp_end int,
  p_dias_tp_ref int
) 
returns int
as $$
declare
  v_modality_id int;
  v_role_main_id int;
  v_role_seg_id int;
  v_main_header_id bigint;
  v_sys_refseg_header_id bigint;
  v_dias_refseg_header_id bigint;
  v_sys_propa_id int;
  v_dias_propa_id int;
  v_study_config_id int;
begin
  --==============================
  -- Validation
  --==============================

  -- validate if study id exists
  if not exists (select 1 from study where study_id = p_study_id) then
    raise exception 'Invalid study_id: %', p_study_id;
  end if;

  --==============================
  -- Creation
  --==============================

  -- set modality id (default as unknown)
  select image_modality_id into v_modality_id from image_modality_lut
  where image_modality_name = p_modality_name;

  if v_modality_id is null then
    select image_modality_id into v_modality_id from image_modality_lut 
    where image_modality_name = 'Unknown';
  end if;

  -- first create image headers
  ---- main image
  if not exists (select 1 from image_header where data_server_id = p_main_image_dsid) then
    insert into image_header(data_server_id, image_role_id, image_modality_id, uploaded_at, last_modified_at)
    values(p_main_image_dsid, v_role_main_id, v_modality_id, now(), now())
    returning image_header_id into v_main_header_id;
  end if;

  ---- systolic segmentation
  if not exists (select 1 from image_header where data_server_id = p_sys_refseg_dsid) then
    insert into image_header(data_server_id, image_role_id, image_modality_id, uploaded_at, last_modified_at)
    values(p_sys_refseg_dsid, v_role_seg_id, v_modality_id, now(), now())
    returning image_header_id into v_sys_refseg_header_id;
  end if;

  ---- diastolic segmentation
  if not exists (select 1 from image_header where data_server_id = p_dias_refseg_dsid) then
    insert into image_header(data_server_id, image_role_id, image_modality_id, uploaded_at, last_modified_at)
    values(p_dias_refseg_dsid, v_role_seg_id, v_modality_id, now(), now())
    returning image_header_id into v_dias_refseg_header_id;
  end if;

  -- insert new study config
  insert into study_config(study_id, main_image_id, created_at, last_modified_at)
  values(p_study_id, v_main_header_id, now(), now())
  returning study_config_id into v_study_config_id;

  -- insert new propagation configs
  ---- systolic
  select propagation_type_id into v_sys_propa_id from propagation_type_lut
  where propagation_type_name = 'Systolic';

  insert into propagation_config(study_config_id, propagation_type_id, reference_segmentation_id,
   time_point_reference, time_point_start, time_point_end, created_at, last_modified_at)
  values(v_study_config_id, v_sys_propa_id, v_sys_refseg_header_id,
   p_sys_tp_ref, p_sys_tp_start, p_sys_tp_end, now(), now());

  ---- diastolic
  select propagation_type_id into v_dias_propa_id from propagation_type_lut
  where propagation_type_name = 'Diastolic';

  insert into propagation_config(study_config_id, propagation_type_id, reference_segmentation_id,
   time_point_reference, time_point_start, time_point_end, created_at, last_modified_at)
  values(v_study_config_id, v_dias_propa_id, v_dias_refseg_header_id,
    p_dias_tp_ref, p_dias_tp_start, p_dias_tp_end, now(), now());

  return v_study_config_id;
end;
$$ language plpgsql;