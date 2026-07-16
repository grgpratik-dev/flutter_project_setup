import 'package:flutter_project_setup/src/core/services/media/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('ImagePickerService', () {
    test(
      'picks one image from the gallery with the supplied options',
      () async {
        final picker = _FakeImagePicker(singleImage: XFile('gallery.jpg'));
        final service = ImagePickerService(picker);

        final result = await service.pickFromGallery(
          maxWidth: 1200,
          maxHeight: 900,
          imageQuality: 80,
        );

        expect(result?.path, 'gallery.jpg');
        expect(picker.source, ImageSource.gallery);
        expect(picker.maxWidth, 1200);
        expect(picker.maxHeight, 900);
        expect(picker.imageQuality, 80);
        expect(picker.requestFullMetadata, isFalse);
      },
    );

    test('takes a photo using the requested camera', () async {
      final picker = _FakeImagePicker(singleImage: XFile('camera.jpg'));
      final service = ImagePickerService(picker);

      final result = await service.takePhoto(
        preferredCameraDevice: CameraDevice.front,
      );

      expect(result?.path, 'camera.jpg');
      expect(picker.source, ImageSource.camera);
      expect(picker.cameraDevice, CameraDevice.front);
    });

    test('picks multiple gallery images with a limit', () async {
      final picker = _FakeImagePicker(
        multipleImages: [XFile('one.jpg'), XFile('two.jpg')],
      );
      final service = ImagePickerService(picker);

      final result = await service.pickMultipleFromGallery(limit: 2);

      expect(result.map((image) => image.path), ['one.jpg', 'two.jpg']);
      expect(picker.limit, 2);
      expect(picker.requestFullMetadata, isFalse);
    });
  });
}

final class _FakeImagePicker extends ImagePicker {
  _FakeImagePicker({this.singleImage, this.multipleImages = const []});

  final XFile? singleImage;
  final List<XFile> multipleImages;

  ImageSource? source;
  double? maxWidth;
  double? maxHeight;
  int? imageQuality;
  int? limit;
  CameraDevice? cameraDevice;
  bool? requestFullMetadata;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    this.source = source;
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;
    this.imageQuality = imageQuality;
    cameraDevice = preferredCameraDevice;
    this.requestFullMetadata = requestFullMetadata;
    return singleImage;
  }

  @override
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async {
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;
    this.imageQuality = imageQuality;
    this.limit = limit;
    this.requestFullMetadata = requestFullMetadata;
    return multipleImages;
  }
}
