import 'package:flutter_test/flutter_test.dart';
import 'package:ir_remote_app/core/ir/ir_encoder.dart';

void main() {
  group('NEC encoder', () {
    test('produces 67-element pattern (2 header + 64 data + 1 stop)', () {
      final pattern = encodeNec(0x00, 0x00);
      expect(pattern.length, 67);
    });

    test('header is [9000, 4500]', () {
      final pattern = encodeNec(0x00, 0x00);
      expect(pattern[0], 9000);
      expect(pattern[1], 4500);
    });

    test('address bit 1 encodes as 560, 1690', () {
      final pattern = encodeNec(0x01, 0x00);
      expect(pattern[2], 560);
      expect(pattern[3], 1690);
    });

    test('address 0x00 gives all-zero bits, inverted gives all-one bits', () {
      final pattern = encodeNec(0x00, 0x00);
      for (var i = 0; i < 8; i++) {
        expect(pattern[2 + i * 2], 560);
        expect(pattern[3 + i * 2], 560);
      }
      for (var i = 8; i < 16; i++) {
        expect(pattern[2 + i * 2], 560);
        expect(pattern[3 + i * 2], 1690);
      }
    });

    test('command 0x01 LSB is 1 at bit position 16', () {
      final pattern = encodeNec(0x00, 0x01);
      expect(pattern[2 + 16 * 2], 560);
      expect(pattern[3 + 16 * 2], 1690);
    });

    test('stop bit is 560', () {
      final pattern = encodeNec(0x00, 0x00);
      expect(pattern.last, 560);
    });
  });

  group('Pronto decoder', () {
    test('yields approximately 38000 Hz for code word 006D', () {
      final result = fromPronto('0000 006D 0002 0000 0001 0001 0001 0001');
      expect(result.freq, closeTo(38000, 500));
    });

    test('pattern length matches pair count', () {
      final result = fromPronto('0000 006D 0004 0000 0001 0002 0003 0004 0005 0006 0007 0008');
      expect(result.pattern.length, 8);
    });
  });
}
