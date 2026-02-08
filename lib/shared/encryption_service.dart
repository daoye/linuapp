import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/settings/key_manager.dart';

final encryptionServiceProvider = Provider((ref) {
  final keyManager = ref.watch(keyManagerProvider);
  return EncryptionService(keyManager);
});

class EncryptionService {
  final KeyManager _keyManager;
  final _algorithm = AesGcm.with256bits();

  EncryptionService(this._keyManager);

  /// Decrypt an encrypted message payload
  /// Returns the decrypted JSON string, or null if decryption fails
  Future<String?> decryptMessage(String encryptedBase64) async {
    try {
      final key = await _keyManager.getEncryptionKey();
      if (key == null) {
        throw Exception('No encryption key available');
      }

      // Decode the base64 encrypted data
      final encryptedBytes = base64Decode(encryptedBase64);
      
      // The encrypted data format: [nonce (12 bytes)][ciphertext + MAC (16 bytes)]
      if (encryptedBytes.length < 28) {
        throw Exception('Invalid encrypted data length');
      }

      // Extract nonce (first 12 bytes for AES-GCM)
      final nonce = encryptedBytes.sublist(0, 12);
      
      // Extract ciphertext + MAC (rest of the data)
      // Format: [nonce (12 bytes)][ciphertext (N bytes)][tag (16 bytes)]
      final ciphertextWithTag = encryptedBytes.sublist(12);
      
      // Separate ciphertext and MAC tag (last 16 bytes)
      final ciphertext = ciphertextWithTag.sublist(0, ciphertextWithTag.length - 16);
      final tag = ciphertextWithTag.sublist(ciphertextWithTag.length - 16);

      // Create SecretBox from the encrypted data
      final secretBox = SecretBox(
        ciphertext,
        nonce: nonce,
        mac: Mac(tag), // AES-GCM tag is the last 16 bytes
      );

      // Decrypt
      final decryptedBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: key,
      );

      // Convert to string
      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('Decryption failed: $e');
      return null;
    }
  }

  /// Encrypt a message payload
  /// Returns the encrypted data as base64 string
  Future<String?> encryptMessage(String plaintext) async {
    try {
      final key = await _keyManager.getEncryptionKey();
      if (key == null) {
        throw Exception('No encryption key available');
      }

      // Convert plaintext to bytes
      final plaintextBytes = utf8.encode(plaintext);

      // Encrypt
      final secretBox = await _algorithm.encrypt(
        plaintextBytes,
        secretKey: key,
      );

      // Combine nonce + ciphertext (ciphertext already includes MAC for AES-GCM)
      final combined = Uint8List.fromList([
        ...secretBox.nonce,
        ...secretBox.cipherText,
      ]);

      // Encode to base64
      return base64Encode(combined);
    } catch (e) {
      debugPrint('Encryption failed: $e');
      return null;
    }
  }

  /// Check if a message is encrypted (simple heuristic: valid base64 and reasonable length)
  bool isEncrypted(String? data) {
    if (data == null || data.isEmpty) return false;
    
    try {
      final decoded = base64Decode(data);
      // Encrypted messages should be at least 28 bytes (12 nonce + 16 MAC)
      return decoded.length >= 28;
    } catch (e) {
      return false;
    }
  }
}
