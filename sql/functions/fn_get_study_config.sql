-- language plpgsql
-- function to get the study-config id from a study id
-- returns a table of study-config details

create or replace function fn_get_study_config(
  p_study_id int
)
returns table (
  id int,
  study_id int,
  main_image_name varchar(255),
  tp_start int,
  tp_end int,
  sys_refseg_name varchar(255),
  sys_tp_start int,
  sys_tp_end int,
  sys_tp_ref int,
  dias_refseg_name varchar(255),
  dias_tp_start int,
  dias_tp_end int,
  dias_tp_ref int
)
as $$
declare
  v_study_config_id int;
  v_sys_propa_type_id int;
  v_dias_propa_type_id int;
  v_sys_propa_id int;
  v_dias_propa_id int;
begin
  -- validate study_id
  if p_study_id is null then
    raise exception 'study_id cannot be null';
  end if;

  -- get study_config_id
  select id into v_study_config_id from study_configs where study_id = p_study_id;
  if v_study_config_id is null then
    return;
  end if;

  -- get propagation_type_id
  select id into v_sys_propa_type_id from propagation_type_lut where propagation_type_name = 'Systolic';
  select id into v_dias_propa_type_id from propagation_type_lut where propagation_type_name = 'Diastolic';

  -- get study_config details
  return query
  select
    sc.id,
    sc.study_id,
    ih_main.name as main_image_name,
    sc.tp_start,
    sc.tp_end,
    ih_sys_refseg.name as sys_refseg_name,
    pc_sys.sys_tp_start,
    pc_sys.sys_tp_end,
    pc_sys.sys_tp_ref,
    ih_dias_refseg.name as dias_refseg_name,
    pc_dias.dias_tp_start,
    pc_dias.dias_tp_end,
    pc_dias.dias_tp_ref
  from study_configs sc
  left join image_header ih_main on ih_main.image_header_id = sc.main_image_id
  left join propagation_config pc_sys on pc_sys.study_config_id = sc.id and pc_sys.propagation_type_id = v_sys_propa_type_id
  left join image_header ih_sys_refseg on ih_sys_refseg.image_header_id = pc_sys.reference_segmentation_id
  left join propagation_config pc_dias on pc_dias.study_config_id = sc.id and pc_dias.propagation_type_id = v_dias_propa_type_id
  left join image_header ih_dias_refseg on ih_dias_refseg.image_header_id = pc_dias.reference_segmentation_id
  where sc.id = v_study_config_id;
end;
$$ language plpgsql;
