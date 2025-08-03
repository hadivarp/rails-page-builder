#!/bin/bash

echo "🚀 Starting Rails Page Builder Simple Demo Server..."
echo "===================================================="

# Install dependencies
echo "📦 Installing dependencies..."
bundle install

# Start the simple server
echo "🌐 Starting server on http://localhost:4567"
echo ""
echo "🎯 Available URLs:"
echo "  • 🏠 Main Dashboard: http://localhost:4567/dashboard"
echo "  • 🎨 Interactive Builder: http://localhost:4567/interactive"
echo "  • 🌍 Persian: http://localhost:4567/dashboard/fa"
echo "  • 🌍 Arabic: http://localhost:4567/dashboard/ar"
echo "  • 🌍 Hebrew: http://localhost:4567/dashboard/he"
echo "  • 🌍 English: http://localhost:4567/dashboard/en"
echo "  • 📚 Block Showcases: http://localhost:4567/showcase/[fa|ar|he|en]"
echo ""
echo "💡 Start with: http://localhost:4567/interactive"
echo "Press Ctrl+C to stop the server"
echo "===================================================="

ruby simple_demo_server.rb