# Taiga Time Tracker Desktop App - Technical Specification

**Qt-based System Tray Application for Ubuntu/Linux**

---

## Executive Summary

A lightweight Qt desktop application that integrates Taiga project management with InvoiceNinja billing through seamless time tracking. The app runs in the system tray, allows one-click time tracking on Taiga tasks, and automatically syncs billable hours to InvoiceNinja for invoicing.

**Key Value Proposition:**
- ✅ Start/stop timer from system tray (one-click workflow)
- ✅ Automatic sync with Taiga tasks
- ✅ Real-time billable hours tracking
- ✅ Automatic invoice generation
- ✅ Offline capability with sync queue
- ✅ Cross-platform (Linux, Windows, macOS)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Desktop Application                   │
│                     (Qt/C++ or PyQt)                     │
├─────────────────────────────────────────────────────────┤
│  System Tray UI  │  Timer Engine  │  Sync Manager      │
│  - Quick Actions │  - Start/Stop  │  - Task Sync       │
│  - Task List     │  - Idle Track  │  - Time Entries    │
│  - Reports       │  - Manual Edit │  - Offline Queue   │
└──────────┬──────────────┬─────────────────┬────────────┘
           │              │                 │
           v              v                 v
    ┌──────────┐   ┌──────────┐    ┌──────────────┐
    │  Taiga   │   │ SQLite   │    │ InvoiceNinja │
    │   API    │   │  Local   │    │     API      │
    │ (Tasks)  │   │   DB     │    │  (Invoices)  │
    └──────────┘   └──────────┘    └──────────────┘
```

---

## Technology Stack

### Recommended: **PyQt6 + Python**

**Advantages:**
- ✅ Rapid development (2-3 weeks vs 6-8 weeks for C++/Qt)
- ✅ Easy API integration with `requests` library
- ✅ Rich Qt bindings (full Qt6 features)
- ✅ Cross-platform packaging (PyInstaller)
- ✅ Native system tray support
- ✅ Easy maintenance and updates
- ✅ Python ecosystem (pandas for reports, sqlite3 for DB)

**Alternative: C++/Qt6**
- Better performance
- Smaller binary size
- More complex development
- Longer development time

### Core Libraries

```python
# requirements.txt
PyQt6==6.6.0
PyQt6-Qt6==6.6.0
requests==2.31.0
python-dotenv==1.0.0
keyring==24.3.0  # Secure credential storage
pydantic==2.5.0  # Configuration validation
schedule==1.2.0  # Background sync scheduling
```

---

## Feature Specification

### 1. System Tray Interface

#### 1.1 Tray Icon States

```
🔴 Timer Running (red icon)
⚪ Timer Stopped (white icon)
🟡 Syncing (yellow icon pulsing)
⚠️  Error/Offline (warning icon)
```

#### 1.2 Tray Menu Structure

```
┌─────────────────────────────────────────┐
│ 🏷️  Current Task: Feature #123         │
│     ⏱️  01:23:45                        │
├─────────────────────────────────────────┤
│ ▶️  Start Timer                         │
│ ⏸️  Pause Timer                         │
│ ⏹️  Stop & Save                         │
├─────────────────────────────────────────┤
│ 📋 Quick Start                          │
│    → Bug #456: Fix login issue         │
│    → Task #789: Update documentation   │
│    → Story #101: Payment gateway       │
├─────────────────────────────────────────┤
│ 📊 Today's Summary                      │
│    → 6h 32m tracked                     │
│    → 5h 15m billable                    │
│    → $393.75 earned                     │
├─────────────────────────────────────────┤
│ ⚙️  Settings                            │
│ 📈 Reports                              │
│ 🔄 Sync Now                             │
│ ❌ Quit                                 │
└─────────────────────────────────────────┘
```

### 2. Main Window (Hidden by default, shown on demand)

#### 2.1 Dashboard Tab
```
┌────────────────────────────────────────────────────────┐
│ 🏠 Dashboard                    👤 User: John Developer │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Current Activity                                       │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 🟢 Timer Active                                   │ │
│  │ Task #123: Implement payment gateway              │ │
│  │ Project: E-Commerce Platform                      │ │
│  │                                                    │ │
│  │        [⏸️  Pause]     [⏹️  Stop & Save]          │ │
│  │                                                    │ │
│  │ Duration: 01:23:45    Billable: Yes    $75/hr    │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  Today's Stats              This Week                  │
│  ┌─────────────────┐       ┌─────────────────┐       │
│  │ ⏱️  6h 32m      │       │ ⏱️  32h 15m     │       │
│  │ 💰 $489.00     │       │ 💰 $2,418.75   │       │
│  │ 📋 8 tasks     │       │ 📋 42 tasks    │       │
│  └─────────────────┘       └─────────────────┘       │
│                                                         │
│  Recent Activity                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Task #789  Documentation Update    2h 15m  Done  │ │
│  │ Bug #456   Fix login redirect      0h 45m  Done  │ │
│  │ Task #123  Payment gateway         1h 23m  Active│ │
│  └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

