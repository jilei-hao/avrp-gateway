create table user_role (
  user_role_id serial primary key,
  role_name varchar(50)
);

create table users (
  user_id serial primary key,
  email varchar(50) unique,
  password_hash varchar,
  user_role_id int references user_role(user_role_id)
);

create table surgery_case (
  case_id serial primary key,
  case_name varchar(50) unique,
  mrn varchar
);

create table user_case_connection (
  user_id int references users(user_id),
  case_id int references surgery_case(case_id),
  primary key (user_id, case_id)
);

create table image_modality_lut (
  image_modality_id serial primary key,
  image_modality_name varchar(50)
);

create table image_role_lut (
  image_role_id serial primary key,
  image_role_name varchar(50)
);

create table study_status_lut (
  study_status_id serial primary key,
  study_status_name varchar(100)
);

create table image_header (
  image_header_id bigint primary key,
  data_server_id bigint,
  data_server_folder varchar(255),
  file_name varchar(255),
  image_role_id int references image_role_lut(image_role_id),
  image_modality_id int references image_modality_lut(image_modality_id),
  uploaded_at timestamp,
  last_modified_at timestamp
);

create table study (
  study_id serial primary key,
  case_id int references surgery_case(case_id),
  study_name varchar(50),
  days_since_last_study int,
  created_at timestamp,
  last_modified_at timestamp
);

create table propagation_type_lut (
  propagation_type_id serial primary key,
  propagation_type_name varchar(50)
);

create table study_config (
  study_config_id serial primary key,
  study_id int references study(study_id),
  main_image_id bigint references image_header(image_header_id),
  create_at timestamp,
  last_modified_at timestamp
);

create table propagation_config (
  propagation_config_id serial primary key,
  study_config_id int references study_config(study_config_id),
  propagation_type_id int references propagation_type_lut(propagation_type_id),
  reference_segmentation_id int references image_header(image_header_id),
  time_point_reference int,
  time_point_start int,
  time_point_end int,
  created_at timestamp,
  last_modified_at timestamp
);

create table app_data_role_lut (
  app_data_role_id serial primary key,
  app_data_role_name varchar(50)
);

create table app_data_header (
  app_data_id serial primary key,
  study_id int references study(study_id),
  app_data_role_id int references app_data_role_lut(app_data_role_id),
  created_datetime timestamp,
  last_modified_datetime timestamp
);
