import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:appwrite/appwrite.dart';
import 'package:datalock/config/config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as flutter;
import '../../data/repositories/auth_repository.dart';
import '../widgets/otp_field.dart';
import '../widgets/custom_button.dart' as flutter;
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpInput extends flutter.StatefulWidget {
  final Function(String userId, String phoneNumber, String result, String? name, String? prenom) onSubmit;
  final VoidCallback onBack;
  final Function(String otp) onVerify;
  final String phoneNumber;
  final String userId;
  final String? name;
  final String? prenom;
  final String entry_id;

  const OtpInput({
    Key? key,
    required this.onBack,
    required this.onVerify,
    required this.phoneNumber,
    required this.userId,
    required this.onSubmit,
    required this.entry_id,
    this.name,
    this.prenom,
  }) : super(key: key);

  @override
  _OtpInputState createState() => _OtpInputState();
}

class _OtpInputState extends flutter.State<OtpInput> {
  final List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  String remainingTime = '';
  final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false; // Add loading state

  String? ipAddress;
  final account = Config.getAccount();
  final databases = Config.getDatabases();

  String _cachedUserId = '';
  String getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'AND';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else {
      return 'lin';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetIpAddress();
    startCountdown();
    _loadCachedUserId();
  }

  Future<void> _loadCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cachedUserId = (prefs.getString('cached_user_id') ?? '');
    });
    
    if (_cachedUserId.isEmpty) {
      print("Attention : L'ID utilisateur mis en cache est vide");
      // Try to recover the ID from another source if possible
      _recoverUserId();
    } else {
      print("User ID loaded from cache: $_cachedUserId");
    }
  }

  // Add a recovery method to try getting the ID from other storage
  Future<void> _recoverUserId() async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id') ?? 
                  await storage.read(key: 'new_user_id');
    
    if (userId != null && userId.isNotEmpty) {
      print("Recovered user ID from secure storage: $userId");
      // Save it to SharedPreferences for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_id', userId);
      
      setState(() {
        _cachedUserId = userId;
      });
    }
  }
  

  @override
  void dispose() {
    // Nettoyer les controllers et focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleControllerChange(int index) {
    final String text = otpControllers[index].text;
    if (text.length == 1 && index < otpControllers.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> fetchAndSetIpAddress() async {
    ipAddress = await getUserIpAddress();
  }

  Future<String> getUserIpAddress() async {
    try {
      final url = Uri.parse('https://api.ipify.org?format=text');
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      final ip = await response.transform(utf8.decoder).first;
      return ip;
    } catch (e) {
      return 'Error getting IP address: $e';
    }
  }

  void startCountdown() {
    int remainingSeconds = 120;
    Stream.periodic(Duration(seconds: 1), (i) => remainingSeconds - i)
        .take(remainingSeconds + 1)
        .listen(
      (seconds) {
        if (mounted) {
          setState(() {
            remainingTime =
                '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            remainingTime = '00:00';
          });
        }
      },
    );
  }

  Future<void> resendOTP() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    final authService = AuthService();
    print('Resending OTP to: ${widget.phoneNumber}');

    String result = await authService.sendSMS(
      widget.phoneNumber,
      getPlatform(),
      ipAddress ?? "255.255.255.255",
      widget.entry_id,
      account,
      databases,
    );

    // Reset loading state
    setState(() {
      _isLoading = false;
    });

    if (result == '200') {
      print('SMS resent successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP_resent_successfully'.tr())),
      );
      startCountdown();
    } else {
      print('Failed to resend SMS: $result');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Erreur de connexion.Merci d\'essayer à nouveau.'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.SingleChildScrollView(
      child: flutter.Container(
        padding: flutter.EdgeInsets.all(24),
        child: flutter.Column(
          crossAxisAlignment: flutter.CrossAxisAlignment.start,
          children: [
            flutter.Row(
              children: [
                flutter.IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _isLoading ? null : widget.onBack,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'otp_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'enter_otp'.tr() + '\n${widget.phoneNumber}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            flutter.Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                otpControllers.length,
                (index) => Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: KeyboardListener(
                    focusNode: FocusNode(), // Pour intercepter les événements clavier
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace) {
                        if (index > 0) {
                          // Effacer le contenu de la case actuelle
                          otpControllers[index].clear();
                          // Reculer immédiatement au champ précédent
                          focusNodes[index - 1].requestFocus();
                        }
                      }
                    },
                    child: TextField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) {
                        if (value.length == 1 && index < otpControllers.length - 1) {
                          // Avancer automatiquement au champ suivant
                          focusNodes[index + 1].requestFocus();
                        }
                      },
                      onTap: () {
                        otpControllers[index].selection = TextSelection.fromPosition(
                          TextPosition(offset: otpControllers[index].text.length),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7F50)),
                  ),
                )
              : flutter.CustomButton(
                  onPressed: () async {
                    if (_cachedUserId.isEmpty) {
                      // Try to recover the ID one more time
                      await _recoverUserId();
                      
                      if (_cachedUserId.isEmpty) {
                        print("Erreur : L'ID utilisateur mis en cache est toujours vide");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Une erreur est survenue. Veuillez réessayer.'.tr())),
                        );
                        return;
                      }
                    }
                    
                    // Set loading state
                    setState(() {
                      _isLoading = true;
                    });
                    
                    final authService = AuthService();
                    String result = await authService.VerifyOTP(
                      widget.phoneNumber,
                      otpControllers.map((controller) => controller.text).join(''),
                      _cachedUserId, // Now this won't be empty
                      account,
                      databases,
                    );
                    
                    // Reset loading state
                    setState(() {
                      _isLoading = false;
                    });
                    
                    print("Résultat de la vérification : $result");
                    
                    if (result == '200') {
                      await widget.onSubmit(_cachedUserId, widget.phoneNumber, result, widget.name, widget.prenom);
                    } else if (result == '400') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('please_provide_a_valid_OTP'.tr())),
                      );
                    } else if (result == '333') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('incorrect_OTP'.tr())),
                      );
                    } else if (result == 'ERR') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur de connexion. Merci d\'essayer à nouveau.'.tr())),
                      );
                    }
                  },
                  text: 'Continue'.tr(),
                ),
            
            SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'didnt_receive_code'.tr(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: (_isLoading || remainingTime != '00:00') ? null : resendOTP,
                    child: Text(
                      'resend'.tr(),
                      style: TextStyle(
                        color: (_isLoading || remainingTime != '00:00')
                            ? Colors.grey
                            : Color.fromARGB(255, 206, 122, 11),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    remainingTime,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

