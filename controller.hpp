#ifndef CONTROLLER_CPP_H
#define CONTROLLER_CPP_H

#include <memory>
#include <string>
#include <vector>
#include <stdexcept>
#include <cstdint>
#include "controller.h"

namespace controller {

// Forward declarations
class Session;
class Policy;

/**
 * RAII wrapper for C strings returned by the C API
 */
class CStringPtr {
private:
    char* ptr;
public:
    explicit CStringPtr(char* p) : ptr(p) {}
    ~CStringPtr() { if (ptr) string_free(ptr); }
    CStringPtr(const CStringPtr&) = delete;
    CStringPtr& operator=(const CStringPtr&) = delete;
    CStringPtr(CStringPtr&& other) noexcept : ptr(other.ptr) { other.ptr = nullptr; }
    const char* get() const { return ptr; }
};

/**
 * Policy class representing access control policies
 */
class Policy {
public:
    std::string target;
    std::string method;

    Policy(const std::string& target, const std::string& method)
        : target(target), method(method) {}

    Policy(const CPolicy& c_policy)
        : target(c_policy.target ? c_policy.target : ""),
          method(c_policy.method ? c_policy.method : "") {}

    CPolicy to_c() const {
        return CPolicy{
            const_cast<char*>(target.c_str()),
            const_cast<char*>(method.c_str())
        };
    }
};

/**
 * Session class representing an active controller session
 */
class Session {
public:
    std::string address;
    uint64_t expires_at;
    std::vector<Policy> policies;

    Session(CSession* c_session) {
        if (!c_session) {
            throw std::runtime_error("Null session pointer");
        }
        
        address = c_session->address ? c_session->address : "";
        expires_at = c_session->expires_at;
        
        if (c_session->policies && c_session->policies_len > 0) {
            for (size_t i = 0; i < c_session->policies_len; ++i) {
                policies.emplace_back(c_session->policies[i]);
            }
        }
        
        session_free(c_session);
    }

    bool is_expired() const {
        // Implement expiration check based on current time
        return false; // Placeholder
    }
};

/**
 * Result class for operations that may fail
 */
class Result {
public:
    bool success;
    std::string error_message;

    Result(const CResult& c_result) 
        : success(c_result.success),
          error_message(c_result.error_message ? c_result.error_message : "") {
        result_free(const_cast<CResult&>(c_result));
    }

    void throw_if_error() const {
        if (!success) {
            throw std::runtime_error(error_message);
        }
    }
};

/**
 * Controller class - main interface for controller operations
 */
class Controller {
private:
    struct Deleter {
        void operator()(CController* p) const {
            if (p) controller_free(p);
        }
    };
    
    std::unique_ptr<CController, Deleter> controller;

public:
    /**
     * Creates a new Controller instance
     * 
     * @param rpc_url The RPC URL to connect to
     * @param address The controller address
     * @param private_key The private key for the controller
     * @throws std::runtime_error if creation fails
     */
    Controller(const std::string& rpc_url,
               const std::string& address,
               const std::string& private_key) {
        auto* c = controller_new(rpc_url.c_str(), address.c_str(), private_key.c_str());
        if (!c) {
            throw std::runtime_error("Failed to create controller");
        }
        controller.reset(c);
    }

    // Disable copy
    Controller(const Controller&) = delete;
    Controller& operator=(const Controller&) = delete;

    // Enable move
    Controller(Controller&&) = default;
    Controller& operator=(Controller&&) = default;

    /**
     * Creates a new session with the specified policies
     * 
     * @param policies Vector of policies for the session
     * @param expires_at Expiration timestamp
     * @return The created session
     * @throws std::runtime_error if creation fails
     */
    Session create_session(const std::vector<Policy>& policies, uint64_t expires_at) {
        std::vector<CPolicy> c_policies;
        c_policies.reserve(policies.size());
        for (const auto& policy : policies) {
            c_policies.push_back(policy.to_c());
        }

        auto* session = controller_create_session(
            controller.get(),
            c_policies.data(),
            c_policies.size(),
            expires_at
        );

        if (!session) {
            throw std::runtime_error("Failed to create session");
        }

        return Session(session);
    }

    /**
     * Gets a session by address
     * 
     * @param address The session address
     * @return Optional session if found
     */
    std::unique_ptr<Session> get_session(const std::string& address) {
        auto* session = controller_get_session(controller.get(), address.c_str());
        if (!session) {
            return nullptr;
        }
        return std::make_unique<Session>(session);
    }

    /**
     * Revokes a session
     * 
     * @param address The session address to revoke
     * @throws std::runtime_error if revocation fails
     */
    void revoke_session(const std::string& address) {
        Result result(controller_revoke_session(controller.get(), address.c_str()));
        result.throw_if_error();
    }

    /**
     * Checks if the controller is valid
     * 
     * @return true if the controller is valid
     */
    bool is_valid() const {
        return controller != nullptr;
    }
};

} // namespace controller

#endif // CONTROLLER_CPP_H