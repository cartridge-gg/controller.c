const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');
const fs = require('fs');

const projectRoot = __dirname;
const controllerRoot = path.resolve(projectRoot, '../..');

const config = getDefaultConfig(projectRoot);

// Watch the controller.c bindings
config.watchFolders = [controllerRoot];

// Try to resolve uniffi-bindgen-react-native path (pnpm uses symlinks)
let uniffiPath = null;
try {
  const uniffiNodePath = path.resolve(__dirname, 'node_modules/uniffi-bindgen-react-native');
  if (fs.existsSync(uniffiNodePath)) {
    // Follow pnpm symlinks to the actual package
    uniffiPath = fs.realpathSync(uniffiNodePath);
  }
} catch (e) {
  console.warn('uniffi-bindgen-react-native not found, may cause runtime issues');
}

// Configure resolver to find the bindings
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, 'node_modules'),
  path.resolve(controllerRoot, 'node_modules'),
];

// Add uniffi to extraNodeModules if it exists
if (uniffiPath) {
  config.resolver.extraNodeModules = config.resolver.extraNodeModules || {};
  config.resolver.extraNodeModules['uniffi-bindgen-react-native'] = uniffiPath;
}

// Ensure TypeScript files are resolved
config.resolver.sourceExts = [...(config.resolver.sourceExts || []), 'ts', 'tsx'];

module.exports = config;

