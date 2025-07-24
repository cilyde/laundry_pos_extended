enum ServiceType { express, wash, iron, both  }

class ClothItem {
  final String name;
  final double washPrice;
  final double? ironPrice;
  final double? bothPrice;
  final double? expressPrice;
  bool isSelected;
  ServiceType? selectedService;
  int quantity;

  String img;

  ClothItem({
    required this.name,
    required this.washPrice,
    this.ironPrice,
    this.bothPrice,
    this.expressPrice,
    this.isSelected = false,
    this.selectedService,
    required this.img,
    this.quantity = 1,
  });

  double get totalPrice {
    switch (selectedService) {
      case ServiceType.wash:
        return washPrice * quantity;
      case ServiceType.iron:
        if (ironPrice != null) {
          return ironPrice! * quantity;
        } else {
          return 0.0;
        }
      case ServiceType.both:
        // if (ironPrice != null) {
        //   return (washPrice + ironPrice!) * quantity;
        // } else {
        //   return washPrice * quantity;
        // }
        if (bothPrice != null) {
          return bothPrice! * quantity;
        } else {
          return 0.0;
        }
      case ServiceType.express:
        if (expressPrice != null) {
          return expressPrice! * quantity;
        } else {
          return 0.0;
        }
      default:
        return 0;
    }
  }
}
