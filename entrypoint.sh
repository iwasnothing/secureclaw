#!/bin/bash
set -e

# 1. Inject Proxy Support
export NODE_PATH=/usr/lib/node_modules:/usr/local/lib/node_modules
if [ -f /root/proxy-inject.js ]; then
  export NODE_OPTIONS="--require /root/proxy-inject.js --dns-result-order=ipv4first"
else
  export NODE_OPTIONS="--dns-result-order=ipv4first"
fi

# 2. Setup Aider Alias
# [FIX] Removed leading slash and extra '/' after openai
echo "alias aider='aider --model openai/models/Qwen/Qwen3-30B-A3B-Instruct-FP8'" >> /root/.bashrc

# 3. Hardening
echo "🔒 Hardening OpenClaw configuration..."
openclaw config set plugins.telegram.enabled false || true
openclaw config set telegram.enabled false || true
openclaw config set telemetry.enabled false || true
openclaw config set updates.check false || true

# 4. Configure Provider
# [FIX] Removed leading slash from ID
MODEL_ID="qwen-30b"
openclaw config set gateway.mode local || true

openclaw config set models.providers.litellm-sidecar "{
  \"baseUrl\": \"http://litellm:4000/v1\",
  \"api\": \"openai\",
  \"apiKey\": \"sk-1234\",
  \"models\": [{
    \"id\": \"$MODEL_ID\",
    \"name\": \"Qwen3-30B\",
    \"reasoning\": false,
    \"contextWindow\": 32768
  }]
}" || true

# 5. Set Default Model
# [FIX] Now 'litellm-sidecar//models/...' produces a clean double-slash
openclaw config set agents.defaults.model "{\"primary\": \"litellm-sidecar//$MODEL_ID\"}" || true
openclaw config set agents.defaults.sandbox.mode "off" || true

# 6. Fix Permissions
openclaw config set tools.deny '["group:web", "browser"]'
chmod 700 /root/.openclaw/credentials
openclaw doctor --fix || true

# 7. Start Gateway
echo "🚀 Enclave Ready. Model: $MODEL_ID"
openclaw gateway --port 18789 &

tail -f /dev/null
