create or replace function fn_get_image_modalities ()
returns table (image_modality_name varchar(50))
as
$$
begin
  -- validation
  return query
  select image_modality_name
  from image_modality_lut;
end;
$$
language plpgsql;