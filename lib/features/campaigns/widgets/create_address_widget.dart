import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/widgets/text_input_field.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CreateAddressWidget extends StatelessWidget {
  final TextEditingController streetTextController;
  final TextEditingController houseNumberTextController;
  final TextEditingController zipCodeTextController;
  final TextEditingController cityTextController;
  final Color? inputBorderColor;

  const CreateAddressWidget({
    super.key,
    required this.streetTextController,
    required this.houseNumberTextController,
    required this.zipCodeTextController,
    required this.cityTextController,
    this.inputBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextInputField(
                  textController: streetTextController,
                  labelText: t.campaigns.address.street,
                  borderColor: inputBorderColor,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 6),
                child: TextInputField(
                  width: 75,
                  labelText: t.campaigns.address.housenumber,
                  textController: houseNumberTextController,
                  borderColor: inputBorderColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 6),
                child: TextInputField(
                  width: 75,
                  labelText: t.campaigns.address.zipcode,
                  textController: zipCodeTextController,
                  inputType: InputFieldType.numbers,
                  borderColor: inputBorderColor,
                ),
              ),
              Expanded(
                child: TextInputField(
                  labelText: t.campaigns.address.city_or_place,
                  textController: cityTextController,
                  borderColor: inputBorderColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
