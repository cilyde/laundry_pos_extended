import '../models/cloth_item.dart';

/// Static item catalog shown on the POS
final List<ClothItem> availableItems = [
  ClothItem(name: 'Shirt', washPrice: 1, ironPrice: 1.5, img: 'assets/images/shirt.png', bothPrice: 2, expressPrice: 2),
  ClothItem(name: 'Pants', washPrice: 1, ironPrice: 1.5, img: 'assets/images/pants.png', bothPrice: 2, expressPrice: 2),
  ClothItem(name: 'Coverole', washPrice: 2.5, ironPrice: 3, img: 'assets/images/coverole.png', bothPrice: 5, expressPrice: 5),
  ClothItem(name: 'Kanthoora', washPrice: 3, ironPrice: 3, img: 'assets/images/kandhoora.png', bothPrice: 5, expressPrice: 5),
  ClothItem(name: 'Salwar', washPrice: 3, ironPrice: 3, img: 'assets/images/salwar.png', bothPrice: 4, expressPrice: 4),
  ClothItem(name: 'Bedsheet', washPrice: 1, ironPrice: 1.5, img: 'assets/images/bedsheet.png', bothPrice: 2, expressPrice: 2),
  ClothItem(name: 'Inner Garment', washPrice: 1, ironPrice: null, img: 'assets/images/innergarments.png'),
  ClothItem(name: 'Single Blanket', washPrice: 10, ironPrice: null, img: 'assets/images/blanket_single.png'),
  ClothItem(name: 'Double Blanket', washPrice: 15, ironPrice: null, img: 'assets/images/blanket_double.png'),
  ClothItem(name: 'Pillow Covers', washPrice: 1, ironPrice: null, img: 'assets/images/pillow_covers.png'),
  ClothItem(name: 'Suit', washPrice: 7.5, ironPrice: 10, img: 'assets/images/suitandpants.png', bothPrice: 15, expressPrice: 13),
  ClothItem(name: 'Lungi', washPrice: 1, ironPrice: 1.5, img: 'assets/images/lungi.png', bothPrice: 2, expressPrice: 2),
  ClothItem(name: 'Mund-Double', washPrice: 2, ironPrice: 3, img: 'assets/images/mund.png', bothPrice: 5, expressPrice: 5),
  ClothItem(name: 'Jacket', washPrice: 5, ironPrice: 5, img: 'assets/images/jacket.png', bothPrice: 10, expressPrice: 8),
  ClothItem(name: 'Socks', washPrice: 1, ironPrice: null, img: 'assets/images/socks.png'),
  ClothItem(name: 'Towel', washPrice: 2, ironPrice: null, img: 'assets/images/towel.png'),
  ClothItem(name: 'Ghutra', washPrice: 1, ironPrice: 1.5, img: 'assets/images/ghutra.png', bothPrice: 2, expressPrice: 2),
];