#### 2.2 Tasks Tab
```
┌────────────────────────────────────────────────────────┐
│ 📋 Tasks                      🔍 [Search...] [Refresh] │
├────────────────────────────────────────────────────────┤
│                                                         │
│ Filter: [All Projects ▼] [Status: All ▼] [Billable ✓]│
│                                                         │
│ ┌──────────────────────────────────────────────────┐  │
│ │ #  Task                    Project      Time   ⚡│  │
│ ├──────────────────────────────────────────────────┤  │
│ │123 Payment gateway impl.   E-Commerce  01:23  ▶️│  │
│ │456 Fix login redirect      Website     02:15  ⏹️│  │
│ │789 Update documentation    Internal    00:45  ⏹️│  │
│ │101 Database optimization   Backend     --:--  ▶️│  │
│ │202 Design review meeting   Marketing   --:--  ▶️│  │
│ └──────────────────────────────────────────────────┘  │
│                                                         │
│ [➕ Sync New Tasks]                                    │
└────────────────────────────────────────────────────────┘
```

#### 2.3 Reports Tab
```
┌────────────────────────────────────────────────────────┐
│ 📊 Reports                Period: [This Week ▼]  [📥] │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Billable Hours Summary                                │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Client          Hours    Rate    Amount    Status│ │
│  ├──────────────────────────────────────────────────┤ │
│  │ Acme Corp       24.5h    $75    $1,837.50   ✓   │ │
│  │ Beta Inc        8.25h    $85    $701.25     ✓   │ │
│  │ Gamma LLC       5.50h    $95    $522.50     ⏳  │ │
│  ├──────────────────────────────────────────────────┤ │
│  │ Total          38.25h            $3,061.25       │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  Daily Breakdown                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │        Mon   Tue   Wed   Thu   Fri   Total      │ │
│  │ Hours  6.5   8.2   7.8   9.0   6.75  38.25      │ │
│  │ Tasks   4     6     5     7     5     27        │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  [Export CSV] [Export PDF] [Generate Invoice]          │
└────────────────────────────────────────────────────────┘
```

#### 2.4 Settings Tab
```
┌────────────────────────────────────────────────────────┐
│ ⚙️  Settings                                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│ 🔐 Accounts                                            │
│  Taiga                                                  │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Server:  https://taiga.dix30.be                  │ │
│  │ API Key: ********************************         │ │
│  │ Status:  🟢 Connected                            │ │
│  │ [Test Connection] [Disconnect]                   │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  InvoiceNinja                                           │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Server:  https://invoicing.company.com           │ │
│  │ Token:   ********************************         │ │
│  │ Status:  🟢 Connected                            │ │
│  │ [Test Connection] [Disconnect]                   │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│ ⏱️  Timer Settings                                     │
│  ┌──────────────────────────────────────────────────┐ │
│  │ ☑️ Auto-pause after idle:  [5] minutes           │ │
│  │ ☑️ Remind to start timer on system startup       │ │
│  │ ☑️ Show desktop notifications                    │ │
│  │ ☐ Track non-billable time by default            │ │
│  │ Rounding: [Quarter hour ▼]                       │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│ 🔄 Sync Settings                                       │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Auto-sync interval: [5] minutes                  │ │
│  │ ☑️ Sync on timer stop                            │ │
│  │ ☑️ Queue entries when offline                    │ │
│  │ Last sync: 2 minutes ago                         │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│ 💰 Billing Settings                                    │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Default hourly rate: $[75.00]                    │ │
│  │ Currency: [USD ▼]                                │ │
│  │ ☑️ Auto-generate invoices: [Monthly ▼]          │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│         [Save Settings]        [Reset to Defaults]     │
└────────────────────────────────────────────────────────┘
```

---

## User Workflows

### Workflow 1: Quick Time Tracking (Primary Use Case)

```
User Action                        App Response                    API Integration
───────────────────────────────────────────────────────────────────────────────────
1. Click tray icon              → Show quick menu                 
2. Select "Bug #456" task       → Start timer (00:00:00)          GET /api/v1/tasks/456
3. [Work on task]               → Timer increments                
4. Click "Pause" (lunch break)  → Timer pauses                    
5. Click "Resume"               → Timer continues                 
6. Click "Stop & Save"          → Save time entry locally         
                                → Sync to Taiga                   PATCH /api/v1/tasks/456
                                                                  (update custom attrs)
                                → Create invoice entry            POST /api/v1/tasks
                                                                  (InvoiceNinja)
                                → Show notification:              
                                  "✓ 2h 15m saved to Bug #456"
```

