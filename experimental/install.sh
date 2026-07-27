#!/usr/bin/env bash
#
# install.sh — Download and install Drupal AGENTS.md + knowledge base
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/amazeeio/drupal-agents-md/main/experimental/install.sh | bash
#
#   Or with wget:
#   wget -qO- https://raw.githubusercontent.com/amazeeio/drupal-agents-md/main/experimental/install.sh | bash
#
# Options:
#   --variant=vanilla    Install Vanilla variant (default)
#   --variant=ddev       Install DDEV variant
#   --variant=lagoon     Install Lagoon variant
#   --branch=name       Use a specific git branch (default: main)
#   --kb-only            Install only the .kb/ folder (no AGENTS.md)
#   --no-kb              Install only the AGENTS.md file (no .kb/ folder)
#   --force              Overwrite existing files without prompting
#   --help               Show this help message
#
set -euo pipefail

REPO_URL="https://github.com/amazeeio/drupal-agents-md.git"
REPO_BRANCH="main"
REPO_DIR=""
VARIANT="vanilla"
INCLUDE_KB=true
INCLUDE_AGENTS=true
FORCE=false
TARGET_DIR="$(pwd)"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ─── Parse arguments ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --variant=*)
      VARIANT="${arg#--variant=}"
      ;;
    --kb-only)
      INCLUDE_AGENTS=false
      INCLUDE_KB=true
      ;;
    --no-kb)
      INCLUDE_AGENTS=true
      INCLUDE_KB=false
      ;;
    --branch=*)
      REPO_BRANCH="${arg#--branch=}"
      ;;
    --force)
      FORCE=true
      ;;
    --help|-h)
      head -20 "$0" | grep '^#' | sed 's/^# \?//'
      exit 0
      ;;
    *)
      error "Unknown option: $arg"
      error "Run with --help for usage."
      exit 1
      ;;
  esac
done

# ─── Validate variant ─────────────────────────────────────────────────────────
VARIANT=$(echo "$VARIANT" | tr '[:upper:]' '[:lower:]')
case "$VARIANT" in
  vanilla|ddev|lagoon) ;;
  *)
    error "Unknown variant '$VARIANT'. Choose: vanilla, ddev, lagoon"
    exit 1
    ;;
esac

# ─── Preflight checks ────────────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
  error "git is required but not found. Install git first."
  exit 1
fi

if [ "$INCLUDE_AGENTS" = false ] && [ "$INCLUDE_KB" = false ]; then
  error "Cannot use both --kb-only and --no-kb at the same time."
  exit 1
fi

# ─── Header ───────────────────────────────────────────────────────────────────
echo ""
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║     Drupal AGENTS.md — Knowledge Base Installer          ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo ""
info "Variant:   ${VARIANT}"
info "Branch:    ${REPO_BRANCH}"
info "Target:    ${TARGET_DIR}"
info "AGENTS.md: $([ "$INCLUDE_AGENTS" = true ] && echo "yes" || echo "no")"
info ".kb/ folder: $([ "$INCLUDE_KB" = true ] && echo "yes" || echo "no")"
echo ""

