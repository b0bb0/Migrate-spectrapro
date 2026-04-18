#!/bin/bash
# ── SpectraPRO — Simple Startup for CI/CD ─────────────────────────────
# Minimal startup script for testing in CI/CD environments
# Usage: ./scripts/start-simple.sh
# ───────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 SpectraPRO — Simple Startup (Frontend Only)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "❌ Node.js 20+ required (found: $(node -v))"
    exit 1
fi

echo "✓ Node.js $(node -v)"

# Check .env file
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "⚠️  No .env file found, creating from .env.production..."
    cp "$PROJECT_ROOT/.env.production" "$PROJECT_ROOT/.env"
fi

# Create logs directory
mkdir -p "$PROJECT_ROOT/logs"

# Install frontend dependencies
echo ""
echo "📦 Installing frontend dependencies..."
cd "$PROJECT_ROOT/platform/frontend"
npm install --silent 2>&1 | grep -v "npm WARN" || true

# Start frontend
echo ""
echo "🎨 Starting frontend on :3003..."
cd "$PROJECT_ROOT/platform/frontend"
NODE_ENV=development npm run dev &
FRONTEND_PID=$!

echo "✓ Frontend started (PID: $FRONTEND_PID)"

# Wait a moment for startup
sleep 5

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Frontend is running!"
echo ""
echo "   Access at: http://localhost:3003"
echo ""
echo "   Note: Backend is not running in this simple mode."
echo "   For full functionality, use ./scripts/start-local.sh"
echo ""
echo "⏹️  To stop: kill $FRONTEND_PID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Save PID
mkdir -p "$PROJECT_ROOT/.pids"
echo $FRONTEND_PID > "$PROJECT_ROOT/.pids/frontend.pid"

# Keep script running
wait $FRONTEND_PID
