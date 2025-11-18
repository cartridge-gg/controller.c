const path = require('path');

module.exports = {
  dependencies: {
    'arcade-native-controller': {
      root: path.resolve(__dirname, 'modules/arcade'),
      platforms: {
        ios: {
          podspecPath: path.resolve(__dirname, 'modules/arcade/Controller.podspec'),
        },
      },
    },
    'arcade-native-dojo': {
      root: path.resolve(__dirname, 'modules/arcade'),
      platforms: {
        ios: {
          podspecPath: path.resolve(__dirname, 'modules/arcade/Dojo.podspec'),
        },
      },
    },
  },
};

