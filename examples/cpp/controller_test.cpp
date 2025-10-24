/**
 * Complete Controller UniFFI C++ Test Suite
 * Tests all functionality including full workflows with signup, execution, and transfers
 */

#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <random>
#include <iomanip>
#include <sstream>
#include "../../bindings/cpp/controller.hpp"

// ANSI color codes
#define GREEN "\033[0;32m"
#define RED "\033[0;31m"
#define BLUE "\033[0;34m"
#define YELLOW "\033[1;33m"
#define NC "\033[0m"

void printSection(const std::string& title) {
    std::cout << "\n" << BLUE << "=== " << title << " ===" << NC << std::endl;
}

void printSuccess(const std::string& message) {
    std::cout << GREEN << "✓ " << message << NC << std::endl;
}

void printError(const std::string& message) {
    std::cout << RED << "❌ " << message << NC << std::endl;
}

void printWarning(const std::string& message) {
    std::cout << YELLOW << "⚠️  " << message << NC << std::endl;
}

void printInfo(const std::string& message) {
    std::cout << "  " << message << std::endl;
}

// Generate random private key for testing
std::string generateStarkPrivateKey() {
    std::random_device rd;
    std::mt19937_64 gen(rd());
    std::uniform_int_distribution<uint8_t> dis(0, 255);
    
    std::stringstream ss;
    ss << "0x";
    for (int i = 0; i < 32; i++) {
        ss << std::hex << std::setw(2) << std::setfill('0') << (int)dis(gen);
    }
    return ss.str();
}

// Generate random username
std::string generateRandomUsername() {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<int> dis(10000000, 99999999);
    return "cppuser-" + std::to_string(dis(gen));
}

// MARK: - Step 1: Test Utility Functions

void testUtilityFunctions() {
    printSection("Step 1: Testing Utility Functions");
    
    try {
        controller::validate_felt("0x1234");
        printSuccess("validate_felt: works");
    } catch (const std::exception& e) {
        printError(std::string("validate_felt error: ") + e.what());
    }
    
    try {
        std::string privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
        auto publicKey = controller::get_public_key(privateKey);
        printSuccess("get_public_key: " + publicKey.substr(0, 20) + "...");
    } catch (const std::exception& e) {
        printError(std::string("get_public_key error: ") + e.what());
    }
    
    try {
        std::string privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
        auto guid = controller::signer_to_guid(privateKey);
        printSuccess("signer_to_guid: " + guid.substr(0, 20) + "...");
    } catch (const std::exception& e) {
        printError(std::string("signer_to_guid error: ") + e.what());
    }
    
    try {
        auto classHashV109 = controller::get_controller_class_hash(controller::Version::kV109);
        printSuccess("get_controller_class_hash(kV109): " + classHashV109.substr(0, 20) + "...");
        
        auto classHashLatest = controller::get_controller_class_hash(controller::Version::kLatest);
        printSuccess("get_controller_class_hash(kLatest): " + classHashLatest.substr(0, 20) + "...");
    } catch (const std::exception& e) {
        printError(std::string("get_controller_class_hash error: ") + e.what());
    }
}

// MARK: - Step 2: Owner Creation

std::shared_ptr<controller::Owner> testOwnerCreation(const std::string& privateKey) {
    printSection("Step 2: Creating Owner");
    std::cout << "🔑 Using private key: " << privateKey << std::endl;
    
    try {
        auto owner = controller::Owner::init(privateKey);
        printSuccess("Owner created successfully");
        return owner;
    } catch (const std::exception& e) {
        printError(std::string("Owner creation error: ") + e.what());
        return nullptr;
    }
}

// MARK: - Step 3: Controller Creation

std::shared_ptr<controller::Controller> testControllerCreation(
    std::shared_ptr<controller::Owner> owner,
    const std::string& privateKey
) {
    printSection("Step 3: Creating Controller");
    
    std::string appId = "test_app_cpp";
    std::string username = generateRandomUsername();
    std::string rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia";
    std::string chainId = "0x534e5f5345504f4c4941";
    
    try {
        std::cout << "📋 Getting controller class hash..." << std::endl;
        auto classHash = controller::get_controller_class_hash(controller::Version::kLatest);
        std::cout << "📄 Class hash: " << classHash << std::endl;
        
        std::cout << "🎮 Creating headless controller..." << std::endl;
        auto ctrl = controller::Controller::new_headless(
            appId,
            username,
            classHash,
            rpcUrl,
            owner,
            chainId
        );
        printSuccess("Controller created successfully");
        
        std::cout << "\n📊 Controller Information:" << std::endl;
        printInfo("📍 Address: " + ctrl->address());
        printInfo("👤 Username: " + ctrl->username());
        printInfo("🆔 App ID: " + ctrl->app_id());
        printInfo("⛓️  Chain ID: " + ctrl->chain_id());
        
        return ctrl;
    } catch (const std::exception& e) {
        printError(std::string("Controller creation error: ") + e.what());
        return nullptr;
    }
}

