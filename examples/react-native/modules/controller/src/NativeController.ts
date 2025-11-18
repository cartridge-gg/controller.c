import { NativeModules } from 'react-native';

const LINKING_ERROR =
  `The package 'controller-native' doesn't seem to be linked. Make sure: \n\n` +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n' +
  '- You ran pod install in the ios directory\n';

const Controller = NativeModules.Controller
  ? NativeModules.Controller
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export default Controller;

