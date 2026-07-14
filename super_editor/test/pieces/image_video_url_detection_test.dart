import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/super_editor.dart';

void main() {
  group('isImageUrl', () {
    test('returns true for common image extensions', () {
      expect(isImageUrl('https://example.com/photo.png'), isTrue);
      expect(isImageUrl('https://example.com/photo.jpg'), isTrue);
      expect(isImageUrl('https://example.com/photo.jpeg'), isTrue);
      expect(isImageUrl('https://example.com/photo.gif'), isTrue);
      expect(isImageUrl('https://example.com/photo.webp'), isTrue);
      expect(isImageUrl('https://example.com/photo.svg'), isTrue);
      expect(isImageUrl('https://example.com/photo.bmp'), isTrue);
      expect(isImageUrl('https://example.com/photo.ico'), isTrue);
      expect(isImageUrl('https://example.com/photo.tiff'), isTrue);
      expect(isImageUrl('https://example.com/photo.tif'), isTrue);
      expect(isImageUrl('https://example.com/photo.avif'), isTrue);
    });

    test('is case-insensitive', () {
      expect(isImageUrl('https://example.com/photo.PNG'), isTrue);
      expect(isImageUrl('https://example.com/photo.JpG'), isTrue);
      expect(isImageUrl('https://example.com/PHOTO.WEBP'), isTrue);
    });

    test('returns true when extension is in the URI path with query params', () {
      expect(isImageUrl('https://example.com/photo.png?token=abc'), isTrue);
      expect(isImageUrl('https://cdn.example.com/img.jpg?w=300&h=200'), isTrue);
    });

    test('returns false for non-image URLs', () {
      expect(isImageUrl('https://example.com/page.html'), isFalse);
      expect(isImageUrl('https://example.com/document.pdf'), isFalse);
      expect(isImageUrl('https://example.com/script.js'), isFalse);
      expect(isImageUrl('https://example.com/'), isFalse);
      expect(isImageUrl('https://example.com'), isFalse);
    });

    test('returns false for video URLs', () {
      expect(isImageUrl('https://example.com/clip.mp4'), isFalse);
      expect(isImageUrl('https://example.com/clip.webm'), isFalse);
      expect(isImageUrl('https://example.com/clip.mov'), isFalse);
    });

    test('returns true for bare file paths', () {
      expect(isImageUrl('assets/images/logo.png'), isTrue);
      expect(isImageUrl('/home/user/photo.jpg'), isTrue);
    });

    test('returns false for empty or whitespace input', () {
      expect(isImageUrl(''), isFalse);
      expect(isImageUrl('   '), isFalse);
    });
  });

  group('isVideoUrl', () {
    test('returns true for common video extensions', () {
      expect(isVideoUrl('https://example.com/clip.mp4'), isTrue);
      expect(isVideoUrl('https://example.com/clip.webm'), isTrue);
      expect(isVideoUrl('https://example.com/clip.mov'), isTrue);
      expect(isVideoUrl('https://example.com/clip.avi'), isTrue);
      expect(isVideoUrl('https://example.com/clip.mkv'), isTrue);
      expect(isVideoUrl('https://example.com/clip.m4v'), isTrue);
      expect(isVideoUrl('https://example.com/clip.wmv'), isTrue);
      expect(isVideoUrl('https://example.com/clip.flv'), isTrue);
      expect(isVideoUrl('https://example.com/clip.ogv'), isTrue);
      expect(isVideoUrl('https://example.com/clip.3gp'), isTrue);
    });

    test('is case-insensitive', () {
      expect(isVideoUrl('https://example.com/clip.MP4'), isTrue);
      expect(isVideoUrl('https://example.com/clip.MoV'), isTrue);
    });

    test('returns true when extension is in the URI path with query params', () {
      expect(isVideoUrl('https://example.com/clip.mp4?token=abc'), isTrue);
      expect(isVideoUrl('https://cdn.example.com/vid.webm?quality=hd'), isTrue);
    });

    test('returns false for non-video URLs', () {
      expect(isVideoUrl('https://example.com/page.html'), isFalse);
      expect(isVideoUrl('https://example.com/'), isFalse);
    });

    test('returns false for image URLs', () {
      expect(isVideoUrl('https://example.com/photo.png'), isFalse);
      expect(isVideoUrl('https://example.com/photo.jpg'), isFalse);
    });

    test('returns true for bare file paths', () {
      expect(isVideoUrl('assets/videos/intro.mp4'), isTrue);
      expect(isVideoUrl('/home/user/recording.mov'), isTrue);
    });

    test('returns false for empty or whitespace input', () {
      expect(isVideoUrl(''), isFalse);
      expect(isVideoUrl('   '), isFalse);
    });
  });
}
