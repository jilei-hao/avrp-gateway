-- delete data related to test1 user
do 
$$
declare
  _uid int;
begin
  select user_id into _uid
  from users
  where username = 'avrpdev';

  -- select user's case ids into a temp table
  create temp table temp_case_study_ids (
    case_id int,
    study_id int
  ) on commit drop;

  insert into temp_case_study_ids (case_id, study_id)
  select ucx.case_id, s.study_id
  from user_case_connection ucx join study s on ucx.case_id = s.case_id
  where ucx.user_id = _uid;

  delete from user_case_connection
  where user_id = _uid;

  delete from propagation_config pc
  where pc.study_config_id in (
    select study_config_id from study_config where study_id in (
      select study_id from temp_case_study_ids
    )
  );

  delete from study_config sc
  where study_id in (
    select distinct study_id from temp_case_study_ids
  );

  delete from study
  where case_id in (select distinct case_id from temp_case_study_ids);

  delete from surgery_case sc 
  where sc.case_id in (select case_id from temp_case_study_ids);
end
$$;