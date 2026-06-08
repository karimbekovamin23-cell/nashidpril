const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { v4: uuidv4 } = require('uuid');

const endpoint = process.env.S3_ENDPOINT || `https://s3.${process.env.AWS_REGION}.amazonaws.com`;

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  endpoint,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

const BUCKET = process.env.AWS_S3_BUCKET;

const uploadFile = async (buffer, mimetype, folder) => {
  const ext = mimetype.split('/')[1];
  const key = `${folder}/${uuidv4()}.${ext}`;

  await s3.send(
    new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      Body: buffer,
      ContentType: mimetype,
    })
  );

  const baseUrl = process.env.S3_ENDPOINT
    ? `${process.env.S3_ENDPOINT}/${BUCKET}`
    : `https://${BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com`;

  return `${baseUrl}/${key}`;
};

const deleteFile = async (url) => {
  const parts = url.split(`/${BUCKET}/`);
  const key = parts[1];
  if (!key) return;
  await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
};

module.exports = { uploadFile, deleteFile };
