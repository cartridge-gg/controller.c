// Generated cpp-adapter for uniffi-bindgen-react-native Android support
#include <jni.h>
#include <jsi/jsi.h>
#include <ReactCommon/CallInvokerHolder.h>
#include <fbjni/fbjni.h>
#include "controller.h"

using namespace facebook;

extern "C" JNIEXPORT void JNICALL
Java_com_cartridge_controller_ControllerModule_nativeInstall(
    JNIEnv *env,
    jobject thiz,
    jlong jsiPtr,
    jobject callInvokerHolder
) {
    auto runtime = reinterpret_cast<jsi::Runtime *>(jsiPtr);
    if (runtime == nullptr) {
        return;
    }

    // Get the CallInvoker from the holder
    auto callInvokerHolderClass = env->GetObjectClass(callInvokerHolder);
    auto getCallInvokerMethod = env->GetMethodID(callInvokerHolderClass, "getCallInvoker", "()Lcom/facebook/react/turbomodule/core/CallInvokerHolderImpl;");
    
    // Use fbjni to get the CallInvoker
    auto jCallInvokerHolder = jni::adopt_local(env->NewLocalRef(callInvokerHolder));
    auto callInvoker = std::dynamic_pointer_cast<react::CallInvoker>(
        jni::static_ref_cast<react::CallInvokerHolder::javaobject>(jCallInvokerHolder)->cthis()->getCallInvoker()
    );

    if (callInvoker) {
        controller::installRustCrate(*runtime, callInvoker);
    }
}
