import 'package:pointycastle/export.dart';
import "package:pointycastle/pointycastle.dart";
import 'package:pointycastle/ecc/ecc_fp.dart' as ecc_fp;
// ignore: implementation_imports
import 'package:pointycastle/src/utils.dart';
import 'package:pointycastle/asn1/object_identifiers.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Wrapper class around the pointycastle library based on the
/// dart_basic_utils package
/// https://github.com/Ephenodrom/Dart-Basic-Utils/blob/master/lib/src/CryptoUtils.dart
class CryptoUtils {
  CryptoUtils._();

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRsaKeyPair({
    int bitLength = 4096,
  }) {
    var keyGenerator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(
            BigInt.from(65537),
            bitLength,
            64,
          ),
          _getSecureRandom(),
        ),
      );

    var keyPair = keyGenerator.generateKeyPair();
    // Cast the keyPair key pair into the RSA key types
    final myPublic = keyPair.publicKey;
    final myPrivate = keyPair.privateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateRsaKeyPairAsync({
    int bitLength = 4096,
  }) {
    return compute((_) => generateRsaKeyPair(bitLength: bitLength), null);
  }

  ///
  /// Signing the given [data] with the given [privateKey].
  ///
  /// The default [algorithm] used is **SHA-256/RSA**. All supported algorihms are :
  ///
  /// * MD2/RSA
  /// * MD4/RSA
  /// * MD5/RSA
  /// * RIPEMD-128/RSA
  /// * RIPEMD-160/RSA
  /// * RIPEMD-256/RSA
  /// * SHA-1/RSA
  /// * SHA-224/RSA
  /// * SHA-256/RSA
  /// * SHA-384/RSA
  /// * SHA-512/RSA
  ///
  static Uint8List rsaSign(
    RSAPrivateKey privateKey,
    Uint8List data, {
    String algorithmName = 'SHA-256/RSA',
  }) {
    var signer = Signer(algorithmName) as RSASigner;

    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    var signature = signer.generateSignature(data);

    return signature.bytes;
  }

  ///
  /// Verifying the given [signedData] with the given [publicKey] and the given [signature].
  /// Will return **true** if the given [signature] matches the [signedData].
  ///
  /// The default [algorithm] used is **SHA-256/RSA**. All supported algorihms are :
  ///
  /// * MD2/RSA
  /// * MD4/RSA
  /// * MD5/RSA
  /// * RIPEMD-128/RSA
  /// * RIPEMD-160/RSA
  /// * RIPEMD-256/RSA
  /// * SHA-1/RSA
  /// * SHA-224/RSA
  /// * SHA-256/RSA
  /// * SHA-384/RSA
  /// * SHA-512/RSA
  ///
  static bool rsaVerify(
    RSAPublicKey publicKey,
    Uint8List signedData,
    Uint8List signature, {
    String algorithm = 'SHA-512/RSA',
  }) {
    final sig = RSASignature(signature);

    final verifier = Signer(algorithm);

    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

    try {
      return verifier.verifySignature(signedData, sig);
    } on ArgumentError {
      return false;
    }
  }

  static SecureRandom _getSecureRandom() {
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255 + 1));
    }

    return FortunaRandom()..seed(KeyParameter(Uint8List.fromList(seeds)));
  }

  static Uint8List encodeRsaPublicKeyToPkcs8(RSAPublicKey publicKey) {
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    var algorithmSeq = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
      ..add(paramsAsn1Obj);

    var publicKeySeq = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus))
      ..add(ASN1Integer(publicKey.exponent));
    var publicKeySeqBitString = ASN1BitString(stringValues: Uint8List.fromList(publicKeySeq.encode()));

    var topLevelSeq = ASN1Sequence()
      ..add(algorithmSeq)
      ..add(publicKeySeqBitString);
    return topLevelSeq.encode();
  }

  static Uint8List encodeRsaPrivateKeyToPkcs8(RSAPrivateKey privateKey) {
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    var algorithmSeq = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
      ..add(paramsAsn1Obj);

    var dP = privateKey.privateExponent! % (privateKey.p! - BigInt.one);
    var exp1 = ASN1Integer(dP);
    var dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.one);
    var exp2 = ASN1Integer(dQ);
    var iQ = privateKey.q!.modInverse(privateKey.p!);
    var co = ASN1Integer(iQ);
    var version = ASN1Integer(BigInt.zero);
    var privateKeySeq = ASN1Sequence()
      ..add(version)
      ..add(ASN1Integer(privateKey.n))
      ..add(ASN1Integer(privateKey.publicExponent))
      ..add(ASN1Integer(privateKey.privateExponent))
      ..add(ASN1Integer(privateKey.p))
      ..add(ASN1Integer(privateKey.q))
      ..add(exp1)
      ..add(exp2)
      ..add(co);

    var publicKeySeqOctetString = ASN1OctetString(octets: Uint8List.fromList(privateKeySeq.encode()));

    var topLevelSeq = ASN1Sequence()
      ..add(version)
      ..add(algorithmSeq)
      ..add(publicKeySeqOctetString);

    return topLevelSeq.encode();
  }

  static RSAPrivateKey decodeRsaPrivateKeyFromPkcs8(Uint8List bytes) {
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    //ASN1Object version = topLevelSeq.elements[0];
    //ASN1Object algorithm = topLevelSeq.elements[1];
    var privateKey = topLevelSeq.elements![2];

    asn1Parser = ASN1Parser(privateKey.valueBytes);
    var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

    var modulus = pkSeq.elements![1] as ASN1Integer;
    //ASN1Integer publicExponent = pkSeq.elements[2] as ASN1Integer;
    var privateExponent = pkSeq.elements![3] as ASN1Integer;
    var p = pkSeq.elements![4] as ASN1Integer;
    var q = pkSeq.elements![5] as ASN1Integer;
    //ASN1Integer exp1 = pkSeq.elements[6] as ASN1Integer;
    //ASN1Integer exp2 = pkSeq.elements[7] as ASN1Integer;
    //ASN1Integer co = pkSeq.elements[8] as ASN1Integer;

    var rsaPrivateKey = RSAPrivateKey(
      modulus.integer!,
      privateExponent.integer!,
      p.integer,
      q.integer,
    );

    return rsaPrivateKey;
  }

  ///
  /// Generates a elliptic curve [AsymmetricKeyPair].
  ///
  /// The default curve is **prime256v1**
  ///
  /// The following curves are supported:
  ///
  /// * brainpoolp160r1
  /// * brainpoolp160t1
  /// * brainpoolp192r1
  /// * brainpoolp192t1
  /// * brainpoolp224r1
  /// * brainpoolp224t1
  /// * brainpoolp256r1
  /// * brainpoolp256t1
  /// * brainpoolp320r1
  /// * brainpoolp320t1
  /// * brainpoolp384r1
  /// * brainpoolp384t1
  /// * brainpoolp512r1
  /// * brainpoolp512t1
  /// * GostR3410-2001-CryptoPro-A
  /// * GostR3410-2001-CryptoPro-B
  /// * GostR3410-2001-CryptoPro-C
  /// * GostR3410-2001-CryptoPro-XchA
  /// * GostR3410-2001-CryptoPro-XchB
  /// * prime192v1
  /// * prime192v2
  /// * prime192v3
  /// * prime239v1
  /// * prime239v2
  /// * prime239v3
  /// * prime256v1
  /// * secp112r1
  /// * secp112r2
  /// * secp128r1
  /// * secp128r2
  /// * secp160k1
  /// * secp160r1
  /// * secp160r2
  /// * secp192k1
  /// * secp192r1
  /// * secp224k1
  /// * secp224r1
  /// * secp256k1
  /// * secp256r1
  /// * secp384r1
  /// * secp521r1
  ///
  static AsymmetricKeyPair<ECPublicKey, ECPrivateKey> generateEcKeyPair({String curve = 'prime256v1'}) {
    var ecDomainParameters = ECDomainParameters(curve);
    var keyParams = ECKeyGeneratorParameters(ecDomainParameters);

    var secureRandom = _getSecureRandom();

    var generator = ECKeyGenerator()..init(ParametersWithRandom(keyParams, secureRandom));

    var keyPair = generator.generateKeyPair();

    // Cast the keyPair key pair into the RSA key types
    final myPublic = keyPair.publicKey;
    final myPrivate = keyPair.privateKey;

    return AsymmetricKeyPair<ECPublicKey, ECPrivateKey>(myPublic, myPrivate);
  }

  static Future<AsymmetricKeyPair<ECPublicKey, ECPrivateKey>> generateEcKeyPairAsync({String curve = 'prime256v1'}) {
    return compute((_) => generateEcKeyPair(curve: curve), null);
  }

  ///
  /// Signing the given [dataToSign] with the given [privateKey].
  ///
  /// The default [algorithm] used is **SHA-1/ECDSA**. All supported algorihms are :
  ///
  /// * SHA-1/ECDSA
  /// * SHA-224/ECDSA
  /// * SHA-256/ECDSA
  /// * SHA-384/ECDSA
  /// * SHA-512/ECDSA
  /// * SHA-1/DET-ECDSA
  /// * SHA-224/DET-ECDSA
  /// * SHA-256/DET-ECDSA
  /// * SHA-384/DET-ECDSA
  /// * SHA-512/DET-ECDSA
  ///
  static Uint8List ecSign(ECPrivateKey privateKey, Uint8List dataToSign, {String algorithmName = 'SHA-1/ECDSA'}) {
    var signer = Signer(algorithmName) as ECDSASigner;

    var params = ParametersWithRandom(PrivateKeyParameter<ECPrivateKey>(privateKey), _getSecureRandom());
    signer.init(true, params);

    var sig = signer.generateSignature(dataToSign) as ECSignature;
    return _ecSignatureToBase64(sig);
  }

  ///
  /// Convert ECSignature [signature] to DER encoded base64 string.
  /// ```
  /// ECDSA-Sig-Value ::= SEQUENCE {
  ///  r INTEGER,
  ///  s INTEGER
  /// }
  ///```
  /// This is mainly used for passing signature as string via request/response use cases
  ///
  static Uint8List _ecSignatureToBase64(ECSignature signature) {
    var topLevel = ASN1Sequence()
      ..add(ASN1Integer(signature.r))
      ..add(ASN1Integer(signature.s));

    return topLevel.encode();
  }

  static ECPublicKey ecPublicKey(String pub, String curveName, {compressed = false}) {
    var pubBytes = CryptoUtils.hexToUint8List(pub);
    var x = pubBytes.sublist(1, (pubBytes.length / 2).round());
    var y = pubBytes.sublist(1 + x.length, pubBytes.length);
    var params = ECDomainParameters(curveName);
    var bigX = decodeBigIntWithSign(1, x);
    var bigY = decodeBigIntWithSign(1, y);
    return ECPublicKey(
        ecc_fp.ECPoint(params.curve as ecc_fp.ECCurve, params.curve.fromBigInteger(bigX) as ecc_fp.ECFieldElement?,
            params.curve.fromBigInteger(bigY) as ecc_fp.ECFieldElement?, compressed),
        params);
  }

  static Uint8List hexToUint8List(String hex) {
    if (hex.length % 2 != 0) {
      throw 'Odd number of hex digits';
    }
    var length = hex.length ~/ 2;
    var result = Uint8List(length);
    for (var i = 0; i < length; ++i) {
      var x = int.parse(hex.substring(2 * i, 2 * (i + 1)), radix: 16);
      result[i] = x;
    }
    return result;
  }

  ///
  /// Enode the given elliptic curve [publicKey] to PEM format.
  ///
  /// This is descripted in <https://tools.ietf.org/html/rfc5915>
  ///
  /// ```ASN1
  /// ECPrivateKey ::= SEQUENCE {
  ///   version        INTEGER { ecPrivkeyVer1(1) } (ecPrivkeyVer1),
  ///   privateKey     OCTET STRING
  ///   parameters [0] ECParameters {{ NamedCurve }} OPTIONAL
  ///   publicKey  [1] BIT STRING OPTIONAL
  /// }
  ///
  /// ```
  ///
  /// As descripted in the mentioned RFC, all optional values will always be set.
  ///
  static Uint8List encodeEcPrivateKeyToPkcs8(ECPrivateKey ecPrivateKey) {
    var outer = ASN1Sequence();

    var version = ASN1Integer(BigInt.from(1));
    var privateKeyAsBytes = i2osp(ecPrivateKey.d!);
    var privateKey = ASN1OctetString(octets: privateKeyAsBytes);
    var choice = ASN1Sequence(tag: 0xA0);

    choice.add(ASN1ObjectIdentifier.fromName(ecPrivateKey.parameters!.domainName));

    var publicKey = ASN1Sequence(tag: 0xA1);
    var q = ecPrivateKey.parameters!.G * ecPrivateKey.d!;
    var encodedBytes = q!.getEncoded(false);
    var subjectPublicKey = ASN1BitString(stringValues: encodedBytes);
    publicKey.add(subjectPublicKey);

    outer.add(version);
    outer.add(privateKey);
    outer.add(choice);
    outer.add(publicKey);
    return outer.encode();
  }

  ///
  /// Decode the given [bytes] into an [ECPrivateKey].
  ///
  /// [pkcs8] defines the ASN1 format of the given [bytes]. The default is false, so SEC1 is assumed.
  ///
  /// Supports SEC1 (<https://tools.ietf.org/html/rfc5915>) and PKCS8 (<https://datatracker.ietf.org/doc/html/rfc5208>)
  ///
  static ECPrivateKey decodeEcPrivateKey(
    Uint8List bytes, {
    bool pkcs8 = false,
    ECDomainParameters? parameters,
  }) {
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    String curveName;
    Uint8List x;
    if (pkcs8) {
      // Parse the PKCS8 format
      var innerSeq = topLevelSeq.elements!.elementAt(1) as ASN1Sequence;
      var b2 = innerSeq.elements!.elementAt(1) as ASN1ObjectIdentifier;
      var b2Data = b2.objectIdentifierAsString;
      var b2CurveData = ObjectIdentifiers.getIdentifierByIdentifier(b2Data);
      if (b2CurveData == null) {
        throw const FormatException('could not extract b2CurveData from encoded EC private key');
      }
      curveName = b2CurveData['readableName'];

      var octetString = topLevelSeq.elements!.elementAt(2) as ASN1OctetString;
      asn1Parser = ASN1Parser(octetString.valueBytes);
      var octetStringSeq = asn1Parser.nextObject() as ASN1Sequence;
      var octetStringKeyData = octetStringSeq.elements!.elementAt(1) as ASN1OctetString;

      x = octetStringKeyData.valueBytes!;
    } else {
      // Parse the SEC1 format
      var privateKeyAsOctetString = topLevelSeq.elements!.elementAt(1) as ASN1OctetString;
      var choice = topLevelSeq.elements!.elementAt(2);
      var s = ASN1Sequence();
      var parser = ASN1Parser(choice.valueBytes);
      while (parser.hasNext()) {
        s.add(parser.nextObject());
      }
      var curveNameOi = s.elements!.elementAt(0) as ASN1ObjectIdentifier;
      var data = ObjectIdentifiers.getIdentifierByIdentifier(curveNameOi.objectIdentifierAsString);
      if (data == null) {
        throw const FormatException('could not extract b2CurveData from encoded EC private key');
      }
      curveName = data['readableName'];

      x = privateKeyAsOctetString.valueBytes!;
    }

    return ECPrivateKey(
      osp2i(x),
      parameters ?? ECDomainParameters(curveName),
    );
  }

  ///
  /// Conversion of integer to bytes according to RFC 3447 at <https://datatracker.ietf.org/doc/html/rfc3447#page-8>
  ///
  static Uint8List i2osp(BigInt number, {int? outLen, Endian endian = Endian.big}) {
    var size = (number.bitLength + 7) >> 3;
    if (outLen == null) {
      outLen = size;
    } else if (outLen < size) {
      throw Exception('Number too large');
    }
    final result = Uint8List(outLen);
    var byteMask = BigInt.from(0xff);
    var pos = endian == Endian.big ? outLen - 1 : 0;
    for (var i = 0; i < size; i++) {
      result[pos] = (number & byteMask).toInt();
      if (endian == Endian.big) {
        pos -= 1;
      } else {
        pos += 1;
      }
      number = number >> 8;
    }
    return result;
  }

  ///
  /// Conversion of bytes to integer according to RFC 3447 at <https://datatracker.ietf.org/doc/html/rfc3447#page-8>
  ///
  static BigInt osp2i(Iterable<int> bytes, {Endian endian = Endian.big}) {
    var result = BigInt.from(0);
    if (endian == Endian.little) {
      bytes = bytes.toList().reversed;
    }

    for (var byte in bytes) {
      result = result << 8;
      result |= BigInt.from(byte);
    }

    return result;
  }

  ///
  /// Enode the given elliptic curve [publicKey] to PEM format.
  ///
  /// This is descripted in <https://tools.ietf.org/html/rfc5480>
  ///
  /// ```ASN1
  /// SubjectPublicKeyInfo  ::=  SEQUENCE  {
  ///     algorithm         AlgorithmIdentifier,
  ///     subjectPublicKey  BIT STRING
  /// }
  /// ```
  ///
  static Uint8List encodeEcPublicKeyToPkcs8(ECPublicKey publicKey) {
    var algorithm = ASN1Sequence();
    algorithm.add(ASN1ObjectIdentifier.fromName('ecPublicKey'));
    algorithm.add(ASN1ObjectIdentifier.fromName(publicKey.parameters!.domainName));
    var encodedBytes = publicKey.Q!.getEncoded(false);

    var subjectPublicKey = ASN1BitString(stringValues: encodedBytes);
    var outer = ASN1Sequence()
      ..add(algorithm)
      ..add(subjectPublicKey);

    return outer.encode();
  }
}
