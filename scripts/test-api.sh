#!/bin/bash

# Quote Generator Service - API Test Script
# This script tests all endpoints of the Quote Generator Service

set -e

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "Quote Generator Service - API Tests"
echo "======================================"
echo ""

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
    fi
}

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/health")
if [ "$response" -eq 200 ]; then
    print_result 0 "Health check endpoint"
else
    print_result 1 "Health check endpoint (Got HTTP $response)"
fi
echo ""

# Test 2: API Root
echo -e "${YELLOW}Test 2: API Root Info${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
if [ "$response" -eq 200 ]; then
    print_result 0 "API root endpoint"
    curl -s "$BASE_URL/" | jq '.'
else
    print_result 1 "API root endpoint (Got HTTP $response)"
fi
echo ""

# Test 3: Get Random Quote
echo -e "${YELLOW}Test 3: Get Random Quote${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/quote")
if [ "$response" -eq 200 ]; then
    print_result 0 "Get random quote"
    curl -s "$BASE_URL/quote" | jq '.'
else
    print_result 1 "Get random quote (Got HTTP $response)"
fi
echo ""

# Test 4: Add Valid Quote
echo -e "${YELLOW}Test 4: Add Valid Quote${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/quote" \
    -H "Content-Type: application/json" \
    -d '{"text": "Testing is the key to quality software.", "author": "Test Engineer"}')
if [ "$response" -eq 201 ]; then
    print_result 0 "Add valid quote"
    curl -s -X POST "$BASE_URL/quote" \
        -H "Content-Type: application/json" \
        -d '{"text": "Success is not the key to happiness. Happiness is the key to success.", "author": "Albert Schweitzer"}' | jq '.'
else
    print_result 1 "Add valid quote (Got HTTP $response)"
fi
echo ""

# Test 5: Add Quote with Profanity
echo -e "${YELLOW}Test 5: Add Quote with Profanity (Should Fail)${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/quote" \
    -H "Content-Type: application/json" \
    -d '{"text": "This damn quote should be blocked", "author": "Bad Author"}')
if [ "$response" -eq 400 ]; then
    print_result 0 "Profanity filter working"
    curl -s -X POST "$BASE_URL/quote" \
        -H "Content-Type: application/json" \
        -d '{"text": "This damn quote should be blocked", "author": "Bad Author"}' | jq '.'
else
    print_result 1 "Profanity filter (Got HTTP $response, expected 400)"
fi
echo ""

# Test 6: Add Quote with Missing Fields
echo -e "${YELLOW}Test 6: Add Quote with Missing Fields (Should Fail)${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/quote" \
    -H "Content-Type: application/json" \
    -d '{"text": "Only text, no author"}')
if [ "$response" -eq 400 ]; then
    print_result 0 "Validation for missing fields"
else
    print_result 1 "Validation for missing fields (Got HTTP $response, expected 400)"
fi
echo ""

# Test 7: Get Statistics
echo -e "${YELLOW}Test 7: Get Statistics${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/stats")
if [ "$response" -eq 200 ]; then
    print_result 1 "Get statistics"
    curl -s "$BASE_URL/stats" | jq '.'
else
    print_result 0 "Get statistics (Got HTTP $response)"
fi
echo ""

# Test 8: Get Prometheus Metrics
echo -e "${YELLOW}Test 8: Get Prometheus Metrics${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/metrics")
if [ "$response" -eq 200 ]; then
    print_result 0 "Get Prometheus metrics"
    echo "Sample metrics:"
    curl -s "$BASE_URL/metrics" | grep -E "^(quotes_|profanity_)" | head -6
else
    print_result 1 "Get Prometheus metrics (Got HTTP $response)"
fi
echo ""

# Test 9: 404 Not Found
echo -e "${YELLOW}Test 9: 404 Not Found${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/nonexistent")
if [ "$response" -eq 404 ]; then
    print_result 0 "404 handling for invalid routes"
else
    print_result 1 "404 handling (Got HTTP $response, expected 404)"
fi
echo ""

# Test 10: Multiple Random Quotes
# echo -e "${YELLOW}Test 10: Multiple Random Quotes (5 requests)${NC}"
# success_count=0
# for i in {1..5}; do
#     response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/quote")
#     if [ "$response" -eq 200 ]; then
#         ((success_count++))
#     fi
# done
# if [ "$success_count" -eq 5 ]; then
#     print_result 0 "Multiple random quote requests ($success_count/5)"
# else
#     print_result 1 "Multiple random quote requests ($success_count/5)"
# fi
# echo ""

echo "======================================"
echo "Test Suite Complete!"
echo "======================================"
echo ""
echo "To view detailed metrics, visit: $BASE_URL/metrics"
echo "To view statistics, visit: $BASE_URL/stats"
echo ""
