create or replace function fn_vs_get_case_study_headers (
  _user_id int
)
returns table (
  case_id int, 
  case_name varchar(50), 
  study_id int, 
  study_name varchar(50),
  time_point_start int,
  time_point_end int,
  main_image_dsid bigint,
  study_status_id int,
  study_status_name varchar(50)
) as $$
begin
  return query
  select
    c.case_id,
    c.case_name,
    s.study_id,
    s.study_name,
    sc.time_point_start,
    sc.time_point_end,
    ih_main.data_server_id as main_image_dsid,
    s.study_status_id,
    ssl.study_status_name
  from study s
  join surgery_case c 
    on s.case_id = c.case_id
  join study_config sc 
    on s.study_id = sc.study_id
  join image_header ih_main
    on sc.main_image_id = ih_main.image_header_id
  join study_status_lut ssl 
    on s.study_status_id = ssl.study_status_id
  where c.case_id in (
    select ucc.case_id
    from user_case_connection ucc
    where user_id = _user_id
  );
end
$$ language plpgsql;