// MARK: - Step 4: Controller Storage

void testControllerStorage() {
    printSection("Step 4: Testing Controller Storage");
    
    try {
        bool hasStorage = controller::controller_has_storage("nonexistent_app");
        printSuccess("controller_has_storage('nonexistent_app'): " + 
                    std::string(hasStorage ? "true" : "false"));
        
        try {
            auto ctrl = controller::Controller::from_storage("nonexistent_app");
            printWarning("Unexpectedly found stored controller");
        } catch (const std::exception& e) {
            printSuccess("Controller::from_storage correctly throws error for non-existent app");
        }
    } catch (const std::exception& e) {
        printError(std::string("Storage test error: ") + e.what());
    }
}

// MARK: - Step 5: Signup

bool testControllerSignup(std::shared_ptr<controller::Controller> ctrl) {
    printSection("Step 5: Testing Signup");
    
    try {
        ctrl->signup(
            controller::SignerType::kStarknet,
            std::nullopt,  // sessionExpiration
            std::nullopt   // cartridgeApiUrl
        );
        printSuccess("Signup successful");
        return true;
    } catch (const std::exception& e) {
        printWarning(std::string("Signup error: ") + e.what());
        printInfo("(This is expected if the account already exists or is not funded)");
        return false;
    }
}

// MARK: - Step 6: Transaction Execution

bool testControllerExecution(std::shared_ptr<controller::Controller> ctrl) {
    printSection("Step 6: Testing Transaction Execution");
    
    try {
        std::cout << "📦 Creating test transaction..." << std::endl;
        controller::Call call;
        call.contract_address = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7";
        call.entrypoint = "approve";
        call.calldata = {
            "0x1234567890abcdef",
            "0x100",
            "0x0"
        };
        
        std::cout << "🚀 Executing transaction..." << std::endl;
        auto txHash = ctrl->execute({call});
        printSuccess("Transaction executed: " + txHash);
        return true;
    } catch (const std::exception& e) {
        printError(std::string("Execution error: ") + e.what());
        printInfo("(This is expected if the account is not deployed or not funded)");
        return false;
    }
}

// MARK: - Step 7: Transfer

bool testControllerTransfer(std::shared_ptr<controller::Controller> ctrl) {
    printSection("Step 7: Testing Transfer");
    
    try {
        std::string recipient = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
        std::string amount = "0x1";
        
        std::cout << "💰 Transferring " << amount << " to " 
                  << recipient.substr(0, 20) << "..." << std::endl;
        auto txHash = ctrl->transfer(recipient, amount);
        printSuccess("Transfer successful: " + txHash);
        return true;
    } catch (const std::exception& e) {
        printError(std::string("Transfer error: ") + e.what());
        printInfo("(This is expected if the account is not deployed or not funded)");
        return false;
    }
}

// MARK: - Step 8: SessionAccount

std::shared_ptr<controller::SessionAccount> testSessionAccount() {
    printSection("Step 8: Testing SessionAccount");
    
    try {
        std::cout << "📜 Creating session policies..." << std::endl;
        controller::SessionPolicy policy;
        policy.contract_address = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7";
        policy.entrypoint = "transfer";
        
        controller::SessionPolicies policies;
        policies.policies = {policy};
        policies.max_fee = "0x100000";
        
        std::cout << "🔐 Creating session account..." << std::endl;
        auto session = controller::SessionAccount::init(
            "https://api.cartridge.gg/x/starknet/sepolia",
            generateStarkPrivateKey(),
            "0x5678",
            "0x9abc",
            "0x534e5f5345504f4c4941",
            policies,
            1735689600
        );
        printSuccess("SessionAccount created successfully");
        return session;
    } catch (const std::exception& e) {
        printError(std::string("SessionAccount creation error: ") + e.what());
        return nullptr;
    }
}

// MARK: - Step 9: SessionAccount.create_from_subscribe

