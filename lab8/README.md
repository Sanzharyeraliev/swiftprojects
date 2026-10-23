# Music Player — Lab 8

## Overview
A single-screen music player built with UIKit. The app features a track cover, title, artist, and Previous / Play-Pause / Next controls that play real audio files bundled with the app.

## Features Implemented
- **Adaptive Layout:** Built completely in Interface Builder using nested `UIStackView` and Auto Layout (pinned to Safe Area with 20pt margins).
- **Data Model:** 10 tracks stored in a `Track` struct.
- **Audio Playback:** Uses `AVAudioPlayer` and `Bundle.main` to load audio files.
- **Controls:** Play/Pause toggles playback and switches SF Symbols (`play.fill` / `pause.fill`).
- **Navigation:** Next / Previous switch tracks and keep the current play state. The list wraps around (Next on the last track goes to the first).
- **Auto-play:** When a track finishes, the next one starts automatically (using `AVAudioPlayerDelegate`).
- **Error Handling:** Missing or broken audio files are handled gracefully without crashing the app.

## Screenshots

### iPhone SE (3rd generation)
![iPhone SE](screenshots/player_se.png)

### iPhone 17 Pro Max
![iPhone 17 Pro Max](screenshots/player_17_pro_max.png)

## Screen Recording
You can find the 20-second demonstration video in the repository root.
