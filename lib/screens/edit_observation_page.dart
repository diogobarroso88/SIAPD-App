import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/observation.dart';
import '../models/observation_image.dart';
import '../models/service.dart';
import '../models/user_group.dart';
import '../models/service_titles.dart';
import '../objectbox.g.dart';
import '../providers/services_provider.dart';
import '../providers/user_groups_provider.dart';
import '../repositories/observations_repository.dart';
import '../services/objectbox_service.dart';


class EditObservationPage extends StatefulWidget {
  final Observation observation;

  const EditObservationPage({
    super.key,
    required this.observation,
  });

  @override
  State<EditObservationPage> createState() =>
      _EditObservationPageState();
}


class _EditObservationPageState
    extends State<EditObservationPage> {

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _descriptionController =
  TextEditingController();

  final TextEditingController _geocodeController =
  TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  static const int _maxImages = 6;

  List<File> _selectedImages = [];

  /// Fotografias que já existiam quando a página foi aberta.
  List<ObservationImage> _existingImages = [];

  Service? _selectedService;
  UserGroup? _selectedGroup;

  String? _selectedVariety;
  String? _selectedPhenologicalState;
  String? _selectedPhenologicalStateUuid;

  bool _isPublic = false;

  bool _initialized = false;
  bool _isSaving = false;


  bool _isVarietyService(Service? service) {
    return service?.slug == 'vine-varieties-identification';
  }


  bool _isPhenologicalService(Service? service) {
    return service?.slug == 'vine-phenological-states';
  }


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


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    final objectBox = context.read<ObjectBoxService>();
    final servicesProvider = context.read<ServicesProvider>();
    final userGroupsProvider = context.read<UserGroupsProvider>();

    final services = servicesProvider.subscribedServices;
    final groups = userGroupsProvider.groups;

    _selectedService = services.cast<Service?>().firstWhere(
          (service) =>
      service != null &&
          service.uuid == widget.observation.serviceUuid,
      orElse: () => null,
    );

    _selectedGroup = groups.cast<UserGroup?>().firstWhere(
          (group) =>
      group != null &&
          group.uuid == widget.observation.userGroupUuid,
      orElse: () => null,
    );

    _titleController.text = widget.observation.title;
    _descriptionController.text = widget.observation.description;
    _geocodeController.text = widget.observation.geocode;

    _isPublic = widget.observation.isPublic;

    // Reconstruir estado específico de variedades.
    if (_isVarietyService(_selectedService)) {
      _selectedVariety = widget.observation.title;
    }

    // Reconstruir estado específico de fenologia.
    if (_isPhenologicalService(_selectedService)) {
      _selectedPhenologicalStateUuid =
          widget.observation.titleUuid;

      for (final state
      in ServiceTitles.vinePhenologicalStates) {
        final uuid =
        ServiceTitles.vinePhenologicalStateUuids[state];

        if (uuid == widget.observation.titleUuid) {
          _selectedPhenologicalState = state;
          break;
        }
      }
    }

    // Carregar fotografias existentes.
    _existingImages = objectBox.observationImageBox
        .query(
      ObservationImage_.observationId.equals(
        widget.observation.id,
      ),
    )
        .build()
        .find();

    _selectedImages = _existingImages
        .map((image) => File(image.localPath))
        .where((file) => file.existsSync())
        .toList();

    _initialized = true;
  }


  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.maxPhotos,
          ),
        ),
      );
      return;
    }

    if (source == ImageSource.gallery) {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isEmpty) {
        return;
      }

      final remainingSlots =
          _maxImages - _selectedImages.length;

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
            content: Text(
              l10n.maxPhotos,
            ),
          ),
        );
      }

      return;
    }

    final image = await _imagePicker.pickImage(
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


  Future<void> _saveChanges({
    bool send = false,

  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isSaving) {
      return;
    }

    if (!_isTitleValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.validTitleRequired,
          ),
        ),
      );
      return;
    }

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.serviceMinimum,
          ),
        ),
      );
      return;
    }

    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.groupMinimum,
          ),
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.photoMinimum,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final objectBox = context.read<ObjectBoxService>();

      final observation = widget.observation;

      final title = _isPhenologicalService(_selectedService)
          ? _selectedPhenologicalState!
          : _isVarietyService(_selectedService)
          ? _selectedVariety!
          : _titleController.text.trim();

      final titleUuid =
      _isPhenologicalService(_selectedService)
          ? _selectedPhenologicalStateUuid ?? ''
          : '';

      // Atualizar os dados da observação existente.
      observation.serviceUuid =
          _selectedService!.uuid;

      observation.serviceSlug =
          _selectedService!.slug;

      observation.userGroupUuid =
          _selectedGroup!.uuid;

      observation.title = title;
      observation.titleUuid = titleUuid;

      observation.description =
          _descriptionController.text.trim();

      observation.geocode =
          _geocodeController.text.trim();

      observation.isPublic = _isPublic;

      observation.syncStatus = 'pending';

      objectBox.observationBox.put(observation);

      // --------------------------------------------------
      // FOTOGRAFIAS
      // --------------------------------------------------

      final existingPaths = _existingImages
          .map((image) => image.localPath)
          .toSet();

      final selectedExistingPaths = _selectedImages
          .map((file) => file.path)
          .where(existingPaths.contains)
          .toSet();

      // Remover fotografias que existiam mas foram apagadas
      // pelo utilizador.
      for (final image in _existingImages) {
        if (!selectedExistingPaths.contains(
          image.localPath,
        )) {
          final file = File(image.localPath);

          if (await file.exists()) {
            await file.delete();
          }

          objectBox.observationImageBox.remove(
            image.id,
          );
        }
      }

      // Pasta da observação.
      final observationDirectory = Directory(
        File(_existingImages.isNotEmpty
            ? _existingImages.first.localPath
            : '')
            .parent
            .path,
      );

      if (!await observationDirectory.exists()) {
        await observationDirectory.create(
          recursive: true,
        );
      }

      // Adicionar fotografias novas.
      for (final image in _selectedImages) {
        if (existingPaths.contains(image.path)) {
          continue;
        }

        final fileName = image.path.split('/').last;

        final destination = File(
          '${observationDirectory.path}/$fileName',
        );

        // Evitar conflitos de nomes.
        var finalDestination = destination;

        if (await finalDestination.exists()) {
          final timestamp =
              DateTime.now().millisecondsSinceEpoch;

          finalDestination = File(
            '${observationDirectory.path}/'
                '${timestamp}_$fileName',
          );
        }

        await image.copy(finalDestination.path);

        final observationImage = ObservationImage(
          observationId: observation.id,
          localPath: finalDestination.path,
          uploaded: false,
        );

        objectBox.observationImageBox.put(
          observationImage,
        );
      }

      // Se for apenas guardar, terminamos aqui.
      if (!send) {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pop(true);
        return;
      }

      // --------------------------------------------------
      // ENVIAR
      // --------------------------------------------------

      final repository =
      context.read<ObservationsRepository>();

      await repository.sendObservation(observation);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            send
                ? '${l10n.observationSendError} '
                '${l10n.changeSaved}'
                : l10n.cantSave,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _geocodeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final servicesProvider =
    context.watch<ServicesProvider>();

    final userGroupsProvider =
    context.watch<UserGroupsProvider>();

    final services =
        servicesProvider.subscribedServices;

    final groups =
        userGroupsProvider.groups;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.observationEdit),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          80,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
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
                initialValue:
                _selectedPhenologicalState,
                decoration:
                InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                  l10n.phenoSelect,
                ),
                items: ServiceTitles
                    .vinePhenologicalStates
                    .map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPhenologicalState =
                        value;

                    _selectedPhenologicalStateUuid =
                    value != null
                        ? ServiceTitles
                        .vinePhenologicalStateUuids[
                    value]
                        : null;

                    _titleController.text =
                        value ?? '';
                  });
                },
              )
            else if (_isVarietyService(
              _selectedService,
            ))
              Autocomplete<String>(
                initialValue: TextEditingValue(
                  text: _selectedVariety ?? '',
                ),
                optionsBuilder:
                    (textEditingValue) {
                  if (textEditingValue
                      .text
                      .isEmpty) {
                    return const Iterable<
                        String>.empty();
                  }

                  return ServiceTitles
                      .vineVarieties
                      .where(
                        (variety) => variety
                        .toLowerCase()
                        .contains(
                      textEditingValue.text
                          .toLowerCase(),
                    ),
                  );
                },
                onSelected: (value) {
                  setState(() {
                    _selectedVariety =
                        value;

                    _titleController.text =
                        value;
                  });
                },
                fieldViewBuilder: (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                    ) {
                  return TextField(
                    controller:
                    textEditingController,
                    focusNode: focusNode,
                    decoration:
                    InputDecoration(
                      border:
                      OutlineInputBorder(),
                      hintText:
                      l10n.varietySearch,
                    ),
                    onChanged: (value) {
                      if (value !=
                          _selectedVariety) {
                        setState(() {
                          _selectedVariety =
                          null;
                        });
                      }
                    },
                  );
                },
              )
            else
              TextField(
                controller: _titleController,
                decoration:
                InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                  l10n.observationTitle,
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
              decoration:
              InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                l10n.optionalDescription,
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
                    onPressed: _isSaving
                        ? null
                        : () => _pickImage(
                      ImageSource.camera,
                    ),
                    icon: const Icon(
                      Icons.camera_alt,
                    ),
                    label:
                    Text(l10n.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _pickImage(
                      ImageSource.gallery,
                    ),
                    icon: const Icon(
                      Icons.photo_library,
                    ),
                    label:
                    Text(l10n.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_selectedImages.isEmpty)
              Container(
                width: double.infinity,
                height: 150,
                decoration:
                BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    l10n.selectedPhotos,
                    textAlign:
                    TextAlign.center,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount:
                _selectedImages.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder:
                    (context, index) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                          child: Image.file(
                            _selectedImages[
                            index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _isSaving
                              ? null
                              : () {
                            setState(() {
                              _selectedImages
                                  .removeAt(
                                index,
                              );
                            });
                          },
                          child: Container(
                            decoration:
                            const BoxDecoration(
                              color: Colors.black54,
                              shape:
                              BoxShape.circle,
                            ),
                            padding:
                            const EdgeInsets.all(
                              4,
                            ),
                            child:
                            const Icon(
                              Icons.close,
                              color:
                              Colors.white,
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
                  fontWeight:
                  FontWeight.bold,
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
                onPressed: _isSaving
                    ? null
                    : (index) {
                  setState(() {
                    _isPublic =
                        index == 1;
                  });
                },
                borderRadius:
                BorderRadius.circular(8),
                children:  [
                  Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(l10n.private),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.public,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(l10n.public),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // SERVIÇO
            // --------------------------------------------------

            Text(
              l10n.service,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<Service>(
              initialValue:
              _selectedService,
              decoration:
              InputDecoration(
                border:
                OutlineInputBorder(),
                hintText:
                l10n.selectService,
              ),
              items: services.map((service) {
                return DropdownMenuItem<Service>(
                  value: service,
                  child: Text(
                    service.name,
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (service) {
                setState(() {
                  _selectedService =
                      service;

                  _selectedVariety =
                  null;

                  _selectedPhenologicalState =
                  null;

                  _selectedPhenologicalStateUuid =
                  null;

                  if (_isVarietyService(
                      service) ||
                      _isPhenologicalService(
                          service)) {
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
              initialValue:
              _selectedGroup,
              decoration:
              InputDecoration(
                border:
                OutlineInputBorder(),
                hintText:
                l10n.selectGroup,
              ),
              items: groups.map((group) {
                return DropdownMenuItem<UserGroup>(
                  value: group,
                  child: Text(
                    group.name,
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (group) {
                setState(() {
                  _selectedGroup =
                      group;
                });
              },
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // LOCALIZAÇÃO
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
              decoration:
              BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius:
                BorderRadius.circular(8),
              ),
              clipBehavior:
              Clip.hardEdge,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    widget.observation
                        .latitude,
                    widget.observation
                        .longitude,
                  ),
                  initialZoom: 16,
                  interactionOptions:
                  const InteractionOptions(
                    flags:
                    InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/'
                        '{z}/{x}/{y}.png',
                    userAgentPackageName:
                    'com.example.mysense_app_new',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          widget.observation
                              .latitude,
                          widget.observation
                              .longitude,
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

            const SizedBox(height: 8),

            Text(
              '${l10n.latitude} ${widget.observation.latitude}\n'
                  '${l10n.longitude} ${widget.observation.longitude}',
              style: const TextStyle(
                color: Colors.grey,
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
                onPressed: _isSaving
                    ? null
                    : () => _saveChanges(
                  send: true,
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    :  Text(l10n.send),
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
                onPressed: _isSaving
                    ? null
                    : () => _saveChanges(),
                child: Text(
                  l10n.saveObservation,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}