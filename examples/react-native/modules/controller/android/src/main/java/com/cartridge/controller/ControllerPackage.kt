package com.cartridge.controller

import android.util.Log
import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class ControllerPackage : TurboReactPackage() {

    companion object {
        private const val TAG = "ControllerPackage"
    }

    init {
        Log.d(TAG, "ControllerPackage instantiated")
    }

    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
        Log.d(TAG, "getModule called for: $name")
        return if (name == ControllerModule.NAME) {
            Log.d(TAG, "Creating ControllerModule")
            ControllerModule(reactContext)
        } else {
            null
        }
    }

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
        Log.d(TAG, "getReactModuleInfoProvider called")
        return ReactModuleInfoProvider {
            Log.d(TAG, "Building module info map")
            mapOf(
                ControllerModule.NAME to ReactModuleInfo(
                    ControllerModule.NAME,           // name
                    ControllerModule::class.java.name, // className
                    false,  // canOverrideExistingModule
                    false,  // needsEagerInit
                    true,   // hasConstants (even if empty, set to true)
                    false,  // isCxxModule
                    true    // isTurboModule
                )
            )
        }
    }
}
