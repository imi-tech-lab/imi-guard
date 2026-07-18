IMI Guard v2.1 ("Evidence & Confidence" release)

SHA-256:
200B50BA5C9FF9A9E77ACED6954E2F230AA4EEA8A940249CB3FB95B5EDC406FC

Verify your download in PowerShell:
Get-FileHash .\IMIGuard.exe -Algorithm SHA256

Portable, read-only Windows endpoint security audit tool. Single self-contained executable,
no installer and no internet connection required. Runs as a graphical app or fully headless
for fleet deployment.

New in v2.1: per-finding confidence + type, confidence-aware scoring, an Audit Completeness
panel, a Risk-by-Area manager rollup, and three new modules - vulnerable/end-of-life software
detection, a Windows Event ID reference, and LAN device intelligence (NIC vendor + device type).
See MANUAL.pdf for full details.

============================================================
COMPATIBILITY (does it need anything installed?)
============================================================
IMI Guard is a single self-contained .exe with NO third-party libraries. It relies only on two
components that are part of Windows itself: the .NET Framework 4.6+ runtime and PowerShell 5.1.

- Windows 10, Windows 11, Server 2016/2019/2022: both are BUILT IN. Nothing to install -
  unzip and run. Fully offline.
- Windows 8.1 / Server 2012 R2: install .NET 4.8 and WMF 5.1 first (a few collectors limited).
- Windows 7 SP1 / Server 2008 R2: runs after installing .NET 4.8 + WMF 5.1, but many collectors
  are unavailable and the OS is end-of-life. Not recommended.
- Older than Windows 7 SP1: not supported.

Check any machine:  powershell -ExecutionPolicy Bypass -File .\check_prereqs.ps1
Offline installers for older systems: see prereqs\README.txt (Microsoft redistributables are
downloaded once and placed in the prereqs folder; they cannot be bundled here for licensing reasons).

============================================================
RUN (graphical)
============================================================
1. Double-click IMIGuard.exe (it requests Administrator automatically).
2. Choose Quick, Full, or Incident mode.
3. Select optional evidence modules (including the opt-in Active LAN scan).
4. Click Start Audit. Use Cancel to stop a running scan.
5. Use Open Report / Open PDF / Open Output Folder when it finishes.

============================================================
RUN (headless / fleet)
============================================================
For RMM, SCCM, Intune, GPO startup scripts, or scheduled tasks (run as SYSTEM/elevated):

  IMIGuard.exe --silent --mode Full --out D:\audits

Options:
  --mode <Quick|Full|Incident>  Audit depth (default: Full).
  --out <folder>                Base output folder (default: audit_results next to exe).
  --config <file>               winguard.config.json for branding / engagement metadata.
  --baseline | --no-baseline    Compare against the previous baseline (default: on).
  --lan | --no-lan              Passive LAN inventory (default: off).
  --active-scan                 OPT-IN aggressive scan: ICMP sweep + TCP probe of the LOCAL
                                subnet only (default: off; authorized networks only).
  --no-connections --no-developer --no-browser --no-usb --no-reputation
  -h, --help                    Full usage.

Exit codes (for automation to branch on risk):
  0 Excellent  1 Good  2 Needs improvement  3 High risk  4 Critical risk
  64 usage error  65 runtime error  66 cancelled

============================================================
AUDIT COVERAGE
============================================================
- System and OS identity
- Local users, admins, and RDP users
- Windows Firewall profiles and inbound exposure
- Microsoft Defender health, exclusions, and detections
- RDP status, listeners, authentication, and failed logons
- TCP/UDP listeners and selected established connections
- Remote access tools (AnyDesk, TeamViewer, RustDesk, VNC, Tailscale, RMM, VPN tools)
- Startup folders, Run keys, Winlogon, IFEO, PowerShell profiles
- Advanced persistence (ASEP): LSA security/authentication/notification packages, BootExecute,
  print processors/monitors, user-level COM registrations (COM hijacking), and shell extensions
