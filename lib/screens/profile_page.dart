import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/locale_provider.dart';
import '../providers/services_provider.dart';
import '../repositories/observations_repository.dart';
import '../l10n/app_localizations.dart';


class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _numberOfObservations = 0;
  bool _isLoadingObservations = true;

  @override
  void initState() {
    super.initState();
    _loadNumberOfObservations();
  }

  Future<void> _loadNumberOfObservations() async {
    try {
      final servicesProvider = context.read<ServicesProvider>();
      final observationsRepository =
      context.read<ObservationsRepository>();

      int total = 0;

      for (final service in servicesProvider.subscribedServices) {
        final observations =
        await observationsRepository.getRemoteObservations(
          service.slug,
        );

        total += observations.length;
      }

      if (mounted) {
        setState(() {
          _numberOfObservations = total;
          _isLoadingObservations = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingObservations = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButton<Locale>(
            value: localeProvider.locale,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: Locale('pt', 'PT'),
                child: Text('🇵🇹 Português'),
              ),
              DropdownMenuItem(
                value: Locale('en', 'GB'),
                child: Text('🇬🇧 English'),
              ),
              DropdownMenuItem(
                value: Locale('es', 'ES'),
                child: Text('🇪🇸 Español'),
              ),
            ],
            onChanged: (locale) {
              if (locale != null) {
                context.read<LocaleProvider>().setLocale(locale);
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 60),

          CircleAvatar(
            radius: 60,
            backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
            child: user.avatarUrl.isEmpty
                ? const Icon(
              Icons.person,
              size: 60,
            )
                : ClipOval(
              child: Image.network(
                user.avatarUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.person,
                    size: 60,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          const SizedBox(height: 60),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.name),
                  subtitle: Text(user.name),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(l10n.email),
                  subtitle: Text(user.email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  title: Text(l10n.sentObservations),
                  subtitle: _isLoadingObservations
                      ? Text(l10n.loading)
                      : Text(
                    _numberOfObservations.toString(),
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