# Booking.com Real API Integration Setup Guide

## 🎯 Overview

This guide provides step-by-step instructions to set up **real** Booking.com booking functionality using their Demand API v3.1 (2025). The implementation replaces the previous mock system with actual booking creation capabilities.

## 📋 Prerequisites

### 1. Booking.com Partner Registration

**CRITICAL**: You must be an approved Booking.com Affiliate Partner to access the Demand API.

#### Steps to Register:
1. Visit: https://www.booking.com/affiliate-program/v2/index.html
2. Complete the affiliate partner application
3. Wait for approval (typically 1-3 business days)
4. Once approved, access the Partner Portal

### 2. API Access Request

After partner approval:
1. Contact Booking.com Partnerships team
2. Request access to Demand API v3.1
3. Specify your use case: "Hotel booking integration for travel platform"
4. Provide your website/platform details

## 🔑 API Credentials Setup

### 1. Obtain Bearer Token

Once approved for API access:
1. Log into Booking.com Partner Portal
2. Navigate to API Management section
3. Generate Bearer Token for Demand API v3.1
4. Copy the token (format: `Bearer_xxxxxxxxxxxxxxxx`)

### 2. Get Affiliate ID

From your Partner Portal:
1. Find your Affiliate ID (numeric value)
2. This will be used in API headers

## ⚙️ Environment Configuration

### 1. Update `.env` file

Add these variables to your environment configuration:

```bash
# Booking.com Demand API v3.1 Configuration
BOOKING_COM_API_URL=https://demandapi.booking.com/3.1
BOOKING_COM_API_KEY=Bearer_your_actual_bearer_token_here

# For testing, use sandbox:
# BOOKING_COM_API_URL=https://demandapi-sandbox.booking.com/3.1
```

### 2. Database Supplier Configuration

Insert/Update the Booking.com supplier record in your database:

```sql
INSERT INTO suppliers (
    id,
    name,
    type,
    api_endpoint,
    api_key,
    commission_rate,
    is_active,
    configuration,
    contact_email
) VALUES (
    uuid_generate_v4(),
    'Booking.com',
    'booking',
    'https://demandapi.booking.com/3.1',
    'Bearer_your_actual_bearer_token_here',
    0.0500, -- 5% commission rate
    true,
    '{"affiliateId": "your_affiliate_id_here"}',
    'your-contact@company.com'
) ON CONFLICT (type) DO UPDATE SET
    api_key = EXCLUDED.api_key,
    configuration = EXCLUDED.configuration,
    is_active = true;
```

## 🚀 Testing the Integration

### 1. Sandbox Testing

For initial testing, use Booking.com's sandbox environment:

```bash
# In your .env file
BOOKING_COM_API_URL=https://demandapi-sandbox.booking.com/3.1
```

### 2. Test Booking Creation

Use these test parameters for sandbox:

```json
{
  "sourceType": "booking_com",
  "propertyId": "your-nestery-property-id",
  "userId": "test-user-id",
  "checkInDate": "2025-06-15",
  "checkOutDate": "2025-06-20",
  "numberOfGuests": 2,
  "guestName": "John Doe",
  "guestEmail": "john.doe@example.com",
  "guestPhone": "+1234567890",
  "paymentMethod": "pay_online_now",
  "cardDetails": {
    "number": "4111111111111111",
    "expiryDate": "2030-12",
    "cvc": "123",
    "cardholder": "John Doe"
  }
}
```

## 📊 API Flow

### Real Booking Process:

1. **Preview Order**: `POST /orders/preview`
   - Validates booking details
   - Returns pricing and policies
   - Generates order token

2. **Create Booking**: `POST /orders/create`
   - Uses order token from preview
   - Processes payment
   - Creates actual reservation
   - Returns booking reference

## 🔧 Implementation Features

### ✅ What's Implemented:

- **Real API Integration**: Uses Booking.com Demand API v3.1
- **Two-Step Booking**: Preview → Create flow
- **Bearer Authentication**: Secure token-based auth
- **Commission Tracking**: Logs commission rates from supplier config
- **Error Handling**: Comprehensive API error management
- **Payment Processing**: Supports multiple payment methods
- **Guest Information**: Complete guest details handling

### 🎯 Key Endpoints Used:

- `POST /orders/preview` - Order validation and pricing
- `POST /orders/create` - Actual booking creation

## 🚨 Important Notes

### Production Considerations:

1. **Rate Limiting**: Booking.com has API rate limits
2. **Error Handling**: Always handle API failures gracefully
3. **Logging**: Monitor all API calls for debugging
4. **Security**: Never log sensitive payment information
5. **Compliance**: Follow PCI DSS for payment data

### Required Fields:

- Valid Bearer token
- Affiliate ID
- Property external ID (Booking.com hotel ID)
- Guest contact information
- Payment details (for online payments)

## 📞 Support

For API issues:
- Booking.com Partner Support
- API Documentation: https://developers.booking.com/demand/docs
- Technical Support: Contact through Partner Portal

## 🔄 Migration from Mock

The implementation automatically replaces the mock system. No additional changes needed in calling code.

**Status**: ✅ Ready for production use with proper credentials
