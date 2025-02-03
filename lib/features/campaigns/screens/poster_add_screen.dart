import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/save_cancel_on_create_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class PosterAddScreen extends StatefulWidget {
  final LatLng location;
  final AddressModel address;
  final File? photo;

  const PosterAddScreen({super.key, this.photo, required this.address, required this.location});

  @override
  State<StatefulWidget> createState() => _PostersAddState();
}

class _PostersAddState extends State<PosterAddScreen> with AddressExtension {
  @override
  TextEditingController streetTextController = TextEditingController();
  @override
  TextEditingController houseNumberTextController = TextEditingController();
  @override
  TextEditingController zipCodeTextController = TextEditingController();
  @override
  TextEditingController cityTextController = TextEditingController();
  File? _currentPhoto;

  @override
  void initState() {
    setAddress(widget.address);
    _currentPhoto = widget.photo;
    super.initState();
  }

  @override
  void dispose() {
    disposeAddressTextControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Container(
      margin: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.campaigns.poster.addPoster,
                  style: theme.textTheme.displayMedium!.apply(color: theme.colorScheme.surface),
                ),
              ),
              _hasPhoto
                  ? GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        alignment: Alignment.centerRight,
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(width: 12),
              GestureDetector(
                onTap: _pickImageFromDevice,
                child: Container(
                  alignment: Alignment.centerRight,
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6),
              GestureDetector(
                onTap: _acquireNewPhoto,
                child: Container(
                  alignment: Alignment.centerRight,
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ThemeColors.background, width: 1),
                    gradient: LinearGradient(
                      colors: [Color(0xFF03BD4E), Color(0xFF875CFF)],
                    ),
                  ),
                  child: _getPhotoPreviewOrIcon(),
                ),
              ),
            ],
          ),
          CreateAddressWidget(
            streetTextController: streetTextController,
            houseNumberTextController: houseNumberTextController,
            zipCodeTextController: zipCodeTextController,
            cityTextController: cityTextController,
          ),
          SaveCancelOnCreateWidget(onSave: _onSavePressed),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ThemeColors.background,
              ),
              SizedBox(width: 10),
              SizedBox(
                width: mediaQuery.size.width - 82,
                child: Text(
                  t.campaigns.poster.info_poster_guidelines,
                  style: theme.textTheme.labelMedium!.apply(
                    color: ThemeColors.background,
                    fontWeightDelta: 3,
                    letterSpacingDelta: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPhotoPreviewOrIcon() {
    if (_currentPhoto != null) {
      return Container(
        width: 150,
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Image.file(
          _currentPhoto!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Center(
        child: Icon(
          Icons.photo_camera,
          color: Colors.white,
          size: 30.0,
        ),
      );
    }
  }

  void _acquireNewPhoto() async {
    final photo = await MediaHelper.acquirePhoto(context);

    if (photo != null) {
      setState(() {
        _currentPhoto = photo;
      });
    }
  }

  void _onSavePressed(BuildContext localContext) async {
    if (!localContext.mounted) return;

    final reducedImage = await MediaHelper.resizeAndReduceImageFile(_currentPhoto);
    String? fileLocation;
    if (reducedImage != null) {
      fileLocation = await MediaHelper.storeImage(reducedImage);
      var exists = await File(fileLocation).exists();
      debugPrint(exists.toString());
    }
    _saveAndReturn(fileLocation);
  }

  void _saveAndReturn(String? fileLocation) {
    Navigator.maybePop(
      context,
      PosterCreateModel(
        location: widget.location,
        address: getAddress(),
        imageFileLocation: fileLocation,
      ),
    );
  }

  void _pickImageFromDevice() async {
    final photo = await MediaHelper.pickImageFromDevice(context);

    if (photo != null) {
      setState(() {
        _currentPhoto = photo;
      });
    }
  }

  void _removeImage() {
    if (_hasPhoto) {
      setState(() {
        _currentPhoto = null;
      });
    }
  }

  bool get _hasPhoto => _currentPhoto != null;
}
