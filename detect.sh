#!/usr/bin/env sh
echo "=== Mini Shai-Hulud check ==="

echo "[1] Compromised packages in the lockfile..."
grep -cE "echarts-for-react|size-sensor|timeago\.js|@tanstack/setup|@antv/setup" \
  package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null

echo "[2] Preinstall hooks in node_modules..."
grep -r '"preinstall".*bun run' node_modules/*/package.json 2>/dev/null && \
  echo "ALERT: found!" || echo "OK"

echo "[3] Malicious GitHub SHA among optional deps..."
grep -r "1916faa365f2788b6e193514872d51a242876569\|7cb42f57561c321ecb09b4552802ae0ac55b3a7a" \
  node_modules/ 2>/dev/null && echo "ALERT: FOUND!" || echo "OK"

echo "[4] kitty-monitor persistence..."
(systemctl --user is-active kitty-monitor 2>/dev/null | grep -q inactive && \
  echo "OK" || "ALERT: kitty-monitor is running!")

echo "[5] Claude Code/VS Code hooks..."
find ~/.claude ~/.vscode -name "*.json" 2>/dev/null | \
  xargs grep -l "SessionStart\|firedalazer" 2>/dev/null && \
  echo "ALERT: hook found!" || echo "OK"

echo "=== Done ==="
