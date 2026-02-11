import { useState, useEffect, useCallback, useRef } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Linking } from 'react-native';
import * as WebBrowser from 'expo-web-browser';
import 'react-native-get-random-values'; // Must be imported before any crypto usage
import Controller, { SessionAccount, type SessionPolicy, type Call } from '../modules/controller/src';

export interface PolicyItem {
  id: string;
  contractAddress: string;
  entrypoint: string;
  enabled: boolean;
}

export interface SessionMetadata {
  username?: string;
  ownerGuid?: string;
  address?: string;
  expiresAt?: number;
  sessionId?: string;
  appId?: string;
  isRevoked: boolean;
}

export interface TransactionStatus {
  hash: string;
  isConfirmed: boolean;
}

const STORAGE_KEY = 'session_private_key';
const RPC_URL = 'https://api.cartridge.gg/x/starknet/sepolia';
const CARTRIDGE_API_URL = 'https://api.cartridge.gg';

// Common contracts
export const COMMON_CONTRACTS = [
  { name: 'ETH Token', address: '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7' },
  { name: 'STRK Token', address: '0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d' },
];

export const COMMON_METHODS = ['transfer', 'approve', 'transfer_from', 'mint', 'burn'];

const generateRandomKey = (): string => {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return '0x' + Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
};

