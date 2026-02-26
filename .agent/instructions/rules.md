# Rootfolio Project Rules

This document contains persistent instructions for the Rootfolio project. These rules are written in English to ensure maximum comprehension and accuracy for AI agents.

## 📋 Language & Output Rules

- **User Communication**: All explanations, progress updates, and notifications to the USER must be in **Korean**.
- **Source Code**: Code comments and documentation within files should be in **Korean**.
- **Configuration Files**: Files intended for AI agents (e.g., in `.agent/instructions/`) should be written in **English**.
- **Translation Requirement**: Every English configuration file MUST have a paired Korean translation named `filename(korea).md` (e.g., `rules.md` must have `rules(korea).md`).
- **AI Operational Logic**: The AI agent MUST **ignore** all files containing `(korea)` in their filename when reading project instructions or rules. These are strictly for the USER.

## 📂 Project Architecture

- **Strict Structure**: Maintain the established hierarchy:
    - `platform/`: Main hub source code.
    - `content/`: Learning notes (`studies/`) and daily logs (`logs/`).
    - `modules/apps/`: Integrated external applications (e.g., Flutter projects).
- **Format**: Knowledge and logs must use **Markdown** (.md) format.

## 🛠️ Development Style
- Use modern, clean, and modular coding patterns.
- Ensure all automated tasks follow the project's aesthetic guidelines (Dark Mode, Premium UI).
