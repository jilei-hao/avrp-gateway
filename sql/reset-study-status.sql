-- delete data related to test1 user
do 
$$
declare
  _uid int;
  v_ready_status_id int;
  v_processing_status_id int;
begin
  select user_id into _uid
  from users
  where username = 'avrpdev';

  -- select user's case ids into a temp table
  create temp table temp_case_study_ids (
    case_id int,
    study_id int
  ) on commit drop;

  -- get the ready-for-processing study status id
  select study_status_id into v_ready_status_id
  from study_status_lut
  where study_status_name = 'ready-for-processing';

  -- get the processing study status id
  select study_status_id into v_processing_status_id
  from study_status_lut
  where study_status_name = 'processing';

  insert into temp_case_study_ids (case_id, study_id)
  select ucx.case_id, s.study_id
  from user_case_connection ucx join study s on ucx.case_id = s.case_id
  where ucx.user_id = _uid
  and s.study_status_id = v_processing_status_id;

  update study set study_status_id = v_ready_status_id
  where study_id in (select study_id from temp_case_study_ids);
end
$$;