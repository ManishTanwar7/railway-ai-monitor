/**
 * Railway AI Monitoring - Dashboard Interactivity & Dynamic Data Engine
 */

// Toast notification system
function showToast(message, type = 'info') {
  let toastContainer = document.getElementById('toast-container');
  if (!toastContainer) {
    toastContainer = document.createElement('div');
    toastContainer.id = 'toast-container';
    toastContainer.className = 'fixed bottom-6 right-6 z-50 flex flex-col space-y-3 pointer-events-none';
    document.body.appendChild(toastContainer);
  }

  const toast = document.createElement('div');
  toast.className = `pointer-events-auto transform transition-all duration-300 translate-y-4 opacity-0 flex items-center px-4 py-3 rounded-lg shadow-lg border text-sm max-w-md ${
    type === 'success' 
      ? 'bg-emerald-50 border-emerald-300 text-emerald-800' 
      : type === 'warning'
      ? 'bg-amber-50 border-amber-300 text-amber-800'
      : type === 'danger'
      ? 'bg-rose-50 border-rose-300 text-rose-800'
      : 'bg-blue-50 border-blue-300 text-blue-900'
  }`;

  const icon = type === 'success' ? 'fa-circle-check text-emerald-600' :
               type === 'warning' ? 'fa-triangle-exclamation text-amber-600' :
               type === 'danger' ? 'fa-circle-exclamation text-rose-600' : 'fa-circle-info text-blue-600';

  toast.innerHTML = `
    <i class="fa-solid ${icon} mr-3 text-lg"></i>
    <div class="flex-1 font-medium">${message}</div>
    <button class="ml-3 text-slate-400 hover:text-slate-700" onclick="this.parentElement.remove()">
      <i class="fa-solid fa-xmark"></i>
    </button>
  `;

  toastContainer.appendChild(toast);

  // Animate in
  setTimeout(() => {
    toast.classList.remove('translate-y-4', 'opacity-0');
  }, 10);

  // Auto dismiss
  setTimeout(() => {
    toast.classList.add('opacity-0', 'translate-y-2');
    setTimeout(() => toast.remove(), 350);
  }, 4500);
}

// REST API fetcher
async function fetchDataset(name) {
  try {
    const response = await fetch(`/api/data/${name}`);
    if (!response.ok) throw new Error(`HTTP error ${response.status}`);
    return await response.json();
  } catch (err) {
    console.error(`Failed to fetch dataset ${name}:`, err);
    showToast(`Failed to load ${name} dataset: ${err.message}`, 'danger');
    return null;
  }
}

// Signal Override Action (Station Master & Admin)
async function overrideSignalAspect(signalId, newAspect) {
  try {
    const response = await fetch('/api/override/signal', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ signal_id: signalId, new_aspect: newAspect })
    });
    const result = await response.json();
    if (response.ok) {
      showToast(`Signal ${signalId} aspect changed to ${newAspect} (Manual Override engaged).`, 'warning');
      
      // Update badge if element exists
      const badge = document.getElementById(`signal-badge-${signalId}`);
      if (badge) {
        badge.textContent = newAspect;
        badge.className = `px-2 py-0.5 rounded text-[10px] font-bold ${
          newAspect === 'GREEN' ? 'badge-ontime' :
          newAspect === 'RED' ? 'badge-halt' :
          'badge-delayed'
        }`;
      }
      const stateSpan = document.getElementById(`signal-state-${signalId}`);
      if (stateSpan) {
        stateSpan.textContent = 'MANUAL_STATION_OVERRIDE';
        stateSpan.classList.add('text-orange-600');
      }
    } else {
      showToast(`Failed to override signal: ${result.detail || 'Access denied'}`, 'danger');
    }
  } catch (err) {
    showToast(`Network error overriding signal: ${err.message}`, 'danger');
  }
}

// Boss AI Parameter Calibration (Admin)
async function updateAiParameter(paramKey, value) {
  try {
    const response = await fetch('/api/override/ai-parameter', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ parameter: paramKey, value: parseFloat(value) })
    });
    const result = await response.json();
    if (response.ok) {
      showToast(`Boss AI updated ${paramKey} to ${value}. Equilibrium recomputed.`, 'success');
      const valDisplay = document.getElementById(`val-${paramKey}`);
      if (valDisplay) valDisplay.textContent = value;
    } else {
      showToast(`Failed to update parameter: ${result.detail}`, 'danger');
    }
  } catch (err) {
    showToast(`Error updating parameter: ${err.message}`, 'danger');
  }
}

