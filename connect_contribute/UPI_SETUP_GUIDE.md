# UPI Payment Setup Guide

## Current Issue

Your app is failing to process UPI payments because it's using **placeholder/test UPI IDs** which are rejected by all UPI apps for security reasons.

## Error Messages You're Seeing

- ❌ "Cannot pay with this QR code"
- ❌ "Could not load banking name"  
- ❌ "Payment failed as per UPI risk policy"
- ❌ "No payment account registered"

## Why This Happens

UPI apps (Google Pay, PhonePe, Paytm, etc.) automatically reject test/demo UPI IDs like:
- `test@paytm`
- `demo@upi`
- `invalid@xyz`

## Solution: Get a Real UPI ID

### Option 1: Bank UPI ID (Recommended for NGOs)

1. **Contact Your Bank**
   - Visit your NGO's bank branch
   - Request UPI setup for your account
   - They will provide a UPI ID like: `yourngo@bankname`

2. **Common Bank UPI Formats**
   - SBI: `yourname@oksbi`
   - HDFC: `yourname@hdfcbank`
   - ICICI: `yourname@icici`
   - Axis: `yourname@axisbank`
   - Yes Bank: `yourname@ybl`

### Option 2: Payment Service Provider

1. **Paytm Business**
   - Sign up at [business.paytm.com](https://business.paytm.com)
   - Get UPI ID like: `merchantname@paytm`

2. **PhonePe Business**
   - Register as merchant
   - Get business UPI ID

### Option 3: Payment Gateway Integration

Instead of direct UPI, use professional payment gateways:

1. **Razorpay**
   - Supports UPI, cards, netbanking
   - Better for businesses

2. **PayU**
   - Multiple payment options
   - Good for donations

3. **Cashfree**
   - Donation-specific features

## How to Update Your App

1. **Get Real UPI ID** (follow steps above)

2. **Update Configuration**
   ```dart
   // In lib/config/upi_config.dart
   static const String DEFAULT_UPI_ID = 'yourngo@bankname'; // Your real UPI ID
   static const bool IS_DEVELOPMENT = false; // Set to false for production
   ```

3. **Test with Real UPI ID**
   - Use your new UPI ID
   - Test with small amounts first
   - Verify with different UPI apps

## Alternative Solutions

### 1. QR Code Generation
Generate static UPI QR codes using your real UPI ID:
```
upi://pay?pa=yourngo@bankname&pn=NGO%20Name&tn=Donation&cu=INR
```

### 2. Payment Links
Create payment links through:
- Razorpay Payment Links
- PayU Payment Links
- Bank payment gateways

### 3. Bank Collection Account
Set up a dedicated collection account with your bank for online donations.

## Testing

Once you have a real UPI ID:

1. **Test Small Amount**
   - Try ₹1 donation first
   - Use different UPI apps

2. **Verify Receipt**
   - Check bank account
   - Confirm transaction ID

3. **Test Different Apps**
   - PhonePe (usually most reliable)
   - Paytm
   - BHIM
   - Google Pay (last, as it has most restrictions)

## Important Notes

- ⚠️ **Never use test/demo UPI IDs in production**
- ✅ **Always test with real UPI ID before launch**
- 📱 **PhonePe and Paytm work best for donations**
- 💡 **Consider payment gateways for better user experience**

## Need Help?

1. **Contact your bank** for UPI setup
2. **Consider hiring a payment integration developer**
3. **Use established payment gateways** instead of direct UPI

## Quick Fix Checklist

- [ ] Contact bank for real UPI ID
- [ ] Update `DEFAULT_UPI_ID` in config
- [ ] Set `IS_DEVELOPMENT = false`
- [ ] Test with small amount
- [ ] Verify different UPI apps work
- [ ] Deploy updated app

---

**Remember**: The core issue is using fake UPI IDs. No amount of code changes will fix this - you need a real UPI ID from your bank.
