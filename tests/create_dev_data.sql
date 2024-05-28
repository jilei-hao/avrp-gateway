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
    (_dev_study_id, _model_sl_output_id, 1, null, null, 7),
    (_dev_study_id, _model_sl_output_id, 2, null, null, 8),
    (_dev_study_id, _model_sl_output_id, 3, null, null, 9),
    (_dev_study_id, _model_sl_output_id, 4, null, null, 10),
    (_dev_study_id, _model_sl_output_id, 5, null, null, 11),
    (_dev_study_id, _model_sl_output_id, 6, null, null, 12),
    (_dev_study_id, _model_sl_output_id, 7, null, null, 13),
    (_dev_study_id, _model_sl_output_id, 8, null, null, 14),
    (_dev_study_id, _model_sl_output_id, 9, null, null, 15),
    (_dev_study_id, _model_sl_output_id, 10, null, null, 16),
    (_dev_study_id, _model_sl_output_id, 11, null, null, 17),
    (_dev_study_id, _model_sl_output_id, 12, null, null, 18),
    (_dev_study_id, _model_sl_output_id, 13, null, null, 19),
    (_dev_study_id, _model_sl_output_id, 14, null, null, 20),
    (_dev_study_id, _model_sl_output_id, 15, null, null, 21),
    (_dev_study_id, _model_sl_output_id, 16, null, null, 22),
    (_dev_study_id, _model_sl_output_id, 17, null, null, 23),
    (_dev_study_id, _model_sl_output_id, 18, null, null, 24),
    (_dev_study_id, _model_sl_output_id, 19, null, null, 25),
    (_dev_study_id, _model_sl_output_id, 20, null, null, 26),
    (_dev_study_id, _coaptation_surface_output_id, 1, 1, null, 27),
    (_dev_study_id, _coaptation_surface_output_id, 2, 1, null, 28),
    (_dev_study_id, _coaptation_surface_output_id, 3, 1, null, 29),
    (_dev_study_id, _coaptation_surface_output_id, 4, 1, null, 30),
    (_dev_study_id, _coaptation_surface_output_id, 5, 1, null, 31),
    (_dev_study_id, _coaptation_surface_output_id, 6, 1, null, 32),
    (_dev_study_id, _coaptation_surface_output_id, 7, 1, null, 33),
    (_dev_study_id, _coaptation_surface_output_id, 8, 1, null, 34),
    (_dev_study_id, _coaptation_surface_output_id, 9, 1, null, 35),
    (_dev_study_id, _coaptation_surface_output_id, 10, 1, null, 36),
    (_dev_study_id, _coaptation_surface_output_id, 11, 1, null, 37),
    (_dev_study_id, _coaptation_surface_output_id, 12, 1, null, 38),
    (_dev_study_id, _coaptation_surface_output_id, 13, 1, null, 39),
    (_dev_study_id, _coaptation_surface_output_id, 14, 1, null, 40),
    (_dev_study_id, _coaptation_surface_output_id, 15, 1, null, 41),
    (_dev_study_id, _coaptation_surface_output_id, 16, 1, null, 42),
    (_dev_study_id, _coaptation_surface_output_id, 17, 1, null, 43),
    (_dev_study_id, _coaptation_surface_output_id, 18, 1, null, 44),
    (_dev_study_id, _coaptation_surface_output_id, 19, 1, null, 45),
    (_dev_study_id, _coaptation_surface_output_id, 20, 1, null, 46),
    (_dev_study_id, _model_ml_output_id, 1, 1, null, 50), 
    (_dev_study_id, _model_ml_output_id, 2, 1, null, 51), 
    (_dev_study_id, _model_ml_output_id, 3, 1, null, 52), 
    (_dev_study_id, _model_ml_output_id, 4, 1, null, 53), 
    (_dev_study_id, _model_ml_output_id, 5, 1, null, 54), 
    (_dev_study_id, _model_ml_output_id, 6, 1, null, 55), 
    (_dev_study_id, _model_ml_output_id, 7, 1, null, 56), 
    (_dev_study_id, _model_ml_output_id, 8, 1, null, 57), 
    (_dev_study_id, _model_ml_output_id, 9, 1, null, 58), 
    (_dev_study_id, _model_ml_output_id, 10, 1, null, 59), 
    (_dev_study_id, _model_ml_output_id, 11, 1, null, 60), 
    (_dev_study_id, _model_ml_output_id, 12, 1, null, 61), 
    (_dev_study_id, _model_ml_output_id, 13, 1, null, 62), 
    (_dev_study_id, _model_ml_output_id, 14, 1, null, 63), 
    (_dev_study_id, _model_ml_output_id, 15, 1, null, 64), 
    (_dev_study_id, _model_ml_output_id, 16, 1, null, 65), 
    (_dev_study_id, _model_ml_output_id, 17, 1, null, 66), 
    (_dev_study_id, _model_ml_output_id, 18, 1, null, 67), 
    (_dev_study_id, _model_ml_output_id, 19, 1, null, 68), 
    (_dev_study_id, _model_ml_output_id, 20, 1, null, 69), 
    (_dev_study_id, _model_ml_output_id, 1, 2, null, 70), 
    (_dev_study_id, _model_ml_output_id, 2, 2, null, 71), 
    (_dev_study_id, _model_ml_output_id, 3, 2, null, 72), 
    (_dev_study_id, _model_ml_output_id, 4, 2, null, 73), 
    (_dev_study_id, _model_ml_output_id, 5, 2, null, 74), 
    (_dev_study_id, _model_ml_output_id, 6, 2, null, 75), 
    (_dev_study_id, _model_ml_output_id, 7, 2, null, 76), 
    (_dev_study_id, _model_ml_output_id, 8, 2, null, 77), 
    (_dev_study_id, _model_ml_output_id, 9, 2, null, 78), 
    (_dev_study_id, _model_ml_output_id, 10, 2, null, 79), 
    (_dev_study_id, _model_ml_output_id, 11, 2, null, 80), 
    (_dev_study_id, _model_ml_output_id, 12, 2, null, 81), 
    (_dev_study_id, _model_ml_output_id, 13, 2, null, 82), 
    (_dev_study_id, _model_ml_output_id, 14, 2, null, 83), 
    (_dev_study_id, _model_ml_output_id, 15, 2, null, 84), 
    (_dev_study_id, _model_ml_output_id, 16, 2, null, 85), 
    (_dev_study_id, _model_ml_output_id, 17, 2, null, 86), 
    (_dev_study_id, _model_ml_output_id, 18, 2, null, 87), 
    (_dev_study_id, _model_ml_output_id, 19, 2, null, 88), 
    (_dev_study_id, _model_ml_output_id, 20, 2, null, 89), 
    (_dev_study_id, _model_ml_output_id, 1, 3, null, 90), 
    (_dev_study_id, _model_ml_output_id, 2, 3, null, 91), 
    (_dev_study_id, _model_ml_output_id, 3, 3, null, 92), 
    (_dev_study_id, _model_ml_output_id, 4, 3, null, 93), 
    (_dev_study_id, _model_ml_output_id, 5, 3, null, 94), 
    (_dev_study_id, _model_ml_output_id, 6, 3, null, 95), 
    (_dev_study_id, _model_ml_output_id, 7, 3, null, 96), 
    (_dev_study_id, _model_ml_output_id, 8, 3, null, 97), 
    (_dev_study_id, _model_ml_output_id, 9, 3, null, 98), 
    (_dev_study_id, _model_ml_output_id, 10, 3, null, 99), 
    (_dev_study_id, _model_ml_output_id, 11, 3, null, 100), 
    (_dev_study_id, _model_ml_output_id, 12, 3, null, 101), 
    (_dev_study_id, _model_ml_output_id, 13, 3, null, 102), 
    (_dev_study_id, _model_ml_output_id, 14, 3, null, 103), 
    (_dev_study_id, _model_ml_output_id, 15, 3, null, 104), 
    (_dev_study_id, _model_ml_output_id, 16, 3, null, 105), 
    (_dev_study_id, _model_ml_output_id, 17, 3, null, 106), 
    (_dev_study_id, _model_ml_output_id, 18, 3, null, 107), 
    (_dev_study_id, _model_ml_output_id, 19, 3, null, 108), 
    (_dev_study_id, _model_ml_output_id, 20, 3, null, 109), 
    (_dev_study_id, _model_ml_output_id, 1, 4, null, 110), 
    (_dev_study_id, _model_ml_output_id, 2, 4, null, 111), 
    (_dev_study_id, _model_ml_output_id, 3, 4, null, 112), 
    (_dev_study_id, _model_ml_output_id, 4, 4, null, 113), 
    (_dev_study_id, _model_ml_output_id, 5, 4, null, 114), 
    (_dev_study_id, _model_ml_output_id, 6, 4, null, 115), 
    (_dev_study_id, _model_ml_output_id, 7, 4, null, 116), 
    (_dev_study_id, _model_ml_output_id, 8, 4, null, 117), 
    (_dev_study_id, _model_ml_output_id, 9, 4, null, 118), 
    (_dev_study_id, _model_ml_output_id, 10, 4, null, 119), 
    (_dev_study_id, _model_ml_output_id, 11, 4, null, 120), 
    (_dev_study_id, _model_ml_output_id, 12, 4, null, 121), 
    (_dev_study_id, _model_ml_output_id, 13, 4, null, 122), 
    (_dev_study_id, _model_ml_output_id, 14, 4, null, 123), 
    (_dev_study_id, _model_ml_output_id, 15, 4, null, 124), 
    (_dev_study_id, _model_ml_output_id, 16, 4, null, 125), 
    (_dev_study_id, _model_ml_output_id, 17, 4, null, 126), 
    (_dev_study_id, _model_ml_output_id, 18, 4, null, 127), 
    (_dev_study_id, _model_ml_output_id, 19, 4, null, 128), 
    (_dev_study_id, _model_ml_output_id, 20, 4, null, 129), 
    (_dev_study_id, _model_ml_output_id, 1, 5, null, 130), 
    (_dev_study_id, _model_ml_output_id, 2, 5, null, 131), 
    (_dev_study_id, _model_ml_output_id, 3, 5, null, 132), 
    (_dev_study_id, _model_ml_output_id, 4, 5, null, 133), 
    (_dev_study_id, _model_ml_output_id, 5, 5, null, 134), 
    (_dev_study_id, _model_ml_output_id, 6, 5, null, 135), 
    (_dev_study_id, _model_ml_output_id, 7, 5, null, 136), 
    (_dev_study_id, _model_ml_output_id, 8, 5, null, 137), 
    (_dev_study_id, _model_ml_output_id, 9, 5, null, 138), 
    (_dev_study_id, _model_ml_output_id, 10, 5, null, 139), 
    (_dev_study_id, _model_ml_output_id, 11, 5, null, 140), 
    (_dev_study_id, _model_ml_output_id, 12, 5, null, 141), 
    (_dev_study_id, _model_ml_output_id, 13, 5, null, 142), 
    (_dev_study_id, _model_ml_output_id, 14, 5, null, 143), 
    (_dev_study_id, _model_ml_output_id, 15, 5, null, 144), 
    (_dev_study_id, _model_ml_output_id, 16, 5, null, 145), 
    (_dev_study_id, _model_ml_output_id, 17, 5, null, 146), 
    (_dev_study_id, _model_ml_output_id, 18, 5, null, 147), 
    (_dev_study_id, _model_ml_output_id, 19, 5, null, 148), 
    (_dev_study_id, _model_ml_output_id, 20, 5, null, 149), 
    (_dev_study_id, _model_ml_output_id, 1, 6, null, 150), 
    (_dev_study_id, _model_ml_output_id, 2, 6, null, 151), 
    (_dev_study_id, _model_ml_output_id, 3, 6, null, 152), 
    (_dev_study_id, _model_ml_output_id, 4, 6, null, 153), 
    (_dev_study_id, _model_ml_output_id, 5, 6, null, 154), 
    (_dev_study_id, _model_ml_output_id, 6, 6, null, 155), 
    (_dev_study_id, _model_ml_output_id, 7, 6, null, 156), 
    (_dev_study_id, _model_ml_output_id, 8, 6, null, 157), 
    (_dev_study_id, _model_ml_output_id, 9, 6, null, 158), 
    (_dev_study_id, _model_ml_output_id, 10, 6, null, 159), 
    (_dev_study_id, _model_ml_output_id, 11, 6, null, 160), 
    (_dev_study_id, _model_ml_output_id, 12, 6, null, 161), 
    (_dev_study_id, _model_ml_output_id, 13, 6, null, 162), 
    (_dev_study_id, _model_ml_output_id, 14, 6, null, 163), 
    (_dev_study_id, _model_ml_output_id, 15, 6, null, 164), 
    (_dev_study_id, _model_ml_output_id, 16, 6, null, 165), 
    (_dev_study_id, _model_ml_output_id, 17, 6, null, 166), 
    (_dev_study_id, _model_ml_output_id, 18, 6, null, 167), 
    (_dev_study_id, _model_ml_output_id, 19, 6, null, 168), 
    (_dev_study_id, _model_ml_output_id, 20, 6, null, 169), 
    (_dev_study_id, _model_ml_output_id, 1, 16, null, 170), 
    (_dev_study_id, _model_ml_output_id, 2, 16, null, 171), 
    (_dev_study_id, _model_ml_output_id, 3, 16, null, 172), 
    (_dev_study_id, _model_ml_output_id, 4, 16, null, 173), 
    (_dev_study_id, _model_ml_output_id, 5, 16, null, 174), 
    (_dev_study_id, _model_ml_output_id, 6, 16, null, 175), 
    (_dev_study_id, _model_ml_output_id, 7, 16, null, 176), 
    (_dev_study_id, _model_ml_output_id, 8, 16, null, 177), 
    (_dev_study_id, _model_ml_output_id, 9, 16, null, 178), 
    (_dev_study_id, _model_ml_output_id, 10, 16, null, 179), 
    (_dev_study_id, _model_ml_output_id, 11, 16, null, 180), 
    (_dev_study_id, _model_ml_output_id, 12, 16, null, 181), 
    (_dev_study_id, _model_ml_output_id, 13, 16, null, 182), 
    (_dev_study_id, _model_ml_output_id, 14, 16, null, 183), 
    (_dev_study_id, _model_ml_output_id, 15, 16, null, 184), 
    (_dev_study_id, _model_ml_output_id, 16, 16, null, 185), 
    (_dev_study_id, _model_ml_output_id, 17, 16, null, 186), 
    (_dev_study_id, _model_ml_output_id, 18, 16, null, 187), 
    (_dev_study_id, _model_ml_output_id, 19, 16, null, 188), 
    (_dev_study_id, _model_ml_output_id, 20, 16, null, 189);
  GET DIAGNOSTICS _rows_inserted = ROW_COUNT;

  -- report row count
  raise notice 'inserted % rows of dev data', _rows_inserted;
end $$;