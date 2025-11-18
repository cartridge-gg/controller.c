import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  ScrollView,
  Alert,
} from 'react';
import 'react-native-get-random-values';
import { validateFelt, getPublicKey } from '../modules/controller/src';

export default function App() {
  const [status, setStatus] = useState<string>('Ready');
  const [privateKey, setPrivateKey] = useState<string>('');
  const [publicKey, setPublicKey] = useState<string>('');
  const [feltInput, setFeltInput] = useState<string>('0x123');
  const [isValidFelt, setIsValidFelt] = useState<boolean | null>(null);

  useEffect(() => {
    console.log('✅ Controller React Native Example loaded!');
    setStatus('Controller module loaded');
  }, []);

  const generateKey = () => {
    try {
      setStatus('Generating key...');
      const bytes = new Uint8Array(32);
      crypto.getRandomValues(bytes);
      const key = '0x' + Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
      setPrivateKey(key);
      
      // Get public key using the controller
      const pubKey = getPublicKey(key);
      setPublicKey(pubKey);
      
      setStatus('Key pair generated successfully!');
      Alert.alert('Success', 'Key pair generated!');
    } catch (error: any) {
      console.error('Error generating key:', error);
      setStatus(`Error: ${error.message}`);
      Alert.alert('Error', error.message);
    }
  };

  const validateFeltValue = () => {
    try {
      setStatus('Validating felt...');
      const isValid = validateFelt(feltInput);
      setIsValidFelt(isValid);
      setStatus(isValid ? 'Valid felt!' : 'Invalid felt!');
      Alert.alert('Validation Result', isValid ? 'Valid felt ✅' : 'Invalid felt ❌');
    } catch (error: any) {
      console.error('Error validating felt:', error);
      setStatus(`Error: ${error.message}`);
      Alert.alert('Error', error.message);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Controller.c React Native Example</Text>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Status</Text>
          <Text style={styles.status}>{status}</Text>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>1. Generate Key Pair</Text>
          <Text style={styles.description}>
            Generate a random private key and derive its public key using the controller.
          </Text>
          <TouchableOpacity style={styles.button} onPress={generateKey}>
            <Text style={styles.buttonText}>Generate Keys</Text>
          </TouchableOpacity>
          {privateKey && (
            <>
              <View style={styles.infoBox}>
                <Text style={styles.infoLabel}>Private Key:</Text>
                <Text style={styles.infoValue} numberOfLines={2}>
                  {privateKey}
                </Text>
              </View>
              <View style={styles.infoBox}>
                <Text style={styles.infoLabel}>Public Key:</Text>
                <Text style={styles.infoValue} numberOfLines={2}>
                  {publicKey}
                </Text>
              </View>
            </>
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>2. Validate Felt</Text>
          <Text style={styles.description}>
            Check if a string is a valid Starknet field element.
          </Text>
          <TextInput
            style={styles.input}
            value={feltInput}
            onChangeText={setFeltInput}
            placeholder="Enter felt value (e.g., 0x123)"
            autoCapitalize="none"
            autoCorrect={false}
          />
          <TouchableOpacity style={styles.button} onPress={validateFeltValue}>
            <Text style={styles.buttonText}>Validate Felt</Text>
          </TouchableOpacity>
          {isValidFelt !== null && (
            <View style={[styles.badge, isValidFelt ? styles.badgeSuccess : styles.badgeError]}>
              <Text style={styles.badgeText}>
                {isValidFelt ? '✅ Valid' : '❌ Invalid'}
              </Text>
            </View>
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>About</Text>
          <Text style={styles.description}>
            This example demonstrates the basic functionality of controller.c React Native bindings.
            The native Rust code is called via JSI (JavaScript Interface) for high performance.
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
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#333',
  },
  section: {
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 10,
    color: '#333',
  },
  description: {
    fontSize: 14,
    color: '#666',
    marginBottom: 10,
    lineHeight: 20,
  },
  status: {
    fontSize: 14,
    color: '#666',
    fontStyle: 'italic',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 10,
    fontSize: 14,
    backgroundColor: '#f9f9f9',
  },
  button: {
    backgroundColor: '#007AFF',
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
    marginTop: 5,
    marginBottom: 5,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  infoBox: {
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    padding: 10,
    marginTop: 10,
  },
  infoLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#666',
    marginBottom: 5,
  },
  infoValue: {
    fontSize: 11,
    color: '#333',
    fontFamily: 'monospace',
  },
  badge: {
    borderRadius: 8,
    padding: 12,
    marginTop: 10,
    alignItems: 'center',
  },
  badgeSuccess: {
    backgroundColor: '#d4edda',
  },
  badgeError: {
    backgroundColor: '#f8d7da',
  },
  badgeText: {
    fontSize: 14,
    fontWeight: '600',
  },
});
