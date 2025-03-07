import 'package:datalock/services/map_service.dart';
import 'package:datalock/ui/screens/AdressesScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/models/addresses_model.dart';

class SaveAddressScreen extends StatefulWidget {
  LatLng location;
  final Address? addressToEdit;

  SaveAddressScreen({
    Key? key,
    required this.location,
    this.addressToEdit,
  }) : super(key: key);

  @override
  State<SaveAddressScreen> createState() => _SaveAddressScreenState();
}

class _SaveAddressScreenState extends State<SaveAddressScreen> {
  String _selectedType = '';
  String _address = '';
  String _customLabel = ''; // Add this line for custom label
  bool _isLoading = true;
  late GoogleMapController _mapController;
  final TextEditingController _customLabelController = TextEditingController(); // Add this line

  @override
  void initState() {
    super.initState();
    _getAddressFromLatLng();
    if (widget.addressToEdit != null) {
      _selectedType = widget.addressToEdit!.icon;
      if (_selectedType == 'location') {
        _customLabel = widget.addressToEdit!.name;
        _customLabelController.text = _customLabel;
      }
    }
  }

  Future<void> _saveAddress() async {
    if (_selectedType.isEmpty) return;
    if (_selectedType == 'Custom' && _customLabel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for this location')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final mapService = MapService();
      final String label;
      final String address;
      if (_selectedType == 'Custom') {
        label = 'C';
        address = _customLabel;
      } else if (_selectedType == 'Home') {
        label = 'H';
        address = 'Domicile';
      } else if (_selectedType == 'Office') {
        label = 'W';
        address = 'Bureau';
      } else {
        label = _selectedType;
        address = _address;
      }

      final result = widget.addressToEdit == null
          ? await mapService.addFavoriteAddress(
              label: label,
              address: address,
              latitude: widget.location.latitude,
              longitude: widget.location.longitude,
            )
          : await mapService.updateFavoriteAddress(
              documentId: widget.addressToEdit!.id,
              address: address,
              latitude: widget.location.latitude,
              longitude: widget.location.longitude,
            );

      if (result['status'] == '200') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully')),
        );
        Navigator.pop(context, true);
      } else if (widget.addressToEdit == null) {
        if (result['status'] == '600') {
          _showBottomSheet('Home address already exists');
        } else if (result['status'] == '602') {
          _showBottomSheet('Work address already exists');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to save address')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to save address')),
        );
      }
    } catch (e) {
      print('Error saving address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while saving the address')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFFF7F50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.location.latitude,
        widget.location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address =
              "${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
      setState(() {
        _address = "${widget.location.latitude}, ${widget.location.longitude}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLocationTypeButton(String type, IconData icon) {
    bool isSelected = _selectedType == type;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFFF7F50).withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Color(0xFFFF7F50), width: 2)
            : Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedType = type;
              if (type != 'Custom') {
                _customLabel = '';
                _customLabelController.clear();
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Color(0xFFFF7F50) : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Color(0xFFFF7F50) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLocationField() {
    bool isSelected = _selectedType == 'Custom';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFFF7F50).withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Color(0xFFFF7F50), width: 2)
            : Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedType = 'Custom';
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: isSelected ? Color(0xFFFF7F50) : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _customLabelController,
                    onTap: () {
                      setState(() {
                        _selectedType = 'Custom';
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _customLabel = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Nommer cet address..',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.addressToEdit != null ? 'Modifier mon adresse' : 'Sauvegarder l\'adresse',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.location,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: widget.location,
                ),
              },
              onTap: (LatLng newLocation) {
                setState(() {
                  widget.location = newLocation;
                });
                _getAddressFromLatLng();
              },
              zoomControlsEnabled: true,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Location',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    TextField(
                      controller: TextEditingController(text: _address),
                      onChanged: (value) {
                        setState(() {
                          _address = value;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Save As',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLocationTypeButton('Home', Icons.home_outlined),
                  _buildLocationTypeButton('Office', Icons.business_outlined),
                  _buildCustomLocationField(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (widget.addressToEdit != null)
                  TextButton(
                    onPressed: () async {
                      final mapService = MapService();
                      final result = await mapService.deleteFavoriteAddress(
                        widget.addressToEdit!.id,
                      );
                      if (result['status'] == '200') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Address deleted successfully')),
                        );
                        Navigator.pop(context, true); // Return true to trigger refresh
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'] ?? 'Failed to delete address')),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    child: const Text('Supprimer l\'adresse'),
                  ),
                if (widget.addressToEdit != null)
                  const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _selectedType.isEmpty ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF70B9BE),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.addressToEdit != null
                        ? 'Sauvegarder les modifications'
                        : 'Sauvegarder l\'adresse',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

