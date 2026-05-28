import React, { useEffect } from 'react';
import { StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSequence,
  Easing,
} from 'react-native-reanimated';

interface FloatingNumberProps {
  value: number;
  x: number;
  y: number;
  isCritical?: boolean;
  onComplete: () => void;
}

export const FloatingNumber: React.FC<FloatingNumberProps> = ({
  value,
  x,
  y,
  isCritical = false,
  onComplete,
}) => {
  const translateY = useSharedValue(0);
  const opacity = useSharedValue(1);
  const scale = useSharedValue(isCritical ? 1.5 : 1);

  useEffect(() => {
    translateY.value = withTiming(-50, { duration: 1000, easing: Easing.out(Easing.ease) });
    opacity.value = withSequence(
      withTiming(1, { duration: 200 }),
      withTiming(0, { duration: 800 })
    );
    scale.value = withSequence(
      withTiming(isCritical ? 1.5 : 1, { duration: 100 }),
      withTiming(isCritical ? 1.2 : 0.8, { duration: 900 })
    );

    const timer = setTimeout(onComplete, 1000);
    return () => clearTimeout(timer);
  }, []);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        { translateY: translateY.value },
        { scale: scale.value },
      ],
      opacity: opacity.value,
    };
  });

  return (
    <Animated.Text
      style={[
        styles.text,
        {
          position: 'absolute',
          left: x,
          top: y,
          color: isCritical ? '#ff0055' : '#00f0ff',
          fontSize: isCritical ? 28 : 20,
          fontWeight: 'bold',
          textShadowColor: isCritical ? '#ff0055' : '#00f0ff',
          textShadowOffset: { width: 0, height: 0 },
          textShadowRadius: 10,
        },
        animatedStyle,
      ]}
    >
      {isCritical ? '💥 ' : ''}{Math.floor(value)}
    </Animated.Text>
  );
};

const styles = StyleSheet.create({
  text: {
    pointerEvents: 'none',
  },
});
