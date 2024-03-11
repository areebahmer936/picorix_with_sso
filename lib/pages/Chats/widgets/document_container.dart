import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:picorix/config/themedata.dart';

class DocumentContainer extends StatefulWidget {
  final String url;
  final Directory extDir;
  const DocumentContainer({super.key, required this.url, required this.extDir});

  @override
  State<DocumentContainer> createState() => _DocumentContainerState();
}

enum FileStatus { downloaded, toBeDownloaded, downloading }

class _DocumentContainerState extends State<DocumentContainer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String documentName = "";
  String documentUrl = "";
  String documentSize = "";
  bool docExists = false;
  String externalPath = "";
  bool downloading = false;
  double progress = 0.0;

  var state = FileStatus.toBeDownloaded;
  final Dio _dio = Dio();
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    documentUrl = widget.url.split(":::").first;
    documentName = Uri.parse(documentUrl).pathSegments.last.split("/").last;
    documentSize = widget.url.split(":::").last;
    String documentsPath = "${widget.extDir.path}/documents";
    // Check if the "documents" folder exists, create it if not
    Directory(documentsPath).create(recursive: true);

    externalPath = "$documentsPath/$documentName";
    print("doc path: " + documentsPath);
    print("external path: " + externalPath);

    bool fileExists = File(externalPath).existsSync();
    docExists = fileExists;
    super.initState();
  }

  Future<void> downloadFile(String url, String savePath) async {
    try {
      setState(() {
        downloading = true;
      });
      await _dio.download(
        documentUrl,
        externalPath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          setState(() {
            progress = (count / total);
          });
        },
      );
      setState(() {
        downloading = false;
        docExists = true;
      });
    } catch (e) {}
  }

  formatFileName(fileName) {
    if (fileName.length <= 20) {
      return fileName;
    } else {
      String baseName = fileName.split('.').first;
      String extension = fileName.split('.').last;

      String start = baseName.substring(0, 5);
      String end = baseName.substring(baseName.length - 4);
      fileName = '$start...$end.$extension';
      return fileName;
    }
  }

  void cancelDownload() {
    setState(() {
      downloading = false;
      progress = 0.0;
    });
    cancelToken.cancel("Download canceled by user");
    cancelToken = CancelToken();
    File(externalPath).existsSync() ? File(externalPath).deleteSync() : null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 80,
      width: 290,
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                height: 70,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/Icons/file.svg",
                    colorFilter:
                        ColorFilter.mode(Colors.grey.shade600, BlendMode.srcIn),
                  ),
                )),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                formatFileName(documentName),
                overflow: TextOverflow.clip,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              Text(
                documentSize,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          const Spacer(),
          docExists
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      OpenFile.open(externalPath);
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.shade400,
                      ),
                      child: Center(
                          child: SvgPicture.asset(
                        "assets/Icons/open.svg",
                        colorFilter: ColorFilter.mode(
                            Colors.grey.shade600, BlendMode.srcIn),
                        height: 25,
                      )),
                    ),
                  ),
                )
              : downloading
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.grey.shade400,
                              ),
                              child: Center(
                                  child: SvgPicture.asset(
                                "assets/Icons/cancel.svg",
                                colorFilter: ColorFilter.mode(
                                    Colors.grey.shade600, BlendMode.srcIn),
                                height: 21,
                              )),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            cancelDownload();
                          },
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              value: progress,
                            ),
                          ),
                        )
                      ],
                    )

                  // ? ValueListenableBuilder(
                  //     valueListenable: task!.progress,
                  //     builder: (context, value, child) {
                  //       return Stack(
                  //         alignment: Alignment.center,
                  //         children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(10.0),
                  //             child: InkWell(
                  //               onTap: () {
                  //                 downloadManager.cancelDownload(documentUrl);
                  //                 downloadManager.removeDownload(documentUrl);
                  //                 var fileName = externalPath;
                  //                 var file = File(fileName);
                  //                 file.existsSync()
                  //                     ? file.delete()
                  //                     : print("doesnt exist");
                  //               },
                  //               child: Container(
                  //                 height: 45,
                  //                 width: 45,
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(100),
                  //                   color: Colors.grey.shade400,
                  //                 ),
                  //                 child: Center(
                  //                     child: SvgPicture.asset(
                  //                   "assets/Icons/cancel.svg",
                  //                   colorFilter: ColorFilter.mode(
                  //                       Colors.grey.shade600, BlendMode.srcIn),
                  //                   height: 25,
                  //                 )),
                  //               ),
                  //             ),
                  //           ),
                  //           SizedBox(
                  //             height: 45,
                  //             width: 45,
                  //             child: CircularProgressIndicator(
                  //               color: blue,
                  //               value: value,
                  //             ),
                  //           )
                  //         ],
                  //       );
                  //     })
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          downloadFile(documentUrl, externalPath);
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.grey.shade400,
                          ),
                          child: Center(
                              child: SvgPicture.asset(
                            "assets/Icons/download.svg",
                            colorFilter: ColorFilter.mode(
                                Colors.grey.shade600, BlendMode.srcIn),
                            height: 25,
                          )),
                        ),
                      ),
                    )
        ],
      ),
    );
  }
}
