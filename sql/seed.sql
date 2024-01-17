--language: postgresql
-- SEED DATA
insert into user_role (role_name)
values ('Administrator'), ('Application'), ('EndUser');

do $$
declare
  _rid_admin int;
  _rid_app int;
  _rid_user int;
begin
  select user_role_id into _rid_admin
  from user_role
  where role_name = 'Administrator'
  limit 1;

  select user_role_id into _rid_app
  from user_role
  where role_name = 'Application'
  limit 1;

  select user_role_id into _rid_user
  from user_role
  where role_name = 'EndUser'
  limit 1;
end;
$$;


insert into study_status_lut (study_status_name)
values 
  ('WaitingForInput'),
  ('ReadyForProcess'), 
  ('Processing'), 
  ('Completed');


insert into image_modality_lut (image_modality_name)
values ('CT'), ('US'), ('Unknown');

insert into image_role_lut (image_role_name)
values ('Main'), ('Segmentation');

insert into app_data_role_lut (app_data_role_name)
values
  ('Volume'),
  ('Segmentation'),
  ('OneLabelModel'),
  ('MultiLabelModel');

insert into propagation_type_lut (propagation_type_name)
values ('Systolic'), ('Diastolic');


