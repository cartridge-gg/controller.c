/**
 * @flow strict
 * @format
 */

import type {TurboModule} from 'react-native/Libraries/TurboModule/RCTExport';
import {TurboModuleRegistry} from 'react-native';

export interface Spec extends TurboModule {
  +installRustCrate: () => boolean;
  +cleanupRustCrate: () => boolean;
}

export default (TurboModuleRegistry.get<Spec>('Controller'): ?Spec);

