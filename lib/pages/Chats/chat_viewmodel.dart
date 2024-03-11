import "dart:async";
import "dart:math";
import "dart:io";

import "package:audioplayers/audioplayers.dart" as sound_effect_player;
import "package:cloud_firestore/cloud_firestore.dart";
import "package:extended_image/extended_image.dart";
import "package:file_picker/file_picker.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_sound/public/flutter_sound_player.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:image_picker/image_picker.dart";
import "package:logger/logger.dart";
// import "package:magika_chat/Utility/helper_functions.dart";
import "package:path_provider/path_provider.dart";
import "package:picorix/models/app_user.dart";
import "package:picorix/models/message.dart";
import "package:record/record.dart" as record;
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:stacked/stacked.dart";
import "package:video_thumbnail/video_thumbnail.dart";

class ChatViewModel extends BaseViewModel {
  TextEditingController chatMessageController = TextEditingController();
  final String chatRoomId;
  final AppUser user;
  String lastSenderUid;
  String? archiveTime;
  late String? userId;
  late Map userData;
  bool? isBlocked;
  bool? isMeBlocked;

  ChatViewModel(
      {required this.myUid,
      required this.chatRoomId,
      required this.lastSenderUid,
      required this.user,
      this.isBlocked,
      this.isMeBlocked,
      this.archiveTime});
  bool isLoading = false;
  String myUid;

  // For Image Media
  XFile imageFile = XFile("");
  bool imageSelected = false;
  bool isImageSending = false;
  ImagePicker imagePicker = ImagePicker();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For Audio Media
  final _audioRecorder = record.AudioRecorder();
  StreamSubscription<record.RecordState>? _recordSub;
  record.RecordState recordState = record.RecordState.stop;
  FlutterSoundPlayer audioPlayer = FlutterSoundPlayer(logLevel: Level.nothing);
  bool isRecorded = false;
  final soundPlayer = sound_effect_player.AudioPlayer();
  String audioPath = "";
  bool isRecording = false;
  String audioDownloadUrl = '';
  bool isAudioSending = false;
  late Timer _timer;
  late Timer _timer2;
  int recordDuration = 0;

  // For Document Media
  FilePickerResult? result;
  PlatformFile? docFile;
  bool fileSelected = false;
  bool showProgress = false;
  double progressValue = 0.0;
  double fileSize = 0.0;
  String fileSizeString = '';
  String documentFileName = "";
  bool isDocSending = false;
  Directory? externalDirectory;

  // For Video Media
  XFile videoFile = XFile("");
  bool videoFileSelected = false;
  double videoFileSize = 0.0;
  String videoFileSizeString = '';
  bool isVideoSending = false;
  String videoFileName = '';
  File videoThumbnail = File("");

  DocumentSnapshot? _lastDocument;
  bool isLoadingMore = false;
  bool isAllLoaded = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  StreamSubscription<DocumentSnapshot>? _blockListenerSubscription;
  StreamSubscription<DocumentSnapshot>? _isFriendSubscription;
  final ScrollController scrollController = ScrollController();

  final StreamController<List<DocumentSnapshot<Map<String, dynamic>>>>
      _chatController = StreamController<
          List<DocumentSnapshot<Map<String, dynamic>>>>.broadcast();

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> get chatStream =>
      _chatController.stream;
  List<DocumentSnapshot<Map<String, dynamic>>> chats = [];

  // Method to set the status
  Future<void> setStatus(bool status) async {
    Map<String, dynamic> isViewing = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .get()
        .then((value) => value.data()!["isViewing"] ?? {});
    isViewing[myUid] = [status, DateTime.now().toUtc().toIso8601String()];
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .update({
      "isViewing": isViewing,
    });
  }

// Method to start periodic status update
  void startPeriodicStatusUpdate() {
    setStatus(true);

    _timer2 = Timer.periodic(const Duration(minutes: 1), (timer) {
      setStatus(true);
    });
  }

