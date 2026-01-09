package com.cartridge.controller

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.turbomodule.core.CallInvokerHolderImpl
import com.facebook.react.turbomodule.core.interfaces.TurboModule

@ReactModule(name = ControllerModule.NAME)
class ControllerModule(reactContext: ReactApplicationContext) : NativeControllerSpec(reactContext), TurboModule {

    companion object {
        const val NAME = "Controller"

        init {
            System.loadLibrary("controller")
        }
    }

    override fun getName(): String = NAME

    override fun initialize() {
        super.initialize()
        val jsContext = reactApplicationContext.javaScriptContextHolder?.get() ?: 0L
        val callInvoker = reactApplicationContext.catalystInstance?.jsCallInvokerHolder as? CallInvokerHolderImpl
        if (jsContext != 0L && callInvoker != null) {
            nativeInstall(jsContext, callInvoker)
        }
    }

    override fun installRustCrate(): Boolean {
        // This is handled by nativeInstall during initialization
        return true
    }

    override fun cleanupRustCrate(): Boolean {
        // Cleanup is handled automatically
        return true
    }

    private external fun nativeInstall(jsiPtr: Long, callInvoker: CallInvokerHolderImpl)
}
