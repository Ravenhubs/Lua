<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Luacore System</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Arial', sans-serif;
            background: url('https://images.unsplash.com/photo-1501785888041-af3ef285b470?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80') no-repeat center center fixed;
            background-size: cover;
            color: #fff;
            overflow-x: hidden;
        }
        .container {
            max-width: 350px;
            margin: 20px auto;
            background: rgba(13, 13, 29, 0.9);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.5);
        }
        .header {
            text-align: center;
            padding: 10px;
            background: #0a0a14;
            border-radius: 12px 12px 0 0;
            font-size: 20px;
            font-weight: bold;
        }
        .progress {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px;
            background: #1a1a2e;
            border-radius: 6px;
        }
        .progress-text {
            font-size: 14px;
            color: #c0c0c0;
        }
        .progress-bar {
            width: 30%;
            height: 8px;
            background: #323232;
            border-radius: 4px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            width: 0%;
            background: #00cc00;
            transition: width 0.5s ease;
        }
        .start-btn {
            padding: 5px 15px;
            background: #64a64a;
            border: none;
            border-radius: 6px;
            color: #fff;
            cursor: pointer;
            font-weight: bold;
        }
        .start-btn:disabled {
            background: #666;
            cursor: not-allowed;
        }
        .table-header {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 1fr;
            gap: 5px;
            padding: 10px;
            background: #14142a;
            border-radius: 6px;
            margin-top: 10px;
        }
        .table-header div {
            font-size: 12px;
            color: #c0c0c0;
            text-align: center;
        }
        .key-row {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 1fr;
            gap: 5px;
            padding: 10px;
            background: #1a1a2e;
            border-radius: 6px;
            margin-top: 5px;
        }
        .key-row div {
            font-size: 12px;
            text-align: center;
        }
        .key-text {
            color: #999;
        }
        .time-text, .status-text {
            color: #f00;
        }
        .renew-btn {
            padding: 5px 10px;
            background: #0077cc;
            border: none;
            border-radius: 4px;
            color: #fff;
            cursor: pointer;
        }
        .renew-btn:disabled {
            background: #666;
            cursor: not-allowed;
        }
        .get-new-key {
            display: block;
            width: 100%;
            padding: 10px;
            margin-top: 15px;
            background: #0066cc;
            border: none;
            border-radius: 8px;
            color: #fff;
            font-weight: bold;
            cursor: pointer;
        }
        .get-new-key:disabled {
            background: #666;
            cursor: not-allowed;
        }
        .key-display {
            margin-top: 15px;
            padding: 10px;
            background: #1e1e3a;
            border-radius: 8px;
            text-align: center;
            word-break: break-all;
        }
        .copy-btn {
            padding: 5px 10px;
            background: #ff9500;
            border: none;
            border-radius: 4px;
            color: #fff;
            cursor: pointer;
            margin-left: 10px;
        }
        .ip-log {
            font-size: 10px;
            color: #ccc;
            text-align: center;
            margin-top: 5px;
        }
        .points-display {
            margin-top: 10px;
            padding: 5px;
            background: #1e1e3a;
            border-radius: 6px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">Luacore</div>
        <div class="progress">
            <span class="progress-text">Progress: <span id="progress-count">0/1</span></span>
            <div class="progress-bar">
                <div class="progress-fill" id="progress-fill"></div>
            </div>
            <button class="start-btn" id="start-btn">START</button>
        </div>
        <div class="table-header">
            <div>YOUR KEYS</div>
            <div>TIME LEFT</div>
            <div>STATUS</div>
            <div>ACTIONS</div>
        </div>
        <div class="key-row">
            <div class="key-text" id="key-text">No Key</div>
            <div class="time-text" id="time-text">Expired</div>
            <div class="status-text" id="status-text">Inactive</div>
            <button class="renew-btn" id="renew-btn" disabled>Renew</button>
        </div>
        <div id="key-display" class="key-display" style="display: none;">
            Your Key: <span id="key-value"></span>
            <button class="copy-btn" id="copy-btn">Copy</button>
        </div>
        <button class="get-new-key" id="get-new-key" disabled>+ GET A NEW KEY</button>
        <div class="ip-log" id="ip-log">Loading IP...</div>
        <div class="points-display" id="points-display" style="display: none;">
            Points: <span id="points-value">0</span>
        </div>
    </div>

    <script>
        console.log('Script loaded at:', new Date().toLocaleString('en-US', { timeZone: 'America/Los_Angeles' }));
        const baseUrl = window.location.origin + window.location.pathname;
        let currentKey = localStorage.getItem('currentKey') || "";
        let expiresAt = parseInt(localStorage.getItem('expiresAt')) || 0;
        let storedIp = localStorage.getItem('storedIp') || "";
        let points = parseInt(localStorage.getItem('userPoints') || '0');
        const keyDuration = 24 * 60 * 60 * 1000; // 24 hours in ms

        // Fetch IP using public API with error handling
        async function getIp() {
            try {
                console.log('Fetching IP...');
                const response = await fetch('https://api.ipify.org?format=json');
                if (!response.ok) throw new Error('Fetch failed');
                const data = await response.json();
                console.log('IP fetched:', data.ip);
                return data.ip;
            } catch (error) {
                console.error('Error fetching IP:', error);
                return 'unknown'; // Fallback
            }
        }

        // Update UI
        function updateUI(valid) {
            const progressCount = document.getElementById("progress-count");
            const progressFill = document.getElementById("progress-fill");
            const startBtn = document.getElementById("start-btn");
            const keyText = document.getElementById("key-text");
            const timeText = document.getElementById("time-text");
            const statusText = document.getElementById("status-text");
            const renewBtn = document.getElementById("renew-btn");
            const getNewKeyBtn = document.getElementById("get-new-key");
            const keyDisplay = document.getElementById("key-display");
            const keyValue = document.getElementById("key-value");
            const copyBtn = document.getElementById("copy-btn");
            const pointsDisplay = document.getElementById("points-display");
            const pointsValue = document.getElementById("points-value");

            if (valid) {
                progressCount.textContent = "1/1";
                progressFill.style.width = "100%";
                startBtn.disabled = false;
                keyText.textContent = currentKey.substring(0, 8) + "...";
                const timeLeftMs = expiresAt - Date.now();
                const hoursLeft = Math.max(0, Math.floor(timeLeftMs / (60 * 60 * 1000)));
                timeText.textContent = hoursLeft + "h";
                timeText.style.color = hoursLeft > 0 ? "#0f0" : "#f00";
                statusText.textContent = "Active";
                statusText.style.color = "#0f0";
                renewBtn.disabled = hoursLeft > 0;
                getNewKeyBtn.disabled = false;
                keyDisplay.style.display = "block";
                keyValue.textContent = currentKey;
                copyBtn.style.display = "inline-block";
                copyBtn.onclick = copyToClipboard;
                pointsDisplay.style.display = "block";
                pointsValue.textContent = points;
            } else {
                progressCount.textContent = "0/1";
                progressFill.style.width = "0%";
                startBtn.disabled = false;
                keyText.textContent = "No Key";
                timeText.textContent = "Expired";
                timeText.style.color = "#f00";
                statusText.textContent = "Inactive";
                statusText.style.color = "#ccc";
                renewBtn.disabled = true;
                getNewKeyBtn.disabled = true;
                keyDisplay.style.display = "none";
                copyBtn.style.display = "none";
                pointsDisplay.style.display = "none";
            }
        }

        function copyToClipboard() {
            navigator.clipboard.writeText(currentKey).then(() => {
                alert("Key copied to clipboard!");
            }).catch(err => {
                console.error('Copy failed:', err);
                alert('Copy failed - please copy manually');
            });
        }

        // Log IP to console and store
        async function logAndStoreIp() {
            const ip = await getIp();
            console.log('User IP logged:', ip);
            localStorage.setItem('storedIp', ip);
            document.getElementById("ip-log").textContent = `IP Logged: ${ip}`;
            return ip;
        }

        // Process points and generate key
        async function processPointsAndGenerateKey() {
            const currentIp = await getIp();
            const stored = localStorage.getItem('storedIp');
            console.log('Verifying IP:', currentIp, 'vs stored:', stored);
            if (currentIp === stored || stored === 'unknown') {
                points += 10; // Award 10 points per completion
                localStorage.setItem('userPoints', points);
                currentKey = 'luacore_' + Math.random().toString(36).substring(2, 18); // 16 random chars
                expiresAt = Date.now() + keyDuration; // Expires 06:32 PM PST, Sep 15, 2025
                localStorage.setItem('currentKey', currentKey);
                localStorage.setItem('expiresAt', expiresAt);
                console.log(`Points: ${points}, Key generated: ${currentKey} for IP: ${currentIp}`);
                updateUI(true);
            } else {
                alert('IP mismatch. Completion not verified. Try without VPN.');
                console.log('IP mismatch detected');
            }
        }

        // Check for process-points on load
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('process-points')) {
            console.log('Processing points and key generation...');
            processPointsAndGenerateKey();
            history.replaceState(null, null, baseUrl); // Remove query param from URL
        }

        // Initial load: Log IP
        logAndStoreIp().then(() => console.log('Initial IP logged'));

        // Initial UI update
        const isValid = currentKey && expiresAt > Date.now();
        updateUI(isValid);
        console.log('Initial UI updated, isValid:', isValid);

        // Event Listeners
        document.getElementById("start-btn").addEventListener("click", () => {
            console.log('START button clicked - generating dynamic Linkvertise URL');
            const randomId = Date.now() + Math.random().toString(36).substring(7);
            const linkvertiseUrl = `https://linkvertise.com/1397349/YuP3yQMbCrxd?o=sharing&rand=${randomId}&destination=${encodeURIComponent(baseUrl + '?process-points')}`;
            window.location.href = linkvertiseUrl;
        });

        document.getElementById("get-new-key").addEventListener("click", () => {
            console.log('GET NEW KEY clicked - resetting and redirecting');
            localStorage.removeItem('currentKey');
            localStorage.removeItem('expiresAt');
            localStorage.removeItem('storedIp');
            localStorage.removeItem('userPoints');
            currentKey = "";
            expiresAt = 0;
            points = 0;
            updateUI(false);
            const randomId = Date.now() + Math.random().toString(36).substring(7);
            const linkvertiseUrl = `https://linkvertise.com/1397349/YuP3yQMbCrxd?o=sharing&rand=${randomId}&destination=${encodeURIComponent(baseUrl + '?process-points')}`;
            window.location.href = linkvertiseUrl;
        });

        document.getElementById("renew-btn").addEventListener("click", () => {
            console.log('RENEW clicked - resetting and redirecting');
            localStorage.removeItem('currentKey');
            localStorage.removeItem('expiresAt');
            localStorage.removeItem('storedIp');
            localStorage.removeItem('userPoints');
            currentKey = "";
            expiresAt = 0;
            points = 0;
            updateUI(false);
            const randomId = Date.now() + Math.random().toString(36).substring(7);
            const linkvertiseUrl = `https://linkvertise.com/1397349/YuP3yQMbCrxd?o=sharing&rand=${randomId}&destination=${encodeURIComponent(baseUrl + '?process-points')}`;
            window.location.href = linkvertiseUrl;
        });

        // Update time every minute
        setInterval(() => {
            const isValid = currentKey && expiresAt > Date.now();
            updateUI(isValid);
            console.log('Timer tick, isValid:', isValid);
        }, 60000);
    </script>
</body>
</html>
