// a helper class to communicate with the data server
import dotenv from 'dotenv';
import fetch from 'node-fetch';
import FormData from 'form-data';
import fs from 'fs';

dotenv.config();

export async function ds_CheckFileExists(_folder, _filename) {
  return fetch(`${process.env.DATA_SERVER_URL}/data?folder=${_folder}&filename=${_filename}`, {
      method: 'HEAD'
    })
  .then(response => {
    const fileId = response.headers.get('X-File-Id');
    console.log("[ds_CheckFileExists] fileId: ", fileId);
    return fileId;
  })
  .catch(error => {
    console.error(error);
  });
}

// todo - this is not used
// rewrite it to download file from data server
export async function ds_GetFile(_fileId) {
  console.log("[ds_GetFile] id: ", _fileId);
  return fetch(`${process.env.DATA_SERVER_URL}/data?id=${_fileId}`, {
      method: 'GET'
    })
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok.');
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

export async function ds_PostFile(_cachedFilePath, _folder, _filename) {
  const formData = new FormData();
  formData.append('file', fs.createReadStream(_cachedFilePath));
  formData.append('folder', _folder);
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