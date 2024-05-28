-- language: plpgsql
-- function to get a table of handler tasks

-- {
--   study_id: 1,
--   study_config: {
--     main_image_dsid: 123,
--     tp_start: 0,
--     tp_end: 10,
--     sys_segref_dsid: 256,
--     sys_tp_ref: 5,
--     sys_tp_start: 0,
--     sys_tp_end: 10,
--     dias_segref_dsid: 257,
--     dias_tp_ref: 5,
--     dias_tp_start: 0,
--     dias_tp_end: 10
--   },
--   module_status: 64
-- }

create or replace function fn_get_handler_tasks ()
returns table (
  study_id int,
  main_image_dsid bigint,
  tp_start int,
  tp_end int,
  sys_segref_dsid bigint,
  sys_tp_ref int,
  sys_tp_start int,
  sys_tp_end int,
  dias_segref_dsid bigint,
  dias_tp_ref int,
  dias_tp_start int,
  dias_tp_end int,
  module_status bigint
)
as
$$
declare
  v_sys_propa_type_id int;
  v_dias_propa_type_id int;
begin
  -- find set of study id that has ready-for-processing status
  create temp table tmp_ready_studies on commit drop as
  select s.study_id from study s 
  join study_status_lut ssl on s.study_status_id = ssl.study_status_id
  where ssl.study_status_name = 'ready-for-processing';

  -- get propagation_type_id
  select propagation_type_id into v_sys_propa_type_id 
  from propagation_type_lut where propagation_type_name = 'systolic';

  select propagation_type_id into v_dias_propa_type_id 
  from propagation_type_lut where propagation_type_name = 'diastolic';

  return query 
  select
    s.study_id,
    ih_main.data_server_id as main_image_dsid,
    sc.time_point_start as tp_start,
    sc.time_point_end as tp_end,
    ih_sys.data_server_id as sys_segref_dsid,
    pc_sys.time_point_reference as sys_tp_ref,
    pc_sys.time_point_start as sys_tp_start,
    pc_sys.time_point_end as sys_tp_end,
    ih_dias.data_server_id as dias_segref_dsid,
    pc_dias.time_point_reference as dias_tp_ref,
    pc_dias.time_point_start as dias_tp_start,
    pc_dias.time_point_end as dias_tp_end,
    s.module_status
  from tmp_ready_studies ts
  join study s on s.study_id = ts.study_id
  join study_config sc on s.study_id = sc.study_id
  join image_header ih_main on ih_main.image_header_id = sc.main_image_id
  join propagation_config pc_sys 
    on pc_sys.study_config_id = sc.study_config_id 
    and pc_sys.propagation_type_id = v_sys_propa_type_id
  join image_header ih_sys on ih_sys.image_header_id = pc_sys.reference_segmentation_id
  join propagation_config pc_dias
    on pc_dias.study_config_id = sc.study_config_id
    and pc_dias.propagation_type_id = v_dias_propa_type_id
  join image_header ih_dias on ih_dias.image_header_id = pc_dias.reference_segmentation_id;
end
$$ language plpgsql;