  // Method to handle app lifecycle changes
  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startPeriodicStatusUpdate();
    } else {
      _timer2.cancel();
      setStatus(false);
    }
  }

  Future initializeCurrentUser(context) async {
    externalDirectory = await getExternalStorageDirectory();
    startPeriodicStatusUpdate();
    userId = myUid;
    scrollController.addListener(scrollListener);
    stream = archiveTime != null
        ? FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chatRoomId)
            .collection("chats")
            .orderBy("timeStamp", descending: true)
            .where("timeStamp", isGreaterThan: archiveTime)
            .limit(50)
            .snapshots()
        : FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chatRoomId)
            .collection("chats")
            .orderBy("timeStamp", descending: true)
            .limit(50)
            .snapshots();
    notifyListeners();

    _subscription =
        stream!.listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final newDocuments = snapshot.docs.where(
          (doc) => !chats.any((existingDoc) => existingDoc.id == doc.id));

      if (chats.isEmpty) {
        chats.addAll(snapshot.docs);
        _chatController.add(chats);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        notifyListeners();
      } else if (newDocuments.isNotEmpty) {
        chats.insertAll(0, newDocuments);
        _chatController.add(chats);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        notifyListeners();
      }

      for (DocumentChange change in snapshot.docChanges) {
        final doc = change.doc;
        if (change.type == DocumentChangeType.modified) {
          final index =
              chats.indexWhere((existingDoc) => existingDoc.id == doc.id);
          if (index != -1) {
            int indexWhere = chats.indexWhere((chatRoom) {
              return change.doc.id == chatRoom.id;
            });

            if (indexWhere >= 0) {
              chats[indexWhere] =
                  change.doc as DocumentSnapshot<Map<String, dynamic>>;
            }
            _chatController.add(chats);
            notifyListeners();
          }
        } else if (change.type == DocumentChangeType.added) {
          lastSenderUid = change.doc.get("userUid");
        }
      }
    });

    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentReference chatRoomRef =
        firestore.collection("chatRooms").doc(chatRoomId);

    _blockListenerSubscription =
        documentRef.snapshots().listen((DocumentSnapshot snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data['blockList'] != null) {
        List blockList = data['blockList'];
        if (blockList.contains(userId)) {
          isMeBlocked = true;
          notifyListeners();
          // Future.delayed(const Duration(seconds: 2), () {
          //   Navigator.pop(context);
          // });
        }
      }
    });
    _isFriendSubscription =
        chatRoomRef.snapshots().listen((DocumentSnapshot snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;

      if (data!["areFriends"] != null && data["areFriends"] == false) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final document =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    userData = document.data()!;

    print(archiveTime);
    _recordSub = _audioRecorder.onStateChanged().listen((recordStateThis) {
      recordState = recordStateThis;
    });
    audioPath = "";
    notifyListeners();
    audioPlayer.setLogLevel(Level.nothing);
    audioPlayer.openPlayer();
  }

  Future fetchNextChats() async {
    if (isLoadingMore || _lastDocument == null) return;
    isLoadingMore = true;
    notifyListeners();
    print("doing");

    (archiveTime != null
            ? firestore
                .collection("chatRooms")
                .doc(chatRoomId)
                .collection("chats")
                .orderBy("timeStamp", descending: true)
                .where("timeStamp", isGreaterThan: archiveTime)
                .limit(50)
                .startAfterDocument(_lastDocument!)
                .get()
            : firestore
                .collection("chatRooms")
                .doc(chatRoomId)
                .collection("chats")
                .orderBy("timeStamp", descending: true)
                .limit(50)
                .startAfterDocument(_lastDocument!)
                .get())
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newDocuments = snapshot.docs.where(
            (doc) => !chats.any((existingDoc) => existingDoc.id == doc.id));
        if (newDocuments.isNotEmpty) {
          chats.addAll(newDocuments);
          _chatController.add(chats);
          isLoadingMore = false;
          notifyListeners();
        }
      } else {
        isLoadingMore = false;
        isAllLoaded = true;
        notifyListeners();
        print("No more documents available.");
      }
    }).catchError((error) {
      isLoadingMore = false;
      notifyListeners();
    });
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isAllLoaded ? null : fetchNextChats();
    }
  }

