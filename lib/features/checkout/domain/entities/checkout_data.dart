class CheckoutData {
  // Step 1
  String fullName;
  String phone;
  String? email;
  String? note;

  // Step 2
  String city;
  String area;
  String street;
  String? extra; // immeuble/etage/app
  String? postalCode;
  String? addressHint; // repère
  String placeType; // Maison / Bureau

  // Step 3
  String paymentMethod; // cash / card
  String deliverySlot; // asap / scheduled
  String? scheduledTime;

  CheckoutData({
    this.fullName = "",
    this.phone = "",
    this.email,
    this.note,
    this.city = "",
    this.area = "",
    this.street = "",
    this.extra,
    this.postalCode,
    this.addressHint,
    this.placeType = "Maison",
    this.paymentMethod = "cash",
    this.deliverySlot = "asap",
    this.scheduledTime,
  });
}
