# 🎮 Arcade Memory Game (8086 Assembly Language)

## 📌 Project Overview
The **Arcade Memory Game** is a low-level programming project developed using **8086 Assembly Language**.  
The game challenges the player's memory by displaying a grid of characters for a short duration. After the grid is hidden, the player must recall and correctly guess the position (row and column) of a given character.

This project demonstrates fundamental concepts of **Computer Organization and Assembly Language (COAL)**, including memory handling, control flow, and hardware-level input/output.

---

✨ Key Features

🎯 4x4 Grid Display
⏳ Timed Memorization Phase
🔄 Dynamic Grid Generation (not hardcoded)
🎮 User Input for Row & Column
✅ Answer Validation System
⚡ Optimized Delay System for smooth gameplay
---

 Concepts Used

This project covers key **assembly-level programming concepts**:

- 8086 Architecture
- Data Segment & Code Segment handling
- Registers (AX, BX, CX, DX, SI)
- Arrays (grid storage in memory)
- Procedures (PROC / ENDP)
- Loops and conditional jumps
- Interrupts:
  - `INT 21h` → input/output operations
- Delay loops for timing control
- Basic game logic implementation


## 🎮 How the Game Works

1. The game displays a 4×4 grid of characters.
2. The player is given a few seconds to memorize it.
3. The grid is hidden.
4. A target character is shown.
5. The player enters:
   - Row number (0–3)
   - Column number (0–3)
6. The program checks if the guess is correct:
   - ✅ Correct → Score increases
   - ❌ Wrong → Score decreases & life lost
7. Game continues until all lives are finished.