# ─── Check for existing files ─────────────────────────────────────────────────
if [ "$FORCE" = false ]; then
  conflicts=()
  if [ "$INCLUDE_AGENTS" = true ] && [ -f "${TARGET_DIR}/AGENTS.md" ]; then
    conflicts+=("AGENTS.md")
  fi
  if [ "$INCLUDE_KB" = true ] && [ -d "${TARGET_DIR}/.kb" ]; then
    conflicts+=(".kb/")
  fi

  if [ ${#conflicts[@]} -gt 0 ]; then
    warn "Found existing files: ${conflicts[*]}"
    echo -n "  Overwrite? [y/N] "
    read -r answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
      info "Aborted."
      exit 0
    fi
  fi
fi

# ─── Clone repo to temp directory ─────────────────────────────────────────────
info "Cloning repository..."
REPO_DIR=$(mktemp -d)
trap 'rm -rf "$REPO_DIR"' EXIT

if ! git clone --depth 1 --branch "$REPO_BRANCH" --quiet "$REPO_URL" "$REPO_DIR" 2>/dev/null; then
  error "Failed to clone repository (branch: ${REPO_BRANCH}). Check your internet connection."
  exit 1
fi
ok "Repository cloned"

# ─── Validate source files exist ──────────────────────────────────────────────
SOURCE_DIR="${REPO_DIR}/experimental"

if [ "$INCLUDE_AGENTS" = true ]; then
  if [ ! -f "${SOURCE_DIR}/AGENTS.md" ]; then
    error "AGENTS.md not found in repository at ${SOURCE_DIR}/AGENTS.md"
    exit 1
  fi
fi

if [ "$INCLUDE_KB" = true ]; then
  if [ ! -d "${SOURCE_DIR}/.kb" ]; then
    error ".kb/ folder not found in repository at ${SOURCE_DIR}/.kb"
    exit 1
  fi
fi

# ─── Apply variant-specific path in AGENTS.md ─────────────────────────────────
# The experimental AGENTS.md uses .kb/ relative paths.
# For DDEV/Lagoon variants, we also copy the variant-specific content.
VARIANT_UPPER=$(echo "$VARIANT" | tr '[:lower:]' '[:upper:]')
VARIANT_AGENTS="${REPO_DIR}/${VARIANT_UPPER}/AGENTS.md"
# Normalize: DDEV stays uppercase, Vanilla/Lagoon need title case
case "$VARIANT" in
  ddev) VARIANT_AGENTS="${REPO_DIR}/DDEV/AGENTS.md" ;;
  vanilla) VARIANT_AGENTS="${REPO_DIR}/Vanilla/AGENTS.md" ;;
  lagoon) VARIANT_AGENTS="${REPO_DIR}/Lagoon/AGENTS.md" ;;
esac

# ─── Install files ────────────────────────────────────────────────────────────
if [ "$INCLUDE_AGENTS" = true ]; then
  # Use the experimental slim AGENTS.md (with .kb/ references)
  cp "${SOURCE_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"

  # If using a non-vanilla variant, append a note about the variant
  if [ "$VARIANT" != "vanilla" ]; then
    # Prepend variant notice to the AGENTS.md
    VARIANT_NOTE="\n<!--\n  Variant: ${VARIANT_UPPER}\n  This project uses the slim AGENTS.md with .kb/ knowledge base.\n  For the full standalone ${VARIANT^^} guide, see:\n  https://github.com/amazeeio/drupal-agents-md/tree/main/${VARIANT^^}\n-->\n"
    # Use a temp file for portability
    echo -e "${VARIANT_NOTE}" | cat - "${TARGET_DIR}/AGENTS.md" > "${TARGET_DIR}/AGENTS.md.tmp" && mv "${TARGET_DIR}/AGENTS.md.tmp" "${TARGET_DIR}/AGENTS.md"
  fi

  ok "Installed AGENTS.md"
fi

if [ "$INCLUDE_KB" = true ]; then
  # Remove existing .kb/ if present
  if [ -d "${TARGET_DIR}/.kb" ]; then
    rm -rf "${TARGET_DIR}/.kb"
  fi

  # Copy .kb/ folder
  cp -r "${SOURCE_DIR}/.kb" "${TARGET_DIR}/.kb"

  # Count installed files
  KB_FILES=$(find "${TARGET_DIR}/.kb" -name "*.md" | wc -l | tr -d ' ')
  ok "Installed .kb/ folder (${KB_FILES} files)"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │  ✅  Installation complete!                             │"
echo "  └─────────────────────────────────────────────────────────┘"
echo ""
info "Files installed in: ${TARGET_DIR}"
if [ "$INCLUDE_AGENTS" = true ]; then
  info "  - AGENTS.md (AI agents will read this automatically)"
fi
if [ "$INCLUDE_KB" = true ]; then
  info "  - .kb/     (knowledge base — loaded on demand by the agent)"
fi
echo ""
info "Your AI coding agent (Cursor, Claude Code, etc.) will automatically"
info "read AGENTS.md and follow its guidance to load .kb/ files as needed."
echo ""
