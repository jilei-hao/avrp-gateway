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

  insert into users (username, user_role_id)
  values ('dev-handler', _rid_app);
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
values ('Systolic'), ('Diastolic');

insert into render_type(render_type_name)
values ('volume'), ('polydata'), ('measurement');

insert into module_data_type(module_data_type_name, render_type_id)
values 
  ('volume-main', 1),
  ('volume-segmentation', 1),
  ('volume-overlay', 1),
  ('polydata-main', 2),
  ('polydata-overlay', 2),
  ('measurement', 3);

insert into module(module_name, module_display_name, module_description)
values
  ('study-generator', 'Study Generator', 'Generates main volumes, segmenation volumes, and main models');

insert into module_output_group(module_id, module_output_group_name, module_data_type_id)
values
  (1, 'study-gen_image-main', 1),
  (1, 'study-gen_image-segmentation', 2),
  (1, 'study-gen_model-main', 4);