// AUDIO

  Future<void> start() async {
    isRecording = true;
    notifyListeners();
    recordDuration = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      recordDuration++;
      notifyListeners();
    });

    try {
      if (await _audioRecorder.hasPermission()) {
        final isSupported = await _audioRecorder.isEncoderSupported(
          record.AudioEncoder.aacLc,
        );
        print('${record.AudioEncoder.aacLc.name} supported: $isSupported');
        // isRecording = await _audioRecorder.isRecording();
        final directory = await getTemporaryDirectory();
        await _audioRecorder.start(const record.RecordConfig(),
            path: "${directory.path}/awdwd.aac");
        // recordDuration = 0;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stop() async {
    isRecording = false;
    _timer.cancel();
    notifyListeners();

    final path = await _audioRecorder.stop();
    if (path != null) {
      audioPath = path;
      isRecorded = true;
      notifyListeners();
    }
  }

  String formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    return '$formattedMinutes:$formattedSeconds';
  }

  Future<void> uploadAudio() async {
    isAudioSending = true;
    final time = DateTime.now();
    notifyListeners();
    if (audioPath == "") {
      print("empty");
      return;
    }

    try {
      String fileName = '${time.millisecondsSinceEpoch}.aac';
      // Get a reference to the storage service
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('audioMessages/user_${userData['uid']}/$fileName');

      // Upload the file
      await storageReference.putFile(File(audioPath));
      audioDownloadUrl = await storageReference.getDownloadURL();

      Message msg = Message(
          userName: userData["userName"],
          userUid: userData["uid"],
          content: "$audioDownloadUrl:::${formatDuration(recordDuration)}",
          type: "audio",
          timeStamp: time,
          seenBy: [],
          reactions: {},
          previousSenderUid: lastSenderUid);

      await firestore
          .collection("chatRooms")
          .doc(chatRoomId)
          .collection("chats")
          .add(msg.toJson())
          .whenComplete(() {
        lastSenderUid = userData['uid'];
        isAudioSending = false;
        isRecorded = false;
        audioPath = '';
        notifyListeners();
      });
      final chatRoomDocument =
          await firestore.collection("chatRooms").doc(chatRoomId).get();
      Map<String, dynamic> unreadCounts =
          chatRoomDocument.data()!["unreadCounts"];
      unreadCounts.forEach((key, value) {
        if (key != userId) {
          unreadCounts[key] += 1;
        }
      });
      // Update the chat room document with the modified unreadCounts map
      await firestore
          .collection("chatRooms")
          .doc(chatRoomId)
          .update({'unreadCounts': unreadCounts});
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomId)
          .update({
        "lastMessage": "${userData['userName']} sent an audio.",
        "lastMessageTime": time.toUtc().toIso8601String(),
        "lastSenderUid": userData['uid']
      });

      // Reset the progress bar

      print('File uploaded successfully');
      print('Download URL: $audioDownloadUrl');
    } on FirebaseException catch (e) {
      print('Error uploading file: $e');
    }
  }

