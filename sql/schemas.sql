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

create table study_status_lut (
  study_status_id serial primary key,
  study_status_name varchar(100)
);

create table study (
  study_id serial primary key,
  study_name varchar(50),
  case_id int references surgery_case(case_id),
  study_status_id int references study_status_lut(study_status_id),
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

-- module prerequisites
create table module_prerequisite (
  module_id int references module(module_id),
  prerequisite_module_id int references module(module_id),
  primary key (module_id, prerequisite_module_id)
);

-- configuration_key_type_lut
create table configuration_key_type_lut (
  configuration_key_type_id serial primary key,
  configuration_key_type_name varchar(50)
);

-- module configuration keys
create table module_configuration_keys (
  module_configuration_key_id serial primary key,
  module_id int references module(module_id),
  configuration_key_name varchar(50),
  configuration_key_type_id int references configuration_key_type_lut(configuration_key_type_id)
);

-- study module configurations
create table module_configuration (
  module_configuration_id serial primary key,
  module_id int references module(module_id),
  module_configuration_key_id int references module_configuration_keys(module_configuration_key_id),
  configuration_value varchar(50)
);

-- application data type lookup
create table application_data_type_lut (
  application_data_type_id serial primary key,
  application_data_type_name varchar(50)
);

create table image_metadata (
  image_metadata_id serial primary key,
  image_modality_id int references image_modality_lut(image_modality_id)
);

-- application level generic data header
create table application_data_header (
  application_data_header_id bigserial primary key,
  data_server_id bigint, -- external
  application_data_type_id int references application_data_type_lut(application_data_type_id),
  meta_data_id int
);

-- definition of module output
-- e.g. volume-main, volume-segmentation
create table module_output (
  module_output_id serial primary key,
  module_id int references module(module_id),
  module_output_name varchar(50)
);

-- indicates how a record is associated with time point
-- e.g. all, specific, etc. 
create table time_point_type_lut (
  time_point_type_id serial primary key,
  time_point_type_name varchar(50)
);

-- module dependency
create table module_dependency (
  module_dependency_id serial primary key,
  dependent_module_id int references module(module_id),
  required_module_output_id int references module_output(module_output_id),
  time_point_type_id int references time_point_type_lut(time_point_type_id),
  time_point int,
  primary_index int,
  secondary_index int
)

-- module data header stores output of modules
create table module_data_header (
  module_data_header_id bigserial primary key,
  study_id int references study(study_id),
  module_output_id int references module_output(module_output_id),
  time_point int,
  primary_index int, -- e.g. label
  secondary_index int, -- e.g. component of label?
  application_data_header_id int references application_data_header(application_data_header_id)
);

create table module_data_index_name_lut (
  module_data_index_name_id serial primary key,
  module_data_index_name varchar(50)
);

create table moduel_data_index_type_lut (
  module_data_index_type_id serial primary key,
  module_data_index_type_name varchar(50)
);

-- module data index lut
create table module_data_index_lut (
  module_data_index_id serial primary key,
  module_output_id int references module_output(module_output_id),
  module_data_index_type_id int references moduel_data_index_type_lut(module_data_index_type_id),
  index_name_id int references module_data_index_name_lut(module_data_index_name_id),
  index_value int, -- 1, 2, 3
  index_desc varchar(50) -- root, leaflet, etc.
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
