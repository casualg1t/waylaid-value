"""Run the project checks and build reproducible install/report artifacts."""
import os, subprocess, sys
from pathlib import Path

os.chdir(Path(__file__).resolve().parent.parent)
lua = os.environ.get('LUA', 'lua')
commands = [
    [sys.executable, 'tools/build_rewards_html.py'],
    [sys.executable, 'tools/build_ui_preview.py'],
    [sys.executable, 'tools/package_addon.py'],
    *[[lua, 'tests/' + name + '.lua'] for name in ['run', 'rewards', 'eligibility', 'scan', 'item-tooltips', 'ui-smoke']],
    ['node', 'tests/rewards-html.js'],
    ['node', 'tests/report-dom.js'],
    [sys.executable, 'tests/audit-data.py'],
]
for command in commands:
    subprocess.run(command, check=True)
print('All checks passed; install ZIP and offline report are in outputs/.')
