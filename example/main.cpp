#include <iostream>
#include <vector>
#include <memory>
#include <chrono>
#include <thread>
#include "../controller.hpp"

using namespace controller;
using namespace std;

void print_session_info(const Session& session) {
    cout << "Session Info:" << endl;
    cout << "  Address: " << session.address << endl;
    cout << "  Expires at: " << session.expires_at << endl;
    cout << "  Policies count: " << session.policies.size() << endl;
    
    for (size_t i = 0; i < session.policies.size(); i++) {
        cout << "    Policy " << (i + 1) << ":" << endl;
        cout << "      Target: " << session.policies[i].target << endl;
        cout << "      Method: " << session.policies[i].method << endl;
    }
}

int main() {
    cout << "Controller C++ Bindings Example" << endl;
    cout << "===============================" << endl << endl;

    try {
        // Initialize controller
        const string rpc_url = "http://localhost:5050";
        const string address = "0x1234567890123456789012345678901234567890";
        const string private_key = "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890";

        cout << "Creating controller..." << endl;
        Controller controller(rpc_url, address, private_key);
        cout << "Controller created successfully!" << endl << endl;

        // Create policies for a new session
        vector<Policy> policies = {
            Policy("0x1111111111111111111111111111111111111111", "transfer"),
            Policy("0x2222222222222222222222222222222222222222", "approve"),
            Policy("0x3333333333333333333333333333333333333333", "mint")
        };

        // Set expiration to 24 hours from now
        auto now = chrono::system_clock::now();
        auto expires_at = chrono::duration_cast<chrono::seconds>(
            now.time_since_epoch()
        ).count() + 86400;

        cout << "Creating session with " << policies.size() << " policies..." << endl;
        Session session = controller.create_session(policies, expires_at);
        cout << "Session created successfully!" << endl;
        print_session_info(session);
        cout << endl;

        // Store session address
        string session_address = session.address;

        // Get session by address
        cout << "Retrieving session by address: " << session_address << endl;
        auto retrieved_session = controller.get_session(session_address);
        if (retrieved_session) {
            cout << "Session retrieved successfully!" << endl;
            print_session_info(*retrieved_session);
        } else {
            cout << "Session not found" << endl;
        }
        cout << endl;

        // Check if session is expired
        if (retrieved_session && retrieved_session->is_expired()) {
            cout << "Warning: Session is expired!" << endl;
        }

        // Revoke session
        cout << "Revoking session..." << endl;
        try {
            controller.revoke_session(session_address);
            cout << "Session revoked successfully!" << endl;
        } catch (const runtime_error& e) {
            cerr << "Failed to revoke session: " << e.what() << endl;
        }

        // Try to get the revoked session
        cout << "\nTrying to retrieve revoked session..." << endl;
        auto revoked_session = controller.get_session(session_address);
        if (revoked_session) {
            cout << "Warning: Revoked session still exists!" << endl;
        } else {
            cout << "Revoked session not found (as expected)" << endl;
        }

        // Demonstrate error handling
        cout << "\nDemonstrating error handling..." << endl;
        try {
            cout << "Trying to create controller with invalid parameters..." << endl;
            Controller bad_controller("", "", "");
        } catch (const runtime_error& e) {
            cout << "Caught expected error: " << e.what() << endl;
        }

        // Create multiple sessions
        cout << "\nCreating multiple sessions..." << endl;
        vector<string> session_addresses;
        for (int i = 0; i < 3; i++) {
            vector<Policy> batch_policies = {
                Policy("0x" + to_string(i) + "111111111111111111111111111111111111111", "execute"),
                Policy("0x" + to_string(i) + "222222222222222222222222222222222222222", "delegate")
            };
            
            Session batch_session = controller.create_session(batch_policies, expires_at + i * 3600);
            cout << "  Created session " << (i + 1) << ": " << batch_session.address << endl;
            session_addresses.push_back(batch_session.address);
        }

        // Clean up multiple sessions
        cout << "\nCleaning up sessions..." << endl;
        for (const auto& addr : session_addresses) {
            try {
                controller.revoke_session(addr);
                cout << "  Revoked session: " << addr << endl;
            } catch (const runtime_error& e) {
                cerr << "  Failed to revoke session " << addr << ": " << e.what() << endl;
            }
        }

    } catch (const exception& e) {
        cerr << "Fatal error: " << e.what() << endl;
        return 1;
    }

    cout << "\nDone!" << endl;
    return 0;
}