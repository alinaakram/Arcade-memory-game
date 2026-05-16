Here is your **complete GitHub-ready report-style description with CONTRIBUTION section added** (clean, structured, and ready to paste):

---

# 🎮 Arcade Memory Game – 8086 Assembly Language

## 📄 Submitted To

Instructor / Course Teacher

## 👩‍💻 Submitted By

Maryam (01-135232-041)
Alina Akram (01-135232-006)

---

## 📌 Project Overview

The Arcade Memory Game is an interactive console-based game developed using 8086 Assembly Language. It demonstrates fundamental and advanced concepts of low-level programming such as memory management, interrupts, loops, procedures, arrays, file handling, and random number generation. The game is designed as a 4×4 memory matching puzzle where the player must find all matching pairs within a limited time.

---

## 🎯 Objective

The main objective of this project is to apply 8086 assembly language concepts in a practical and interactive application. It helps in understanding system-level programming, hardware interaction through interrupts, and efficient memory usage in a real-time game environment.

---

## 🎮 Game Description

At the beginning of the game, a 4×4 grid of cards is displayed briefly to allow the player to memorize the positions. After a few seconds, the grid is hidden, and the player starts selecting two positions at a time to find matching pairs. If both selected cards match, the score increases and the cards remain revealed. If they do not match, the player loses a life and may receive a score penalty. The game continues until all pairs are matched, the timer runs out, or all lives are lost.

---

## ✨ Features

* 4×4 memory matching board
* Randomized card shuffling using Fisher-Yates algorithm
* Score and streak bonus system
* 3-minute countdown timer
* Lives system
* Hint feature
* Sound effects for interactions
* High score saving using file handling
* Win, Game Over, and Timeout conditions
* Colored console-based interface

---

## 🧠 Concepts Used

* Arrays
* Loops
* Procedures
* Macros
* Stack operations
* BIOS interrupts
* DOS interrupts
* Random number generation
* Timer handling
* File handling
* Screen manipulation
* Sound generation

---

## ⚙️ Interrupts Used

* INT 21H – DOS services (input/output and file handling)
* INT 10H – Video services (screen display and control)
* INT 16H – Keyboard input handling
* INT 1AH – System timer services

---

## 💾 File Handling

The game stores and retrieves the highest score using a file named:

**HI.DAT**

### File Operations:

* Create file
* Open file
* Read file
* Write file
* Close file

---

## 🧩 Important Functionalities

* Card shuffling using Fisher-Yates algorithm
* Grid display and hiding logic
* Index calculation for selected positions
* Matching and revealing logic
* Score calculation system
* High score management
* Timer-based gameplay control

---

## 🚀 How to Run the Project

### Requirements:

* DOSBox emulator
* MASM or TASM assembler

### Steps:

Using TASM:

```bash id="4ldh9c"
tasm game.asm
tlink game.obj
```

Using MASM:

```bash id="j8xq2k"
masm game.asm;
link game.obj;
```

Then run:

```bash id="z2tq5p"
game.exe
```

---

## 👥 Contribution

### **Maryam (01-135232-041):**

* Designed and implemented core game logic in 8086 Assembly
* Developed memory matching system and grid structure
* Worked on timer and interrupt handling
* Assisted in debugging and optimization
*  Implemented file handling for high score storage

---

### **Alina Akram (01-135232-006):**

* Implemented scoring, lives, and streak system
* Designed UI layout and screen formatting in DOSBox
* Developed shuffle/randomization algorithm
* Added sound effects and game feedback system
* Created documentation and report formatting in LaTeX

---

## 📄 Conclusion

The Arcade Memory Game project successfully demonstrates the application of 8086 assembly language in developing an interactive game. It strengthens understanding of low-level programming concepts such as interrupts, memory management, and system-level operations. The project also highlights how complex logic and gameplay mechanics can be implemented using assembly language.

---

If you want, I can also:
✔ convert this into a **beautiful GitHub README with badges and icons**
✔ or make it into a **Word/PDF final submission report**
