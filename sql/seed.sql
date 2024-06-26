--language: postgresql
-- SEED DATA
insert into user_role (role_name)
values ('administrator'), ('application'), ('user');

do $$
declare
  _rid_admin int;
  _rid_app int;
  _rid_user int;
begin
  select user_role_id into _rid_admin
  from user_role
  where role_name = 'administrator'
  limit 1;

  select user_role_id into _rid_app
  from user_role
  where role_name = 'application'
  limit 1;

  select user_role_id into _rid_user
  from user_role
  where role_name = 'user'
  limit 1;
end;
$$;

--=========================================================
-- Fill lookup table values
--=========================================================

insert into study_status_lut (study_status_name)
values 
  ('waiting'), -- waiting prerequisites
  ('ready'), -- ready to run (all prerequisites met)
  ('running'), -- currently running
  ('completed'), -- completed successfully
  ('failed'); -- failed to complete (needs rerun or examination)


insert into image_modality_lut (image_modality_name)
values ('CT'), ('US'), ('unknown');

insert into module_output(module_id, module_output_name, render_type_id)
values
  (1, 'volume-main', 1),
  (1, 'volume-segmentation', 1),
  (1, 'model-sl', 2),
  (1, 'model-ml', 2),
  (2, 'coaptation-surface', 2);

insert into study_module_status_lut (study_module_status_name)
values
  ('waiting'), -- waiting prerequisites
  ('ready'), -- ready to run (all prerequisites met)
  ('running'), -- currently running
  ('completed'), -- completed successfully
  ('failed'); -- failed to complete (needs rerun or examination)

insert into application_data_type_lut (application_data_type_name)
values ('image'), ('polydata'), ('json');

insert into configuration_key_type_lut (configuration_key_type_name)
values ('text'), ('time-point'), ('data-id'), ('decimal'), ('integer');

insert into module_data_index_name_lut (module_data_index_name)
values
  ('label'),
  ('coaptation-surface-type');

insert into module_data_index_lut 
	(module_output_id, index_type, index_name_id, index_value, index_desc)
values
	(4, 1, 1, 1, 'l-cusp'),
	(4, 1, 1, 2, 'n-cusp'),
	(4, 1, 1, 3, 'r-cusp'),
	(4, 1, 1, 4, 'whole-root-wall'),
	(4, 1, 1, 5, 'lvo'),
	(4, 1, 1, 6, 'stj'),
	(4, 1, 1, 7, 'ias'),
	(4, 1, 1, 8, 'lc-root'),
	(4, 1, 1, 9, 'nc-root'),
	(4, 1, 1, 10, 'rc-root'),
	(4, 1, 1, 11, 'raphe'),
	(4, 1, 1, 12, 'lumen'),
	(4, 1, 1, 13, 'lc-sinus'),
	(4, 1, 1, 14, 'nc-sinus'),
	(4, 1, 1, 15, 'rc-sinus'),
	(4, 1, 1, 16, 'calcification'),
  (5, 1, 2, 1, 'all'),
  (5, 1, 2, 2, 'LR'),
  (5, 1, 2, 3, 'LN'),
  (5, 1, 2, 4, 'RN');

--=========================================================
-- Predefined non-lut data
--=========================================================

insert into module(module_name, module_precedence_rank, module_description)
values
  ('user-input', 0, 'Stores all user inputs'),
  ('study-generator', 1, 'Generates main volumes, segmenation volumes, and main models'),
  ('measurement', 2, 'Generates measurements and coaptation surfaces'),
  ('root-diameter', 2, 'Generates root diameters');

-- configure modules
do $$
declare
  _user_input_id int;
  _study_gen_id int;
  _measurement_id int;
  _root_diam_id int;
begin
  select module_id into _user_input_id
  from module
  where module_name = 'user-input';

  select module_id into _study_gen_id
  from module
  where module_name = 'study-generator';

  select module_id into _measurement_id
  from module
  where module_name = 'measurement';

  select module_id into _root_diam_id
  from module
  where module_name = 'root-diameter';

  -- insert prerequisites
  insert into module_prerequisite (module_id, prerequisite_module_id)
  values
    (_study_gen_id, _user_input_id),
    (_measurement_id, _study_gen_id),
    (_root_diam_id, _study_gen_id);

  -- insert configuration keys
  do $$
  declare
    _config_key_text_id int;
    _config_key_tp_id int;
    _config_key_decimal_id int;
    _config_key_integer_id int;
    _config_key_data_id int;
  begin
    select configuration_key_type_id into _config_key_text_id
    from configuration_key_type_lut
    where configuration_key_type_name = 'text';

    select configuration_key_type_id into _config_key_tp_id
    from configuration_key_type_lut
    where configuration_key_type_name = 'time-point';

    select configuration_key_type_id into _config_key_decimal_id
    from configuration_key_type_lut
    where configuration_key_type_name = 'decimal';

    select configuration_key_type_id into _config_key_integer_id
    from configuration_key_type_lut
    where configuration_key_type_name = 'integer';

    select configuration_key_type_id into _config_key_ds_id
    from configuration_key_type_lut
    where configuration_key_type_name = 'data-id';

    insert into module_configuration_keys (module_id, configuration_key_name, configuration_key_type_id)
    values
      (_user_input_id, 'image-main', _config_key_data_id),
      (_user_input_id, 'tp_start', _config_key_tp_id),
      (_user_input_id, 'tp_end', _config_key_tp_id),
      (_user_input_id, 'seg_sys_ref', _config_key_data_id),
      (_user_input_id, 'seg_sys_tp_ref', _config_key_tp_id),
      (_user_input_id, 'seg_sys_tp_start', _config_key_tp_id),
      (_user_input_id, 'seg_sys_tp_end', _config_key_tp_id),
      (_user_input_id, 'seg_dias_ref', _config_key_data_id),
      (_user_input_id, 'seg_dias_tp_ref', _config_key_tp_id),
      (_user_input_id, 'seg_dias_tp_start', _config_key_tp_id),
      (_user_input_id, 'seg_dias_tp_end', _config_key_tp_id);

  end;
  
end;
$$;