### Workflow 2: Manual Time Entry

```
User Action                        App Response                    API Integration
───────────────────────────────────────────────────────────────────────────────────
1. Right-click tray → "Reports" → Open reports window            
2. Click "Add Manual Entry"     → Show time entry form           
3. Fill form:                   
   - Task: #789                 
   - Duration: 1h 30m           
   - Date: Yesterday            
   - Billable: Yes              
   - Notes: "Fixed bug offline"
4. Click "Save"                 → Validate data                   
                                → Create local entry              
                                → Queue for sync                  
                                → Sync to Taiga                   PATCH /api/v1/tasks/789
                                → Sync to InvoiceNinja            POST /api/v1/tasks
```

### Workflow 3: Weekly Invoice Generation

```
System/User Action                 App Response                    API Integration
───────────────────────────────────────────────────────────────────────────────────
1. Friday 5pm (automated)       → Aggregate week's entries        
                                → Group by client/project         
2. Generate draft invoice       → Calculate totals                GET /api/v1/tasks
                                → Create line items               (fetch unbilled)
3. Show notification:           → "Weekly invoice ready"          
   "38.25h tracked this week    
    $2,868.75 total"            
4. User clicks notification     → Show invoice preview            
5. User reviews & clicks        → Send to InvoiceNinja            POST /api/v1/invoices
   "Generate Invoice"           → Mark entries as billed          
                                → Show success notification       
```

### Workflow 4: Offline Operation

```
User Action                        App Response                    Behavior
───────────────────────────────────────────────────────────────────────────────
1. Work offline (no internet)   → Timer works normally           Store in SQLite
2. Stop timer                   → Save to local queue            Queue sync
3. App detects connection       → Show "Syncing..." notification Background sync
4. Sync queue processes         → Upload all queued entries      Batch API calls
5. Sync complete                → "✓ 3 entries synced"          Clear queue
```

---

## Technical Implementation

### 1. Project Structure

```
taiga-timetracker/
├── main.py                      # Application entry point
├── requirements.txt
├── setup.py                     # PyInstaller config
├── config/
│   ├── __init__.py
│   ├── settings.py              # App settings
│   └── credentials.py           # Secure credential storage
├── ui/
│   ├── __init__.py
│   ├── tray_icon.py             # System tray implementation
│   ├── main_window.py           # Main window
│   ├── dashboard.py             # Dashboard tab
│   ├── tasks.py                 # Tasks tab
│   ├── reports.py               # Reports tab
│   ├── settings.py              # Settings tab
│   └── resources/
│       ├── icons/               # Tray icons
│       └── styles.qss           # Qt stylesheet
├── core/
│   ├── __init__.py
│   ├── timer.py                 # Timer engine
│   ├── idle_detector.py         # Idle time detection
│   └── time_entry.py            # Time entry model
├── api/
│   ├── __init__.py
│   ├── taiga_client.py          # Taiga API wrapper
│   ├── invoiceninja_client.py   # InvoiceNinja API wrapper
│   └── sync_manager.py          # Sync coordination
├── database/
│   ├── __init__.py
│   ├── models.py                # SQLite ORM models
│   └── migrations/              # Schema migrations
├── utils/
│   ├── __init__.py
│   ├── notifications.py         # Desktop notifications
│   └── validators.py            # Input validation
└── tests/
    ├── test_timer.py
    ├── test_api.py
    └── test_sync.py
```

### 2. Core Components

#### 2.1 Timer Engine (`core/timer.py`)

