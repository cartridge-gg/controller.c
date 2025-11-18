import { View } from 'react-native';
import { vars } from 'nativewind';
import { SessionApp } from './components/session/SessionApp';

// Verify NativeWind installation
if (__DEV__) {
  try {
    const { verifyInstallation } = require('nativewind');
    verifyInstallation();
  } catch (e) {
    console.log('NativeWind verification:', e);
  }
}

// Cartridge theme colors
const themeVars = vars({
  "--background-100": "135 8% 9%",
  "--background-125": "135 8% 10%",
  "--background-150": "135 7% 11%",
  "--background-200": "135 6% 13%",
  "--background-300": "120 5% 15%",
  "--background-400": "120 6% 17%",
  "--background-500": "132 4% 23%",
  "--translucent-dark-100": "0 0% 0% / 0.078",
  "--translucent-dark-150": "0 0% 0% / 0.122",
  "--translucent-dark-200": "0 0% 0% / 0.478",
  "--translucent-dark-300": "0 0% 0% / 0.639",
  "--translucent-light-100": "0 0% 100% / 0.039",
  "--translucent-light-150": "0 0% 100% / 0.161",
  "--translucent-light-200": "0 0% 100% / 0.478",
  "--translucent-light-300": "0 0% 100% / 0.639",
  "--spacer-100": "132 14% 7%",
  "--foreground-100": "0 0% 100%",
  "--foreground-200": "0 0% 61%",
  "--foreground-300": "0 0% 50%",
  "--foreground-400": "0 0% 31%",
  "--primary-100": "44 96% 64%",
  "--primary-200": "44 58% 52%",
  "--primary-foreground-100": "132 14% 7%",
  "--wallet-theme-100": "249 76% 79%",
  "--wallet-theme-200": "233 89% 71%",
  "--wallet-theme-300": "28 79% 57%",
  "--wallet-theme-400": "16 100% 68%",
  "--wallet-theme-500": "227 58% 65%",
  "--wallet-theme-600": "211 97% 61%",
  "--secondary-100": "120 57% 78%",
  "--destructive-100": "0 72% 65%",
  "--constructive-100": "128 67% 66%",
});

function App() {
  return (
    <View style={[{ flex: 1 }, themeVars]}>
      <SessionApp />
    </View>
  );
}

export default App;
