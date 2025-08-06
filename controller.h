#ifndef CONTROLLER_C_H
#define CONTROLLER_C_H

#pragma once

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

// Opaque type for Controller
typedef struct CController CController;

// Policy structure for C
typedef struct CPolicy {
  char *target;
  char *method;
} CPolicy;

// Session structure for C
typedef struct CSession {
  char *address;
  uint64_t expires_at;
  struct CPolicy *policies;
  uintptr_t policies_len;
} CSession;

// Result type for FFI functions
typedef struct CResult {
  bool success;
  char *error_message;
} CResult;

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

// Creates a new Controller instance
struct CController *controller_new(const char *app_id,
                                   const char *username,
                                   const char *class_hash,
                                   const char *rpc_url,
                                   const char *owner,
                                   const char *address,
                                   const char *private_key);

// Frees a Controller instance
void controller_free(struct CController *controller);

// Creates a new session
struct CSession *controller_create_session(struct CController *controller,
                                           const struct CPolicy *policies,
                                           uintptr_t policies_len,
                                           uint64_t expires_at);

// Frees a session
void session_free(struct CSession *session);

// Gets a session by address
struct CSession *controller_get_session(struct CController *controller, const char *address);

// Revokes a session
struct CResult controller_revoke_session(struct CController *controller, const char *address);

// Frees a CResult
void result_free(struct CResult result);

// Frees a C string
void string_free(char *s);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  /* CONTROLLER_C_H */