```python
from PyQt6.QtCore import QObject, QTimer, pyqtSignal
from datetime import datetime, timedelta

class TimerEngine(QObject):
    """High-precision timer with pause/resume capability"""
    
    time_updated = pyqtSignal(int)  # Emit seconds elapsed
    timer_started = pyqtSignal()
    timer_paused = pyqtSignal()
    timer_stopped = pyqtSignal(int)  # Emit total seconds
    
    def __init__(self):
        super().__init__()
        self._timer = QTimer()
        self._timer.timeout.connect(self._tick)
        self._timer.setInterval(1000)  # 1 second
        
        self._elapsed_seconds = 0
        self._start_time = None
        self._pause_time = None
        self._is_running = False
        self._current_task_id = None
        
    def start(self, task_id: int):
        """Start timer for a task"""
        if self._is_running:
            self.stop()
        
        self._current_task_id = task_id
        self._elapsed_seconds = 0
        self._start_time = datetime.now()
        self._is_running = True
        self._timer.start()
        self.timer_started.emit()
        
    def pause(self):
        """Pause the timer"""
        if not self._is_running:
            return
        
        self._pause_time = datetime.now()
        self._timer.stop()
        self.timer_paused.emit()
        
    def resume(self):
        """Resume the timer"""
        if self._is_running and self._pause_time:
            # Adjust start time by pause duration
            pause_duration = datetime.now() - self._pause_time
            self._start_time += pause_duration
            self._pause_time = None
            self._timer.start()
            
    def stop(self) -> dict:
        """Stop timer and return time entry data"""
        if not self._is_running:
            return None
        
        self._timer.stop()
        self._is_running = False
        
        end_time = datetime.now()
        total_seconds = self._elapsed_seconds
        
        entry = {
            'task_id': self._current_task_id,
            'start_time': self._start_time,
            'end_time': end_time,
            'duration_seconds': total_seconds,
            'duration_formatted': self._format_duration(total_seconds)
        }
        
        self.timer_stopped.emit(total_seconds)
        self._reset()
        
        return entry
        
    def _tick(self):
        """Called every second"""
        self._elapsed_seconds += 1
        self.time_updated.emit(self._elapsed_seconds)
        
    def _format_duration(self, seconds: int) -> str:
        """Format seconds as HH:MM:SS"""
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
        
    def _reset(self):
        """Reset timer state"""
        self._elapsed_seconds = 0
        self._start_time = None
        self._pause_time = None
        self._current_task_id = None
        
    @property
    def is_running(self) -> bool:
        return self._is_running
        
    @property
    def current_task_id(self) -> int:
        return self._current_task_id
        
    @property
    def elapsed_seconds(self) -> int:
        return self._elapsed_seconds
```

#### 2.2 Idle Detector (`core/idle_detector.py`)

```python
import subprocess
import platform
from PyQt6.QtCore import QObject, QTimer, pyqtSignal

class IdleDetector(QObject):
    """Detect system idle time and auto-pause timer (cross-platform)"""
    
    idle_detected = pyqtSignal(int)  # Emit idle seconds
    idle_ended = pyqtSignal()
    
    def __init__(self, idle_threshold_minutes: int = 5):
        super().__init__()
        self._idle_threshold = idle_threshold_minutes * 60
        self._check_timer = QTimer()
        self._check_timer.timeout.connect(self._check_idle)
        self._check_timer.setInterval(30000)  # Check every 30 seconds
        self._is_idle = False
        self._platform = platform.system()
        
    def start_monitoring(self):
        """Start monitoring for idle time"""
        self._check_timer.start()
        
    def stop_monitoring(self):
        """Stop monitoring"""
        self._check_timer.stop()
        
    def _check_idle(self):
        """Check system idle time"""
        idle_seconds = self._get_system_idle_seconds()
        
        if idle_seconds >= self._idle_threshold:
            if not self._is_idle:
                self._is_idle = True
                self.idle_detected.emit(idle_seconds)
        else:
            if self._is_idle:
                self._is_idle = False
                self.idle_ended.emit()
                
    def _get_system_idle_seconds(self) -> int:
        """Get system idle time in seconds (cross-platform)"""
        try:
            if self._platform == 'Linux':
                return self._get_idle_linux()
            elif self._platform == 'Darwin':  # macOS
                return self._get_idle_macos()
            elif self._platform == 'Windows':
                return self._get_idle_windows()
            else:
                return 0
        except Exception:
            # Fallback: assume not idle
            return 0
    
    def _get_idle_linux(self) -> int:
        """Get idle time on Linux (X11)"""
        # Use xprintidle (install via: apt install xprintidle)
        result = subprocess.run(['xprintidle'], 
                              capture_output=True, 
                              text=True, 
                              timeout=1)
        idle_ms = int(result.stdout.strip())
        return idle_ms // 1000
    
    def _get_idle_macos(self) -> int:
        """Get idle time on macOS"""
        # Use ioreg command (built-in on macOS)
        cmd = "ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'"
        result = subprocess.run(cmd, 
                              shell=True,
                              capture_output=True, 
                              text=True, 
                              timeout=1)
        idle_seconds = float(result.stdout.strip())
        return int(idle_seconds)
    
    def _get_idle_windows(self) -> int:
        """Get idle time on Windows"""
        try:
            import ctypes
            
            class LASTINPUTINFO(ctypes.Structure):
                _fields_ = [
                    ('cbSize', ctypes.c_uint),
                    ('dwTime', ctypes.c_uint),
                ]
            
            lastInputInfo = LASTINPUTINFO()
            lastInputInfo.cbSize = ctypes.sizeof(lastInputInfo)
            ctypes.windll.user32.GetLastInputInfo(ctypes.byref(lastInputInfo))
            
            millis = ctypes.windll.kernel32.GetTickCount() - lastInputInfo.dwTime
            return millis // 1000
        except Exception:
            return 0
            
    def set_idle_threshold(self, minutes: int):
        """Update idle threshold"""
        self._idle_threshold = minutes * 60
```