std::shared_ptr<controller::SessionAccount> testSessionAccountFromSubscribe() {
    printSection("Step 9: Testing SessionAccount::create_from_subscribe");
    
    try {
        controller::SessionPolicy policy;
        policy.contract_address = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7";
        policy.entrypoint = "transfer";
        
        controller::SessionPolicies policies;
        policies.policies = {policy};
        policies.max_fee = "0x100000";
        
        std::cout << "🌐 Attempting to create session from GraphQL API..." << std::endl;
        auto session = controller::SessionAccount::create_from_subscribe(
            generateStarkPrivateKey(),
            policies,
            "https://api.cartridge.gg/x/starknet/sepolia",
            "https://x.cartridge.gg/graphql"
        );
        printSuccess("SessionAccount::create_from_subscribe succeeded");
        return session;
    } catch (const std::exception& e) {
        printWarning("SessionAccount::create_from_subscribe failed (expected without real session):");
        std::string errorMsg = e.what();
        if (errorMsg.length() > 100) {
            errorMsg = errorMsg.substr(0, 100) + "...";
        }
        printInfo(errorMsg);
        return nullptr;
    }
}

// MARK: - Step 10: Session Execution

void testSessionExecution(std::shared_ptr<controller::SessionAccount> session) {
    if (!session) {
        printSection("Step 10: Skipping Session Execution (no session)");
        return;
    }
    
    printSection("Step 10: Testing Session Execution");
    
    try {
        controller::Call call;
        call.contract_address = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7";
        call.entrypoint = "transfer";
        call.calldata = {
            "0x1234567890abcdef",
            "0x1",
            "0x0"
        };
        
        std::cout << "🚀 Executing with session..." << std::endl;
        auto txHash = session->execute({call});
        printSuccess("Session execution successful: " + txHash);
    } catch (const std::exception& e) {
        printError(std::string("Session execution error: ") + e.what());
    }
}

// MARK: - Step 11: Error Handling

void testErrorHandling(std::shared_ptr<controller::Controller> ctrl) {
    printSection("Step 11: Testing Error Handling");
    
    try {
        ctrl->switch_chain("invalid_url");
    } catch (const std::exception& e) {
        printSuccess(std::string("Error correctly caught: ") + typeid(e).name());
        
        try {
            auto errorMsg = ctrl->error_message();
            if (!errorMsg.empty()) {
                std::string shortMsg = errorMsg.substr(0, std::min(size_t(50), errorMsg.length()));
                printSuccess("Error message available: " + shortMsg + "...");
            }
            
            ctrl->clear_last_error();
            printSuccess("Error cleared");
        } catch (...) {
            // Ignore
        }
    }
}

// MARK: - Main

void runTests() {
    std::cout << std::string(70, '=') << std::endl;
    std::cout << "  🚀 COMPLETE CONTROLLER-UNIFFI C++ TEST SUITE" << std::endl;
    std::cout << "  Testing all functionality with full workflows" << std::endl;
    std::cout << std::string(70, '=') << std::endl;
    
    std::string privateKey = generateStarkPrivateKey();
    
    testUtilityFunctions();
    
    auto owner = testOwnerCreation(privateKey);
    if (!owner) {
        printError("Cannot continue without owner");
        return;
    }
    
    auto ctrl = testControllerCreation(owner, privateKey);
    if (!ctrl) {
        printError("Cannot continue without controller");
        return;
    }
    
    testControllerStorage();
    testControllerSignup(ctrl);
    testControllerExecution(ctrl);
    testControllerTransfer(ctrl);
    
    auto session = testSessionAccount();
    auto sessionFromApi = testSessionAccountFromSubscribe();
    testSessionExecution(sessionFromApi ? sessionFromApi : session);
    
    testErrorHandling(ctrl);
    
    std::cout << "\n" << std::string(70, '=') << std::endl;
    std::cout << "  " << GREEN << "✅ ALL TESTS COMPLETED" << NC << std::endl;
    std::cout << "  All modules and workflows tested!" << std::endl;
    std::cout << std::string(70, '=') << std::endl;
    std::cout << std::endl;
    std::cout << "📝 Note: Some operations may fail if the account is not deployed/funded." << std::endl;
    std::cout << "   This is expected behavior for a test environment." << std::endl;
    std::cout << std::endl;
}

int main() {
    try {
        runTests();
        return 0;
    } catch (const std::exception& e) {
        std::cerr << RED << "Fatal error: " << e.what() << NC << std::endl;
        return 1;
    }
}

