import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

BACKEND_IP = "172.18.0.4"

def run_cmd(ssh, cmd, timeout=15):
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        return out.read().decode(errors='replace') + err.read().decode(errors='replace')
    except:
        return "TIMEOUT"

# PURE HTML Admin Login - no Flutter dependency, works 100%
PURE_HTML_ADMIN = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>sovereign_admin</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: linear-gradient(135deg, #0a0a1a 0%, #1a0a2e 50%, #0a0a1a 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: 'Segoe UI', sans-serif;
      color: #fff;
    }
    .panel {
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(98,0,234,0.4);
      border-radius: 20px;
      padding: 40px;
      width: 360px;
      backdrop-filter: blur(10px);
      box-shadow: 0 0 40px rgba(98,0,234,0.3);
    }
    .logo {
      text-align: center;
      margin-bottom: 30px;
    }
    .logo-icon {
      font-size: 50px;
      display: block;
      margin-bottom: 10px;
    }
    h1 {
      font-size: 22px;
      color: #c084fc;
      text-align: center;
      letter-spacing: 3px;
      text-transform: uppercase;
      margin-bottom: 5px;
    }
    .version {
      text-align: center;
      font-size: 11px;
      color: #6200EA;
      letter-spacing: 2px;
      margin-bottom: 30px;
    }
    .input-group {
      margin-bottom: 15px;
    }
    label {
      display: block;
      font-size: 12px;
      color: #888;
      margin-bottom: 5px;
      letter-spacing: 1px;
    }
    input {
      width: 100%;
      padding: 12px 15px;
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(98,0,234,0.3);
      border-radius: 10px;
      color: #fff;
      font-size: 14px;
      outline: none;
      transition: border-color 0.3s;
    }
    input:focus { border-color: #6200EA; }
    .pin-label {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 12px;
      color: #888;
      margin-bottom: 8px;
    }
    .pin-display {
      letter-spacing: 8px;
      font-size: 20px;
      text-align: center;
      padding: 12px;
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(98,0,234,0.3);
      border-radius: 10px;
      min-height: 50px;
      margin-bottom: 15px;
      color: #c084fc;
    }
    .numpad {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 8px;
      margin-bottom: 15px;
    }
    .num-btn {
      padding: 15px;
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.1);
      border-radius: 10px;
      color: #fff;
      font-size: 18px;
      cursor: pointer;
      transition: all 0.2s;
      text-align: center;
    }
    .num-btn:hover { background: rgba(98,0,234,0.3); border-color: #6200EA; }
    .del-btn { background: rgba(239,68,68,0.2); border-color: rgba(239,68,68,0.3); font-size: 14px; }
    .submit-btn {
      width: 100%;
      padding: 15px;
      background: linear-gradient(135deg, #6200EA, #9c27b0);
      border: none;
      border-radius: 12px;
      color: #fff;
      font-size: 16px;
      font-weight: bold;
      cursor: pointer;
      letter-spacing: 2px;
      transition: all 0.3s;
    }
    .submit-btn:hover { transform: translateY(-2px); box-shadow: 0 5px 20px rgba(98,0,234,0.5); }
    .error { color: #ef4444; text-align: center; font-size: 13px; margin-top: 10px; display: none; }
    .loading-overlay {
      display: none;
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.8);
      align-items: center;
      justify-content: center;
      font-size: 20px;
      color: #c084fc;
    }
    .dashboard {
      display: none;
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: #0a0a1a;
      overflow-y: auto;
      padding: 20px;
    }
    .dash-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 15px 20px;
      background: rgba(98,0,234,0.1);
      border-radius: 12px;
      margin-bottom: 20px;
      border: 1px solid rgba(98,0,234,0.2);
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-bottom: 20px;
    }
    .stat-card {
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(98,0,234,0.2);
      border-radius: 12px;
      padding: 20px;
      text-align: center;
    }
    .stat-num { font-size: 32px; font-weight: bold; color: #c084fc; }
    .stat-label { font-size: 12px; color: #888; margin-top: 5px; }
    .logout-btn {
      padding: 8px 20px;
      background: rgba(239,68,68,0.2);
      border: 1px solid rgba(239,68,68,0.4);
      border-radius: 8px;
      color: #ef4444;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <div class="loading-overlay" id="loadingOverlay">Connecting to Sovereign V15...</div>

  <div id="loginPanel" class="panel">
    <div class="logo">
      <span class="logo-icon">🛡️</span>
    </div>
    <h1>CORE GOVERNANCE</h1>
    <div class="version">V15-GATEWAY-SYNC [MASTER]</div>
    <div class="version" style="color:#888; margin-bottom:25px;">SOVEREIGN V15 MASTER ACCESS</div>

    <div class="input-group">
      <label>MASTER KEY</label>
      <input type="password" id="masterKey" placeholder="Enter master key..." autocomplete="off">
    </div>

    <div class="pin-label">
      <span>SECURITY PIN</span>
      <span id="pinDisplay" style="color:#c084fc; font-size:12px;">------</span>
    </div>
    <div class="pin-display" id="pinVisual">·</div>

    <div class="numpad">
      <div class="num-btn" onclick="addPin('1')">1</div>
      <div class="num-btn" onclick="addPin('2')">2</div>
      <div class="num-btn" onclick="addPin('3')">3</div>
      <div class="num-btn" onclick="addPin('4')">4</div>
      <div class="num-btn" onclick="addPin('5')">5</div>
      <div class="num-btn" onclick="addPin('6')">6</div>
      <div class="num-btn" onclick="addPin('7')">7</div>
      <div class="num-btn" onclick="addPin('8')">8</div>
      <div class="num-btn" onclick="addPin('9')">9</div>
      <div class="num-btn" onclick="addPin('0')">0</div>
      <div class="num-btn del-btn" onclick="delPin()">⌫</div>
      <div class="num-btn" onclick="clearPin()" style="font-size:11px;">CLR</div>
    </div>

    <button class="submit-btn" onclick="doLogin()">⚡ INITIALIZE HANDSHAKE</button>
    <div class="error" id="errorMsg"></div>
  </div>

  <div class="dashboard" id="dashboard">
    <div class="dash-header">
      <div>
        <div style="font-size:18px; font-weight:bold; color:#c084fc;">🛡️ SOVEREIGN ADMIN V15</div>
        <div style="font-size:12px; color:#888;" id="adminEmail"></div>
      </div>
      <button class="logout-btn" onclick="doLogout()">LOGOUT</button>
    </div>
    <div class="stats-grid" id="statsGrid">
      <div class="stat-card"><div class="stat-num" id="totalUsers">-</div><div class="stat-label">TOTAL USERS</div></div>
      <div class="stat-card"><div class="stat-num" id="totalVideos">-</div><div class="stat-label">TOTAL VIDEOS</div></div>
      <div class="stat-card"><div class="stat-num" id="totalRevenue">-</div><div class="stat-label">TOTAL REVENUE</div></div>
      <div class="stat-card"><div class="stat-num" id="activeUsers">-</div><div class="stat-label">ACTIVE TODAY</div></div>
    </div>
    <div style="text-align:center; color:#888; padding:20px;">More dashboard features loading from backend...</div>
  </div>

  <script>
    var pin = "";
    var token = "";

    function addPin(d) {
      if (pin.length < 6) {
        pin += d;
        updatePinDisplay();
      }
    }
    function delPin() {
      pin = pin.slice(0, -1);
      updatePinDisplay();
    }
    function clearPin() {
      pin = "";
      updatePinDisplay();
    }
    function updatePinDisplay() {
      var dots = "";
      for (var i = 0; i < pin.length; i++) dots += "● ";
      document.getElementById("pinDisplay").textContent = pin.length === 0 ? "·" : dots;
      document.getElementById("pinVisual").textContent = pin.length === 0 ? "·" : dots;
    }

    async function doLogin() {
      var masterKey = document.getElementById("masterKey").value;
      var errorEl = document.getElementById("errorMsg");
      errorEl.style.display = "none";

      if (!masterKey || pin.length < 4) {
        errorEl.textContent = "Master key and PIN required";
        errorEl.style.display = "block";
        return;
      }

      document.getElementById("loadingOverlay").style.display = "flex";

      try {
        var resp = await fetch("/api/admin/login", {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({master_key: masterKey, pin: pin})
        });
        var data = await resp.json();

        if (resp.ok && data.token) {
          token = data.token;
          localStorage.setItem("admin_token", token);
          showDashboard(data);
        } else {
          errorEl.textContent = data.detail || data.message || "Access Denied";
          errorEl.style.display = "block";
        }
      } catch(e) {
        errorEl.textContent = "Neural Link Error: " + e.message;
        errorEl.style.display = "block";
      }
      document.getElementById("loadingOverlay").style.display = "none";
    }

    function showDashboard(data) {
      document.getElementById("loginPanel").style.display = "none";
      document.getElementById("dashboard").style.display = "block";
      if (data.admin_email) document.getElementById("adminEmail").textContent = data.admin_email;
      loadStats();
    }

    async function loadStats() {
      try {
        var resp = await fetch("/api/admin/stats", {
          headers: {"Authorization": "Bearer " + token}
        });
        var data = await resp.json();
        if (data.total_users !== undefined) document.getElementById("totalUsers").textContent = data.total_users;
        if (data.total_videos !== undefined) document.getElementById("totalVideos").textContent = data.total_videos;
        if (data.total_revenue !== undefined) document.getElementById("totalRevenue").textContent = "$" + data.total_revenue;
        if (data.active_today !== undefined) document.getElementById("activeUsers").textContent = data.active_today;
      } catch(e) {
        console.log("Stats load error:", e);
      }
    }

    function doLogout() {
      token = "";
      localStorage.removeItem("admin_token");
      location.reload();
    }

    // Check existing token on load
    window.onload = function() {
      var saved = localStorage.getItem("admin_token");
      if (saved) {
        token = saved;
        // Verify token
        fetch("/api/admin/verify", {
          headers: {"Authorization": "Bearer " + token}
        }).then(r => r.json()).then(data => {
          if (data.valid) showDashboard(data);
          else localStorage.removeItem("admin_token");
        }).catch(() => localStorage.removeItem("admin_token"));
      }
    };
  </script>
</body>
</html>
'''

def deploy_pure_admin():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== Deploying Pure HTML Admin Panel (no Flutter dependency) ===")
    sftp = ssh.open_sftp()
    with sftp.file("/root/sovereign/webadmin_panel/index.html", "w") as f:
        f.write(PURE_HTML_ADMIN)
    sftp.close()
    print("Deployed!")
    
    print("=== Verify in container ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway head -5 /usr/share/nginx/html/admin/index.html"))
    
    print("=== nginx reload ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway nginx -s reload"))
    
    print("=== curl test ===")
    result = run_cmd(ssh, "curl -s 'http://localhost/' -H 'Host: vazo.fectok.com' | head -10", timeout=10)
    print(result)
    
    ssh.close()
    print("\n✅ Pure HTML admin panel deployed! vazo.fectok.com should now show the admin login.")

if __name__ == "__main__":
    deploy_pure_admin()