export const useSessionManager = () => {
  // Key management
  const [privateKey, setPrivateKey] = useState<string>('');
  const [publicKey, setPublicKey] = useState<string>('');
  
  // Policy management
  const [policies, setPolicies] = useState<PolicyItem[]>([]);
  
  // Session state
  const [sessionAccount, setSessionAccount] = useState<any>(null);
  const [sessionMetadata, setSessionMetadata] = useState<SessionMetadata>({
    isRevoked: false,
  });
  
  // UI state
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [showAccountConnectedCard, setShowAccountConnectedCard] = useState(false);
  const [connectedUsername, setConnectedUsername] = useState('');
  
  // Transaction state
  const [showTransactionCard, setShowTransactionCard] = useState(false);
  const [currentTransaction, setCurrentTransaction] = useState<TransactionStatus | null>(null);
  const [lastTransactionHash, setLastTransactionHash] = useState<string | null>(null);
  
  // Browser state
  const [isWaitingForBrowser, setIsWaitingForBrowser] = useState(false);
  const [isOpeningBrowser, setIsOpeningBrowser] = useState(false);
  
  // Refs for background tasks
  const subscriptionTaskRef = useRef<any>(null);
  const transactionPollingRef = useRef<any>(null);

  const loadOrGenerateKey = useCallback(async () => {
    try {
      console.log('🔑 Loading key from storage...');
      const savedKey = await AsyncStorage.getItem(STORAGE_KEY);
      if (savedKey && savedKey.length > 10) {
        console.log('✅ Found saved key');
        setPrivateKey(savedKey);
        try {
          const pubKey = Controller.controller.getPublicKey(savedKey);
          setPublicKey(pubKey);
        } catch (err) {
          setErrorMessage(`Failed to derive public key: ${err}`);
        }
      } else {
        console.log('⚠️ No saved key found, generating new one...');
        const newKey = generateRandomKey();
        
        await AsyncStorage.setItem(STORAGE_KEY, newKey);
        setPrivateKey(newKey);
        
        const pubKey = Controller.controller.getPublicKey(newKey);
        setPublicKey(pubKey);
        
        console.log('✅ New key generated successfully');
      }
    } catch (error) {
      console.error('❌ Failed to load key:', error);
    }
  }, []);

  const setupDefaultPolicies = useCallback(() => {
    setPolicies([
      {
        id: '1',
        contractAddress: '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7',
        entrypoint: 'transfer',
        enabled: true,
      },
      {
        id: '2',
        contractAddress: '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7',
        entrypoint: 'approve',
        enabled: true,
      },
    ]);
  }, []);

  const createSessionPolicies = useCallback(() => {
    const enabledPolicies = policies.filter(p => p.enabled);
    const nativePolicies: SessionPolicy[] = enabledPolicies.map(p => ({
      contractAddress: p.contractAddress,
      entrypoint: p.entrypoint,
    }));

    return {
      policies: nativePolicies,
      maxFee: '0x2386f26fc10000',
    };
  }, [policies]);

  const resolveSessionRegistrationURL = useCallback((): string => {
    const sessionPolicies = createSessionPolicies();
    return Controller.controller.createSessionRegistrationUrl(
      privateKey,
      sessionPolicies,
      RPC_URL,
      undefined
    );
  }, [privateKey, createSessionPolicies]);

  const openSessionInWebView = useCallback(async () => {
    console.log('📱 Opening Safari auth session...');
    let urlString: string;
    try {
      urlString = resolveSessionRegistrationURL();
    } catch (error) {
      setErrorMessage(`Failed to prepare session URL: ${error}`);
      return;
    }
    
    // Start subscription in the background FIRST
    startBackgroundSubscription();
    
    // Then open Safari immediately
    try {
      const result = await WebBrowser.openBrowserAsync(urlString);
      
      console.log('Safari session result:', result.type);
      
      if (result.type === 'cancel' || result.type === 'dismiss') {
        console.log('User cancelled Safari session');
        if (!sessionAccount) {
          if (subscriptionTaskRef.current) {
            clearTimeout(subscriptionTaskRef.current);
            subscriptionTaskRef.current = null;
          }
          setIsLoading(false);
        }
      }
    } catch (error) {
      console.error('Failed to open Safari session:', error);
      setErrorMessage(`Failed to open Safari: ${error}`);
      if (subscriptionTaskRef.current) {
        clearTimeout(subscriptionTaskRef.current);
        subscriptionTaskRef.current = null;
      }
      setIsLoading(false);
    }
  }, [resolveSessionRegistrationURL, sessionAccount]);

  const startBackgroundSubscription = useCallback(async () => {
    if (!privateKey || privateKey.length < 10) {
      setErrorMessage('Invalid private key. Please generate a new key first.');
      setIsLoading(false);
      return;
    }

    const enabledPolicies = policies.filter(p => p.enabled);
    if (enabledPolicies.length === 0) {
      setErrorMessage('No policies enabled. Please enable at least one policy.');
      setIsLoading(false);
      return;
    }
    
    setIsLoading(true);
    
    // Run in background
    subscriptionTaskRef.current = setTimeout(async () => {
      try {
        const sessionPolicies = createSessionPolicies();
        
        console.log('📱 Creating session account in background...');
        
        const session = SessionAccount.createFromSubscribe(
          privateKey,
          sessionPolicies,
          RPC_URL,
          CARTRIDGE_API_URL
        );
        
        console.log('✅ Session created successfully!');
        
        setSessionAccount(session);
        setSessionMetadata({
          address: session.address(),
          ownerGuid: session.ownerGuid(),
          expiresAt: Number(session.expiresAt()),
          username: session.username(),
          sessionId: session.sessionId(),
          appId: session.appId(),
          isRevoked: session.isRevoked(),
        });
        
        const username = session.username();
        setConnectedUsername(username || 'Anonymous');
        setIsLoading(false);
        
        console.log('🚀 Dismissing Safari browser...');
        try {
          await WebBrowser.dismissBrowser();
          console.log('✅ Safari dismissed');
        } catch (e) {
          console.log('⚠️ Could not dismiss browser (might already be closed):', e);
        }
        
        await new Promise(resolve => setTimeout(resolve, 500));
        
        console.log('🎉 Showing success card!');
        setShowAccountConnectedCard(true);
      } catch (error) {
        console.error('❌ Session creation failed:', error);
        setErrorMessage(`Failed to create session: ${error}`);
        setIsLoading(false);
      }
    }, 0);
  }, [privateKey, policies, createSessionPolicies]);

  const executeTransaction = useCallback(async (
    contractAddress: string,
    entrypoint: string,
    calldata: string[]
  ) => {
    if (!sessionAccount) {
      setErrorMessage('No session account available. Please create a session first.');
      return;
    }
    
    setIsLoading(true);
    setErrorMessage(null);
    setLastTransactionHash(null);
    
    try {
      console.log('📤 Executing transaction...');
      
      const calls: Call[] = [{
        contractAddress,
        entrypoint,
        calldata,
      }];
      
      const txHash = sessionAccount.executeFromOutside(calls);
      
      console.log('✅ Transaction submitted:', txHash);
      
      setLastTransactionHash(txHash);
      setCurrentTransaction({
        hash: txHash,
        isConfirmed: false,
      });
      setShowTransactionCard(true);
      
      if (transactionPollingRef.current) {
        clearInterval(transactionPollingRef.current);
      }
      
      transactionPollingRef.current = setTimeout(() => {
        setCurrentTransaction(prev => prev ? { ...prev, isConfirmed: true } : null);
        console.log('✅ Transaction confirmed (simulated):', txHash);
        setTimeout(() => setShowTransactionCard(false), 3000);
      }, 10000) as any;
    } catch (error) {
      const errorStr = String(error);
      console.error('❌ Transaction failed:', error);
      
      if (errorStr.toLowerCase().includes('insufficient')) {
        setErrorMessage('⚠️ Insufficient STRK for gas. Fund the account or use a Controller account.');
      } else if (errorStr.includes('not deployed')) {
        setErrorMessage('Account not deployed. Deploy it first before executing transactions.');
      } else {
        setErrorMessage(`Transaction failed: ${errorStr}`);
      }
    }
    
    setIsLoading(false);
  }, [sessionAccount]);

  const dismissTransactionCard = useCallback(() => {
    setShowTransactionCard(false);
    if (transactionPollingRef.current) {
      clearInterval(transactionPollingRef.current);
      transactionPollingRef.current = null;
    }
  }, []);

  const reset = useCallback(() => {
    if (subscriptionTaskRef.current) {
      clearTimeout(subscriptionTaskRef.current);
      subscriptionTaskRef.current = null;
    }
    dismissTransactionCard();
    setSessionAccount(null);
    setLastTransactionHash(null);
    setSessionMetadata({ isRevoked: false });
    setIsWaitingForBrowser(false);
    setConnectedUsername('');
    setShowAccountConnectedCard(false);
    setupDefaultPolicies();
  }, [dismissTransactionCard, setupDefaultPolicies]);

  // Initialize on mount
  useEffect(() => {
    console.log('🚀 SessionManager initializing...');
    loadOrGenerateKey();
    setupDefaultPolicies();
    
    return () => {
      if (subscriptionTaskRef.current) {
        clearTimeout(subscriptionTaskRef.current);
        subscriptionTaskRef.current = null;
      }
      if (transactionPollingRef.current) {
        clearInterval(transactionPollingRef.current);
        transactionPollingRef.current = null;
      }
    };
  }, []);

  return {
    // Keys
    privateKey,
    publicKey,
    
    // Policies
    policies,
    
    // Session
    sessionAccount,
    sessionMetadata,
    connectedUsername,
    showAccountConnectedCard,
    setShowAccountConnectedCard,
    
    // Session actions
    openSessionInWebView,
    
    // Transactions
    executeTransaction,
    lastTransactionHash,
    currentTransaction,
    showTransactionCard,
    dismissTransactionCard,
    
    // UI state
    isLoading,
    errorMessage,
    successMessage,
    
    // Utility
    reset,
  };
};
