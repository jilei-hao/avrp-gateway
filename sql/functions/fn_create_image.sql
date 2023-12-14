create or replace function fn_create_image (
  _file_server_path varchar,
  _image_role_name varchar(50),
  _image_modality_name varchar(50),
  _uploaded_by_user_id int
)
returns int
as
$$
declare
  new_image_id int;
begin
  -- validation
  if _file_server_path = '' or _file_server_path is null then
    raise exception 'FileServerPath cannot be empty or null!';
  end if;

  if not exists (select 1 from image_role_lut where image_role_name = _image_role_name) then
    raise exception 'Invalid image role: %', _image_role_name;
  end if;

  if not exists (select 1 from image_modality_lut where image_modality_name = _image_modality_name) then
    raise exception 'Invalid image modality: %', _image_modality_name;
  end if;

  if not exists (select 1 from users where user_id = _uploaded_by_user_id) then
    raise exception 'Invalid user id: %', _uploaded_by_user_id;
  end if;

  -- start inserting
  insert into image_header (
    file_server_path,
    image_role_id,
    image_modality_id,
    uploaded_by_id,
    uploaded_datetime
  )
  values (
    _file_server_path,
    (select image_role_id from image_role_lut where image_role_name = _image_role_name),
    (select image_modality_id from image_modality_lut where image_modality_name = _image_modality_name),
    _uploaded_by_user_id,
    now()
  )
  returning image_id into new_image_id;

  return new_image_id;

end;
$$
language plpgsql;