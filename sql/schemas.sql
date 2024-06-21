create table user_role (
  user_role_id serial primary key,
  role_name varchar(50)
);

create table users (
  user_id serial primary key,
  username varchar(50) unique,
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
  image_header_id bigserial primary key,
  data_server_id bigint, -- external
  image_role_id int references image_role_lut(image_role_id),
  image_modality_id int references image_modality_lut(image_modality_id),
  uploaded_at timestamp,
  last_modified_at timestamp
);


create table study (
  study_id serial primary key,
  case_id int references surgery_case(case_id),
  study_name varchar(50),
  study_status_id int references study_status_lut(study_status_id),
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
  time_point_start int,
  time_point_end int,
  created_at timestamp,
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

-- definition of modules
-- e.g. study-gen, measurement
create table module (
  module_id serial primary key,
  module_name varchar(50),
  module_precedence_rank int, -- determines the order of execution
  module_description varchar
);

-- definition of module output
-- e.g. volume-main, volume-segmentation
create table module_output (
  module_output_id serial primary key,
  module_id int references module(module_id),
  module_output_name varchar(50)
);

-- module data header stores output of modules
create table module_data_header (
  module_data_header_id bigserial primary key,
  study_id int references study(study_id),
  module_output_id int references module_output(module_output_id),
  time_point int,
  primary_index int, -- e.g. label
  secondary_index int, -- e.g. component of label?
  data_server_id bigint -- external
);

create table module_data_index_name_lut (
  module_data_index_name_id serial primary key,
  module_data_index_name varchar(50)
);

-- module data index lut
create table module_data_index_lut (
  module_data_index_id serial primary key,
  module_output_id int references module_output(module_output_id),
  index_type int, -- 1 for primary, 2 for secondary
  index_name_id int references module_data_index_name_lut(module_data_index_name_id),
  index_value int, -- 1, 2, 3
  index_desc varchar(50) -- root, leaflet, etc.
);

-- module prerequisites (one module can have multiple prerequisites)
CREATE TABLE module_prerequisite (
  module_id int REFERENCES module(module_id),
  prerequisite_module_id int REFERENCES module(module_id),
  PRIMARY KEY (module_id, prerequisite_module_id)
);

-- study-module status lookup
CREATE TABLE study_module_status_lut (
  study_module_status_id serial PRIMARY KEY,
  study_module_status_name varchar(50)
);

-- study-module status
create table study_module_status (
  study_id int REFERENCES study(study_id),
  module_id int REFERENCES module(module_id),
  study_module_status_id int REFERENCES study_module_status_lut(study_module_status_id),
  primary key (study_id, module_id)
);
