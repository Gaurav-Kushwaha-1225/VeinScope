import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';

void server(List<String> args) async {
  final socket = await SSHSocket.connect('172.18.40.134', 22);

  final client = SSHClient(
    socket,
    username: 'teaching',
    onPasswordRequest: () {
      stdout.write('ds123');
      stdin.echoMode = false;
      return stdin.readLineSync() ?? exit(1);
    },
  );

  final uptime = await client.run('uptime');
  print(utf8.decode(uptime));

  client.close();
  await client.done;
}

Future<void> processImageOnServer(String localImagePath, String outputImagePath) async {
  final socket = await SSHSocket.connect('172.18.40.134', 22);

  final client = SSHClient(
    socket,
    username: 'teaching',
    onPasswordRequest: () {
      return 'ds123'; // Provide the password directly
    },
  );

  try {
    // Upload the image to the server
    final remoteInputPath = '/input_image.png';
    final remoteOutputPath = '/output_image.png';
    final file = File(localImagePath);
    final sftp = await client.sftp();

    // Open a file on the server for writing
    final remoteFile = await sftp.open(remoteInputPath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
    await remoteFile.write(Stream.fromIterable([file.readAsBytesSync()]));
    await remoteFile.close();

    // Run the Python script
    final result = await client.run('python3 a.py');
    print(utf8.decode(result));

    // Open the output file on the server for reading
    final outputFile = File(outputImagePath);
    final remoteOutputFile = await sftp.open(remoteOutputPath, mode: SftpFileOpenMode.read);
    final Uint8List outputBytes = await remoteOutputFile.readBytes();
    await outputFile.writeAsBytes(outputBytes);
    await remoteOutputFile.close();

    print('Image processed and saved to $outputImagePath');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
    await client.done;
  }
}