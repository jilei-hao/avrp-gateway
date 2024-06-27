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

insert into module_data_index_type_lut (module_data_index_type_name)
values
  ('primary'),
  ('secondary');

insert into time_point_type_lut (time_point_type_name)
values
  ('all'),
  ('specific');

do $$
declare
  _primary_index_type int;
  _secondary_index_type int;
  _model_ml_output_id int;
  _co_surface_output_id int;
  _label_index_name_id int;
  _co_surface_index_name_id int;
begin
  select module_output_id into _model_ml_output_id
  from module_output
  where module_output_name = 'model-ml';

  select module_output_id into _co_surface_output_id
  from module_output
  where module_output_name = 'coaptation-surface';

  select module_data_index_type_id into _primary_index_type
  from module_data_index_type_lut
  where module_data_index_type_name = 'primary';

  select module_data_index_type_id into _secondary_index_type
  from module_data_index_type_lut
  where module_data_index_type_name = 'secondary';

  select module_data_index_name_id into _label_index_name_id
  from module_data_index_name_lut
  where module_data_index_name = 'label';

  select module_data_index_name_id into _co_surface_index_name_id
  from module_data_index_name_lut
  where module_data_index_name = 'coaptation-surface-type';

  insert into module_data_index_lut 
	  (module_output_id, module_data_index_type_id, index_name_id, index_value, index_desc)
  values
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 1, 'l-cusp'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 2, 'n-cusp'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 3, 'r-cusp'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 4, 'whole-root-wall'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 5, 'lvo'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 6, 'stj'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 7, 'ias'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 8, 'lc-root'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 9, 'nc-root'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 10, 'rc-root'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 11, 'raphe'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 12, 'lumen'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 13, 'lc-sinus'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 14, 'nc-sinus'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 15, 'rc-sinus'),
    (_model_ml_output_id, _primary_index_type, _label_index_name_id, 16, 'calcification'),
    (_co_surface_output_id, _primary_index_type, _co_surface_index_name_id, 1, 'all'),
    (_co_surface_output_id, _primary_index_type, _co_surface_index_name_id, 2, 'LR'),
    (_co_surface_output_id, _primary_index_type, _co_surface_index_name_id, 3, 'LN'),
    (_co_surface_output_id, _primary_index_type, _co_surface_index_name_id, 4, 'RN');
end;
$$;



--=========================================================
-- Predefined non-lut data
--=========================================================

insert into module(module_name, module_precedence_rank, module_description)
values
  ('user-input', 0, 'Stores all user inputs'),
  ('study-generator', 1, 'Generates main volumes, segmenation volumes, and main models'),
  ('measurement', 2, 'Generates measurements and coaptation surfaces'),
  ('root-diameter', 2, 'Generates root diameters');

insert into module_output(module_id, module_output_name)
values
  (1, 'volume-main'),
  (1, 'volume-segmentation'),
  (1, 'model-sl'),
  (1, 'model-ml'),
  (2, 'coaptation-surface');

-- configure modules
do $$
declare
  _user_input_id int;
  _study_gen_id int;
  _measurement_id int;
  _root_diam_id int;
  _config_key_text_id int;
  _config_key_tp_id int;
  _config_key_decimal_id int;
  _config_key_integer_id int;
  _config_key_data_id int;
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

  select configuration_key_type_id into _config_key_data_id
  from configuration_key_type_lut
  where configuration_key_type_name = 'data-id';
  
end;
$$;
