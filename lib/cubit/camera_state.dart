part of 'camera_cubit.dart';

@immutable
abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {}
