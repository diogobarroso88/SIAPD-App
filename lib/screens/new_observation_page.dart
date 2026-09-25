import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/observation.dart';
import '../models/observation_image.dart';
import '../models/service.dart';
import '../models/user.dart';
import '../models/user_group.dart';
import '../objectbox.g.dart';
import '../providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../providers/user_groups_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/service_titles.dart';
import '../repositories/observations_repository.dart';
import '../services/objectbox_service.dart';
import 'navigation_home_screen.dart';



class NewObservationPage extends StatefulWidget {
  const NewObservationPage({super.key});

  @override
  State<NewObservationPage> createState() => _NewObservationPageState();
}

class _NewObservationPageState extends State<NewObservationPage> {

  final _descriptionController = TextEditingController();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _geocodeController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  List<File> _selectedImages = [];

  static const int _maxImages = 6;

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.maxPhotos),
        ),
      );
      return;
    }

    if (source == ImageSource.gallery) {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isEmpty) {
        return;
      }

      final remainingSlots = _maxImages - _selectedImages.length;

      setState(() {
        _selectedImages.addAll(
          images
              .take(remainingSlots)
              .map((image) => File(image.path)),
        );
      });

      if (images.length > remainingSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.maxPhotos),
          ),
        );
      }

      return;
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImages.add(File(image.path));
    });
  }

  String? _selectedVariety;
  String? _selectedPhenologicalState;
  String? _selectedPhenologicalStateUuid;

  Service? _selectedService;
  UserGroup? _selectedGroup;

  bool _isPublic = false;
  bool _defaultsInitialized = false;

  Position? _currentPosition;
  bool _isGettingLocation = false;
  String? _locationError;


  bool _isTitleValid() {
    if (_selectedService == null) {
      return false;
    }

    if (_isVarietyService(_selectedService)) {
      return _selectedVariety != null;
    }

    if (_isPhenologicalService(_selectedService)) {
      return _selectedPhenologicalState != null;
    }

    return _titleController.text.trim().isNotEmpty;
  }

  void _setDefaultSelections(
      List<Service> services,
      List<UserGroup> groups,
      User user,
      ) {
    if (_selectedService == null && services.isNotEmpty) {
      _selectedService = services.first;
    }

    if (_selectedGroup == null && groups.isNotEmpty) {
      final userName = user.name.toLowerCase();

      final matchingGroup = groups.where(
            (group) => group.name.toLowerCase().contains(userName),
      );

      _selectedGroup = matchingGroup.isNotEmpty
          ? matchingGroup.first
          : groups.first;
    }
  }

  Future<void> _saveObservation({bool send = false}) async {
    final l10n = AppLocalizations.of(context)!;
    // Validações obrigatórias
    if (!_isTitleValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.validTitleRequired),
        ),
      );
      return;
    }

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.serviceMinimum),
        ),
      );
      return;
    }

    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.groupMinimum),
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photoMinimum),
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gpsMinimum),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final objectBox = context.read<ObjectBoxService>();

    final user = authProvider.user!;

    final title = _isPhenologicalService(_selectedService)
        ? _selectedPhenologicalState!
        : _isVarietyService(_selectedService)
        ? _selectedVariety!
        : _titleController.text.trim();

    final titleUuid = _isPhenologicalService(_selectedService)
        ? _selectedPhenologicalStateUuid ?? ''
        : '';

    final observation = Observation(
      userUuid: user.uuid,
      serviceUuid: _selectedService!.uuid,
      serviceSlug: _selectedService!.slug,
      userGroupUuid: _selectedGroup!.uuid,
      title: title,
      titleUuid: titleUuid,
      description: _descriptionController.text.trim(),
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      geocode: _geocodeController.text.trim(),
      isPublic: _isPublic,
      syncStatus: 'pending',
    );

    // Guardar primeiro a observação para obter o ID do ObjectBox
    final observationId = objectBox.observationBox.put(observation);

    // Pasta permanente para as fotografias
    final appDirectory = await getApplicationDocumentsDirectory();

    final observationDirectory = Directory(
      '${appDirectory.path}/observations/$observationId',
    );

    if (!await observationDirectory.exists()) {
      await observationDirectory.create(recursive: true);
    }

    // Guardar cada fotografia
    for (final image in _selectedImages) {
      final fileName = image.path.split('/').last;

      final destination = File(
        '${observationDirectory.path}/$fileName',
      );

      await image.copy(destination.path);

      final observationImage = ObservationImage(
        observationId: observationId,
        localPath: destination.path,
        uploaded: false,
      );

      objectBox.observationImageBox.put(observationImage);
    }

    print('========== OBSERVAÇÃO GUARDADA ==========');
    print('ObjectBox ID: $observationId');
    print('Utilizador: ${observation.userUuid}');
    print('Título: ${observation.title}');
    print('Title UUID: ${observation.titleUuid}');
    print('Serviço: ${observation.serviceSlug}');
    print('Grupo: ${observation.userGroupUuid}');
    print('Latitude: ${observation.latitude}');
    print('Longitude: ${observation.longitude}');
    print('Fotografias: ${_selectedImages.length}');
    print('Estado: ${observation.syncStatus}');
    print('==========================================');

    // Se foi apenas para guardar, vamos diretamente para a Homepage.
    if (!send) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NavigationHomeScreen(),
        ),
      );

      return;
    }

    // Se foi para enviar, enviar agora.
    final observationsRepository = context.read<ObservationsRepository>();

    try {
      await observationsRepository.sendObservation(observation);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NavigationHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.observationSendError} '
                '${l10n.observationSavedForRetry}',
          ),
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _locationError = l10n.locationUnavailable;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = l10n.gpsDenied;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
          l10n.deniedGps;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        _locationError = l10n.locationUnavailable;
      });
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  String _getPhenologicalStateTranslation(
      String state,
      AppLocalizations l10n,
      ) {
    final uuid = ServiceTitles.vinePhenologicalStateUuids[state];

    switch (uuid) {
      case 'a_winter_bud':
        return l10n.phenologyAWinterBud;
      case 'b_woolly_bud':
        return l10n.phenologyBWoollyBud;
      case 'c_bud_break':
        return l10n.phenologyCBudBreak;
      case 'd_leaf_emergence':
        return l10n.phenologyDLeafEmergence;
      case 'e_leaves_separated':
        return l10n.phenologyELeavesSeparated;
      case 'f_inflorescences_visible':
        return l10n.phenologyFInflorescencesVisible;
      case 'g_inflorescences_separated':
        return l10n.phenologyGInflorescencesSeparated;
      case 'h_flowers_separated':
        return l10n.phenologyHFlowersSeparated;
      case 'i_bloom':
        return l10n.phenologyIBloom;
      case 'j_fruit_set':
        return l10n.phenologyJFruitSet;
      case 'k_berries_pea_size':
        return l10n.phenologyKBerriesPeaSize;
      case 'l_berries_touching':
        return l10n.phenologyLBerriesTouching;
      case 'm_veraison':
        return l10n.phenologyMVeraison;
      case 'n_maturity':
        return l10n.phenologyNMaturity;
      case 'o_cane_maturation':
        return l10n.phenologyOCaneMaturation;
      case 'p_leaf_fall':
        return l10n.phenologyPLeafFall;
      default:
        return state;
    }
  }

  bool _isVarietyService(Service? service) {
    return service?.slug == 'vine-varieties-identification';
  }

  bool _isPhenologicalService(Service? service) {
    return service?.slug == 'vine-phenological-states';
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _geocodeController.dispose();
    super.dispose();
  }

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;

    final servicesProvider = context.read<ServicesProvider>();
    final userGroupsProvider = context.read<UserGroupsProvider>();
    final authProvider = context.read<AuthProvider>();

    final services = servicesProvider.subscribedServices;
    final groups = userGroupsProvider.groups;
    final user = authProvider.user;

    if (_defaultsInitialized) {
      return;
    }

    if (services.isEmpty || groups.isEmpty || user == null) {
      return;
    }

    // Serviço por defeito
    _selectedService = services.first;

    // Grupo por defeito
    final userName = user.name.trim().toLowerCase();

    UserGroup? defaultGroup;

    if (userName.isNotEmpty) {
      for (final group in groups) {
        if (group.name.trim().toLowerCase() == '${l10n.individualGroup} $userName') {
          defaultGroup = group;
          break;
        }
      }

      if (defaultGroup == null) {
        for (final group in groups) {
          if (group.name.trim().toLowerCase().contains(userName)) {
            defaultGroup = group;
            break;
          }
        }
      }
    }

    _selectedGroup = defaultGroup ?? groups.first;

    _defaultsInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final servicesProvider = context.watch<ServicesProvider>();
    final userGroupsProvider = context.watch<UserGroupsProvider>();

    final services = servicesProvider.subscribedServices;
    final groups = userGroupsProvider.groups;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newObservation),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // TÍTULO
            // --------------------------------------------------

            Text(
              l10n.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (_isPhenologicalService(_selectedService))
              DropdownButtonFormField<String>(
                value: _selectedPhenologicalState,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: l10n.phenoSelect,
                ),
                items: ServiceTitles.vinePhenologicalStates.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(
                      _getPhenologicalStateTranslation(state, l10n),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPhenologicalState = value;
                    _selectedPhenologicalStateUuid =
                    value != null
                        ? ServiceTitles.vinePhenologicalStateUuids[value]
                        : null;

                    _titleController.text = value ?? '';
                  });
                },
              )
            else if (_isVarietyService(_selectedService))
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }

                  return ServiceTitles.vineVarieties.where(
                        (variety) => variety.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: (value) {
                  setState(() {
                    _selectedVariety = value;
                    _titleController.text = value;
                  });
                },
                fieldViewBuilder: (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                    ) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: l10n.varietySearch,
                    ),
                    onChanged: (value) {
                      // Se o utilizador alterar o texto depois de selecionar
                      // uma casta, deixa de ser considerada uma seleção válida.
                      if (value != _selectedVariety) {
                        setState(() {
                          _selectedVariety = null;
                        });
                      }
                    },
                  );
                },
              )
            else
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: l10n.observationTitle,
                ),
              ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // DESCRIÇÃO
            // --------------------------------------------------

            Text(
              l10n.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: l10n.optionalDescription,
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // FOTOGRAFIAS
            // --------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(l10n.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Preview das fotografias
            if (_selectedImages.isEmpty)
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    l10n.selectedPhotos,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // PRIVACIDADE
            // --------------------------------------------------

            Center(
              child: Text(
                l10n.privacy,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: ToggleButtons(
                isSelected: [
                  !_isPublic,
                  _isPublic,
                ],
                onPressed: (index) {
                  setState(() {
                    _isPublic = index == 1;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 18),
                        SizedBox(width: 6),
                        Text(l10n.private),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.public, size: 18),
                        SizedBox(width: 6),
                        Text(l10n.public),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // SERVIÇO
            // --------------------------------------------------
            const SizedBox(height: 16),
            Text(
              l10n.service,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<Service>(
              initialValue: _selectedService,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: l10n.serviceChoose,
              ),
              items: services.map((service) {
                return DropdownMenuItem<Service>(
                  value: service,
                  child: Text(service.name),
                );
              }).toList(),
              onChanged: (service) {
                setState(() {
                  _selectedService = service;
                  _selectedVariety = null;
                  _selectedPhenologicalState = null;
                  _selectedPhenologicalStateUuid = null;

                  if (_isVarietyService(service) ||
                      _isPhenologicalService(service)) {
                    _titleController.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // GRUPO
            // --------------------------------------------------

            Text(
              l10n.group,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<UserGroup>(
              initialValue: _selectedGroup,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: l10n.selectGroup,
              ),
              items: groups.map((group) {
                return DropdownMenuItem<UserGroup>(
                  value: group,
                  child: Text(group.name),
                );
              }).toList(),
              onChanged: (group) {
                setState(() {
                  _selectedGroup = group;
                });
              },
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // MAPA
            // --------------------------------------------------

            Text(
              l10n.location,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: _isGettingLocation
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : _locationError != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _locationError!,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : _currentPosition == null
                  ? Center(
                child: Text(l10n.locationUnavailable),
              )
                  : FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.mysense_app_new',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_on,
                          size: 45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // ENVIAR
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (!_isTitleValid()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.validTitleRequired),
                      ),
                    );
                    return;
                  }

                  _saveObservation(send: true);
                },
                child: Text(l10n.send),
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // GUARDAR
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  if (!_isTitleValid()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.validTitleRequired),
                      ),
                    );
                    return;
                  }

                  _saveObservation();
                },
                child: Text(l10n.saveObservation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

