# MAHM (Multi-Agentic Hypertension Management) - GitHub Copilot Instructions

**For comprehensive development instructions for coding agents working on the MAHM repository, please refer to the [agents.md](../agents.md) document in the repository root.**

This file contains GitHub Copilot-specific configuration and quick reference for the MAHM project.

## Quick Reference

### Essential Commands

Running the prototype UI:
```bash
cd /home/runner/work/mahm/mahm/prototype/v1
npm install     # 80s - NEVER CANCEL (timeout: 120s+)
npm run build   # 5s - NEVER CANCEL (timeout: 30s+)
npm test        # 2s - NEVER CANCEL (timeout: 30s+)
npm run lint:js # 1s
npm run watch   # 25s startup - NEVER CANCEL
```

For detailed instructions, troubleshooting, file locations, and development practices, see [agents.md](../agents.md).