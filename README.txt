IMI Guard v3.0 ("Unauthorized-Use Investigation" release)
IMI Tech Lab - Cybersecurity & Innovation
 
Portable, read-only Windows endpoint security audit and investigation tool. A single
self-contained executable - no installer, no third-party libraries, no internet connection
required. Runs as a graphical app for a technician at the machine, or fully headless for
fleet deployment. It never modifies system settings, never deletes files, never runs
remediation, and never uploads data.
 
============================================================
WHAT'S NEW IN 3.0
============================================================
v3.0 answers the question a field audit team is actually sent to answer:
"Did someone break the rules on this PC?"
 
- Organization policy pack (policy.json). Declare what the site permits: internet /
  hotspot / tethering / USB storage allowed or not, approved Wi-Fi networks, approved
  USB devices (by serial), working hours, prohibited software. Without a policy, findings
  are neutral observations; with one, the same evidence becomes a confirmed Policy
  Violation. The tool never guesses what your site permits.
- Unauthorized-use detection (WG-UAU-*). Mobile hotspot and USB tethering used to
  bypass a no-internet rule, connection sharing / hosted networks, removable-media
  usage (which device by serial, when it was connected, which files on it were opened),
  and after-hours sign-in review.
- Drive-letter-reuse guard. A file open is attributed to a USB device only if it happened
  inside that device's connection window - drive letters get reused, and innocent
  internal-disk files must never be reported as USB activity. Excluded opens are
  disclosed in the finding, so the reader sees what was withheld and why.
- Program-execution history (WG-EXE-*). Recovers which programs were run and when
  from Prefetch, BAM/DAM, and UserAssist - even if the program was since deleted.
  Also parses the long-retention artifacts ShimCache and Amcache (with per-file SHA-1),
  which survive when Prefetch is disabled or rolled over. Flags network-restriction
  bypass tools (Psiphon, Ultrasurf, personal VPNs) and programs run from USB sticks.
- Data-movement / exfiltration evidence (WG-EXFIL-*). Personal cloud accounts signed
  in on a work PC (OneDrive / Dropbox / Google Drive / MEGA and more, with the account
  and synced folder), background BITS transfer jobs, and staged archives ready to move.
  All read offline from local traces - the tool never contacts a cloud service.
- Separate Unauthorized-Use verdict, reported independently of the security-posture
  score: a hardened PC can still have been misused, and a badly configured PC can be
  entirely innocent.
