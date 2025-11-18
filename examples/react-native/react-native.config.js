const path = require('path');

module.exports = {
  dependencies: {
    'controller-native': {
      root: path.resolve(__dirname, 'modules/controller'),
      platforms: {
        ios: {
          podspecPath: path.resolve(__dirname, 'modules/controller/Controller.podspec'),
        },
      },
    },
  },
};
