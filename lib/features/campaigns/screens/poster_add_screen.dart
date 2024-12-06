import 'dart:io';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:gruene_app/features/campaigns/screens/doors_add_screen.dart';
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

class _PostersAddState extends State<PosterAddScreen> with AddressMixin {
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
    return Container(
      margin: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.campaigns.posters.addPoster,
                  style: theme.textTheme.displayMedium!.apply(color: theme.colorScheme.surface),
                ),
              ),
              Container(
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
            ],
          ),
          CreateAddressWidget(
            streetTextController: streetTextController,
            houseNumberTextController: houseNumberTextController,
            zipCodeTextController: zipCodeTextController,
            cityTextController: cityTextController,
          ),
          SaveCancelOnCreateWidget(onSave: _onSavePressed),
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
        child: GestureDetector(
          onTap: _acquireNewPhoto,
          child: Image.file(
            _currentPhoto!,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Center(
        child: GestureDetector(
          onTap: _acquireNewPhoto,
          child: Icon(
            Icons.photo_camera,
            color: Colors.white,
            size: 30.0,
          ),
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

    _saveAndReturn(reducedImage);
  }

  void _saveAndReturn(Uint8List? reducedImage) {
    Navigator.maybePop(
      context,
      PosterCreateModel(
        location: widget.location,
        street: streetTextController.text,
        houseNumber: houseNumberTextController.text,
        zipCode: zipCodeTextController.text,
        city: cityTextController.text,
        photo: reducedImage,
      ),
    );
  }
}
