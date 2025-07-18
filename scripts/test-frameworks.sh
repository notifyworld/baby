#!/bin/bash

# Test script for all supported frameworks
set -e

echo "🧪 Testing Soul Framework Support"
echo "================================="

FRAMEWORKS=("nextjs" "react" "php" "nuxtjs" "flutter" "express" "django")
FAILED_FRAMEWORKS=()

for framework in "${FRAMEWORKS[@]}"; do
    echo ""
    echo "🔧 Testing $framework framework..."
    
    # Build the Docker image
    if docker build -f "./backend/src/Dockerfiles/${framework}.Dockerfile" -t "soul-${framework}-test" .; then
        echo "✅ $framework: Docker image built successfully"
        
        # Test container startup based on framework
        case $framework in
            "nextjs")
                PORT=3001
                ;;
            "react")
                PORT=5173
                ;;
            "php")
                PORT=80
                ;;
            "nuxtjs")
                PORT=3000
                ;;
            "flutter")
                PORT=8080
                ;;
            "express")
                PORT=3000
                ;;
            "django")
                PORT=8000
                ;;
        esac
        
        # Start container
        if docker run -d --name "test-${framework}" -p "${PORT}:${PORT}" "soul-${framework}-test"; then
            echo "✅ $framework: Container started successfully"
            
            # Wait for service to be ready
            sleep 30
            
            # Test HTTP endpoint
            if curl -f "http://localhost:${PORT}" > /dev/null 2>&1; then
                echo "✅ $framework: HTTP endpoint responding"
            else
                echo "❌ $framework: HTTP endpoint not responding"
                FAILED_FRAMEWORKS+=($framework)
            fi
            
            # Cleanup
            docker stop "test-${framework}" > /dev/null 2>&1
            docker rm "test-${framework}" > /dev/null 2>&1
        else
            echo "❌ $framework: Container failed to start"
            FAILED_FRAMEWORKS+=($framework)
        fi
        
        # Remove test image
        docker rmi "soul-${framework}-test" > /dev/null 2>&1
    else
        echo "❌ $framework: Docker image build failed"
        FAILED_FRAMEWORKS+=($framework)
    fi
done

echo ""
echo "📊 Test Results Summary"
echo "======================"

if [ ${#FAILED_FRAMEWORKS[@]} -eq 0 ]; then
    echo "🎉 All frameworks passed testing!"
    exit 0
else
    echo "❌ Failed frameworks: ${FAILED_FRAMEWORKS[*]}"
    echo "📝 Check the logs above for details"
    exit 1
fi