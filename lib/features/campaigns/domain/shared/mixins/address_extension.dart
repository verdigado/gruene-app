part of '../mixins.dart';

/// Mixin for handling address-related form fields
/// Used by doors, flyers, and posters edit/add screens
mixin AddressExtension {
  abstract TextEditingController streetTextController;
  abstract TextEditingController houseNumberTextController;
  abstract TextEditingController zipCodeTextController;
  abstract TextEditingController cityTextController;

  void disposeAddressTextControllers() {
    streetTextController.dispose();
    houseNumberTextController.dispose();
    zipCodeTextController.dispose();
    cityTextController.dispose();
  }

  AddressModel getAddress() {
    return AddressModel(
      street: streetTextController.text,
      houseNumber: houseNumberTextController.text,
      zipCode: zipCodeTextController.text,
      city: cityTextController.text,
    );
  }

  void setAddress(AddressModel address) {
    streetTextController.text = address.street;
    houseNumberTextController.text = address.houseNumber;
    zipCodeTextController.text = address.zipCode;
    cityTextController.text = address.city;
  }
}
