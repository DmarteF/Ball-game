import type { ConfigContext, ExpoConfig } from 'expo/config';
import adsSettings from './src/services/adsConfig.shared.json';

const androidAppId = adsSettings.ADS_PRODUCTION
  ? adsSettings.ADMOB_IDS.production.androidAppId
  : adsSettings.ADMOB_IDS.test.androidAppId;

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'Neon Idle Escape',
  slug: 'neon-idle-escape',
  version: '1.0.0',
  orientation: 'portrait',
  jsEngine: 'hermes',
  icon: './neon_idle_escape_app_icon_1024.png',
  scheme: 'neonidleescape',
  userInterfaceStyle: 'automatic',
  newArchEnabled: true,
  ios: {
    supportsTablet: true,
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './neon_idle_escape_app_icon_1024.png',
      backgroundColor: '#000',
    },
    package: 'com.dragonfire.neonidleescape',
    edgeToEdgeEnabled: true,
    permissions: [
      'android.permission.RECORD_AUDIO',
      'android.permission.MODIFY_AUDIO_SETTINGS',
    ],
  },
  web: {
    bundler: 'metro',
    output: 'static',
    favicon: './assets/images/favicon.png',
  },
  plugins: [
    'expo-router',
    [
      'expo-splash-screen',
      {
        image: './assets/images/splash-image.png',
        imageWidth: 200,
        resizeMode: 'contain',
        backgroundColor: '#000',
      },
    ],
    'expo-audio',
    'expo-asset',
    [
      'react-native-google-mobile-ads',
      {
        androidAppId,
      },
    ],
  ],
  experiments: {
    typedRoutes: true,
  },
  extra: {
    router: {},
    eas: {
      projectId: '27b640a9-71f1-4d10-9050-2de1ad5a08fd',
    },
  },
  owner: 'dmartef4444',
  runtimeVersion: {
    policy: 'appVersion',
  },
  updates: {
    url: 'https://u.expo.dev/27b640a9-71f1-4d10-9050-2de1ad5a08fd',
  },
});
