import 'package:equatable/equatable.dart';

class DentalReview extends Equatable {
  final String id;
  final String authorName;
  final String clinicName;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isVerifiedBuyer;

  const DentalReview({
    required this.id,
    required this.authorName,
    this.clinicName = 'Private Dental Practice',
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerifiedBuyer = true,
  });

  @override
  List<Object?> get props => [
        id,
        authorName,
        clinicName,
        rating,
        comment,
        date,
        isVerifiedBuyer,
      ];
}

class DentalNotificationItem extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final String type; // 'order', 'promo', 'stock', 'system'

  const DentalNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, message, time, isRead, type];
}

class DeliveryAddress extends Equatable {
  final String id;
  final String label; // "Clinic Head Office", "Branch 2", "Home"
  final String recipientName;
  final String clinicName;
  final String phone;
  final String street;
  final String city;
  final String postalCode;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    this.clinicName = '',
    required this.phone,
    required this.street,
    required this.city,
    required this.postalCode,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city - $postalCode';

  @override
  List<Object?> get props => [
        id,
        label,
        recipientName,
        clinicName,
        phone,
        street,
        city,
        postalCode,
        isDefault,
      ];
}