// DOCUMENTS

  selectFile(context) async {
    result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        dialogTitle: "size <= 50 mbs",
        allowedExtensions: [
          "torrent",
          "kml",
          "gpx",
          "csv",
          "asf",
          "bin",
          "c",
          "class",
          "conf",
          "cpp",
          "doc",
          "docx",
          "xls",
          "xlsx",
          "exe",
          "gtar",
          "gz",
          "h",
          "htm",
          "html",
          "jar",
          "jpeg",
          "jpg",
          "java",
          "js",
          "log",
          "mp2",
          "mp3",
          "mpc",
          "mpe",
          "mpeg",
          "mpg",
          "mpg4",
          "mpga",
          "msg",
          "pdf",
          "pps",
          "ppt",
          "pptx",
          "prop",
          "rc",
          "rmvb",
          "rtf",
          "sh",
          "tar",
          "tgz",
          "txt",
          "wmv",
          "wps",
          "xml",
          "z",
        ]);
    late double fileSizeInMB;
    if (result != null) {
      docFile = result?.files.first;
      fileSizeInMB = docFile!.size / (1024 * 1024);
      if (fileSizeInMB > 50) {
        showSnackBar(context, "File size should be less than 50 mbs");
        result = null;
        removeFileFromCache(docFile!.path);
        return;
      } else {
        fileSelected = true;
        documentFileName = formatFileName(result!.files.first.name);
        fileSize = fileSizeInMB;
        fileSizeString = formatFileSize(fileSizeInMB);
        notifyListeners();
      }
    }
  }

  formatFileSize(fileSizeInMB) {
    String sizeString = '';
    if (fileSizeInMB >= 1) {
      // Display in MB with two decimal places
      sizeString = "${fileSizeInMB.toStringAsFixed(2)} MB";
    } else {
      double fileSizeInKB = docFile!.size / 1024;

      if (fileSizeInKB >= 1) {
        // Display in KB with two decimal places
        sizeString = "${fileSizeInKB.toStringAsFixed(2)} KB";
      } else {
        // Display in bytes
        sizeString = "${docFile!.size} Bytes";
      }
    }
    return sizeString;
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

  Future<void> moveFileToExternalStorage(PlatformFile file) async {
    try {
      // Get the external storage directory
      Directory? externalDirectory = await getExternalStorageDirectory();

      if (externalDirectory != null) {
        // Create a File object from the PlatformFile
        File platformFile = File(file.path!);

        // Construct paths for the destination in external storage
        String documentsPath = "${externalDirectory.path}/documents";
        String externalPath = "$documentsPath/${file.name}";

        // Check if the "documents" folder exists, create it if not
        Directory(documentsPath).create(recursive: true);

        // Copy the file from its original location to external storage
        await platformFile.copy(externalPath);

        print("File moved to external storage: $documentsPath");
      } else {
        print("External storage directory not found.");
      }
    } catch (e) {
      print("Error moving file to external storage: $e");
    }
  }

  removeDocument() {
    isDocSending = false;
    result = null;
    removeFileFromCache(docFile!.path);
    docFile = null;
    fileSelected = false;
    showProgress = false;
    progressValue = 0.0;
    fileSize = 0.0;
    fileSizeString = '';
    documentFileName = "";
    notifyListeners();
  }

  uploadDocument() async {
    final time = DateTime.now();
    String downloadUrl = "";

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("ChatMedia/User_$userId/Documents/${result!.files.first.name}");
    isDocSending = true;
    notifyListeners();
    try {
      await storageReference.getMetadata();
    } catch (e) {
      if (fileSize > 10) {
        showProgress = true;
        progressValue = 0.0;
        notifyListeners();
        UploadTask uploadTask =
            storageReference.putData(result!.files.first.bytes!);
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          progressValue = snapshot.bytesTransferred.toDouble() /
              snapshot.totalBytes.toDouble();
          notifyListeners();
        });
        await uploadTask;
      } else {
        Reference storageReference = FirebaseStorage.instance.ref().child(
            "ChatMedia/User_$userId/Documents/${result!.files.first.name}");
        UploadTask uploadTask =
            storageReference.putData(result!.files.first.bytes!);
        await uploadTask;
      }
    }
    await moveFileToExternalStorage(result!.files.first);
    downloadUrl = await storageReference.getDownloadURL();
    Message msg = Message(
        userName: userData["userName"],
        userUid: userData["uid"],
        content: "$downloadUrl:::$fileSizeString",
        type: "document",
        timeStamp: time,
        seenBy: [],
        reactions: {},
        previousSenderUid: lastSenderUid);
    // removeDocument();
    lastSenderUid = userData['uid'];
    await firestore
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .add(msg.toJson());
    final chatRoomDocument =
        await firestore.collection('chatRooms').doc(chatRoomId).get();
    Map<String, dynamic> unreadCounts =
        chatRoomDocument.data()!["unreadCounts"];
    unreadCounts.forEach((key, value) {
      if (key != userId) {
        unreadCounts[key] += 1;
      }
    });
    await firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .update({'unreadCounts': unreadCounts});

    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .update({
      "lastMessage": "${userData['userName']} sent a Document.",
      "lastMessageTime": time.toUtc().toIso8601String(),
      "lastSenderUid": userData['uid']
    });

    removeDocument();
    print(downloadUrl);
  }

  Future<void> removeFileFromCache(String? filePath) async {
    try {
      var cacheManager = DefaultCacheManager();
      await cacheManager.removeFile(filePath!);
      print("File removed from cache: $filePath");
    } catch (e) {
      print("Error removing file from cache: $e");
    }
  }

  Future<void> checkRemainingCacheSize() async {
    try {
      Directory cacheDir = await getTemporaryDirectory();
      File dummyFile = File('${cacheDir.path}/dummy_file.txt');
      await dummyFile.writeAsString(''); // Create a dummy file

      Directory cacheParentDir = dummyFile.parent;
      FileStat stat = await cacheParentDir.stat();
      int availableSpace = stat.size;

      dummyFile.delete(); // Clean up the dummy file

      print(
          'Available space in cache directory: ${availableSpace / (1024 * 1024)} MB');
    } catch (e) {
      print('Error checking cache size: $e');
    }
  }

