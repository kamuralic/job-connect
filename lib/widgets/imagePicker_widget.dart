import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/image_picker_provider.dart';
import 'package:provider/provider.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({Key? key}) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  @override
  Widget build(BuildContext context) {
    ImagesProvider _imagesProvider = Provider.of<ImagesProvider>(context);
    return Dialog(
      child: Column(
        children: [
          AppBar(
            title: Text('Upload Images'),
          ),
          Expanded(
            child: Container(
              child: GridView.builder(
                  itemCount: _imagesProvider.images.length +
                      1, // addition of 1 is because weve put the add button at index 0 of the grid
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    return index == 0
                        ? Center(
                            child: Column(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _imagesProvider.getImages();
                                    },
                                    icon:
                                        Icon(CupertinoIcons.add_circled_solid)),
                                Text(
                                  "ADD",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_imagesProvider
                                            .images[index - 1]))),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: IconButton(
                                    padding: EdgeInsets.all(4),
                                    onPressed: () {
                                      _imagesProvider
                                          .removeImageFromList(index - 1);
                                    },
                                    icon: Icon(Icons.clear)),
                              )
                            ],
                          );
                  }),
            ),
          ),
          _imagesProvider.images.isNotEmpty
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context, true);
                          },
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade400,
                                      offset: Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],
                                color: Colors.green,
                              ),
                              child: Text(
                                'Save',
                                style: Theme.of(context).textTheme.subtitle2,
                              )),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _imagesProvider.clearAll();
                          },
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade400,
                                      offset: Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],
                                color: Colors.red,
                              ),
                              child: Text(
                                'Clear All',
                                style: Theme.of(context).textTheme.subtitle2,
                              )),
                        ),
                      ),
                    ],
                  ),
                )
              : Text('')
        ],
      ),
    );
  }
}
