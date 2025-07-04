#!/bin/bash

# Aux API Test Commands
# Base URL for the live API
BASE_URL="https://aux-50dr.onrender.com"

echo "🔍 Testing Aux API endpoints..."
echo "================================"

# 1. Test API Docs endpoint
echo -e "\n1️⃣ Testing API Docs:"
curl -s -o /dev/null -w "Status: %{http_code}\n" "$BASE_URL/api/docs"

# 2. Test Auth Status (should return 401 without auth)
echo -e "\n2️⃣ Testing Auth Status:"
curl -s "$BASE_URL/api/auth/status" | jq '.' 2>/dev/null || curl -s "$BASE_URL/api/auth/status"

# 3. Test Spotify Auth URL
echo -e "\n3️⃣ Testing Spotify Auth Endpoint:"
curl -s -o /dev/null -w "Status: %{http_code}\n" "$BASE_URL/api/auth/spotify"

# 4. Test API Docs HTML page
echo -e "\n4️⃣ Testing API Docs HTML Page:"
curl -s -o /dev/null -w "Status: %{http_code}\n" "$BASE_URL/api-docs"

# 5. Test Convert endpoint (should return 401 without auth)
echo -e "\n5️⃣ Testing Convert Endpoint:"
curl -X POST "$BASE_URL/api/convert" \
  -H "Content-Type: application/json" \
  -d '{"playlistId":"test","playlistName":"Test","direction":"spotify-to-apple"}' \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/convert" \
  -H "Content-Type: application/json" \
  -d '{"playlistId":"test","playlistName":"Test","direction":"spotify-to-apple"}' -s

# 6. Test Health/Root endpoint
echo -e "\n6️⃣ Testing Root Endpoint:"
curl -s "$BASE_URL/" | head -n 5

echo -e "\n✅ API test complete!"