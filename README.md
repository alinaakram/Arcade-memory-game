# 🎮 Arcade Memory Game – 8086 Assembly Language

An interactive console-based memory matching game developed using **8086 Assembly Language**.  
This project demonstrates low-level programming concepts including arrays, loops, procedures, interrupts, timers, sound effects, file handling, randomization, and screen management.

---

## ✨ Features

- 🧠 4×4 memory matching game
- 🔀 Randomized card shuffling (Fisher-Yates algorithm)
- 🏆 Score and streak bonus system
- ⏳ 3-minute countdown timer
- ❤️ Lives system
- 💡 Hint system
- 🔊 Sound effects
- 💾 High score saving using file handling
- 🎯 Win / Game Over / Timeout states
- 🎨 Colored console interface

---

## 🛠 Technologies Used

| Technology             | Purpose                 |
|------------------------|------------------------|
| 8086 Assembly Language | Core Programming        |
| MASM / TASM            | Assembler               |
| DOSBox                 | Emulator                |
| BIOS Interrupts        | Timer, Screen, Keyboard |
| DOS Interrupts         | File Handling & Output  |

---

## 📜 Game Rules

1. The player memorizes the displayed grid.
2. Cards are shown for 4 seconds, then hidden.
3. The player selects two positions.
4. If both cards match:
   - Score increases
   - Cards remain visible
   - Bonus streak may apply
5. If cards do not match:
   - One life is lost
   - Score decreases
6. The game is won when all pairs are matched.

---

## 🧩 Concepts Used

- Arrays
- Loops
- Procedures
- Macros
- Stack Operations
- BIOS Interrupts
- DOS Interrupts
- Random Number Generation
- Fisher-Yates Shuffle Algorithm
- Timer Handling
- File Handling
- Sound Generation

---

## ⚙️ Important Procedures

| Procedure         | Purpose                  |
|------------------|--------------------------|
| `shuffle`         | Random card shuffling    |
| `rand`            | Random number generator  |
| `show_grid`       | Display full board       |
| `show_hidden`     | Display hidden board     |
| `calc1 / calc2`   | Index calculation        |
| `reveal`          | Reveal matched cards     |
| `print_num`       | Print numbers            |
| `load_high_score` | Load saved score         |
| `save_high_score` | Save high score          |

---

## 🔌 Interrupts Used

| Interrupt | Purpose         |
|----------|-----------------|
| INT 21H  | DOS Services     |
| INT 10H  | Video Services   |
| INT 16H  | Keyboard Input   |
| INT 1AH  | System Timer     |

---

## 💾 File Handling

High score is stored in:

### File Operations:
- Create file
- Open file
- Read file
- Write file
- Close file

---

## 🖼 Screenshots

### 🎮 Game Start
![Game Start](gamestart.jpeg)

### 🎲 Gameplay
![Gameplay](running game.jpeg)

### 🎯 Match Found
![Match](MATCH.jpeg)

### ⭐ Bonus Score
![Bonus](BONUS.jpeg)

### 🏆 Game Won
![Won](won.jpeg)

### 💀 Game Over
![Game Over](over.jpeg)

### ⏰ Time Out
![Timeout](timeout.jpeg)

---

## 🚀 How to Run

### Requirements
- DOSBox
- MASM or TASM Assembler


