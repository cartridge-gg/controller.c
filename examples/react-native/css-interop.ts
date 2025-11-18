import { Image } from "expo-image";
import { LinearGradient } from "expo-linear-gradient";
import { cssInterop, remapProps } from "nativewind";
import { FlatList, Pressable, Text, View } from "react-native";
import Svg, { Circle, Path, Rect, SvgUri } from "react-native-svg";

// Configure LinearGradient to accept className
cssInterop(LinearGradient, {
  className: {
    target: "style",
  },
});

// Configure Image from expo-image to accept className
cssInterop(Image, {
  className: {
    target: "style",
  },
});

// Configure FlatList to accept className for both style and contentContainerStyle
remapProps(FlatList, {
  className: "style",
  contentContainerClassName: "contentContainerStyle",
});

// Configure core React Native components
cssInterop(View, {
  className: {
    target: "style",
  },
});

cssInterop(Text, {
  className: {
    target: "style",
  },
});

cssInterop(Pressable, {
  className: {
    target: "style",
  },
});

// Configure SVG components
cssInterop(Svg, {
  className: {
    target: "style",
    fill: true,
  },
});

cssInterop(Path, {
  className: {
    // @ts-expect-error
    target: "style",
    nativeStyleToProp: {
      width: true,
      height: true,
      stroke: true,
      strokeWidth: true,
      fill: true,
    },
  },
});

cssInterop(Circle, {
  className: {
    // @ts-expect-error
    target: "style",
    nativeStyleToProp: {
      width: true,
      height: true,
      stroke: true,
      strokeWidth: true,
      fill: true,
    },
  },
});

cssInterop(Rect, {
  className: {
    // @ts-expect-error
    target: "style",
    nativeStyleToProp: {
      width: true,
      height: true,
      stroke: true,
      strokeWidth: true,
      fill: true,
    },
  },
});

cssInterop(SvgUri, {
  className: {
    target: "style",
  },
});

