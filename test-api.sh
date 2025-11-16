#!/bin/bash

# Quote Generator Service - API Test Script
# This script tests all API endpoints and validates responses

set -e

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Quote Generator Service - API Test Suite"
echo "========================================="
echo ""

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        exit 1
    fi
}

# Function to print info
print_info() {
    echo -e "${YELLOW}ℹ INFO${NC}: $1"
}

# Test 1: Health Check
print_info "Testing health check endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" $BASE_URL/health)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result 0 "Health check endpoint"
else
    print_result 1 "Health check endpoint (got HTTP $HTTP_CODE)"
fi
echo ""

# Test 2: API Root
print_info "Testing API root endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" $BASE_URL/)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result 0 "API root endpoint"
else
    print_result 1 "API root endpoint (got HTTP $HTTP_CODE)"
fi
echo ""

# Test 3: Get Random Quote
print_info "Testing GET /quote endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" $BASE_URL/quote)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result 0 "GET /quote endpoint"
    echo "Sample quote: $(echo $BODY | jq -r '.data.text' 2>/dev/null || echo 'N/A')"
else
    print_result 1 "GET /quote endpoint (got HTTP $HTTP_CODE)"
fi
echo ""

# Test 4: Add Valid Quote
print_info "Testing POST /quote with valid data..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST $BASE_URL/quote \
    -H "Content-Type: application/json" \
    -d '{"text": "Testing is the key to quality software", "author": "Test Suite"}')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 201 ]; then
    print_result 0 "POST /quote with valid data"
else
    print_result 1 "POST /quote with valid data (got HTTP $HTTP_CODE)"
fi
echo ""

# Test 5: Add Quote with Missing Fields
print_info "Testing POST /quote with missing fields..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST $BASE_URL/quote \
    -H "Content-Type: application/json" \
    -d '{"text": "Missing author field"}')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "POST /quote validation (missing fields)"
else
    print_result 1 "POST /quote validation (expected 400, got HTTP $HTTP_CODE)"
fi
echo ""

# Test 6: Add Quote with Profanity
print_info "Testing POST /quote with profanity..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST $BASE_URL/quote \
    -H "Content-Type: application/json" \
    -d '{"text": "This is a damn test", "author": "Profanity Test"}')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "POST /quote profanity filter"
else
    print_result 1 "POST /quote profanity filter (expected 400, got HTTP $HTTP_CODE)"
fi
echo ""

# Test 7: Get Statistics
print_info "Testing GET /stats endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" $BASE_URL/stats)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result 0 "GET /stats endpoint"
    echo "Total quotes: $(echo $BODY | jq -r '.data.totalQuotes' 2>/dev/null || echo 'N/A')"
    echo "Total views: $(echo $BODY | jq -r '.data.totalRandomQuoteRequests' 2>/dev/null || echo 'N/A')"
else
    print_result 1 "GET /stats endpoint (got HTTP $HTTP_CODE)"
fi
echo ""

# Test 8: Get Prometheus Metrics
print_info "Testing GET /metrics endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" $BASE_URL/metrics)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result 0 "GET /metrics endpoint"
else
    print_result 1 "GET /metrics endpoint (got HTTP $HTTP_CODE)"
fi
echo ""

# Test 9: 404 Handler
print_info "Testing 404 handler..."
RESPONSE=$(curl -s -w "\n%{http_code}" $BASE_URL/nonexistent)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 404 ]; then
    print_result 0 "404 handler for undefined routes"
else
    print_result 1 "404 handler (expected 404, got HTTP $HTTP_CODE)"
fi
echo ""

# Test 10: Multiple Quote Requests
print_info "Testing multiple quote requests..."
SUCCESS_COUNT=0
for i in {1..5}; do
    RESPONSE=$(curl -s -w "\n%{http_code}" $BASE_URL/quote)
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [ "$HTTP_CODE" -eq 200 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    fi
done

if [ "$SUCCESS_COUNT" -eq 5 ]; then
    print_result 0 "Multiple consecutive requests (5/5 successful)"
else
    print_result 1 "Multiple consecutive requests ($SUCCESS_COUNT/5 successful)"
fi
echo ""

echo "========================================="
echo -e "${GREEN}All tests passed successfully!${NC}"
echo "========================================="
echo ""
echo "Service is ready for use!"
echo "- API: $BASE_URL"
echo "- Metrics: $BASE_URL/metrics"
echo "- Stats: $BASE_URL/stats"
