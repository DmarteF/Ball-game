import React, { memo, useState } from 'react';
import { Image, ImageStyle, StyleProp, StyleSheet, Text, TextStyle, View, ViewStyle } from 'react-native';

interface ProfileAvatarProps {
  avatar?: string;
  imageUri?: string;
  size?: number;
  style?: StyleProp<ViewStyle>;
  imageStyle?: StyleProp<ImageStyle>;
  textStyle?: StyleProp<TextStyle>;
}

function ProfileAvatarBase({ avatar = '🔵', imageUri, size = 52, style, imageStyle, textStyle }: ProfileAvatarProps) {
  const [imageFailed, setImageFailed] = useState(false);
  const shouldUseImage = Boolean(imageUri && !imageFailed);

  return (
    <View style={[styles.container, { width: size, height: size, borderRadius: size / 2 }, style]}>
      {shouldUseImage ? (
        <Image
          source={{ uri: imageUri }}
          resizeMode="cover"
          onError={() => setImageFailed(true)}
          style={[styles.image, { width: size, height: size, borderRadius: size / 2 }, imageStyle]}
        />
      ) : (
        <Text style={[styles.text, { fontSize: size * 0.52, lineHeight: size * 0.62 }, textStyle]}>{avatar}</Text>
      )}
    </View>
  );
}

export const ProfileAvatar = memo(ProfileAvatarBase);

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
    backgroundColor: '#ffffff14',
    borderWidth: 1,
    borderColor: '#00f0ff88',
    shadowColor: '#00f0ff',
    shadowOpacity: 0.35,
    shadowRadius: 8,
    elevation: 4,
  },
  image: {
    flexShrink: 0,
  },
  text: {
    color: '#ffffff',
    textAlign: 'center',
  },
});
