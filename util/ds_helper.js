// a helper class to communicate with the data server
import dotenv from 'dotenv';
import fetch from 'node-fetch';
import FormData from 'form-data';
import fs from 'fs';

dotenv.config();

export async function ds_PostData(_cachedFilePath, _path, _filename) {
  const formData = new FormData();
  formData.append('file', fs.createReadStream(_cachedFilePath));
  formData.append('path', _path);
  formData.append('filename', _filename);
  formData.append('create_folder_if_not_exists', 'true');

  return fetch(`${process.env.DATA_SERVER_URL}/data`, {
    method: 'POST',
    body: formData
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok. Message: ' + response.statusText);
    }
    return response.json();
  })
  .then(data => {
    return data.fileId;
  })
  .catch(error => {
    console.error(error);
  });
}