#### 2.3 System Tray (`ui/tray_icon.py`)

```python
from PyQt6.QtWidgets import QSystemTrayIcon, QMenu
from PyQt6.QtGui import QIcon, QAction
from PyQt6.QtCore import pyqtSlot

class TrayIcon(QSystemTrayIcon):
    """System tray icon with context menu"""
    
    def __init__(self, timer_engine, parent=None):
        super().__init__(parent)
        self.timer = timer_engine
        
        # Load icons
        self.icon_idle = QIcon("ui/resources/icons/timer_idle.png")
        self.icon_running = QIcon("ui/resources/icons/timer_running.png")
        self.icon_syncing = QIcon("ui/resources/icons/syncing.png")
        
        self.setIcon(self.icon_idle)
        self.setVisible(True)
        
        # Create menu
        self._create_menu()
        
        # Connect signals
        self.timer.timer_started.connect(self._on_timer_started)
        self.timer.timer_stopped.connect(self._on_timer_stopped)
        self.activated.connect(self._on_tray_clicked)
        
    def _create_menu(self):
        """Create context menu"""
        self.menu = QMenu()
        
        # Current task section
        self.task_label = QAction("No task selected", self)
        self.task_label.setEnabled(False)
        self.menu.addAction(self.task_label)
        
        self.time_label = QAction("00:00:00", self)
        self.time_label.setEnabled(False)
        self.menu.addAction(self.time_label)
        
        self.menu.addSeparator()
        
        # Timer controls
        self.start_action = QAction("▶️  Start Timer", self)
        self.start_action.triggered.connect(self._on_start_clicked)
        self.menu.addAction(self.start_action)
        
        self.pause_action = QAction("⏸️  Pause Timer", self)
        self.pause_action.triggered.connect(self._on_pause_clicked)
        self.pause_action.setEnabled(False)
        self.menu.addAction(self.pause_action)
        
        self.stop_action = QAction("⏹️  Stop & Save", self)
        self.stop_action.triggered.connect(self._on_stop_clicked)
        self.stop_action.setEnabled(False)
        self.menu.addAction(self.stop_action)
        
        self.menu.addSeparator()
        
        # Quick start submenu
        self.quick_start_menu = QMenu("📋 Quick Start", self)
        self._populate_quick_start()
        self.menu.addMenu(self.quick_start_menu)
        
        self.menu.addSeparator()
        
        # Stats
        self.stats_action = QAction("📊 Today: 0h 0m", self)
        self.stats_action.setEnabled(False)
        self.menu.addAction(self.stats_action)
        
        self.menu.addSeparator()
        
        # Other actions
        self.settings_action = QAction("⚙️  Settings", self)
        self.settings_action.triggered.connect(self._on_settings_clicked)
        self.menu.addAction(self.settings_action)
        
        self.reports_action = QAction("📈 Reports", self)
        self.reports_action.triggered.connect(self._on_reports_clicked)
        self.menu.addAction(self.reports_action)
        
        self.sync_action = QAction("🔄 Sync Now", self)
        self.sync_action.triggered.connect(self._on_sync_clicked)
        self.menu.addAction(self.sync_action)
        
        self.menu.addSeparator()
        
        self.quit_action = QAction("❌ Quit", self)
        self.quit_action.triggered.connect(self._on_quit_clicked)
        self.menu.addAction(self.quit_action)
        
        self.setContextMenu(self.menu)
        
    def _populate_quick_start(self):
        """Populate quick start menu with recent tasks"""
        # TODO: Fetch from database/API
        tasks = [
            {"id": 123, "name": "Bug #123: Fix login issue"},
            {"id": 456, "name": "Task #456: Update docs"},
            {"id": 789, "name": "Story #789: Payment gateway"},
        ]
        
        for task in tasks:
            action = QAction(task["name"], self)
            action.triggered.connect(
                lambda checked, tid=task["id"]: self._start_task(tid)
            )
            self.quick_start_menu.addAction(action)
            
    def update_time_display(self, seconds: int):
        """Update time display"""
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        self.time_label.setText(f"⏱️  {hours:02d}:{minutes:02d}:{secs:02d}")
        
    @pyqtSlot()
    def _on_timer_started(self):
        """Handle timer start"""
        self.setIcon(self.icon_running)
        self.start_action.setEnabled(False)
        self.pause_action.setEnabled(True)
        self.stop_action.setEnabled(True)
        
    @pyqtSlot(int)
    def _on_timer_stopped(self, total_seconds):
        """Handle timer stop"""
        self.setIcon(self.icon_idle)
        self.start_action.setEnabled(True)
        self.pause_action.setEnabled(False)
        self.stop_action.setEnabled(False)
        self.time_label.setText("00:00:00")
        
    def _start_task(self, task_id: int):
        """Start timer for specific task"""
        self.timer.start(task_id)
        # TODO: Fetch task name from database
        self.task_label.setText(f"Task #{task_id}")
        
    # ... other slot implementations
```

