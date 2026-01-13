import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {

  @override
  List<Object> get props => [];
}

class FetchProducts extends ProductEvent {}

class UpdateProductStock extends ProductEvent {
  final String id;
  final int newStock;

  UpdateProductStock({required this.id, required this.newStock});

  @override
  List<Object> get props => [id, newStock];
}