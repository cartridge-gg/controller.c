use account_sdk::controller::Controller;
use libc::{c_char, c_void};
use std::ffi::{CStr, CString};
use std::os::raw::c_int;
use std::ptr;
use std::slice;
use tokio::runtime::Runtime;

/// Opaque type for Controller
pub struct CController {
    inner: Controller,
    runtime: Runtime,
}

/// Result type for FFI functions
#[repr(C)]
pub struct CResult {
    success: bool,
    error_message: *mut c_char,
}

/// Session structure for C
#[repr(C)]
pub struct CSession {
    address: *mut c_char,
    expires_at: u64,
    policies: *mut CPolicy,
    policies_len: usize,
}

/// Policy structure for C
#[repr(C)]
pub struct CPolicy {
    target: *mut c_char,
    method: *mut c_char,
}

/// Creates a new Controller instance
#[no_mangle]
pub extern "C" fn controller_new(
    app_id: *const c_char,
    username: *const c_char,
    class_hash: *const c_char,
    rpc_url: *const c_char,
    owner: *const c_char,
    address: *const c_char,
    private_key: *const c_char,
) -> *mut CController {
    let rpc_url = unsafe {
        if rpc_url.is_null() {
            return ptr::null_mut();
        }
        match CStr::from_ptr(rpc_url).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let address = unsafe {
        if address.is_null() {
            return ptr::null_mut();
        }
        match CStr::from_ptr(address).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let private_key = unsafe {
        if private_key.is_null() {
            return ptr::null_mut();
        }
        match CStr::from_ptr(private_key).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let runtime = match Runtime::new() {
        Ok(rt) => rt,
        Err(_) => return ptr::null_mut(),
    };

    let controller = match runtime.block_on(Controller::new(
        app_id,
        username,
        class_hash,
        rpc_url,
        owner,
        address,
        private_key,
    )) {
        Ok(c) => c,
        Err(_) => return ptr::null_mut(),
    };

    Box::into_raw(Box::new(CController { inner: controller, runtime }))
}

/// Frees a Controller instance
#[no_mangle]
pub extern "C" fn controller_free(controller: *mut CController) {
    if !controller.is_null() {
        unsafe {
            let _ = Box::from_raw(controller);
        }
    }
}

/// Creates a new session
#[no_mangle]
pub extern "C" fn controller_create_session(
    controller: *mut CController,
    policies: *const CPolicy,
    policies_len: usize,
    expires_at: u64,
) -> *mut CSession {
    if controller.is_null() {
        return ptr::null_mut();
    }

    let controller = unsafe { &mut *controller };

    // Convert C policies to Rust policies
    let policies_vec = if policies.is_null() || policies_len == 0 {
        Vec::new()
    } else {
        unsafe {
            slice::from_raw_parts(policies, policies_len)
                .iter()
                .filter_map(|p| {
                    let target = CStr::from_ptr(p.target).to_str().ok()?;
                    let method = CStr::from_ptr(p.method).to_str().ok()?;
                    Some(Policy { target: target.to_string(), method: method.to_string() })
                })
                .collect()
        }
    };

    match controller.runtime.block_on(controller.inner.create_session(policies_vec, expires_at)) {
        Ok(session) => {
            // Convert Rust session to C session
            let c_session = Box::new(CSession {
                address: CString::new(session.address).unwrap().into_raw(),
                expires_at: session.expires_at,
                policies: ptr::null_mut(), // Will be set if needed
                policies_len: 0,
            });
            Box::into_raw(c_session)
        }
        Err(_) => ptr::null_mut(),
    }
}

/// Frees a session
#[no_mangle]
pub extern "C" fn session_free(session: *mut CSession) {
    if !session.is_null() {
        unsafe {
            let session = Box::from_raw(session);
            if !session.address.is_null() {
                let _ = CString::from_raw(session.address);
            }
            // Free policies if allocated
            if !session.policies.is_null() {
                for i in 0..session.policies_len {
                    let policy = session.policies.add(i);
                    if !(*policy).target.is_null() {
                        let _ = CString::from_raw((*policy).target);
                    }
                    if !(*policy).method.is_null() {
                        let _ = CString::from_raw((*policy).method);
                    }
                }
            }
        }
    }
}

/// Gets a session by address
#[no_mangle]
pub extern "C" fn controller_get_session(
    controller: *mut CController,
    address: *const c_char,
) -> *mut CSession {
    if controller.is_null() || address.is_null() {
        return ptr::null_mut();
    }

    let controller = unsafe { &mut *controller };
    let address = unsafe {
        match CStr::from_ptr(address).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    match controller.runtime.block_on(controller.inner.get_session(address)) {
        Ok(Some(session)) => {
            let c_session = Box::new(CSession {
                address: CString::new(session.address).unwrap().into_raw(),
                expires_at: session.expires_at,
                policies: ptr::null_mut(),
                policies_len: 0,
            });
            Box::into_raw(c_session)
        }
        _ => ptr::null_mut(),
    }
}

/// Revokes a session
#[no_mangle]
pub extern "C" fn controller_revoke_session(
    controller: *mut CController,
    address: *const c_char,
) -> CResult {
    if controller.is_null() || address.is_null() {
        return CResult {
            success: false,
            error_message: CString::new("Invalid parameters").unwrap().into_raw(),
        };
    }

    let controller = unsafe { &mut *controller };
    let address = unsafe {
        match CStr::from_ptr(address).to_str() {
            Ok(s) => s,
            Err(_) => {
                return CResult {
                    success: false,
                    error_message: CString::new("Invalid address").unwrap().into_raw(),
                };
            }
        }
    };

    match controller.runtime.block_on(controller.inner.revoke_session(address)) {
        Ok(_) => CResult { success: true, error_message: ptr::null_mut() },
        Err(e) => CResult {
            success: false,
            error_message: CString::new(format!("Error: {}", e)).unwrap().into_raw(),
        },
    }
}

/// Frees a CResult
#[no_mangle]
pub extern "C" fn result_free(result: CResult) {
    if !result.error_message.is_null() {
        unsafe {
            let _ = CString::from_raw(result.error_message);
        }
    }
}

/// Frees a C string
#[no_mangle]
pub extern "C" fn string_free(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}