#### 2.4 Taiga API Client (`api/taiga_client.py`)

```python
import requests
from typing import List, Dict, Optional
from datetime import datetime

class TaigaClient:
    """Taiga API wrapper"""
    
    def __init__(self, base_url: str, auth_token: str):
        self.base_url = base_url.rstrip('/')
        self.auth_token = auth_token
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/json'
        })
        
    def get_my_tasks(self, status: str = None) -> List[Dict]:
        """Get current user's tasks"""
        url = f"{self.base_url}/api/v1/tasks"
        params = {'assigned_to': 'me'}
        
        if status:
            params['status'] = status
            
        response = self.session.get(url, params=params)
        response.raise_for_status()
        return response.json()
        
    def get_task(self, task_id: int) -> Dict:
        """Get specific task details"""
        url = f"{self.base_url}/api/v1/tasks/{task_id}"
        response = self.session.get(url)
        response.raise_for_status()
        return response.json()
        
    def update_task_time(self, task_id: int, duration_hours: float, 
                         is_billable: bool = True) -> Dict:
        """Update task with tracked time"""
        url = f"{self.base_url}/api/v1/tasks/{task_id}"
        
        # Get current task to get version
        task = self.get_task(task_id)
        
        # Update custom attributes
        custom_attrs = task.get('custom_attributes_values', {})
        
        # Add new duration to existing
        current_duration = custom_attrs.get('duration_hours', 0)
        custom_attrs['duration_hours'] = current_duration + duration_hours
        custom_attrs['billable'] = is_billable
        
        payload = {
            'version': task['version'],
            'custom_attributes_values': custom_attrs
        }
        
        response = self.session.patch(url, json=payload)
        response.raise_for_status()
        return response.json()
        
    def test_connection(self) -> bool:
        """Test if connection is valid"""
        try:
            url = f"{self.base_url}/api/v1/users/me"
            response = self.session.get(url, timeout=5)
            return response.status_code == 200
        except Exception:
            return False
```

#### 2.5 Database Models (`database/models.py`)

```python
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

class TimeEntry(Base):
    """Time entry model"""
    __tablename__ = 'time_entries'
    
    id = Column(Integer, primary_key=True)
    task_id = Column(Integer, nullable=False, index=True)
    task_name = Column(String)
    project_name = Column(String)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime)
    duration_seconds = Column(Integer, default=0)
    is_billable = Column(Boolean, default=True)
    hourly_rate = Column(Float, default=75.0)
    notes = Column(String)
    
    # Sync status
    synced_to_taiga = Column(Boolean, default=False)
    synced_to_invoiceninja = Column(Boolean, default=False)
    taiga_synced_at = Column(DateTime)
    invoice_synced_at = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    @property
    def duration_hours(self) -> float:
        """Get duration in hours"""
        return self.duration_seconds / 3600
        
    @property
    def billable_amount(self) -> float:
        """Calculate billable amount"""
        if not self.is_billable:
            return 0.0
        return self.duration_hours * self.hourly_rate


class Task(Base):
    """Cached task data"""
    __tablename__ = 'tasks'
    
    id = Column(Integer, primary_key=True)
    taiga_id = Column(Integer, unique=True, nullable=False, index=True)
    ref = Column(Integer)
    subject = Column(String, nullable=False)
    project_id = Column(Integer)
    project_name = Column(String)
    status = Column(String)
    is_closed = Column(Boolean, default=False)
    
    # Billing info
    default_hourly_rate = Column(Float, default=75.0)
    client_invoice_id = Column(String)
    
    last_synced = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class SyncQueue(Base):
    """Queue for offline sync"""
    __tablename__ = 'sync_queue'
    
    id = Column(Integer, primary_key=True)
    entry_id = Column(Integer, nullable=False)  # time_entry id
    action = Column(String, nullable=False)  # 'create', 'update'
    target = Column(String, nullable=False)  # 'taiga', 'invoiceninja'
    retry_count = Column(Integer, default=0)
    last_attempt = Column(DateTime)
    error_message = Column(String)
    
    created_at = Column(DateTime, default=datetime.utcnow)


# Database setup
def init_database(db_path: str = "timetracker.db"):
    """Initialize database"""
    engine = create_engine(f'sqlite:///{db_path}')
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    return Session()
```

---

## Installation & Distribution

### 1. Development Setup