- Services and auto-start services
- Scheduled tasks
- SMB shares and SMB server configuration
- Installed software inventory
- Windows Update, hotfix, and pending reboot state
- Event-log timeline (account changes, service installs, Defender, task creation, logons)
- PowerShell event/history triage
- Malware-indicator triage in risky process/file locations
- WMI event persistence
- Proxy, DNS, hosts file, and recent root certificates
- TPM, Secure Boot, BitLocker, and UAC
- Browser extension inventory only
- Network connection history: known networks (first/last connected, gateway MAC), Wi-Fi and
  VPN/RAS connect events, VPN profiles/adapters, and cellular/modem/tethering adapters
- USB device history: per-device first-installed, last-connected, last-removed, session
  duration, present state, and serials
- WSL, Docker, VM, VPN, and developer exposure
- Digital signature and SHA256 hash checks for services/startup/tasks/listeners
- Passive LAN inventory (no scanning) and, on explicit opt-in, an active local-subnet scan
- Baseline comparison for new ports, services, tasks, admins, Defender exclusions, remote
  tools, and root certificates
- MITRE ATT&CK technique mapping on findings (tunable via rulecatalog.json)
- Editable whitelist.json for approved known-good findings
- Offline technician action library with check, remediation, and validation commands

Findings that repeat (e.g. many unquoted service paths) are consolidated into a single row
with an instance count, keeping the security score defensible and the report readable.

============================================================
CONFIGURATION FILES (created next to the exe on first run)
============================================================
- winguard.config.json  Branding/engagement: organization, client, engagement id, analyst,
                        classification banner, logo path, report footer.
- whitelist.json        Suppress approved known-good findings.
- rulecatalog.json      Per-rule MITRE technique/references and optional severity overrides,
                        editable without recompiling.

============================================================
OUTPUTS (per timestamped folder under audit_results)
============================================================
- report.html            Interactive report: severity donut, category chart, live search,
                         severity filters, sortable table, collapsible sections. Print-ready.
- report.pdf             Branded PDF summary.
- audit_metadata.json    Aggregation anchor: schema version, asset id, score, counts, engagement.
- winguard_run.log       Tool-execution audit trail with per-collector timing.
- findings.json / findings.csv
- technician_action_guide.md
- summary.txt
- baseline_current.json / baseline_diff.html
- whitelist_suppressed_findings.json
- raw_evidence/*.json
- CSV exports: network_ports, installed_apps, services, scheduled_tasks, file_reputation,
  rdp_history, logon_history, network_history, usb_history, active_lan_hosts

Each audit is linked to a stable, non-reversible asset id (WGA-...) derived from the machine
identity, so repeat scans of the same endpoint can be tracked and aggregated over time.

============================================================
SAFETY AND ETHICS
============================================================
- Read-only audit. No cleanup or automatic remediation; remediation commands in the report are
  guidance only and are never executed by the tool.
- No exploit checks. No password, cookie, saved credential, private document, browser history,
  or token collection. No file upload.
- Passive LAN inventory is the default. The Active LAN scan is OFF by default, requires explicit
  opt-in (a confirmation prompt in the GUI, or --active-scan on the CLI), is limited to the
  directly-connected local subnet, and performs only ICMP discovery and TCP connection probes
  (no exploitation or credential testing). Use only on networks you are authorized to test.

============================================================
LICENSING
============================================================
IMI Guard is licensed with an offline license file named license.key. The application checks it
locally (nothing is sent to any server), and the file is cryptographically signed so it cannot be
edited or forged.

To license this copy, place the license.key you were given in the SAME folder as IMIGuard.exe.

Without a valid license the tool still runs, but reports are marked "UNLICENSED - EVALUATION" and
the interface shows a banner. If your license has expired, contact your supplier for a renewal.

To request or renew a license, contact your IMI Guard supplier.

============================================================
BUILD
============================================================
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1

Uses the Windows .NET Framework C# compiler already present on standard Windows systems; no
package install required. The build embeds an application manifest (Administrator + DPI aware).

Code signing (recommended for enterprise deployment) runs automatically if a certificate is
provided via environment variables before building:
  WG_SIGN_THUMBPRINT   thumbprint of a code-signing cert in the local store, OR
  WG_SIGN_PFX          path to a .pfx  (+ optional WG_SIGN_PFX_PASSWORD)
Without one, the build succeeds but the executable is unsigned.

The build also produces release\ and IMIGuard_release.zip.

============================================================
TESTS
============================================================
Rule-engine regression tests (synthetic evidence -> expected findings):
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run_tests.ps1
Exit code 0 = all tests passed.
