# MAHM (Multi-Agentic Hypertension Management) - GitHub Copilot Instructions

**For comprehensive development instructions for coding agents working on the MAHM repository, please refer to the [agents.md](../agents.md) document in the repository root.**

This file contains GitHub Copilot-specific configuration and quick reference for the MAHM project.

## Quick Reference

### Project Overview
- **Location**: `prototype/v1/` (NHS prototype kit application)
- **Stack**: Node.js + Express + Nunjucks + Gulp
- **Purpose**: NHS App AI hypertension management demo
- **Data**: Simulated only - NOT clinical use

### Essential Commands
```bash
cd /home/runner/work/mahm/mahm/prototype/v1
npm install     # 80s - NEVER CANCEL (timeout: 120s+)
npm run build   # 5s - NEVER CANCEL (timeout: 30s+)
npm test        # 2s - NEVER CANCEL (timeout: 30s+)
npm run lint:js # 1s
npm run watch   # 25s startup - NEVER CANCEL
```

### Development Workflow
1. Always work in `prototype/v1/` directory
2. Run validation commands before committing
3. Test key scenarios: homepage, MAHM features, navigation
4. Ensure 75%+ test coverage and lint compliance

For detailed instructions, troubleshooting, file locations, and development practices, see [agents.md](../agents.md).