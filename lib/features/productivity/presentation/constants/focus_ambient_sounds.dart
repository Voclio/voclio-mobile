import 'package:voclio_app/core/icons/app_icons.dart';
import 'package:flutter/material.dart';

class FocusAmbientSound {
  final String? id;
  final String label;
  final IconData icon;
  final String? url;

  FocusAmbientSound({
    required this.id,
    required this.label,
    required this.icon,
    this.url,
  });
}

class FocusAmbientSounds {
  static final List<FocusAmbientSound> all = [
    FocusAmbientSound(
      id: null,
      label: 'None',
      icon: AppIcons.volume_off,
    ),
    FocusAmbientSound(
      id: 'rain',
      label: 'Rain',
      icon: AppIcons.water_drop,
      url: 'https://assets.mixkit.co/active_storage/sfx/2393/2393-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'ocean',
      label: 'Ocean',
      icon: AppIcons.waves,
      url: 'https://assets.mixkit.co/active_storage/sfx/1531/1531-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'forest',
      label: 'Forest',
      icon: AppIcons.forest,
      url: 'https://assets.mixkit.co/active_storage/sfx/2472/2472-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'cafe',
      label: 'Cafe',
      icon: AppIcons.coffee,
      url: 'https://assets.mixkit.co/active_storage/sfx/2578/2578-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'white_noise',
      label: 'White',
      icon: AppIcons.cloud_off_rounded,
      url: 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'thunder',
      label: 'Storm',
      icon: AppIcons.flash_on_rounded,
      url: 'https://assets.mixkit.co/active_storage/sfx/2817/2817-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'wind',
      label: 'Wind',
      icon: AppIcons.auto_awesome_rounded,
      url: 'https://assets.mixkit.co/active_storage/sfx/1220/1220-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'birds',
      label: 'Birds',
      icon: AppIcons.celebration_rounded,
      url: 'https://assets.mixkit.co/active_storage/sfx/2432/2432-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'fireplace',
      label: 'Fire',
      icon: AppIcons.local_fire_department,
      url: 'https://assets.mixkit.co/active_storage/sfx/1726/1726-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'lofi',
      label: 'Lo-fi',
      icon: AppIcons.music_note,
      url: 'https://assets.mixkit.co/active_storage/sfx/212/212-preview.mp3',
    ),
    FocusAmbientSound(
      id: 'piano',
      label: 'Piano',
      icon: AppIcons.notifications_active_outlined,
      url: 'https://assets.mixkit.co/active_storage/sfx/2528/2528-preview.mp3',
    ),
  ];

  static FocusAmbientSound? byId(String? id) {
    for (final sound in all) {
      if (sound.id == id) return sound;
    }
    return null;
  }

  static String? labelFor(String? id) => byId(id)?.label;
}
