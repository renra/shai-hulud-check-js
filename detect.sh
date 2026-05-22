#!/usr/bin/env sh
echo "=== Mini Shai-Hulud check ==="

echo "[1] Potentially compromised packages in the lockfile..."
grep -nE "echarts-for-react|size-sensor|timeago\.js|@tanstack/setup|@antv/setup" \
  package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null

echo "[2] Preinstall hooks in node_modules..."
find node_modules -maxdepth 2 -name "package.json" | xargs grep -l '"preinstall"' 2>/dev/null | \
  xargs grep -l 'bun run' 2>/dev/null && echo "ALERT: found!" || echo "OK"

echo "[3] Malicious GitHub SHA among optional deps..."
grep -r "1916faa365f2788b6e193514872d51a242876569\|7cb42f57561c321ecb09b4552802ae0ac55b3a7a" \
  node_modules/ 2>/dev/null && echo "ALERT: found!" || echo "OK"

echo "[4] kitty-monitor persistence..."
(systemctl --user is-active kitty-monitor 2>/dev/null | grep -q inactive && \
  echo "OK" || echo "ALERT: kitty-monitor is running!")

echo "[5] Claude Code/VS Code hooks..."
find ~/.claude ~/.vscode -name "*.json" 2>/dev/null | \
  xargs grep -l "SessionStart\|firedalazer" 2>/dev/null && \
  echo "ALERT: hook found!" || echo "OK"

echo "[6] Checking @tanstack ..."
find node_modules/@tanstack -name "package.json" | \
  xargs grep -l "voicproducoes\|79ac49eedf" 2>/dev/null &&
  echo "ALERT: vulnerable version of tanstack found!" || echo "OK"


echo "[7] Checking for router_init.js..."
found=0
find . -name "router_init.js" | while read f; do
  hash=$(shasum -a 256 "$f" | cut -d' ' -f1)
  if [ "$hash" = "ab4fcadaec49c03278063dd269ea5eef82d24f2124a8e15d7b90f2fa8601266c" ]; then
    echo "ALERT: malicious router_init.js found at $f"
    found=1
  fi
done
[ "$found" = "0" ] && echo "OK"



echo "=== Done ==="
