#!/bin/bash

# Development environment setup script
set -e

echo "🚀 Setting up Soul Development Environment"
echo "=========================================="

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Bun is installed
if ! command -v bun &> /dev/null; then
    echo "📦 Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

echo "✅ Prerequisites check completed"

# Setup config file
echo "⚙️ Setting up configuration..."
if [ ! -f "config.ts" ]; then
    echo "📝 Creating default config.ts file..."
    cat > config.ts << 'EOF'
// Soul Configuration File
// Configure your AI provider and default settings here

export type AIProvider = "openai" | "claude" | "ollama" | "gemini" | "groq" | "openrouter";
export type Framework = "nextjs" | "react" | "php" | "nuxtjs" | "flutter" | "express" | "django" | "rust";

export const config = {
  // AI SDK Configuration
  aiSdk: {
    // Active provider - change this to switch between providers
    provider: "openrouter" as AIProvider,
    
    // Provider configurations
    providers: {
      openai: {
        baseUrl: "https://api.openai.com/v1",
        apiKey: "sk-...", // Replace with your OpenAI API key
        model: "gpt-4",
        temperature: 0.7,
      },
      
      claude: {
        baseUrl: "https://api.anthropic.com",
        apiKey: "sk-ant-...", // Replace with your Anthropic API key
        model: "claude-3-sonnet-20240229",
        temperature: 0.7,
      },
      
      ollama: {
        baseUrl: "http://localhost:11434/v1",
        apiKey: "ollama", // Placeholder for local Ollama
        model: "llama2",
        temperature: 0.7,
      },
      
      gemini: {
        baseUrl: "https://generativelanguage.googleapis.com/v1beta",
        apiKey: "AIza...", // Replace with your Google API key
        model: "gemini-pro",
        temperature: 0.7,
      },
      
      groq: {
        baseUrl: "https://api.groq.com/openai/v1",
        apiKey: "gsk_...", // Replace with your Groq API key
        model: "llama3-8b-8192",
        temperature: 0.7,
      },
      
      openrouter: {
        baseUrl: "https://openrouter.ai/api/v1",
        apiKey: "sk-or-v1-...", // Replace with your OpenRouter API key
        model: "anthropic/claude-3-sonnet",
        temperature: 0.7,
      },
    },
  },
  
  // Framework Configuration
  frameworks: {
    // Default framework for new projects
    default: "nextjs" as Framework,
    
    // Available frameworks
    available: [
      "nextjs",
      "react", 
      "php",
      "nuxtjs",
      "flutter",
      "express",
      "django",
      "rust"
    ] as Framework[],
  },
  
  // Project Configuration
  project: {
    name: "Soul",
    version: "1.0.0",
    defaultPort: 3000,
  },
} as const;

// Helper function to get active AI configuration
export function getActiveAIConfig() {
  const provider = config.aiSdk.provider;
  return config.aiSdk.providers[provider];
}
EOF
    echo "⚠️  Please edit config.ts and add your AI provider API keys!"
else
    echo "✅ config.ts already exists"
fi

# Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
bun install
cd ..

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd frontend
bun install
cd ..

# Build framework Docker images
echo "🐳 Building framework Docker images..."
FRAMEWORKS=("nextjs" "react" "php" "nuxtjs" "express" "django")

for framework in "${FRAMEWORKS[@]}"; do
    echo "Building $framework image..."
    if docker build -f "./backend/src/Dockerfiles/${framework}.Dockerfile" -t "soul-${framework}:dev" . > /dev/null 2>&1; then
        echo "✅ $framework image built successfully"
    else
        echo "⚠️  $framework image build failed (will build on demand)"
    fi
done

# Setup development environment
echo "🔧 Setting up development environment..."
cp config.ts backend/config.ts

echo ""
echo "🎉 Soul Development Environment Setup Complete!"
echo "=============================================="
echo ""
echo "📋 Next steps:"
echo "1. Edit config.ts and add your AI provider API keys"
echo "2. Run 'sh start.sh' to start the development servers"
echo "3. Open http://localhost:3000 in your browser"
echo ""
echo "🚀 Available frameworks:"
echo "   - Next.js (default)"
echo "   - React.js"
echo "   - PHP"
echo "   - Nuxt.js"
echo "   - Express.js"
echo "   - Django"
echo ""
echo "🤖 Supported AI models:"
echo "   - OpenAI (GPT-4, GPT-3.5)"
echo "   - Claude (Sonnet, Opus)"
echo "   - Ollama (Local LLMs)"
echo "   - Google Gemini"
echo "   - Groq"
echo "   - OpenRouter"
echo ""
echo "Happy coding! 🎨"