- Investigation timeline (timeline.json / timeline.csv). Every dated event - sign-ins,
  USB connect/remove, file opens, program executions, network joins, Defender
  detections, log clearing, service installs - on one chronological view, with correlated
  sequences called out ("USB connected -> bypass tool run -> file opened, all after
  hours"). The timeline reports its own reliability.
- Case record + evidence manifest (chain of custody). case.json records who ran the
  audit, where, why, and under whose authority; evidence_manifest.json records the
  SHA-256 of every output file. Verify any package later, on any machine:
  IMIGuard.exe --verify "<folder>" - it prints INTACT, or names every modified,
  missing, or added file.
- Pre-flight "Scan Environment & Reliability" panel at the top of every report: whether
  the scan ran elevated, PowerShell language mode and execution policy, and any
  third-party AV/EDR present - rated Reliable / Reduced / Unreliable, so a starved scan
  is never mistaken for a clean endpoint.
- ACL-aware service severity: a service under a user profile is Critical only if a
  standard user can actually overwrite a binary that a privileged service runs (a working
  local privilege escalation); if not user-writable, it is not flagged at all. This removes
  the "AppData = High" false positives.
- Root-cause correlation: when one app surfaces as several findings, they are grouped
  under one root cause. Only the primary is scored; the rest raise confidence without
  deducting points again.
- Accurate finding types (Confirmed misconfiguration, Confirmed exposure, Historical
  security event, Heuristic review, Malware indicator, Informational context...) instead
  of labelling everything "Suspicious", plus honest first-run baseline status.
 
EVIDENCE HONESTY (read this): Windows does not log file copies by default. IMI Guard
can prove a specific device was connected and when, and that files on a removable drive
were opened and when. It CANNOT prove a file was copied, and the absence of these
artifacts does not prove no data was taken. The reports say so explicitly. The tool
establishes what and when - never why. See MANUAL, section 29.
 
Carried forward from 2.x: CIS-aligned compliance engine (~40 controls with Pass/Fail
and a compliance score), advanced security-policy / hardening collector, process-lineage
detection, hash-reputation module (offline denylist + optional consent-gated VirusTotal
lookup by SHA-256 only), trusted-publisher allowlist, per-finding confidence and type,
confidence-aware scoring, Audit Completeness, Risk by Area, vulnerable / end-of-life
software detection, Windows Event ID reference, and LAN device intelligence.
See MANUAL.pdf for full details.
 
============================================================
COMPATIBILITY (does it need anything installed?)
============================================================
IMI Guard is a single self-contained .exe with NO third-party libraries. It relies only on
two components that are part of Windows itself: the .NET Framework 4.6+ runtime and
Windows PowerShell 5.1.
 
- Windows 10, Windows 11, Server 2016/2019/2022: both are BUILT IN. Nothing to
  install - unzip and run. Fully offline.
- Windows 8.1 / Server 2012 R2: install .NET 4.8 and WMF 5.1 first (a few collectors
  limited).
- Windows 7 SP1 / Server 2008 R2: runs after installing .NET 4.8 + WMF 5.1, but many
  collectors are unavailable and the OS is end-of-life. Not recommended.
- Older than Windows 7 SP1: not supported.
 
Administrator rights are required for full evidence (the executable requests elevation
automatically). Run unelevated and the affected collectors report "Limited".
 
Check any machine:  powershell -ExecutionPolicy Bypass -File .\check_prereqs.ps1
Offline installers for older systems: see prereqs\README.txt (Microsoft redistributables
are downloaded once and placed in the prereqs folder; they cannot be bundled here for
licensing reasons).
 
============================================================
RUN (graphical)
============================================================
1. Double-click IMIGuard.exe and approve the Administrator (UAC) prompt.
2. Choose Quick (~1-2 min), Full (~5-10 min), or Incident (~5-15 min) mode.
3. Select optional evidence modules (including the opt-in Active LAN scan).
4. Click Start Audit. A progress bar and live run log show each collector; use Cancel
   to stop.
5. Use Open Report / Open PDF / Open Output Folder when it finishes.
 
Each run writes to a new timestamped folder under audit_results\ next to the
executable (or under --out).
 
============================================================
RUN (headless / fleet)
============================================================
For RMM, SCCM, Intune, GPO startup scripts, or scheduled tasks (run as SYSTEM or
another elevated context). Any command-line switch puts the tool in headless mode:
 
  IMIGuard.exe --silent --mode Full --out D:\audits
 
Options:
  --mode <Quick|Full|Incident>  Audit depth (default: Full).
  --out <folder>                Base output folder (default: audit_results next to exe).
  --config <file>               winguard.config.json for branding / engagement metadata.
  --baseline | --no-baseline    Compare against the previous baseline (default: on).
  --lan | --no-lan              Passive LAN inventory (default: off).
  --active-scan                 OPT-IN aggressive scan: ICMP sweep + TCP probe of the
                                LOCAL subnet only (default: off; authorized networks only).
  --no-connections --no-developer --no-browser --no-usb --no-reputation
                                Skip the named module.
  --verify <folder>             Verify a previously produced output package against its
                                evidence_manifest.json. Prints RESULT: INTACT, or
                                RESULT: FAILED naming each MODIFIED / MISSING / ADDED
                                file. Runs on any machine.
  -h, --help                    Full usage.
 
Exit codes (for automation to branch on risk):
  0 Excellent (>=90)   1 Good (75-89)   2 Needs improvement (60-74)
  3 High risk (40-59)  4 Critical risk (<40)
  64 usage error       65 runtime error   66 cancelled
 
Example: treat exit code >= 3 as an alert, and collect the timestamped output folder
(or just audit_metadata.json + findings.json) to a central share. The stable asset id
in each report links repeat scans of the same machine.
 
============================================================
AUDIT COVERAGE
============================================================
Security posture
- System and OS identity
- Local users, admins, and RDP users
- Windows Firewall profiles and inbound exposure
- Microsoft Defender health, exclusions, and detections (event type + threat name)
- RDP status, listeners, authentication, and failed logons
- TCP/UDP listeners and selected established connections
- Remote access tools (AnyDesk, TeamViewer, RustDesk, VNC, Tailscale, RMM, VPN tools)
- Startup folders, Run keys, Winlogon, IFEO, PowerShell profiles
- Advanced persistence (ASEP): LSA security/authentication/notification packages,
  BootExecute, print processors/monitors, user-level COM registrations (COM hijacking),
  and shell extensions
- Services and auto-start services, with ACL-aware severity (user-writable binary run
  by a privileged service = Critical)
- Scheduled tasks
- SMB shares and SMB server configuration
- Installed software inventory + vulnerable / end-of-life software detection
- Windows Update, hotfix, and pending reboot state
- Event-log timeline (account changes, service installs, Defender, task creation, logons)
- PowerShell event/history triage
- Malware-indicator triage in risky process/file locations
- WMI event persistence
- Proxy, DNS, hosts file, and recent root certificates
- TPM, Secure Boot, BitLocker, and UAC
- Advanced hardening: WDigest, LSA protection, Credential Guard, NLA, ASR, audit
  policy, account & lockout policy
- CIS-aligned compliance engine (~40 controls, Pass/Fail, compliance score,
  CIS/NIST/Essential-8 references)
- Browser extension inventory with permission scoring (extensions only)
- Process lineage with signature + SHA-256 (Office/browser -> script chains, unsigned
  processes from user-writable paths)
- Digital signature and SHA-256 hash checks for services/startup/tasks/listeners,
  with genuinely-unsigned separated from unresolved (evidence gaps are never
  labelled "unsigned")
- Hash reputation: offline known-bad denylist (hash_denylist.json), plus optional,
  consent-gated, off-by-default VirusTotal lookup that sends only the SHA-256
 
Unauthorized-use and investigation (v3.0)
- Policy-gated unauthorized-use verdict, separate from the security score
- Mobile hotspot / USB tethering / connection-sharing detection (saved SSIDs,
  per-network first/last-connected dates, RNDIS/PAN adapters)
- USB device history: per-device first-installed, last-connected, last-removed, session
  duration, present state, and serials
- Removable-media file access tied to device connection windows (drive-letter-reuse
  guard), with untied opens excluded and disclosed
- Program-execution history from Prefetch, BAM/DAM, UserAssist, ShimCache, and
  Amcache (with SHA-1), including bypass tools deleted weeks ago
- Data-movement evidence: personal cloud sign-ins (with account and synced folder),
  BITS transfer jobs, staged archives - all read offline
- After-hours sign-in review against policy working hours
- Investigation timeline with correlated episodes and its own reliability rating
- Case record (case.json) and SHA-256 evidence manifest with --verify integrity check
 
Network and environment
- Network connection history: known networks (first/last connected, gateway MAC),
  Wi-Fi and VPN/RAS connect events, VPN profiles/adapters, and cellular/modem/
  tethering adapters
- WSL, Docker, VM, VPN, and developer exposure
- Passive LAN inventory (no scanning) with NIC vendor + device type and, on explicit
  opt-in, an active local-subnet scan
- Baseline comparison for new ports, services, tasks, admins, Defender exclusions,
  remote tools, and root certificates
 
Reporting quality
- MITRE ATT&CK references on findings (associations, not confirmed detections;
  tunable via rulecatalog.json)
- Root-cause correlation: one app = one scored finding, the rest become supporting
  observations
- Correlated-risk findings (e.g. exposed RDP + weak authentication = Critical)
- Editable whitelist.json for approved known-good findings
- Offline technician action library with check, remediation, and validation commands,
  routed by an explicit rule-id -> template map with a destructive-command guard
  (review-only and Informational findings can never emit a delete/disable/remove step)
 
Findings that repeat (e.g. many unquoted service paths) are consolidated into a single
row with an instance count, keeping the security score defensible and the report
readable.
 
============================================================
CONFIGURATION FILES (created next to the exe on first run)
============================================================
- winguard.config.json     Branding/engagement: organization, client, engagement id,
                           analyst, classification banner, logo path, report footer.
- policy.json              Organization policy pack (v3.0): internet / hotspot /
                           tethering / USB storage allowed or not, approved networks
                           and USB serials, working hours, approved cloud accounts,
                           prohibited software. Turns neutral observations into
                           confirmed policy violations. Review before every site -
                           never ship one site's policy to the next.
- case.json                Case record (v3.0): case id, organization, site, auditor,
                           audit reason, approving authority, witness. Printed on the
                           report cover and sealed into the evidence manifest.
- whitelist.json           Suppress approved known-good findings (suppressed items
                           are preserved in whitelist_suppressed_findings.json).
- rulecatalog.json         Per-rule MITRE technique/references and optional severity
                           overrides, editable without recompiling. Keys may be exact
                           ids (WG-RDP-001) or family prefixes (WG-RDP-).
- publisher_allowlist.json Extra trusted software publishers (Authenticode signer
                           subjects) to suppress false positives on signed vendor
                           binaries.
- hash_denylist.json       Known-bad SHA-256 hashes from your IR / threat-intel
                           feeds; a match convicts the file (WG-HASH-001, Critical).
                           Ships with the harmless EICAR test hash so you can verify
                           the module.
- hash_reputation.json     Optional online VirusTotal lookup. OFF by default; with no
                           API key the tool stays 100% offline. When enabled, only the
                           SHA-256 is sent - never file content, paths, or machine data.
 
============================================================
OUTPUTS (per timestamped folder under audit_results)
============================================================
- report.html                 Interactive report: scan-reliability panel, severity donut,
                              category chart, live search, severity filters, sortable
                              table, collapsible sections. Print-ready, fully offline.
- report.pdf                  Branded PDF summary.
- audit_metadata.json         Aggregation anchor: schema/tool version, asset id, score,
                              band, counts, engagement, collector health, risk by area.
- winguard_run.log            Tool-execution audit trail with per-collector timing.
- findings.json / findings.csv
                              Machine-readable findings with count, confidence, type,
                              status, evidence quality, MITRE technique, and the
                              remediation_template + allow_destructive routing fields.
- compliance.json / compliance.csv
                              CIS-aligned control results (id, section, Pass/Fail,
                              frameworks, evidence, remediation).
- timeline.json / timeline.csv
                              The investigation timeline (v3.0) with correlated
                              episodes and reliability.
- evidence_manifest.json      SHA-256 of every output file + the case record, the
                              tool's own hash, and audit start/end times (v3.0).
                              Store write-once if findings may be disputed.
- technician_action_guide.md  Per-finding check / remediation / validation commands.
- summary.txt                 Plain-text executive summary.
- baseline_current.json / baseline_diff.html
- whitelist_suppressed_findings.json
- raw_evidence/*.json         Raw per-module evidence (redacted).
- CSV exports: network_ports, installed_apps, services, scheduled_tasks,
  file_reputation, rdp_history, logon_history, network_history, usb_history,
  active_lan_hosts
 
Each audit is linked to a stable, non-reversible asset id (WGA-...) derived from the
machine identity, so repeat scans of the same endpoint can be tracked and aggregated
over time.
 
============================================================
SAFETY AND ETHICS
============================================================
- Read-only audit. No cleanup or automatic remediation; remediation commands in the
  report are guidance only and are never executed by the tool. Review-only and
  Informational findings can never be issued destructive commands.
- No exploit checks. No password, cookie, saved credential, private document, browser
  history, or token collection. No file upload. Optional hash lookup (off by default)
  sends only a SHA-256 fingerprint.
- Passive LAN inventory is the default. The Active LAN scan is OFF by default, requires
  explicit opt-in (a confirmation prompt in the GUI, or --active-scan on the CLI), is
  limited to the directly-connected local subnet, and performs only ICMP discovery and
  TCP connection probes (no exploitation or credential testing). Use only on networks
  you are authorized to test.
- Unauthorized-use investigations: get authorization in writing first and record it in
  case.json (AuditReason, ApprovingAuthority, WitnessName). The tool establishes what
  happened and when; intent is always the investigator's call. Findings can affect
  people's livelihoods - preserve the evidence manifest and let the policy gate, not
  assumption, decide what counts as a violation.
 
============================================================
LICENSING
============================================================
IMI Guard is licensed with an offline license file named license.key. The application
checks it locally (nothing is sent to any server), and the file is cryptographically
signed so it cannot be edited or forged.
 
To license this copy, place the license.key you were given in the SAME folder as
IMIGuard.exe.
 
Without a valid license the tool still runs, but reports are marked
"UNLICENSED - EVALUATION" and the interface shows a banner. If your license has
expired, contact your supplier for a renewal.
 
To request or renew a license, contact your IMI Guard supplier.
 
============================================================
BUILD
============================================================
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
 
Uses the Windows .NET Framework C# compiler already present on standard Windows
systems; no package install required. The build embeds an application manifest
(Administrator + DPI aware).
 
Code signing (recommended for enterprise deployment) runs automatically if a
certificate is provided via environment variables before building:
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