// IMAGES

  profileImage(snapshotData) {
    return ExtendedImage.network(
      snapshotData,
      fit: BoxFit.cover,
      // enableLoadState: false,
      gaplessPlayback: true,

      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return SvgPicture.asset("assets/app/userPlaceholder.svg");
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return SvgPicture.asset("assets/app/userPlaceholder.svg");
        }
      },
    );
  }

  selectImage() async {
    final XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      imageFile = selectedImage;
      imageSelected = true;
      notifyListeners();
    } else {
      return null;
    }
  }

  selectImageFromCamera() async {
    final XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (selectedImage != null) {
      imageFile = selectedImage;
      imageSelected = true;
      notifyListeners();
    } else {
      return null;
    }
  }

  upload(image) async {
    isImageSending = true;
    final time = DateTime.now();
    notifyListeners();
    String imageUrl = "";
    final ref = FirebaseStorage.instance
        .ref()
        .child('ChatMedia')
        .child("User_$userId")
        .child('${time.toIso8601String()}${image.name}');
    await ref.putFile(File(image.path));
    imageUrl = await ref.getDownloadURL();

    final msg = Message(
        userName: userData['userName'],
        userUid: userData['uid'],
        content: imageUrl,
        type: 'image',
        timeStamp: time,
        seenBy: [],
        previousSenderUid: lastSenderUid,
        reactions: {}).toJson();
    lastSenderUid = userData['uid'];
    await firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('chats')
        .add(msg);
    final chatRoomDocument =
        await firestore.collection('chatRooms').doc(chatRoomId).get();
    Map<String, dynamic> unreadCounts =
        chatRoomDocument.data()!["unreadCounts"];
    unreadCounts.forEach((key, value) {
      if (key != userId) {
        unreadCounts[key] += 1;
      }
    });
    // Update the chat room document with the modified unreadCounts map
    await firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .update({'unreadCounts': unreadCounts});

    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .update({
      "lastMessage": "${userData['userName']} sent an image.",
      "lastMessageTime": time.toUtc().toIso8601String(),
      "lastSenderUid": userData['uid']
    });
    isImageSending = false;
    imageFile = XFile("");
    imageSelected = false;
    notifyListeners();
  }

