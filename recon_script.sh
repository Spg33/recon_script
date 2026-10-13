#!/usr/bin/env bash
#
# recon_script.sh - Penetration testing workspace scaffolder
#
# Creates a tidy, consistent directory structure for a target engagement
# and drops in a ready-to-use Markdown notes template so you can start
# documenting findings immediately.
#
# Usage:
#   ./recon_script.sh <target-ip-or-domain>
#
# Example:
#   ./recon_script.sh 10.10.10.5
#   ./recon_script.sh example.com
#
# Author:  spanos131313
# License: MIT
#

# --- Shell safety settings --------------------------------------------------
# -e : exit immediately if a command exits with a non-zero status
# -u : treat unset variables as an error when substituting
# -o pipefail : a pipeline returns the exit status of the last command to fail
set -euo pipefail

# --- Constants --------------------------------------------------------------
# Name of the script as invoked, used for clean usage/error messages.
readonly SCRIPT_NAME="$(basename "$0")"

# Subdirectories created inside the target workspace.
readonly SUBDIRS=("nmap" "exploits" "web" "notes")

# --- Helper functions -------------------------------------------------------

# Print a usage message to stderr and exit with a non-zero status.
usage() {
    cat >&2 <<EOF
Usage: ${SCRIPT_NAME} <target-ip-or-domain>

Creates an organized workspace for a penetration test against the given target.

Arguments:
  target    The target IP address or domain name (e.g. 10.10.10.5 or example.com)

Example:
  ${SCRIPT_NAME} 10.10.10.5
EOF
    exit 1
}

# Print an informational message in a consistent format.
info() {
    printf '[+] %s\n' "$1"
}

# Print a warning message to stderr in a consistent format.
warn() {
    printf '[!] %s\n' "$1" >&2
}

# Generate the Markdown notes template inside the notes directory.
# Arguments:
#   $1 - absolute or relative path to the notes directory
#   $2 - the target name (used to personalize the template)
create_notes_template() {
    local notes_dir="$1"
    local target="$2"
    local notes_file="${notes_dir}/notes.md"

    cat > "${notes_file}" <<EOF
# Engagement Notes - ${target}

> Generated on $(date '+%Y-%m-%d %H:%M:%S') by ${SCRIPT_NAME}

---

## Scope

- **Target:** ${target}
- **Engagement window:**
- **Rules of engagement / authorization:**
- **In-scope hosts/ranges:**
- **Out-of-scope / do not touch:**

## Initial Recon

- **Open ports & services:**
- **OS / version fingerprinting:**
- **DNS / subdomains:**
- **Web technologies:**

## Vulnerability Analysis

- **Potential vulnerabilities identified:**
- **CVEs of interest:**
- **Misconfigurations:**

## Exploitation

- **Attack vectors attempted:**
- **Successful exploits:**
- **Credentials obtained:**
- **Shells / access gained:**

## Post-Exploitation

- **Privilege escalation:**
- **Persistence:**
- **Lateral movement:**
- **Data of interest / loot:**
- **Cleanup performed:**
EOF

    info "Created notes template: ${notes_file}"
}

# --- Main -------------------------------------------------------------------
main() {
    # Requirement: a single target argument must be supplied.
    if [[ $# -eq 0 ]]; then
        warn "No target specified."
        usage
    fi

    # Reject extra positional arguments to avoid ambiguous input.
    if [[ $# -gt 1 ]]; then
        warn "Too many arguments. Provide exactly one target."
        usage
    fi

    # The target is used verbatim as the parent directory name.
    local target="$1"
    local workspace="${target}"

    # Error handling: don't clobber an existing workspace.
    if [[ -d "${workspace}" ]]; then
        warn "Workspace '${workspace}' already exists. Aborting to avoid overwriting existing work."
        exit 1
    fi

    info "Setting up recon workspace for target: ${target}"

    # Create the parent directory and each subdirectory.
    # 'mkdir -p' creates parents as needed and is safe to call per-path here.
    for sub in "${SUBDIRS[@]}"; do
        mkdir -p "${workspace}/${sub}"
        info "Created directory: ${workspace}/${sub}"
    done

    # Generate the notes template inside the notes subdirectory.
    create_notes_template "${workspace}/notes" "${target}"

    info "Workspace ready at: ./${workspace}"
}

# Entry point: pass all script arguments through to main.
main "$@"
