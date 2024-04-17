-- language: plpgsql

create or replace function fn_vs_get_study_data_headers(
  in _study_id int
) returns table (
  data_group_name varchar(50), -- volume, model etc.
  time_point int, 
  primary_index int, -- e.g. label
  primary_index_name varchar(50),
  primary_index_desc varchar(50),
  secondary_index int, -- e.g. time
  secondary_index_name varchar(50),
  secondary_index_desc varchar(50),
  data_server_id bigint
) as $$
declare
  _primary_index_type int = 1;
  _secondary_index_type int = 2;
begin
  return query
  select
    mo.module_output_name as data_group_name,
    mdh.time_point,
    mdh.primary_index,
    mdi_name_primary.module_data_index_name as primary_index_name,
    mdi_primary.index_desc as primary_index_desc,
    mdh.secondary_index,
    mdi_name_secondary.module_data_index_name as secondary_index_name,
    mdi_secondary.index_desc as secondary_index_desc,
    mdh.data_server_id
  from module_data_header mdh
  join module_output mo on mdh.module_output_id = mo.module_output_id
  left join module_data_index_lut mdi_primary 
    on mdh.primary_index = mdi_primary.index_value 
    and mdh.module_output_id = mdi_primary.module_output_id
    and mdi_primary.index_type = _primary_index_type
  left join module_data_index_name_lut mdi_name_primary
    on mdi_primary.index_name_id = mdi_name_primary.module_data_index_name_id
  left join module_data_index_lut mdi_secondary 
    on mdh.secondary_index = mdi_secondary.index_value
    and mdh.module_output_id = mdi_secondary.module_output_id
    and mdi_secondary.index_type = _secondary_index_type
  left join module_data_index_name_lut mdi_name_secondary
    on mdi_secondary.index_name_id = mdi_name_secondary.module_data_index_name_id
  where mdh.study_id = _study_id;
end
$$ language plpgsql;