// TEXT

  deleteMessage(message) async {
    final messageDocRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection("chats")
        .doc(message);
    final chatDocRef =
        FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId);

    await messageDocRef.update({"isDeleted": true, "reactions": {}});
    final doc = await chatDocRef.get();
    final messageDoc = await messageDocRef.get();
    if (doc.data()!["lastMessageTime"] == messageDoc.data()!["timeStamp"]) {
      await chatDocRef.update({"lastMessage": "user deleted the message"});
    }
  }

  addReaction(message, reaction) async {
    final uid = userId;
    final chatDocRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection("chats")
        .doc(message);

    final chatDoc = await chatDocRef.get();

    final Map<String, dynamic> reactions = chatDoc.data()!['reactions'];
    if (reaction == 'cancel') {
      if (reactions.containsKey(uid)) {
        reactions.remove(uid);
      }
    } else {
      reactions.addAll({userId!: reaction});
    }
    await chatDocRef.update({'reactions': reactions});
  }

  sendMessage(currentChatRoomId, type, chat) async {
    final time = DateTime.now();
    final chatRoomRef =
        firestore.collection("chatRooms").doc(currentChatRoomId);
    if (chatMessageController.text.isNotEmpty) {
      Message message = Message(
          content: chatMessageController.text,
          timeStamp: time,
          userName: userData['userName'],
          type: "text",
          seenBy: [],
          reactions: {},
          userUid: userId!,
          previousSenderUid: lastSenderUid);
      chatMessageController.clear();
      lastSenderUid = userData['uid'];
      await chatRoomRef.collection("chats").add(message.toJson());

      final chatRoomDocument = await chatRoomRef.get();
      Map<String, dynamic> unreadCounts =
          chatRoomDocument.data()!["unreadCounts"];
      unreadCounts.forEach((key, value) {
        if (key != userId) {
          unreadCounts[key] += 1;
        }
      });
      // Update the chat room document with the modified unreadCounts map
      await chatRoomRef.update({'unreadCounts': unreadCounts});

      await chatRoomRef.update({
        "lastMessage": message.content,
        "lastMessageTime": time.toUtc().toIso8601String(),
        "lastSenderUid": userData["uid"]
      });
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
    );
  }

  // VIDEO

  Future<void> pickVideo(context) async {
    try {
      final picker = ImagePicker();
      var pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) {
        return;
      }
      videoFile = pickedFile;
      int size = await pickedFile.length();
      videoFileSize = size / (1024 * 1024);
      if (videoFileSize > 50) {
        throw RangeError("File Size Should be less than 50");
      }
      videoFileSizeString = await formatBytes(pickedFile.path, 2);
      videoFileName = formatFileName(videoFile.name);
      videoFileSelected = true;
      notifyListeners();
    } catch (e) {
      showSnackBar(context, e.toString());
      removeFileFromCache(videoFile.path);

      return;
    }
  }

  uploadVideo() async {
    final time = DateTime.now();

    String downloadUrl = "";
    String thumbnailUrl = "";

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("ChatMedia/User_$userId/Videos/${videoFile.name}");
    Reference thumbnailStorageReference = FirebaseStorage.instance
        .ref()
        .child("ChatMedia/User_$userId/Videos/${videoFile.name}.png");
    isVideoSending = true;
    isVideoSending = true;

    notifyListeners();
    await moveVideoToExternalStorage(videoFile);

    try {
      await storageReference.getMetadata();
    } on FirebaseException catch (e) {
      if (e.message.toString().toLowerCase() == "not found.") {
        print("yes");
      }

      if (videoFileSize > 10) {
        showProgress = true;
        progressValue = 0.0;
        notifyListeners();

        await thumbnailStorageReference.putFile(File(videoThumbnail.path));
        thumbnailUrl = await thumbnailStorageReference.getDownloadURL();
        UploadTask uploadTask = storageReference.putFile(File(videoFile.path));
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          progressValue = snapshot.bytesTransferred.toDouble() /
              snapshot.totalBytes.toDouble();
          notifyListeners();
        });
        await uploadTask;
      } else {
        await thumbnailStorageReference.putFile(File(videoThumbnail.path));
        thumbnailUrl = await thumbnailStorageReference.getDownloadURL();
        UploadTask uploadTask = storageReference.putFile(File(videoFile.path));
        await uploadTask;
      }
    }

    downloadUrl = await storageReference.getDownloadURL();
    Message msg = Message(
        userName: userData["userName"],
        userUid: userData["uid"],
        content: "$downloadUrl:::$thumbnailUrl",
        type: "video",
        timeStamp: time,
        seenBy: [],
        reactions: {},
        previousSenderUid: lastSenderUid);
    // removeDocument();
    lastSenderUid = userData['uid'];
    await firestore
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .add(msg.toJson());
    final chatRoomDocument =
        await firestore.collection('chatRooms').doc(chatRoomId).get();
    Map<String, dynamic> unreadCounts =
        chatRoomDocument.data()!["unreadCounts"];
    unreadCounts.forEach((key, value) {
      if (key != userId) {
        unreadCounts[key] += 1;
      }
    });
    await firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .update({'unreadCounts': unreadCounts});

    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .update({
      "lastMessage": "${userData['userName']} sent a Video.",
      "lastMessageTime": time.toUtc().toIso8601String(),
      "lastSenderUid": userData['uid']
    });

    removeVideo();
    //print(downloadUrl);
  }

  removeVideo() {
    removeFileFromCache(videoFile.path);
    videoFile = XFile("");
    videoFileSelected = false;
    showProgress = false;
    progressValue = 0.0;
    videoFileSize = 0.0;
    videoFileSizeString = '';
    notifyListeners();
  }

  Future<void> moveVideoToExternalStorage(
    XFile xFile,
  ) async {
    try {
      if (externalDirectory != null) {
        // Construct paths for the destination in external storage
        String thumbnailPath = "${externalDirectory!.path}/thumbnails";
        Directory(thumbnailPath).create(recursive: true);

        Uint8List? uint8list = await VideoThumbnail.thumbnailData(
          video: xFile.path,
          quality: 10,
          maxHeight: 250,
          imageFormat: ImageFormat.PNG,
        );

        File thumbnailFile = await File(
                '${externalDirectory!.path}/thumbnails/${xFile.name}.png')
            .create();
        thumbnailFile.writeAsBytesSync(uint8list!);
        videoThumbnail = thumbnailFile;
        //String VideosPath = "${externalDirectory!.path}/videos";
        //String externalPath = "$VideosPath/${xFile.name}";
        // Check if the "documents" folder exists, create it if not
        ///Directory(VideosPath).create(recursive: true);

        // Copy the file from its original location to external storage
        //await file.copy(externalPath);

        //print("File moved to external storage: $VideosPath");
      } else {
        print("External storage directory not found.");
      }
    } catch (e) {
      print("Error moving file to external storage: $e");
    }
  }

  formatBytes(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  void dispose() {
    _timer2.cancel();
    setStatus(false);
    print("lol");
    _timer.isActive ? _timer.cancel() : null;
    _subscription!.cancel();
    _isFriendSubscription!.cancel();
    _blockListenerSubscription!.cancel();
    _recordSub?.cancel();
    _audioRecorder.dispose();
    audioPlayer.closePlayer();
    super.dispose();
  }
}
