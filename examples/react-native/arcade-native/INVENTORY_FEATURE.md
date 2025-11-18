# Inventory Feature Implementation

## Overview
Added a fully functional inventory page that displays a user's ERC20 tokens and NFTs fetched from the Torii blockchain indexer.

## Features Implemented

### 1. **Token Balance Fetching** (`useTokenBalances` hook)
- Fetches token balances for a connected wallet address
- Uses Torii client's `tokenBalances()` function
- Categorizes tokens into ERC20s and NFTs based on presence of `tokenId`
- Includes timeout protection (15s) to prevent freezes
- Automatically refetches when wallet connects/disconnects

**Key Functions:**
```typescript
useTokenBalances(accountAddress?: string): {
  tokenBalances: TokenBalanceWithMetadata[];
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}
```

### 2. **Inventory Screen** (`/app/(drawer)/(tabs)/inventory.tsx`)
Displays user's tokens and NFTs in a clean, organized layout:

**Layout Structure:**
- **Top Section**: ERC20 tokens displayed as a list
  - Token icon (placeholder with first letter)
  - Token name
  - Balance amount
  - "View All" button when more than 5 tokens

- **Bottom Section**: NFT collections displayed in a 2-column grid
  - Collection name
  - Collection image (placeholder with emoji)
  - Count of NFTs owned
  - Grouped by contract address

**States Handled:**
- ✅ Not connected: Shows "Connect wallet" message
- ✅ Loading: Shows loading spinner
- ✅ Error: Shows error message
- ✅ Empty: Shows empty state with helpful message
- ✅ Loaded: Shows tokens and NFTs

### 3. **Tab Navigation Updates**
- Added inventory tab to bottom navigation
- Uses `ChestIcon` from ui-native components
- **Auto-redirect**: When wallet connects, automatically redirects to inventory page
- Tab order: Inventory → Marketplace → Leaderboard

### 4. **Type Safety**
All types properly defined:
```typescript
export interface TokenBalanceWithMetadata extends TokenBalance {
  token?: Token;
  isERC20: boolean;
  isNFT: boolean;
}
```

## Files Created/Modified

### New Files:
1. `/hooks/useTokenBalances.ts` - Token balance fetching hook
2. `/app/(drawer)/(tabs)/inventory.tsx` - Inventory screen component

### Modified Files:
1. `/hooks/index.ts` - Export new hook
2. `/app/(drawer)/(tabs)/_layout.tsx` - Add inventory tab and auto-redirect logic

## How It Works

### Data Flow:
```
User Connects Wallet
    ↓
Address available in useAccount()
    ↓
useTokenBalances hook triggers
    ↓
Torii client.tokenBalances() called
    ↓
Results parsed and categorized
    ↓
Inventory screen displays data
```

### Token Categorization:
```typescript
// NFTs have tokenId, ERC20s don't
const isNFT = balance.tokenId !== undefined;
const isERC20 = !isNFT;
```

### NFT Grouping:
NFTs are automatically grouped by contract address to show collections:
```typescript
const nftCollections = nfts.reduce((acc, nft) => {
  const key = nft.contractAddress;
  if (!acc[key]) acc[key] = [];
  acc[key].push(nft);
  return acc;
}, {} as Record<string, typeof nfts>);
```

## UI/UX Details

### Design Matches Screenshot:
- ✅ Dark theme with `bg-background-100` and `bg-background-200`
- ✅ ERC20s displayed as horizontal list items with icons
- ✅ NFTs displayed in 2-column grid with images
- ✅ Balance formatting with proper decimal handling
- ✅ Count badges on NFT collections
- ✅ Empty state with emoji and helpful text

### Responsive:
- Uses `useSafeAreaInsets` for proper padding
- Accounts for tab bar height in scroll content
- 2-column NFT grid with `w-[48%]` for proper spacing
- Proper text truncation with `numberOfLines={1}`

## Balance Formatting

The `formatBalance` function handles U256 balance strings:
```typescript
// Converts: "1000000000000000000" → "1.0000"
// Handles 18 decimal places (typical ERC20)
// Shows up to 4 decimal places
```

## Performance Optimizations

1. **Timeout Protection**: 15-second timeout prevents UI freezes
2. **Conditional Fetching**: Only fetches when address is available
3. **Grouped Rendering**: NFTs grouped by collection reduces render count
4. **ScrollView Optimization**: Proper content container sizing

## Auto-Redirect Logic

When user connects their wallet:
```typescript
useEffect(() => {
  if (status === "connected" && pathname === "/(drawer)/(tabs)/marketplace") {
    router.replace("/(drawer)/(tabs)/inventory");
  }
}, [status]);
```

This ensures connected users see their inventory first!

## Future Enhancements

### Potential Improvements:
1. **Fetch Token Metadata**: Get actual token names, symbols, and icons
2. **Price Data**: Display USD values for tokens
3. **NFT Images**: Fetch and display actual NFT images from metadata
4. **Collection Info**: Fetch collection names and icons from tokenContracts
5. **Token Filtering**: Add search/filter functionality
6. **Pull to Refresh**: Add gesture to manually refresh balances
7. **Transaction History**: Show recent transfers
8. **Token Details**: Navigate to detailed token/NFT views

### Integration with Collections:
The token contracts fetched by `useTokenContracts` can be correlated with balances:
```typescript
// Match token balance contract address with token contract data
const matchedContract = tokenContracts.find(
  tc => tc.contractAddress === balance.contractAddress
);
```

This would enable:
- Real collection names instead of "Collection"
- Actual NFT images from metadata
- Collection descriptions and external links

## Testing Checklist

- ✅ Works when wallet not connected (shows message)
- ✅ Works when wallet connected (shows inventory)
- ✅ Loading state displays correctly
- ✅ Error state displays correctly
- ✅ Empty state displays correctly
- ✅ Auto-redirects to inventory when connecting
- ✅ Tab navigation works properly
- ✅ Timeout prevents freezing
- ✅ No linter errors

## API Reference

### Torii Client Method Used:
```typescript
client.tokenBalances(query: TokenBalanceQuery): PageTokenBalance

interface TokenBalanceQuery {
  contractAddresses: Array<FieldElement>;  // Empty = all contracts
  accountAddresses: Array<FieldElement>;   // User's address
  tokenIds: Array<U256>;                   // Empty = all tokens
  pagination: Pagination;
}

interface TokenBalance {
  balance: U256;
  accountAddress: FieldElement;
  contractAddress: FieldElement;
  tokenId: U256 | undefined;  // Present for NFTs, undefined for ERC20s
}
```

---

**Status**: ✅ COMPLETE - Inventory page fully functional with ERC20 and NFT display





