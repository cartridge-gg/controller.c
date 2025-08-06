#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "../controller.h"

void print_session_info(const CSession* session) {
    if (!session) {
        printf("Session: NULL\n");
        return;
    }
    
    printf("Session Info:\n");
    printf("  Address: %s\n", session->address ? session->address : "NULL");
    printf("  Expires at: %llu\n", (unsigned long long)session->expires_at);
    printf("  Policies count: %zu\n", session->policies_len);
    
    for (size_t i = 0; i < session->policies_len; i++) {
        printf("    Policy %zu:\n", i + 1);
        printf("      Target: %s\n", session->policies[i].target);
        printf("      Method: %s\n", session->policies[i].method);
    }
}

int main() {
    printf("Controller C Bindings Example\n");
    printf("============================\n\n");

    // Initialize controller
    const char* rpc_url = "http://localhost:5050";
    const char* address = "0x1234567890123456789012345678901234567890";
    const char* private_key = "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890";

    printf("Creating controller...\n");
    CController* controller = controller_new(rpc_url, address, private_key);
    if (!controller) {
        fprintf(stderr, "Failed to create controller\n");
        return 1;
    }
    printf("Controller created successfully!\n\n");

    // Create policies for a new session
    CPolicy policies[] = {
        { .target = "0x1111111111111111111111111111111111111111", .method = "transfer" },
        { .target = "0x2222222222222222222222222222222222222222", .method = "approve" },
        { .target = "0x3333333333333333333333333333333333333333", .method = "mint" }
    };
    size_t policies_count = sizeof(policies) / sizeof(policies[0]);

    // Set expiration to 24 hours from now
    uint64_t expires_at = (uint64_t)time(NULL) + 86400;

    printf("Creating session with %zu policies...\n", policies_count);
    CSession* session = controller_create_session(controller, policies, policies_count, expires_at);
    if (!session) {
        fprintf(stderr, "Failed to create session\n");
        controller_free(controller);
        return 1;
    }
    printf("Session created successfully!\n");
    print_session_info(session);
    printf("\n");

    // Store session address for later use
    char* session_address = NULL;
    if (session->address) {
        session_address = strdup(session->address);
    }

    // Free the created session
    session_free(session);

    // Get session by address
    if (session_address) {
        printf("Retrieving session by address: %s\n", session_address);
        CSession* retrieved_session = controller_get_session(controller, session_address);
        if (retrieved_session) {
            printf("Session retrieved successfully!\n");
            print_session_info(retrieved_session);
            session_free(retrieved_session);
        } else {
            printf("Session not found\n");
        }
        printf("\n");

        // Revoke session
        printf("Revoking session...\n");
        CResult revoke_result = controller_revoke_session(controller, session_address);
        if (revoke_result.success) {
            printf("Session revoked successfully!\n");
        } else {
            fprintf(stderr, "Failed to revoke session: %s\n", 
                    revoke_result.error_message ? revoke_result.error_message : "Unknown error");
        }
        result_free(revoke_result);

        // Try to get the revoked session
        printf("\nTrying to retrieve revoked session...\n");
        CSession* revoked_session = controller_get_session(controller, session_address);
        if (revoked_session) {
            printf("Warning: Revoked session still exists!\n");
            session_free(revoked_session);
        } else {
            printf("Revoked session not found (as expected)\n");
        }

        free(session_address);
    }

    // Clean up
    printf("\nCleaning up...\n");
    controller_free(controller);
    printf("Done!\n");

    return 0;
}