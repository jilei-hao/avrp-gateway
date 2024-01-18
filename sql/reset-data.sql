-- delete data related to test1 user
do 
$$
declare
  _uid int;
begin
  select user_id into _uid
  from users
  where email = 'test1@test.com';

  -- select user's case ids into a temp table
  create temp table temp_case_ids (
    case_id int
  );

  insert into temp_case_ids (case_id)
  select case_id
  from user_case_connection
  where user_id = _uid;

  delete from user_case_connection
  where user_id = _uid;

  delete from study_config sc
  where study_id in (select study_id from study where case_id in (select case_id from temp_case_ids));

  delete from study
  where case_id in (select case_id from temp_case_ids);

  delete from surgery_case sc 
  where sc.case_id in (select case_id from temp_case_ids);
end
$$;