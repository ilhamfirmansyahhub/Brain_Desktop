# Brain Search - KRunner Mode

## Status

Stable configuration.

## Features

- Trigger search from empty desktop
- Keyboard listener using evdev
- Hyprland window detection
- Quickshell IPC integration
- Exclusive keyboard focus
- ESC closes search
- Search can be opened again after closing
- Runs as systemd user service

## Components

### brain_runner.py

Location:

src/scripts/brain_runner.py

Function:

- Listen keyboard events
- Detect desktop state
- Open Brain Search popup
- Prevent repeated trigger while search is active

### BrainSearchService.qml

Location:

src/services/BrainSearchService.qml

Function:

- Manage search state
- Load applications
- Launch applications
- Save search state

### BrainSearch.qml

Location:

src/popups/BrainSearch.qml

Function:

- Search interface
- Text input
- Result list
- Enter launches application
- ESC closes popup


## Systemd

Service:

brain-runner.service

Enable:

systemctl --user enable --now brain-runner.service


## Design Goal

Replicate KDE KRunner workflow:

Desktop idle:
    press key

↓

Brain Search opens

↓

Type application name

↓

Press Enter

↓

Launch application
