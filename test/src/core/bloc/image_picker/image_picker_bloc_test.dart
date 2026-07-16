import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_setup/src/core/bloc/image_picker/image_picker_bloc.dart';
import 'package:flutter_project_setup/src/core/services/media/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('ImagePickerBloc', () {
    blocTest<ImagePickerBloc, ImagePickerState>(
      'emits picking then success when an image is selected',
      build: () => ImagePickerBloc(
        _FakeImagePickerService(galleryImage: XFile('avatar.jpg')),
      ),
      act: (bloc) => bloc.add(const ImageFromGalleryRequested()),
      expect: () => [
        const ImagePickerState(status: ImagePickerStatus.picking),
        isA<ImagePickerState>()
            .having(
              (state) => state.status,
              'status',
              ImagePickerStatus.success,
            )
            .having((state) => state.image?.path, 'image path', 'avatar.jpg'),
      ],
    );

    blocTest<ImagePickerBloc, ImagePickerState>(
      'emits cancelled when the user closes the picker',
      build: () => ImagePickerBloc(_FakeImagePickerService()),
      act: (bloc) => bloc.add(const ImageFromGalleryRequested()),
      expect: () => const [
        ImagePickerState(status: ImagePickerStatus.picking),
        ImagePickerState(status: ImagePickerStatus.cancelled),
      ],
    );

    blocTest<ImagePickerBloc, ImagePickerState>(
      'exposes a platform error for the UI',
      build: () => ImagePickerBloc(
        _FakeImagePickerService(
          error: PlatformException(
            code: 'camera_access_denied',
            message: 'Camera permission was denied.',
          ),
        ),
      ),
      act: (bloc) => bloc.add(const PhotoCaptureRequested()),
      expect: () => const [
        ImagePickerState(status: ImagePickerStatus.picking),
        ImagePickerState(
          status: ImagePickerStatus.failure,
          errorMessage: 'Camera permission was denied.',
        ),
      ],
    );

    blocTest<ImagePickerBloc, ImagePickerState>(
      'clears an existing selection',
      build: () => ImagePickerBloc(
        _FakeImagePickerService(galleryImage: XFile('avatar.jpg')),
      ),
      act: (bloc) async {
        bloc.add(const ImageFromGalleryRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ImagePickerCleared());
      },
      expect: () => [
        const ImagePickerState(status: ImagePickerStatus.picking),
        isA<ImagePickerState>().having(
          (state) => state.status,
          'status',
          ImagePickerStatus.success,
        ),
        const ImagePickerState(),
      ],
    );
  });
}

final class _FakeImagePickerService extends ImagePickerService {
  _FakeImagePickerService({this.galleryImage, this.error})
    : super(ImagePicker());

  final XFile? galleryImage;
  final PlatformException? error;

  @override
  Future<XFile?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = false,
  }) async {
    if (error case final error?) throw error;
    return galleryImage;
  }

  @override
  Future<XFile?> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = false,
  }) async {
    if (error case final error?) throw error;
    return galleryImage;
  }
}