```bash
# Clone repository
git clone https://github.com/your-org/taiga-timetracker.git
cd taiga-timetracker

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# Linux/macOS:
source venv/bin/activate
# Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install system dependencies
# Ubuntu/Debian:
sudo apt install xprintidle  # For idle detection

# macOS (no additional dependencies needed - uses built-in ioreg)
# Windows (no additional dependencies needed - uses Win32 API)

# Run in development
python main.py
```

### 2. Build Standalone Executable

```python
# setup.py for PyInstaller
import PyInstaller.__main__

PyInstaller.__main__.run([
    'main.py',
    '--name=TaigaTimeTracker',
    '--onefile',
    '--windowed',
    '--icon=ui/resources/icons/app.ico',
    '--add-data=ui/resources:ui/resources',
    '--hidden-import=PyQt6',
    '--hidden-import=requests',
])
```

```bash
# Build executable
python setup.py build

# Output: dist/TaigaTimeTracker (single executable)
```

### 3. Distribution Packages

#### Ubuntu/Debian (.deb)

```bash
# Create .deb package
mkdir -p taiga-timetracker_1.0.0/DEBIAN
mkdir -p taiga-timetracker_1.0.0/usr/bin
mkdir -p taiga-timetracker_1.0.0/usr/share/applications
mkdir -p taiga-timetracker_1.0.0/usr/share/icons

# Copy files
cp dist/TaigaTimeTracker taiga-timetracker_1.0.0/usr/bin/
cp taiga-timetracker.desktop taiga-timetracker_1.0.0/usr/share/applications/
cp ui/resources/icons/app.png taiga-timetracker_1.0.0/usr/share/icons/

# Create control file
cat > taiga-timetracker_1.0.0/DEBIAN/control << EOF
Package: taiga-timetracker
Version: 1.0.0
Architecture: amd64
Maintainer: Your Name <your@email.com>
Description: Time tracking app for Taiga + InvoiceNinja
 Desktop time tracker with automatic billing integration
Depends: xprintidle
EOF

# Build .deb
dpkg-deb --build taiga-timetracker_1.0.0
```

#### AppImage (Universal Linux)

```bash
# Create AppImage using linuxdeploy
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

./linuxdeploy-x86_64.AppImage \
    --appdir AppDir \
    --executable dist/TaigaTimeTracker \
    --desktop-file taiga-timetracker.desktop \
    --icon-file ui/resources/icons/app.png \
    --output appimage
```

#### macOS (.dmg)

```bash
# Build macOS app bundle
pip install py2app

# Create setup.py for py2app
cat > setup_macos.py << 'EOF'
from setuptools import setup

APP = ['main.py']
DATA_FILES = [('resources', ['ui/resources'])]
OPTIONS = {
    'argv_emulation': True,
    'iconfile': 'ui/resources/icons/app.icns',
    'plist': {
        'CFBundleName': 'Taiga Time Tracker',
        'CFBundleDisplayName': 'Taiga Time Tracker',
        'CFBundleIdentifier': 'com.yourorg.taigatimetracker',
        'CFBundleVersion': '1.0.0',
        'CFBundleShortVersionString': '1.0.0',
        'LSUIElement': True,  # Hide from Dock (menu bar app)
    },
    'packages': ['PyQt6', 'requests', 'keyring', 'sqlalchemy'],
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)
EOF

# Build app bundle
python setup_macos.py py2app

# Create DMG installer
hdiutil create -volname "Taiga Time Tracker" \
    -srcfolder dist/TaigaTimeTracker.app \
    -ov -format UDZO \
    TaigaTimeTracker-1.0.0.dmg
```

#### Windows (.exe)

```bash
# Build Windows executable (cross-platform with PyInstaller)
pip install pyinstaller

# Build with Windows-specific options
pyinstaller main.py \
    --name=TaigaTimeTracker \
    --onefile \
    --windowed \
    --icon=ui/resources/icons/app.ico \
    --add-data="ui/resources;ui/resources" \
    --hidden-import=PyQt6 \
    --hidden-import=requests

# Create installer with Inno Setup (Windows) or NSIS
# Or use PyInstaller's onefile mode for portable .exe
```

---

## Development Roadmap

### Phase 1: MVP (3 weeks)

**Week 1: Core Timer**
- ✅ Timer engine with start/stop/pause
- ✅ System tray icon with basic menu
- ✅ SQLite database setup
- ✅ Basic time entry storage

**Week 2: API Integration**
- ✅ Taiga API client
- ✅ InvoiceNinja API client
- ✅ Task synchronization
- ✅ Time entry sync

**Week 3: UI & Polish**
- ✅ Main window with tabs
- ✅ Settings panel
- ✅ Desktop notifications
- ✅ Build & package for Ubuntu

### Phase 2: Enhanced Features (2 weeks)