// Employee Diagnostics Trigger (Employee)
async function triggerDiagnostic(moduleName) {
  showToast(`Initiating deep diagnostic on [${moduleName}]...`, 'info');
  const btn = event.currentTarget;
  if (btn) btn.disabled = true;

  try {
    const response = await fetch('/api/employee/action', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'DIAGNOSTIC_TEST', module: moduleName })
    });
    const result = await response.json();
    if (response.ok) {
      setTimeout(() => {
        showToast(`Diagnostic Complete: ${result.report}. System integrity: ${result.integrity}%`, 'success');
        if (btn) btn.disabled = false;
        
        // Append to logs table if exists
        const logTable = document.getElementById('employee-diagnostic-logs');
        if (logTable) {
          const row = document.createElement('tr');
          row.innerHTML = `
            <td class="font-mono text-slate-500 text-xs">${new Date().toLocaleTimeString()}</td>
            <td class="font-semibold text-slate-900 text-xs">${moduleName}</td>
            <td><span class="px-2 py-0.5 rounded badge-ontime text-[10px] font-bold">PASSED</span></td>
            <td class="text-slate-600 text-xs">${result.report}</td>
          `;
          logTable.insertBefore(row, logTable.firstChild);
        }
      }, 700);
    } else {
      showToast(`Diagnostic failed: ${result.detail}`, 'danger');
      if (btn) btn.disabled = false;
    }
  } catch (err) {
    showToast(`Diagnostic failed: ${err.message}`, 'danger');
    if (btn) btn.disabled = false;
  }
}

// Live Simulated Train Tracker (Real-time movement updates)
let isLiveModeActive = true;
let liveIntervalId = null;

function toggleLiveSimulation() {
  const toggleBtn = document.getElementById('live-toggle-btn');
  isLiveModeActive = !isLiveModeActive;

  if (isLiveModeActive) {
    if (toggleBtn) {
      toggleBtn.innerHTML = `<i class="fa-solid fa-satellite-dish text-xs animate-pulse"></i> <span>LIVE TRACKING: ACTIVE</span>`;
      toggleBtn.className = 'px-3 py-2 rounded-md text-xs font-semibold bg-emerald-700 hover:bg-emerald-600 text-white transition flex items-center space-x-1.5 shadow-sm';
    }
    showToast('Live telemetry polling engaged (3s cycle).', 'success');
    startPolling();
  } else {
    if (toggleBtn) {
      toggleBtn.innerHTML = `<i class="fa-solid fa-pause text-xs"></i> <span>LIVE TRACKING: PAUSED</span>`;
      toggleBtn.className = 'px-3 py-2 rounded-md text-xs font-semibold bg-amber-600 hover:bg-amber-500 text-white transition flex items-center space-x-1.5 shadow-sm';
    }
    showToast('Live telemetry polling paused.', 'warning');
    if (liveIntervalId) clearInterval(liveIntervalId);
  }
}

async function refreshLiveTrainTelemetry() {
  try {
    const res = await fetch('/api/trains/live');
    if (!res.ok) return;
    const trains = await res.json();
    
    // Update live indicators on tables/cards if present
    trains.forEach(train => {
      const speedElem = document.getElementById(`train-speed-${train.train_id}`);
      if (speedElem) {
        speedElem.textContent = `${train.speed_kmh.toFixed(1)} km/h`;
      }
      const etaElem = document.getElementById(`train-eta-${train.train_id}`);
      if (etaElem) {
        etaElem.textContent = `${train.eta_next_station_min.toFixed(1)}m`;
      }
      const distElem = document.getElementById(`train-dist-${train.train_id}`);
      if (distElem) {
        distElem.textContent = `${train.distance_to_next_km.toFixed(1)} km`;
      }
    });

    const clockElem = document.getElementById('telemetry-sync-clock');
    if (clockElem) {
      clockElem.textContent = `SYNC: ${new Date().toLocaleTimeString()}`;
    }
  } catch (err) {
    console.debug('Telemetry sync skipped:', err);
  }
}

function startPolling() {
  if (liveIntervalId) clearInterval(liveIntervalId);
  liveIntervalId = setInterval(() => {
    if (isLiveModeActive) {
      refreshLiveTrainTelemetry();
    }
  }, 3000);
}

// Station Master Emergency Halt Trigger
async function triggerEmergencyAllStop() {
  const confirmHalt = confirm("WARNING: Triggering Emergency Interlocking Halt will switch all signals to RED and freeze autonomous dispatching. Proceed?");
  if (!confirmHalt) return;

  try {
    const response = await fetch('/api/override/emergency-halt', { method: 'POST' });
    const res = await response.json();
    showToast('EMERGENCY INTERLOCKING ACTIVE: ALL SIGNALS RED. TRAINS HALTED.', 'danger');
    setTimeout(() => window.location.reload(), 1500);
  } catch (err) {
    showToast(`Halt command failed: ${err.message}`, 'danger');
  }
}

// Passenger Train Filter
function filterPassengerTrains(searchQuery) {
  const query = searchQuery.toLowerCase();
  const rows = document.querySelectorAll('.passenger-train-card');
  let matchedCount = 0;

  rows.forEach(card => {
    const text = card.textContent.toLowerCase();
    if (text.includes(query)) {
      card.style.display = 'block';
      matchedCount++;
    } else {
      card.style.display = 'none';
    }
  });

  const countDisplay = document.getElementById('search-result-count');
  if (countDisplay) {
    countDisplay.textContent = `Showing ${matchedCount} scheduled train(s)`;
  }
}

// Initialize live polling if on dashboard
document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('live-toggle-btn')) {
    startPolling();
  }
});
