import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:tubetube/cores/method.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/upload/short_video/short_video_details.dart';
import 'package:tubetube/features/upload/short_video/trim_slinder.dart';
import 'package:video_editor/video_editor.dart';

class ShortVideoScreen extends StatefulWidget {
  final File shortVideo;

  const ShortVideoScreen({
    Key? key,
    required this.shortVideo,
  }) : super(key: key);

  @override
  State<ShortVideoScreen> createState() => _ShortVideoScreenState();
}

class _ShortVideoScreenState extends State<ShortVideoScreen> {
  VideoEditorController? editorController;
  final isExporting = ValueNotifier<bool>(false);
  final exporingProgress = ValueNotifier<double>(0.0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editorController = VideoEditorController.file(
      widget.shortVideo,
      minDuration: const Duration(seconds: 3),
      maxDuration: const Duration(seconds: 60),
    );
    editorController!
        .initialize(aspectRatio: 4 / 3)
        .then((_) => setState(() {}));
  }

  Future<void> exportVideo() async {
    isExporting.value = true;
    final config = VideoFFmpegVideoEditorConfig(editorController!);
    final execute = await config.getExecuteConfig();
    final String command = execute.command;

    FFmpegKit.executeAsync(
      command,
      (session) async {
        final ReturnCode? code = await session.getReturnCode();
        if (ReturnCode.isSuccess(code)) {
          //Xuat video
          isExporting.value = false;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>ShortVideoDetails(video: widget.shortVideo),
            ),
          );
        } else {
          // Hien Loi
          showErrorSnackBar(
              "Thất Bại,không thể xuất video được .Vui lòng thử lại sau!",
              context);
        }
      },
      null,
      (status) {
        exporingProgress.value =
            config.getFFmpegProgress(status.getTime().toInt());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Đăng Video Shorts",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: editorController!.initialized
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blueGrey,
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                    CropGridViewer.preview(
                      controller: editorController!,
                    ),
                    const Spacer(),
                    MyTrimSlider(controller: editorController!, height: 50),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                (18),
                              ),
                            ),
                          ),
                          child: TextButton(
                              onPressed: exportVideo,
                              child: Text("XONG")),
                        ),
                      ),
                    )
                  ],
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
