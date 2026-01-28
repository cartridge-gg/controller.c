import React from 'react';
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
  Linking,
} from 'react-native';
import { useSessionManager } from '../hooks/useSessionManager';

export default function App() {
  const {
    publicKey,
    sessionAccount,
    sessionMetadata,
    connectedUsername,
    showAccountConnectedCard,
    setShowAccountConnectedCard,
    openSessionInWebView,
    executeTransaction,
    lastTransactionHash,
    currentTransaction,
    showTransactionCard,
    dismissTransactionCard,
    isLoading,
    errorMessage,
    reset,
  } = useSessionManager();

  const handleExecuteTransfer = async () => {
    const ethContract = '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7';
    const recipient = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
    const amount = '0x1'; // 1 wei
    
    await executeTransaction(ethContract, 'transfer', [recipient, amount, '0x0']);
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>🔐 Session Account</Text>
        <Text style={styles.subtitle}>
          Create and use a session account with Controller
        </Text>

        {/* Error Banner */}
        {errorMessage && (
          <View style={styles.errorBanner}>
            <Text style={styles.errorText}>{errorMessage}</Text>
          </View>
        )}

        {/* Public Key Display */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Your Public Key</Text>
          {publicKey ? (
            <View style={styles.infoBox}>
              <Text style={styles.infoValue} numberOfLines={2}>
                {publicKey}
              </Text>
            </View>
          ) : (
            <ActivityIndicator style={{ marginTop: 10 }} />
          )}
        </View>

        {/* Session Creation */}
        {!sessionAccount && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>1. Create Session</Text>
            <Text style={styles.infoText}>
              This will open a browser to authorize the session with policies for ETH token transfer and approve.
            </Text>
            <TouchableOpacity
              style={[styles.button, isLoading && styles.buttonDisabled]}
              onPress={openSessionInWebView}
              disabled={isLoading || !publicKey}
            >
              {isLoading ? (
                <ActivityIndicator color="white" />
              ) : (
                <Text style={styles.buttonText}>Open Session Browser</Text>
              )}
            </TouchableOpacity>
          </View>
        )}

        {/* Account Connected Card */}
        {showAccountConnectedCard && (
          <View style={styles.successCard}>
            <Text style={styles.successTitle}>✅ Account Connected!</Text>
            <Text style={styles.successText}>
              Username: {connectedUsername}
            </Text>
            {sessionMetadata.address && (
              <Text style={styles.successText} numberOfLines={1}>
                Address: {sessionMetadata.address.substring(0, 20)}...
              </Text>
            )}
            <TouchableOpacity
              style={styles.dismissButton}
              onPress={() => setShowAccountConnectedCard(false)}
            >
              <Text style={styles.dismissButtonText}>Continue</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Session Info */}
        {sessionAccount && !showAccountConnectedCard && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>✓ Session Active</Text>
            <View style={styles.infoBox}>
              <Text style={styles.infoLabel}>Username:</Text>
              <Text style={styles.infoValue}>{connectedUsername}</Text>
              {sessionMetadata.address && (
                <>
                  <Text style={styles.infoLabel}>Address:</Text>
                  <Text style={styles.infoValue} numberOfLines={1}>
                    {sessionMetadata.address}
                  </Text>
                </>
              )}
              {sessionMetadata.expiresAt && (
                <>
                  <Text style={styles.infoLabel}>Expires:</Text>
                  <Text style={styles.infoValue}>
                    {new Date(sessionMetadata.expiresAt * 1000).toLocaleString()}
                  </Text>
                </>
              )}
            </View>
          </View>
        )}

        {/* Transaction Execution */}
        {sessionAccount && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>2. Execute Transaction</Text>
            <Text style={styles.infoText}>
              Test the session by executing a transfer of 1 wei ETH
            </Text>
            <TouchableOpacity
              style={[styles.button, isLoading && styles.buttonDisabled]}
              onPress={handleExecuteTransfer}
              disabled={isLoading}
            >
              {isLoading ? (
                <ActivityIndicator color="white" />
              ) : (
                <Text style={styles.buttonText}>Execute Test Transfer</Text>
              )}
            </TouchableOpacity>
          </View>
        )}

        {/* Transaction Card */}
        {showTransactionCard && currentTransaction && (
          <View style={styles.successCard}>
            <Text style={styles.successTitle}>
              {currentTransaction.isConfirmed ? '✅ Transaction Confirmed!' : '⏳ Transaction Submitted'}
            </Text>
            <Text style={styles.infoLabel}>Transaction Hash:</Text>
            <Text style={styles.successText} numberOfLines={1}>
              {currentTransaction.hash.substring(0, 30)}...
            </Text>
            <TouchableOpacity
              style={styles.linkButton}
              onPress={() =>
                Linking.openURL(`https://sepolia.voyager.online/tx/${currentTransaction.hash}`)
              }
            >
              <Text style={styles.linkButtonText}>View on Voyager</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.dismissButton}
              onPress={dismissTransactionCard}
            >
              <Text style={styles.dismissButtonText}>Dismiss</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Reset Button */}
        {sessionAccount && (
          <TouchableOpacity style={styles.resetButton} onPress={reset}>
            <Text style={styles.resetButtonText}>Reset Session</Text>
          </TouchableOpacity>
        )}

        {/* Info Section */}
        <View style={styles.infoSection}>
          <Text style={styles.infoTitle}>📝 How It Works</Text>
          <Text style={styles.infoText}>
            1. Create Session: Opens a browser to authorize{'\n'}
            2. The hook waits for authorization{'\n'}
            3. Session is automatically created{'\n'}
            4. Execute transactions without signing each time
          </Text>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    padding: 20,
    paddingTop: 60,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 20,
  },
  errorBanner: {
    backgroundColor: '#FFEBEE',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
    borderLeftWidth: 4,
    borderLeftColor: '#F44336',
  },
  errorText: {
    color: '#C62828',
    fontSize: 14,
  },
  section: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
    color: '#333',
  },
  button: {
    backgroundColor: '#007AFF',
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
    marginTop: 8,
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  linkButton: {
    backgroundColor: '#34C759',
    borderRadius: 8,
    padding: 12,
    alignItems: 'center',
    marginTop: 12,
  },
  linkButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  resetButton: {
    backgroundColor: '#FF3B30',
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
    marginTop: 8,
    marginBottom: 16,
  },
  resetButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  infoBox: {
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    padding: 12,
    marginTop: 8,
  },
  infoLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#666',
    marginTop: 8,
    marginBottom: 4,
  },
  infoValue: {
    fontSize: 12,
    color: '#333',
    fontFamily: 'monospace',
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginBottom: 8,
  },
  successCard: {
    backgroundColor: '#E8F5E9',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    borderWidth: 2,
    borderColor: '#4CAF50',
  },
  successTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2E7D32',
    marginBottom: 12,
  },
  successText: {
    fontSize: 14,
    color: '#2E7D32',
    marginBottom: 4,
    fontFamily: 'monospace',
  },
  dismissButton: {
    backgroundColor: '#4CAF50',
    borderRadius: 8,
    padding: 12,
    alignItems: 'center',
    marginTop: 12,
  },
  dismissButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  infoSection: {
    backgroundColor: '#E3F2FD',
    borderRadius: 12,
    padding: 16,
    marginTop: 8,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1565C0',
    marginBottom: 8,
  },
});
