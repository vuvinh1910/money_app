import 'package:flutter/material.dart';

class FlutterCircleImagePicker {
  static Future<String?> showCircleImagePicker(
      BuildContext context, {
        required double imageSize,
        required ShapeBorder imagePickerShape,
        required Widget title,
        required Widget closeChild,
        required String searchHintText,
        required String noResultsText,
      }) async {
    String? imagePicked = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: imagePickerShape,
          title: title,
          content: Container(
            constraints: BoxConstraints(maxHeight: 350, minWidth: 450),
            child: Column(
              children: <Widget>[
                // Có thể thêm lại SearchBar ở đây nếu cần
                Flexible(
                  child: CircleImagePicker(
                    noResultsText: noResultsText,
                    imageSize: imageSize,
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: closeChild,
            )
          ],
        );
      },
    );

    return imagePicked;
  }
}

class CircleImagePicker extends StatefulWidget {
  final double imageSize;
  final String noResultsText;
  static void Function(VoidCallback fn)? reload;
  static Map<String, String> imgMap = {};

  const CircleImagePicker({
    required this.imageSize,
    required this.noResultsText,
    Key? key,
  }) : super(key: key);

  @override
  _CircleImagePickerState createState() => _CircleImagePickerState();
}

class _CircleImagePickerState extends State<CircleImagePicker> {
  @override
  void initState() {
    super.initState();
    CircleImagePicker.imgMap = imgUrl;
    CircleImagePicker.reload = setState;
  }

  List<Widget> _buildImages(BuildContext context) {
    List<Widget> result = [];

    CircleImagePicker.imgMap.forEach((String key, String imgUrl) {
      result.add(
        InkResponse(
          onTap: () => Navigator.pop(context, imgUrl),
          child: SizedBox(
            height: widget.imageSize,
            width: widget.imageSize,
            child: Image.asset(imgUrl),
          ),
        ),
      );
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: CircleImagePicker.imgMap.isNotEmpty
                ? _buildImages(context)
                : [
              Center(
                child: Text(widget.noResultsText),
              ),
            ],
          ),
        ),
      ),
      IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment(0.0, 0.3),
              colors: [Colors.white, Color(0x1AFFFFFF)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ),
      IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment(0.0, -0.3),
              colors: [Colors.white, Color(0x1AFFFFFF)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ),
    ]);
  }
}

Map<String, String> imgUrl = {
  'bank': 'assets/logo.png',
  'wallet': 'assets/bank.png',
  'dollar': 'assets/dollar.png',
  'jp-yen': 'assets/jp-yen.png',
  'e-wallet': 'assets/e-wallet.png',
  'bitcocin': 'assets/bitcoin.png',
  'bank-card': 'assets/bank-card.png',
  'credit': 'assets/credit.png',
  'phone-wallet': 'assets/phone-wallet.png',
  'saving-pig': 'assets/saving-pig.png',
};