**Week 4: Advanced Features**
- ✅ Idle detection & auto-pause
- ✅ Offline queue & sync
- ✅ Manual time entry editing
- ✅ Keyboard shortcuts

**Week 5: Reports & Analytics**
- ✅ Daily/weekly/monthly reports
- ✅ Export to CSV/PDF
- ✅ Invoice generation triggers
- ✅ Client-based grouping

### Phase 3: Polish & Release (1 week)

**Week 6: Testing & Release**
- ✅ Unit tests
- ✅ Integration tests
- ✅ User documentation
- ✅ Release v1.0.0

---

## Cost Estimation

### Development Costs

| Phase | Duration | Cost (at $75/hr) |
|-------|----------|------------------|
| Phase 1: MVP | 120 hours | $9,000 |
| Phase 2: Features | 80 hours | $6,000 |
| Phase 3: Polish | 40 hours | $3,000 |
| **Total** | **240 hours** | **$18,000** |

### Ongoing Costs

- **Maintenance**: 8-10 hours/month ($600-750/month)
- **Bug fixes**: As needed
- **Feature updates**: Quarterly releases
- **Support**: Self-service documentation

### ROI Analysis

**Assumptions:**
- Team of 5 developers
- Average rate: $75/hour
- 5 minutes saved per time entry (vs manual)
- 8 time entries per day per person
- 20 working days per month

**Time Saved:**
- Per person: 5 min × 8 entries × 20 days = 13.3 hours/month
- Team total: 13.3 × 5 = 66.7 hours/month
- **Monetary value**: 66.7 hours × $75 = $5,000/month

**Payback Period:** 3.6 months

---

## Alternative Approaches

### Option 1: Web-Based (Tauri + Vue.js)
**Pros:**
- Modern web technologies
- Easy updates (web app)
- Cross-platform

**Cons:**
- Larger bundle size
- Requires browser runtime
- More complex setup

### Option 2: Electron + React
**Pros:**
- Rich ecosystem
- Hot reload development
- Great debugging tools

**Cons:**
- Large memory footprint (~100MB)
- Slow startup time
- Resource intensive

### Option 3: Native C++/Qt
**Pros:**
- Best performance
- Smallest binary (~5MB)
- Native look & feel

**Cons:**
- Longer development time (2x)
- Harder maintenance
- Steeper learning curve

**Recommendation:** **PyQt6** offers the best balance of development speed, performance, and maintainability for this use case.

---

## Security Considerations

### 1. Credential Storage

```python
import keyring

# Store credentials securely in system keyring
keyring.set_password("taiga-timetracker", "taiga_token", api_token)
keyring.set_password("taiga-timetracker", "invoice_token", invoice_token)

# Retrieve credentials
taiga_token = keyring.get_password("taiga-timetracker", "taiga_token")
```

### 2. API Communication

- ✅ Always use HTTPS
- ✅ Validate SSL certificates
- ✅ Token refresh on expiry
- ✅ Rate limiting respect

### 3. Local Data

- ✅ Encrypt SQLite database (sqlcipher)
- ✅ Secure file permissions (0600)
- ✅ Clear sensitive data on uninstall

---

## Future Enhancements

### v2.0 Features
- 🎯 AI-powered task suggestions
- 🎯 Pomodoro timer integration
- 🎯 Team collaboration (see teammates' status)
- 🎯 Mobile companion app (Android/iOS)
- 🎯 Browser extension (track web-based work)
- 🎯 Calendar integration (Google Calendar, Outlook)
- 🎯 Voice commands ("Hey Taiga, start timer")
- 🎯 Smart reminders based on patterns

### v3.0 Features
- 🎯 Screenshot capture on timer start/stop
- 🎯 Activity monitoring (app/window tracking)
- 🎯 Jira, Asana, Trello integration
- 🎯 Custom workflows & automations
- 🎯 Multi-tenancy (multiple accounts)

---

## Conclusion

A Qt-based desktop time tracker for Taiga + InvoiceNinja is not only **feasible but highly beneficial** for streamlining the billing workflow. The PyQt6 implementation offers:

✅ **Rapid development** (6 weeks to v1.0)  
✅ **Native performance** (low resource usage)  
✅ **Cross-platform** (Linux, Windows, macOS)  
✅ **Offline capability** (work anywhere)  
✅ **ROI positive** (payback in 3.6 months)  
✅ **Maintainable** (Python ecosystem)  

The system tray approach provides **frictionless time tracking** with one-click start/stop, while automated sync to both Taiga and InvoiceNinja ensures **accurate billing without manual data entry**.

---

**Next Steps:**
1. Review and approve specification
2. Set up development environment
3. Begin Phase 1 implementation (MVP)
4. Weekly demo and feedback sessions
5. Beta testing with team
6. Production release

**Questions or changes?** Let's discuss and refine the specification to match your exact needs!
