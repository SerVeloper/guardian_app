import 'dart:io';
import 'package:aws_s3_upload/aws_s3_upload.dart';

class S3Service {

  static const bucket = "guardian-emergency-evidence";
  static const region = "us-east-1";

  static const accessKey = "TU_ACCESS_KEY";
  static const secretKey = "TU_SECRET_KEY";

  static Future uploadFile(File file, String name) async {

    final result = await AwsS3.uploadFile(
      accessKey: accessKey,
      secretKey: secretKey,
      file: file,
      bucket: bucket,
      region: region,
      destDir: "emergency",
      filename: name,
    );

    print(result);
  }
}