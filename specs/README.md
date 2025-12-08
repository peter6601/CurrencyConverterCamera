# Documentation & Specifications Organization

This directory contains all project specifications, guides, and documentation organized by category.

## Directory Structure

### 📂 Core
Core product specifications and data models.
- `product_spec.md`: The main product requirement document.
- `data-model.md`: Database and object models.
- `INITIALIZATION_FLOW.md`: App startup logic.

### 📂 Phases
Documentation related to specific development phases.
- `PHASE_1_SETUP.md`: Initial setup guide.
- `PHASE_2_*.md`: Phase 2 implementation details, checklists, and guides.
- `PHASE_4_IMPLEMENTATION.md`: Phase 4 details.

### 📂 Fixes
Bug reports, investigation notes, and fix implementation plans.
- `CAMERA_*.md`: Camera related fixes.
- `FIX_*.md`: General bug fixes and remaining test fixes.
- `DEBUG_*.md`: Debugging logs and findings.

### 📂 Features
Self-contained feature specifications.
- `001-camera-currency-converter/`: Specifications for the initial MVP.

### 📂 Git
Git workflows, commit guides, and repository management.
- `GIT_COMMIT_GUIDE.md`: Standards for commit messages.
- `GIT_WORKFLOW_DIAGRAM.md`: Branching and merging strategy.

### 📂 Guides
General "How-to" guides.
- `QUICK_START.md`: Quick start for new developers.

### 📂 _Archive
Old, redundant, or malformed files that are kept for backup purposes.

### Build Note
To prevent documentation from being accidentally bundled into the app (and avoid Xcode errors like "Multiple commands produce ... data-model.md"), the project excludes Markdown files from build inputs.

- Build settings are centralized in `Config/BuildSettings.xcconfig`.
- Exclusion rule: `EXCLUDED_SOURCE_FILE_NAMES = *.md`
- If you need to ship a specific markdown file, override this in the target's build settings.

