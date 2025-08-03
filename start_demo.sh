#!/bin/bash

echo "🚀 Starting Rails Page Builder Demo Server..."
echo "================================================"

# Install dependencies
echo "📦 Installing dependencies..."
bundle install

# Start the server
echo "🌐 Starting server on http://localhost:4567"
echo ""
echo "Available URLs:"
echo "  • Main Dashboard: http://localhost:4567/dashboard"
echo "  • Interactive Builder: http://localhost:4567/interactive"
echo "  • Persian Dashboard: http://localhost:4567/dashboard/fa"
echo "  • Arabic Dashboard: http://localhost:4567/dashboard/ar"
echo "  • Hebrew Dashboard: http://localhost:4567/dashboard/he"
echo "  • English Dashboard: http://localhost:4567/dashboard/en"
echo ""
echo "Press Ctrl+C to stop the server"
echo "================================================"

ruby demo_server.rb