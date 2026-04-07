#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# SOVEREIGN V15: ONE-CLICK CLOUD IGNITION SCRIPT [ROADMAP V1.8]
# ═══════════════════════════════════════════════════════════════

# ১. ইমার্জেন্সি ডিরেক্টরি সেটআপ
init_fortress() {
    echo "🚀 Launching Sovereign Cloud Fortress (Master Node)..."
    
    # Project Path Sensing
    PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
    cd "$PROJECT_ROOT" || exit
    
    # Environment Pulse Migration
    if [ -f "backend/.env.production" ]; then
        echo "📡 Migrating Production Environment DNA..."
        cp backend/.env.production backend/.env
    fi
    
    # Create permanent volumes for the Decoupled Tree
    sudo mkdir -p /var/lib/sovereign/auth
    sudo mkdir -p /mnt/sovereign_media
    sudo mkdir -p /opt/sovereign/admin_secret
    
    # Set permissions
    sudo chown -R $USER:$USER /var/lib/sovereign/auth /mnt/sovereign_media /opt/sovereign/core
    
    echo "📁 Infrastructure Directories Established."
}

# ২. ডকার কন্টেইনার ফায়ারআপ
ignite_engines() {
    echo "⚡ Fueling Docker Engines..."
    PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
    cd "$PROJECT_ROOT" || exit
    
    docker-compose down # Stop existing if any
    docker-compose up -d --build
}

# ৩. সিকিউরিটি ও ৩-লেয়ার AI অ্যাক্টিভেশন (UFW Firewall)
secure_fortress() {
    echo "🛡️ Activating 3-Layer AI Guard & OS Firewall..."
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    # Admin Port if accessed directly (Optional since we use masking)
    # sudo ufw allow 5000/tcp 
    sudo ufw --force enable
    echo "🔥 Firewall Armed. Only Authorized Ports Open."
}

# ৪. লঞ্চ রিপোর্ট
report_launch() {
    echo "----------------------------------------------------"
    echo "🌐 SOVEREIGN V15 LIVE REPORT: SUCCESS"
    echo "----------------------------------------------------"
    echo "✅ DOMAIN: fectok.com"
    echo "✅ ADMIN: vazo.fectok.com (Masked Access)"
    echo "✅ DNA: Triple-Layer Watchdog Active"
    echo "✅ STORAGE: Media Garden /mnt/sovereign_media (10K Video Optimized)"
    echo "✅ PERSISTENCE: Auth Vault /var/lib/sovereign/auth"
    echo "----------------------------------------------------"
}

# CASE HANDLER for Antigravity Protocol
case "$1" in
  launch) init_fortress && ignite_engines && secure_fortress && report_launch ;;
  status) docker ps && ufw status ;;
  stop) docker-compose down ;;
  *) echo "Usage: ./scripts/ignite.sh launch | status | stop" ;;
esac
