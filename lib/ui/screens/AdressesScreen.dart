import 'package:datalock/config/config.dart';
import 'package:datalock/services/map_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../data/models/addresses_model.dart';
import 'MapScreen.dart';
import 'SaveAddressScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appwrite/appwrite.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _isLoading = true;
  final MapService _mapService = MapService();
  String? cachedUserId;
  final account = Config.getAccount();
  final databases = Config.getDatabases();
  List<Address> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadCachedUserId();
  }

  Future<void> _loadCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedUserId = prefs.getString('cached_user_id');
    });
    if (cachedUserId == null) {
      print("Attention : L'ID utilisateur mis en cache est null");
    } else {
      _loadAddresses();
    }
  }

Future<void> _loadAddresses() async {
  print('Starting to load addresses...');
  setState(() {
    _isLoading = true;
  });

  try {
    if (cachedUserId == null) {
      print("Error: No cached user ID found");
      return;
    }

    final result = await _mapService.getFavoriteAddresses(
      cachedUserId!,
      account,
      databases
    );
    print('Got addresses result: $result');

    if (result['status'] == '200' && result['data'] != null) {
      final List<dynamic> addressesData = result['data'] as List<dynamic>;
      print('Processing addresses data: $addressesData');

      final List<Address> loadedAddresses = addressesData.map((addr) {
        String name;
        String icon;
        
        switch (addr['label']) {
          case 'H':
            name = 'Domicile'.tr();
            icon = 'home';
            break;
          case 'W':
            name = 'Bureau'.tr();
            icon = 'work';
            break;
          case 'C':
            // Pour les adresses personnalisées, nous utiliserons le champ 'address' comme nom
            // car il contient le texte entré par l'utilisateur
            name = addr['address'];
            icon = 'location';
            break;
          default:
            name = addr['address'];
            icon = 'location';
        }

        return Address(
          id: addr['\$id'] ?? '',
          name: name,
          latitude: double.parse(addr['latitude'].toString()),
          longitude: double.parse(addr['longitude'].toString()),
          icon: icon,
          color: Color(0xFFFF7F50),
        );
      }).toList();

      print('Created Address objects: $loadedAddresses');

      setState(() {
        addresses = loadedAddresses;
      });
    } else {
      print('Error loading addresses: ${result['message']}');
    }
  } catch (e) {
    print('Error loading addresses: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


 Widget _buildAddressItem({
  required String title,
  required String coordinates,
  required IconData icon,
  required String documentId,
  bool isCurrentLocation = false,
  VoidCallback? onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFFF7F50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Color(0xFFFF7F50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coordinates,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.grey[600],
                size: 24,
              ),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
              onPressed: () => _showDeleteConfirmation(context, documentId),
            ),
          ],
        ),
      ),
    ),
  );
}
Future<void> _showDeleteConfirmation(BuildContext context, String documentId) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
                'Remove Adresse'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
               Text(
                'Are you sure you want to delete this adresse?'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 235, 228),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:  Text(
                        'Cancel'.tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final mapService = MapService();
                        final result = await mapService.deleteFavoriteAddress(documentId);
                        
                        if (result['status'] == '200') {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Address deleted successfully'.tr())),
                            );
                          }
                          _loadAddresses(); // Refresh the list
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'] ?? 'Failed to delete address'.tr())),
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:  Text(
                        'Yes, remove'.tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'office':
      case 'work':
        return Icons.work_outline;
      case 'navigation':
        return Icons.navigation_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  String _formatCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°';
  }

  @override
  Widget build(BuildContext context) {
    print('Building AddressesScreen with ${addresses.length} addresses');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF7F50)),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          'Mes adresses'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F50)))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...addresses.map((address) {
                        print('Rendering address: ${address.name}');
                        return _buildAddressItem(
                          title: address.name,
                          coordinates: _formatCoordinates(
                            address.latitude,
                            address.longitude,
                          ),
                          icon: _getIconForType(address.icon),
                          documentId: address.id,  // Add this line
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SaveAddressScreen(
                                  location: LatLng(
                                    address.latitude,
                                    address.longitude,
                                  ),
                                  addressToEdit: address,
                                ),
                              ),
                            );

                            if (result == true) {
                              await _loadAddresses();
                            }
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      final LatLng? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            initialLocation: const LatLng(0, 0), // Provide a default location
                          ),
                        ),
                      );
                      if (result != null) {
                        final bool? saveResult = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SaveAddressScreen(
                              location: result,
                            ),
                          ),
                        );
                        if (saveResult == true) {
                          await _loadAddresses();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF7F50),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:  Text(
                      'Ajouter une adresse'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

