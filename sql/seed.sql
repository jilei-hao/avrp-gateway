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
  ('waiting-for-input'),
  ('ready-for-processing'), 
  ('processing'), 
  ('completed');


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


insert into module_data_index_lut (module_output_id, index_type, index_name_id, index_value, index_desc)
values
  (4, 1, 1, 1, 'label-placeholder'),
  (5, 1, 2, 1, 'all'),
  (5, 1, 2, 2, 'LR'),
  (5, 1, 2, 3, 'LN'),
  (5, 1, 2, 4, 'RN');


