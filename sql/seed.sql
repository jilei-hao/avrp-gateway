--language: postgresql
-- SEED DATA
insert into user_role (role_name)
values ('administrator'), ('application'), ('end-user');

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
  where role_name = 'end-user'
  limit 1;
end;
$$;


insert into study_status_lut (study_status_name)
values 
  ('waiting'),
  ('ready'), 
  ('running'), 
  ('completed'),
  ('error');


insert into image_modality_lut (image_modality_name)
values ('CT'), ('US'), ('unknown');

insert into image_role_lut (image_role_name)
values ('main'), ('segmentation');

insert into propagation_type_lut (propagation_type_name)
values ('systolic'), ('diastolic');

insert into render_type(render_type_name)
values ('volume'), ('polydata'), ('text'), ('unrenderable');

insert into module_output_purpose(module_output_purpose_name)
values ('view-service'), ('manager'), ('internal');

insert into module(module_name, module_description)
values
  ('study-generator', 'Generates main volumes, segmenation volumes, and main models'),
  ('measurement', 'Generates measurements and coaptation surfaces');

insert into module_output(module_id, module_output_name, render_type_id, module_output_purpose_id)
values
  (1, 'volume-main', 1, 1),
  (1, 'volume-segmentation', 1, 1),
  (1, 'model-sl', 2, 1),
  (1, 'model-ml', 2, 1),
  (2, 'coaptation-surface', 2, 1);

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

insert into study_module_status_lut (study_module_status_name)
values
  ('waiting'), -- waiting prerequisites
  ('ready'), -- ready to run (all prerequisites met)
  ('running'), -- currently running
  ('completed'), -- completed successfully
  ('failed'); -- failed to complete (needs rerun or examination)


do $$
declare
  _study_gen_id int;
  _measurement_id int;
begin
  select module_id into _study_gen_id
  from module
  where module_name = 'study-generator'

  select module_id into _measurement_id
  from module
  where module_name = 'measurement'

  -- measurement module depends on study generator
  insert into module_prerequisite (module_id, prerequisite_module_id)
  values
    (_measurement_id, _study_gen_id);
end;
$$;
