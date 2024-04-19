do $$
declare
  _dev_user_id int;
  _dev_case_id int;
  _dev_study_id int;
  _studygen_module_id int;
  _measurement_module_id int;
  _volume_output_id int;
  _segmentation_output_id int;
  _model_sl_output_id int;
  _model_ml_output_id int;
  _coaptation_surface_output_id int;
  _rows_deleted int;
  _rows_inserted int;
  _image_header_id int;
begin
  select user_id into _dev_user_id
  from users
  where username = 'avrpdev'
  limit 1;

  -- print user id
  raise notice 'dev user id: %', _dev_user_id;

  --================================================
  -- create case and study
  --================================================

  if not (select count(*) from surgery_case where case_name = 'dev-case-1') > 0 then
    select fn_create_case('dev-case-1', _dev_user_id, 'dev-mrn-1') into _dev_case_id;
  else
    select case_id into _dev_case_id
    from surgery_case
    where case_name = 'dev-case-1';

    raise notice 'dev case already exists';
  end if;

  if not ((
    select count(*) from user_case_connection 
    where user_id = _dev_user_id and case_id = _dev_case_id
    ) > 0) 
  then
    insert into user_case_connection(user_id, case_id)
    values (_dev_user_id, _dev_case_id);
  else
    raise notice 'dev case connection already exists';
  end if;

  raise notice 'case id: %', _dev_case_id;

  if not (select count(*) from study where study_name = 'dev-study-1') > 0 then
    select fn_create_study(_dev_case_id, 'dev-study-1') into _dev_study_id;
  else
    select study_id into _dev_study_id
    from study
    where study_name = 'dev-study-1';

    raise notice 'dev study already exists';
  end if;

  -- print study id
  raise notice 'study id: %', _dev_study_id;

  --================================================
  -- create study config
  --================================================

  if not ((select count(*) from image_header where data_server_id = 1) > 0) then
    insert into image_header(data_server_id, image_role_id, image_modality_id, uploaded_at, last_modified_at)
    values
      (1, 1, 1, now(), now())
    returning image_header_id into _image_header_id;
  else
    select image_header_id into _image_header_id
    from image_header
    where data_server_id = 1;

    raise notice 'main image already exists';
  end if;

  if not ((select count(*) from study_config where study_id = _dev_study_id) > 0) then
    insert into study_config(study_id, time_point_start, time_point_end, main_image_id)
    values
      (_dev_study_id, 1, 20, _image_header_id);
  else
    raise notice 'dev study config already exists';
  end if;


  --================================================
  -- create module data
  --================================================

  -- get module id
  select module_id into _studygen_module_id
  from module
  where module_name = 'study-generator';

  select module_id into _measurement_module_id
  from module
  where module_name = 'measurement';

  -- get module output ids
  select module_output_id into _volume_output_id
  from module_output
  where module_id = _studygen_module_id
  and module_output_name = 'volume-main';

  select module_output_id into _segmentation_output_id
  from module_output
  where module_id = _studygen_module_id
  and module_output_name = 'volume-segmentation';

  select module_output_id into _model_sl_output_id
  from module_output
  where module_id = _studygen_module_id
  and module_output_name = 'model-sl';

  select module_output_id into _model_ml_output_id
  from module_output
  where module_id = _studygen_module_id
  and module_output_name = 'model-ml';

  select module_output_id into _coaptation_surface_output_id
  from module_output
  where module_id = _measurement_module_id
  and module_output_name = 'coaptation-surface';

  -- delete existing dev data
  delete from module_data_header where study_id = _dev_study_id;
  GET DIAGNOSTICS _rows_deleted = ROW_COUNT;

  -- insert to module data header
  -- report row count
  raise notice 'deleted % rows of existing dev data', _rows_deleted;

  insert into module_data_header(study_id, module_output_id, time_point, primary_index, secondary_index, data_server_id)
  values
    (_dev_study_id, _model_sl_output_id, 1, 3, 1, 7),
    (_dev_study_id, _model_sl_output_id, 2, 3, 1, 8),
    (_dev_study_id, _model_sl_output_id, 3, 3, 1, 9),
    (_dev_study_id, _model_sl_output_id, 4, 3, 1, 10),
    (_dev_study_id, _model_sl_output_id, 5, 3, 1, 11),
    (_dev_study_id, _model_sl_output_id, 6, 3, 1, 12),
    (_dev_study_id, _model_sl_output_id, 7, 3, 1, 13),
    (_dev_study_id, _model_sl_output_id, 8, 3, 1, 14),
    (_dev_study_id, _model_sl_output_id, 9, 3, 1, 15),
    (_dev_study_id, _model_sl_output_id, 10, 3, 1, 16),
    (_dev_study_id, _model_sl_output_id, 11, 3, 1, 17),
    (_dev_study_id, _model_sl_output_id, 12, 3, 1, 18),
    (_dev_study_id, _model_sl_output_id, 13, 3, 1, 19),
    (_dev_study_id, _model_sl_output_id, 14, 3, 1, 20),
    (_dev_study_id, _model_sl_output_id, 15, 3, 1, 21),
    (_dev_study_id, _model_sl_output_id, 16, 3, 1, 22),
    (_dev_study_id, _model_sl_output_id, 17, 3, 1, 23),
    (_dev_study_id, _model_sl_output_id, 18, 3, 1, 24),
    (_dev_study_id, _model_sl_output_id, 19, 3, 1, 25),
    (_dev_study_id, _model_sl_output_id, 20, 3, 1, 26),
    (_dev_study_id, _coaptation_surface_output_id, 1, 1, 1, 27),
    (_dev_study_id, _coaptation_surface_output_id, 2, 1, 1, 28),
    (_dev_study_id, _coaptation_surface_output_id, 3, 1, 1, 29),
    (_dev_study_id, _coaptation_surface_output_id, 4, 1, 1, 30),
    (_dev_study_id, _coaptation_surface_output_id, 5, 1, 1, 31),
    (_dev_study_id, _coaptation_surface_output_id, 6, 1, 1, 32),
    (_dev_study_id, _coaptation_surface_output_id, 7, 1, 1, 33),
    (_dev_study_id, _coaptation_surface_output_id, 8, 1, 1, 34),
    (_dev_study_id, _coaptation_surface_output_id, 9, 1, 1, 35),
    (_dev_study_id, _coaptation_surface_output_id, 10, 1, 1, 36),
    (_dev_study_id, _coaptation_surface_output_id, 11, 1, 1, 37),
    (_dev_study_id, _coaptation_surface_output_id, 12, 1, 1, 38),
    (_dev_study_id, _coaptation_surface_output_id, 13, 1, 1, 39),
    (_dev_study_id, _coaptation_surface_output_id, 14, 1, 1, 40),
    (_dev_study_id, _coaptation_surface_output_id, 15, 1, 1, 41),
    (_dev_study_id, _coaptation_surface_output_id, 16, 1, 1, 42),
    (_dev_study_id, _coaptation_surface_output_id, 17, 1, 1, 43),
    (_dev_study_id, _coaptation_surface_output_id, 18, 1, 1, 44),
    (_dev_study_id, _coaptation_surface_output_id, 19, 1, 1, 45),
    (_dev_study_id, _coaptation_surface_output_id, 20, 1, 1, 46);
  GET DIAGNOSTICS _rows_inserted = ROW_COUNT;

  -- report row count
  raise notice 'inserted % rows of dev data', _rows_inserted;
end $$;