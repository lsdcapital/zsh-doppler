#!/usr/bin/env zsh

# Zsh Doppler Plugin
# Shows current Doppler project and config in your prompt

# Configuration variables with defaults
[[ -z "$DOPPLER_PROMPT_ENABLED" ]] && DOPPLER_PROMPT_ENABLED=true
(( ${+DOPPLER_PROMPT_PREFIX} )) || DOPPLER_PROMPT_PREFIX="["
(( ${+DOPPLER_PROMPT_SUFFIX} )) || DOPPLER_PROMPT_SUFFIX="]"
[[ -z "$DOPPLER_PROMPT_SEPARATOR" ]] && DOPPLER_PROMPT_SEPARATOR="/"
[[ -z "$DOPPLER_PROMPT_FORMAT" ]] && DOPPLER_PROMPT_FORMAT="%project%separator%config"
[[ -z "$DOPPLER_PROMPT_COLOR" ]] && DOPPLER_PROMPT_COLOR="cyan"
[[ -z "$DOPPLER_STARSHIP_USE_ANSI" ]] && DOPPLER_STARSHIP_USE_ANSI=true

# Environment-based color configuration
[[ -z "$DOPPLER_COLOR_DEV" ]] && DOPPLER_COLOR_DEV="green"
[[ -z "$DOPPLER_COLOR_STAGING" ]] && DOPPLER_COLOR_STAGING="yellow"
[[ -z "$DOPPLER_COLOR_PROD" ]] && DOPPLER_COLOR_PROD="red"
[[ -z "$DOPPLER_COLOR_DEFAULT" ]] && DOPPLER_COLOR_DEFAULT="cyan"

# Production warning configuration
[[ -z "$DOPPLER_PROD_WARNING" ]] && DOPPLER_PROD_WARNING=true
[[ -z "$DOPPLER_PROD_WARNING_MESSAGE" ]] && DOPPLER_PROD_WARNING_MESSAGE="⚠️  PRODUCTION ENVIRONMENT"



# Check if doppler CLI is available
function _doppler_check_cli() {
    command -v doppler >/dev/null 2>&1
}

# Determine color based on config/environment name
function _doppler_get_color() {
    local config="$1"
    local color

    # Convert to lowercase for matching
    local config_lower="${config:l}"

    # Match environment patterns
    case "$config_lower" in
        dev*|development*|local*)
            color="$DOPPLER_COLOR_DEV"
            ;;
        stag*|staging*|test*|uat*|qa*)
            color="$DOPPLER_COLOR_STAGING"
            ;;
        prod*|production*|live*|prd*)
            color="$DOPPLER_COLOR_PROD"
            ;;
        ci*|sandbox*)
            color="$DOPPLER_COLOR_DEFAULT"
            ;;
        *)
            color="$DOPPLER_COLOR_DEFAULT"
            ;;
    esac

    echo "$color"
}

# Check if a config name matches production patterns
function _doppler_is_production() {
    local config_lower="${1:l}"
    [[ "$config_lower" == prod* || "$config_lower" == production* ||
       "$config_lower" == live* || "$config_lower" == prd* ]]
}

# Display production warning banner
function _doppler_show_prod_warning() {
    local project="$1" config="$2"
    [[ "$DOPPLER_PROD_WARNING" != "true" ]] && return

    print -P "%F{red}%B${DOPPLER_PROD_WARNING_MESSAGE}%b%f %F{white}($project/$config)%f"
}

# Convert color names to Powerlevel10k color codes
function _doppler_get_p10k_color() {
    local color="$1"

    case "$color" in
        green)
            echo "2"
            ;;
        yellow)
            echo "3"
            ;;
        red)
            echo "1"
            ;;
        cyan)
            echo "6"
            ;;
        blue)
            echo "4"
            ;;
        magenta)
            echo "5"
            ;;
        white)
            echo "7"
            ;;
        *)
            # If it's already a number or unknown, pass it through
            echo "$color"
            ;;
    esac
}

# Get current doppler project and config from environment variables or ~/.doppler/.doppler.yaml
function _doppler_get_info() {
    # Check environment variables first (for doppler run sessions)
    if [[ -n "$DOPPLER_PROJECT" ]] && [[ -n "${DOPPLER_CONFIG:-$DOPPLER_ENVIRONMENT}" ]]; then
        local info="$DOPPLER_PROJECT:${DOPPLER_CONFIG:-$DOPPLER_ENVIRONMENT}"
        echo "$info"
        return 0
    fi

    # Try to get from ~/.doppler/.doppler.yaml (fastest method)
    # Allow override for testing via DOPPLER_YAML_PATH environment variable
    local doppler_yaml="${DOPPLER_YAML_PATH:-$HOME/.doppler/.doppler.yaml}"
    if [[ -f "$doppler_yaml" ]]; then
        local current_dir="${PWD:A}"
        local info
        info=$(awk -v dir="$current_dir" '
            function is_parent(scope, dir) {
                return scope == "/" || scope == dir || index(dir, scope "/") == 1
            }

            function flush_scope() {
                if (scope_matches && project != "" && config != "" && length(scope) >= best_len) {
                    best_len = length(scope)
                    best_project = project
                    best_config = config
                }
            }

            /^[[:space:]]*\/.*:[[:space:]]*$/ {
                flush_scope()
                scope = $0
                sub(/^[[:space:]]*/, "", scope)
                sub(/:[[:space:]]*$/, "", scope)
                scope_matches = is_parent(scope, dir)
                project = ""
                config = ""
                next
            }

            scope_matches && /enclave.project:/ { project = $2 }
            scope_matches && /enclave.config:/ { config = $2 }

            END {
                flush_scope()
                if (best_project != "" && best_config != "") {
                    print best_project ":" best_config
                }
            }
        ' "$doppler_yaml" 2>/dev/null)

        if [[ -n "$info" ]]; then
            echo "$info"
            return 0
        fi
    fi


    return 1
}

# Format doppler prompt info with an explicit template.
function _doppler_format_prompt_template() {
    local info="$1"
    local template="${2:-$DOPPLER_PROMPT_FORMAT}"
    local project="${info%%:*}"
    local config="${info##*:}"

    # Replace placeholders in format string
    local formatted="$template"
    formatted="${formatted//\%project/$project}"
    formatted="${formatted//\%config/$config}"
    formatted="${formatted//\%separator/$DOPPLER_PROMPT_SEPARATOR}"

    print -r -- "$formatted"
}

# Format doppler prompt info using the standard prompt template.
function _doppler_format_prompt() {
    _doppler_format_prompt_template "$1" "$DOPPLER_PROMPT_FORMAT"
}

function _doppler_prompt_text_from_info() {
    local info="$1"
    local formatted=$(_doppler_format_prompt "$info")
    print -r -- "${DOPPLER_PROMPT_PREFIX}${formatted}${DOPPLER_PROMPT_SUFFIX}"
}

# Convert zsh/p10k color names or 256-color codes to ANSI for Starship custom modules.
# Supported: the 8 base color names (black/red/green/yellow/blue/magenta/cyan/white),
# their numeric equivalents 0-7, and any numeric 256-color code. Other names (e.g.
# brightred) return non-zero, and the caller degrades to uncolored text.
function _doppler_color_to_ansi() {
    local color="$1"

    case "$color" in
        black|0)   print -nr -- $'\033[30m' ;;
        red|1)     print -nr -- $'\033[31m' ;;
        green|2)   print -nr -- $'\033[32m' ;;
        yellow|3)  print -nr -- $'\033[33m' ;;
        blue|4)    print -nr -- $'\033[34m' ;;
        magenta|5) print -nr -- $'\033[35m' ;;
        cyan|6)    print -nr -- $'\033[36m' ;;
        white|7)   print -nr -- $'\033[37m' ;;
        # Empty or non-numeric (e.g. brightred) is unsupported; the caller degrades
        # to uncolored text. Any remaining all-digit value is a 256-color code.
        # (Pattern avoids the zsh-only <-> glob so shellcheck can parse this file.)
        ''|*[!0-9]*) return 1 ;;
        *)         print -nr -- $'\033[38;5;'"$color"$'m' ;;
    esac
}

function _doppler_prompt_ansi_from_text() {
    local text="$1"
    local color="$2"
    local ansi

    if ansi=$(_doppler_color_to_ansi "$color" 2>/dev/null); then
        print -nr -- "${ansi}${text}"$'\033[0m'
    else
        print -nr -- "$text"
    fi
}

# Print the current environment color name (useful for diagnostics/integrations).
function doppler_prompt_color() {
    [[ "$DOPPLER_PROMPT_ENABLED" != "true" ]] && return

    local info
    if info=$(_doppler_get_info); then
        local config="${info##*:}"
        _doppler_get_color "$config"
    fi
}

# Plain text output: best for scripts and prompt engines that apply styling themselves.
function doppler_prompt_text() {
    [[ "$DOPPLER_PROMPT_ENABLED" != "true" ]] && return

    local info
    if info=$(_doppler_get_info); then
        _doppler_prompt_text_from_info "$info"
    fi
}

# ANSI-colored output: useful for Starship custom modules.
function doppler_prompt_ansi() {
    [[ "$DOPPLER_PROMPT_ENABLED" != "true" ]] && return

    local info
    if info=$(_doppler_get_info); then
        local config="${info##*:}"
        local color=$(_doppler_get_color "$config")
        local text=$(_doppler_prompt_text_from_info "$info")
        _doppler_prompt_ansi_from_text "$text" "$color"
        print
    fi
}

# Main function to get doppler prompt with zsh prompt escapes.
function doppler_prompt_info() {
    [[ "$DOPPLER_PROMPT_ENABLED" != "true" ]] && return

    local info
    if info=$(_doppler_get_info); then
        local config="${info##*:}"
        local color=$(_doppler_get_color "$config")
        local text=$(_doppler_prompt_text_from_info "$info")
        print -r -- "%F{$color}${text}%f"
    fi
}

# Starship-friendly function. Uses ANSI by default so environment colors are preserved.
function doppler_prompt_starship() {
    if [[ "$DOPPLER_STARSHIP_USE_ANSI" == "true" ]]; then
        doppler_prompt_ansi "$@"
    else
        doppler_prompt_text "$@"
    fi
}

# Function alias for shorter usage (works in non-interactive shells)
function doppler_prompt() {
    doppler_prompt_info "$@"
}

# Cache doppler prompt info to avoid running on every keystroke
function _doppler_precmd() {
    # Calculate doppler prompt info once per command (not per redraw!)
    # This prevents expensive file I/O on every keystroke, backspace, cursor movement, etc.
    DOPPLER_PROMPT_INFO=""
    DOPPLER_PROMPT_TEXT=""
    DOPPLER_PROMPT_ANSI=""
    DOPPLER_PROMPT_STARSHIP=""
    DOPPLER_PROMPT_COLOR_CURRENT=""

    if [[ "$DOPPLER_PROMPT_ENABLED" == "true" ]]; then
        local info
        if info=$(_doppler_get_info 2>/dev/null); then
            local config="${info##*:}"
            local color=$(_doppler_get_color "$config")
            local text=$(_doppler_prompt_text_from_info "$info")
            local ansi

            DOPPLER_PROMPT_TEXT="$text"
            DOPPLER_PROMPT_COLOR_CURRENT="$color"
            DOPPLER_PROMPT_INFO="%F{$color}${text}%f"
            ansi=$(_doppler_prompt_ansi_from_text "$text" "$color") && DOPPLER_PROMPT_ANSI="$ansi"
            if [[ "$DOPPLER_STARSHIP_USE_ANSI" == "true" ]]; then
                DOPPLER_PROMPT_STARSHIP="$DOPPLER_PROMPT_ANSI"
            else
                DOPPLER_PROMPT_STARSHIP="$DOPPLER_PROMPT_TEXT"
            fi
        fi
    fi

    # Only the Starship-facing variables need to be visible to child processes
    # (Starship's custom-module command runs in a subshell). DOPPLER_PROMPT_INFO
    # (zsh prompt escapes) and DOPPLER_PROMPT_COLOR_CURRENT stay as plain shell
    # variables to avoid polluting the environment of everything you launch.
    export DOPPLER_PROMPT_TEXT DOPPLER_PROMPT_ANSI DOPPLER_PROMPT_STARSHIP
}

# Enable prompt substitution
setopt prompt_subst

# Add precmd hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _doppler_precmd

# Production warning on directory change (only on transition into prod)
_DOPPLER_PROD_DIR=""

function _doppler_chpwd() {
    local info project config current_dir="$PWD"

    # Check if we're still under a known prod directory (exact match or subdir)
    if [[ -n "$_DOPPLER_PROD_DIR" ]]; then
        if [[ "$current_dir" = "$_DOPPLER_PROD_DIR" || "$current_dir" = "$_DOPPLER_PROD_DIR"/* ]]; then
            return  # Still in prod context, no warning needed
        fi
    fi

    # Check if new directory has a prod config
    if info=$(_doppler_get_info); then
        project="${info%%:*}"
        config="${info#*:}"

        if _doppler_is_production "$config"; then
            _doppler_show_prod_warning "$project" "$config"
            _DOPPLER_PROD_DIR="$current_dir"
            return
        fi
    fi

    # Not in prod (or no config)
    _DOPPLER_PROD_DIR=""
}

add-zsh-hook chpwd _doppler_chpwd

# Helper functions for manual prompt setup
function doppler_prompt_setup() {
    cat << 'EOF'
# Add Doppler info to your prompt:

# RECOMMENDED: Use cached variable (updated once per command, not per keystroke)
# For left side of prompt (PROMPT or PS1):
PROMPT='${DOPPLER_PROMPT_INFO} %~ $ '

# For right side of prompt (RPROMPT or RPS1):
RPROMPT='${DOPPLER_PROMPT_INFO}'

# Or integrate with existing prompt:
PROMPT='%F{green}%n@%m%f ${DOPPLER_PROMPT_INFO}%F{blue}%~%f $ '

# LEGACY (not recommended): Direct function call (runs on every keystroke!)
# PROMPT='$(doppler_prompt_info) %~ $ '
# RPROMPT='$(doppler_prompt_info)'

# Configuration options:
export DOPPLER_PROMPT_ENABLED=true        # Enable/disable the prompt
export DOPPLER_PROMPT_PREFIX="["          # Text before doppler info
export DOPPLER_PROMPT_SUFFIX="]"          # Text after doppler info
export DOPPLER_PROMPT_SEPARATOR="/"       # Separator between project and config
export DOPPLER_PROMPT_FORMAT="%project%separator%config"  # Format template
export DOPPLER_PROMPT_COLOR="cyan"        # Color (red, green, blue, yellow, magenta, cyan, white)
EOF
}

# Helper function to show current configuration
function doppler_prompt_config() {
    echo "Doppler Prompt Configuration:"
    echo "  DOPPLER_PROMPT_ENABLED: $DOPPLER_PROMPT_ENABLED"
    echo "  DOPPLER_PROMPT_PREFIX: '$DOPPLER_PROMPT_PREFIX'"
    echo "  DOPPLER_PROMPT_SUFFIX: '$DOPPLER_PROMPT_SUFFIX'"
    echo "  DOPPLER_PROMPT_SEPARATOR: '$DOPPLER_PROMPT_SEPARATOR'"
    echo "  DOPPLER_PROMPT_FORMAT: '$DOPPLER_PROMPT_FORMAT'"
    echo "  DOPPLER_PROMPT_COLOR: $DOPPLER_PROMPT_COLOR (fallback)"
    echo "  DOPPLER_STARSHIP_USE_ANSI: $DOPPLER_STARSHIP_USE_ANSI"
    echo ""
    echo "Environment-based Colors:"
    echo "  DOPPLER_COLOR_DEV: $DOPPLER_COLOR_DEV"
    echo "  DOPPLER_COLOR_STAGING: $DOPPLER_COLOR_STAGING"
    echo "  DOPPLER_COLOR_PROD: $DOPPLER_COLOR_PROD"
    echo "  DOPPLER_COLOR_DEFAULT: $DOPPLER_COLOR_DEFAULT"
    echo ""
    echo "Production Warning:"
    echo "  DOPPLER_PROD_WARNING: $DOPPLER_PROD_WARNING"
    echo "  DOPPLER_PROD_WARNING_MESSAGE: '$DOPPLER_PROD_WARNING_MESSAGE'"
    echo ""
    echo "Caching behavior:"
    echo "  DOPPLER_PROMPT_INFO (zsh cached): '$DOPPLER_PROMPT_INFO'"
    echo "  DOPPLER_PROMPT_TEXT (plain cached): '$DOPPLER_PROMPT_TEXT'"
    echo "  DOPPLER_PROMPT_STARSHIP (Starship cached): '$DOPPLER_PROMPT_STARSHIP'"
    echo "  DOPPLER_PROMPT_COLOR_CURRENT: '$DOPPLER_PROMPT_COLOR_CURRENT'"
    echo "  Current prompt info: $(doppler_prompt_info)"
    echo "  Current plain text: $(doppler_prompt_text)"
    echo ""
    echo "Usage recommendation:"
    echo "  Normal zsh: PROMPT='\${DOPPLER_PROMPT_INFO} %~ $ '  # Cached (fast)"
    echo "  Starship: run doppler_starship_setup and add the custom module to starship.toml"
    echo "  Avoid: PROMPT='\$(doppler_prompt_info) %~ $ ' # Function call (slow)"
}

# =============================================================================
# POWERLEVEL10K SUPPORT
# =============================================================================

# Powerlevel10k configuration variables
[[ -z "$POWERLEVEL9K_DOPPLER_BACKGROUND" ]] && POWERLEVEL9K_DOPPLER_BACKGROUND=none
[[ -z "$POWERLEVEL9K_DOPPLER_FOREGROUND" ]] && POWERLEVEL9K_DOPPLER_FOREGROUND=51
[[ -z "$POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION" ]] && POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION='🔐'
(( ${+POWERLEVEL9K_DOPPLER_PREFIX} )) || POWERLEVEL9K_DOPPLER_PREFIX='['
(( ${+POWERLEVEL9K_DOPPLER_SUFFIX} )) || POWERLEVEL9K_DOPPLER_SUFFIX=']'

# Check if we're running under Powerlevel10k
function _doppler_is_p10k() {
    [[ -n "$POWERLEVEL9K_VERSION" ]] || [[ -n "$__p9k_sourced" ]] || command -v p10k >/dev/null 2>&1
}

# Powerlevel10k segment function
function prompt_doppler() {
    # Check if plugin is enabled
    if [[ "$DOPPLER_PROMPT_ENABLED" != "true" ]]; then
        return
    fi

    local info
    if info=$(_doppler_get_info); then
        local project="${info%%:*}"
        local config="${info##*:}"
        local formatted

        # Determine color based on config
        local color=$(_doppler_get_color "$config")
        local p10k_color=$(_doppler_get_p10k_color "$color")

        # Use p10k-specific format if available, otherwise fallback to generic format
        if [[ -n "$POWERLEVEL9K_DOPPLER_FORMAT" ]]; then
            formatted="$POWERLEVEL9K_DOPPLER_FORMAT"
        else
            formatted="$DOPPLER_PROMPT_FORMAT"
        fi

        formatted=$(_doppler_format_prompt_template "$info" "$formatted")

        # Use p10k segment API with dynamic color
        p10k segment -f "$p10k_color" \
                     -b "$POWERLEVEL9K_DOPPLER_BACKGROUND" \
                     -i "$POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION" \
                     -t "${POWERLEVEL9K_DOPPLER_PREFIX}${formatted}${POWERLEVEL9K_DOPPLER_SUFFIX}"
    fi
}

# Instant prompt support for Powerlevel10k
function instant_prompt_doppler() {
    # For instant prompt, check environment variables only (no external commands)
    # This ensures the prompt loads instantly with real data when available

    if [[ -n "$DOPPLER_PROJECT" ]] && [[ -n "$DOPPLER_CONFIG" || -n "$DOPPLER_ENVIRONMENT" ]]; then
        local project="$DOPPLER_PROJECT"
        local config="${DOPPLER_CONFIG:-$DOPPLER_ENVIRONMENT}"
        local info="$project:$config"
        local formatted=$(_doppler_format_prompt_template "$info" "$DOPPLER_PROMPT_FORMAT")

        # Determine color based on config
        local color=$(_doppler_get_color "$config")
        local p10k_color=$(_doppler_get_p10k_color "$color")

        p10k segment -f "$p10k_color" \
                     -b "$POWERLEVEL9K_DOPPLER_BACKGROUND" \
                     -i "$POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION" \
                     -t "${POWERLEVEL9K_DOPPLER_PREFIX}${formatted}${POWERLEVEL9K_DOPPLER_SUFFIX}"
    fi
}

# Auto-configure Powerlevel10k if detected
function _doppler_auto_configure_p10k() {
    if _doppler_is_p10k; then
        # Check if doppler is already in the prompt elements
        local left_elements=(${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]})
        local right_elements=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]})
        
        # Check if doppler is already configured
        if [[ ! " ${left_elements[*]} " =~ " doppler " ]] && [[ ! " ${right_elements[*]} " =~ " doppler " ]]; then
            # Auto-add to right prompt elements if AUTO_ADD is enabled
            if [[ "$DOPPLER_P10K_AUTO_ADD" == "true" ]]; then
                POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(doppler "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}")
            fi
        fi
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Auto-configure if requested
if [[ "$DOPPLER_P10K_AUTO_ADD" == "true" ]]; then
    _doppler_auto_configure_p10k
fi

# Helper function for Powerlevel10k setup
function doppler_p10k_setup() {
    if ! _doppler_is_p10k; then
        echo "❌ Powerlevel10k not detected. This function is only for p10k users."
        echo "   Use 'doppler_prompt_setup' for standard Zsh configuration."
        return 1
    fi
    
    cat << 'EOF'
# Powerlevel10k Doppler Segment Setup
# Add 'doppler' to your prompt elements in ~/.p10k.zsh:

# For left side:
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  # ... your existing elements ...
  doppler  # Add this line
  dir
  vcs
)

# For right side:
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  doppler  # Add this line
  status
  # ... your existing elements ...
)

# Configuration options (add to ~/.p10k.zsh or ~/.zshrc):
typeset -g POWERLEVEL9K_DOPPLER_FOREGROUND=cyan          # Text color
typeset -g POWERLEVEL9K_DOPPLER_BACKGROUND=none          # Background color (or number)
typeset -g POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION='🔐'  # Icon
typeset -g POWERLEVEL9K_DOPPLER_PREFIX='['               # Text before
typeset -g POWERLEVEL9K_DOPPLER_SUFFIX=']'               # Text after
typeset -g POWERLEVEL9K_DOPPLER_FORMAT='%project%separator%config'  # Format template

# Auto-add to right prompt (set before loading plugin):
export DOPPLER_P10K_AUTO_ADD=true

# After adding, restart your terminal or run: p10k reload
EOF

    echo ""
    echo "Current configuration check:"
    local left_elements=(${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]})
    local right_elements=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]})
    
    if [[ " ${left_elements[*]} " =~ " doppler " ]]; then
        echo "✓ doppler found in LEFT prompt elements"
    elif [[ " ${right_elements[*]} " =~ " doppler " ]]; then
        echo "✓ doppler found in RIGHT prompt elements"
    else
        echo "⚠ doppler NOT found in prompt elements - add manually to ~/.p10k.zsh"
        echo "  Edit ~/.p10k.zsh and add 'doppler' to POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS"
    fi
}

# Helper function for Starship setup
function doppler_starship_setup() {
    cat << 'EOF'
# Starship Doppler Module Setup
#
# 1. Source zsh-doppler BEFORE Starship in ~/.zshrc so the cached variables are
#    available to Starship's custom module:
#
#      source /path/to/zsh-doppler.plugin.zsh
#      eval "$(starship init zsh)"
#
# 2. Add $custom to your Starship format or right_format, then add this module to
#    ~/.config/starship.toml:

[custom.doppler]
command = 'printf "%s" "$DOPPLER_PROMPT_STARSHIP"'
when = 'test -n "$DOPPLER_PROMPT_STARSHIP"'
format = '$output'

# Note: ANSI mode embeds raw color codes in the module output, which preserves
# Doppler's dynamic dev/staging/prod colors but can cause spacing/width artifacts
# in some terminals. If you hit that, prefer Starship-managed styling instead:
#   export DOPPLER_STARSHIP_USE_ANSI=false
# and use this module instead:
#
# [custom.doppler]
# command = 'printf "%s" "$DOPPLER_PROMPT_TEXT"'
# when = 'test -n "$DOPPLER_PROMPT_TEXT"'
# format = '[$output]($style)'
# style = 'cyan'
EOF
}

# Helper function to test doppler connection
function doppler_prompt_test() {
    echo "Testing Doppler CLI availability..."
    if _doppler_check_cli; then
        echo "✓ Doppler CLI is available"
        local info
        if info=$(_doppler_get_info); then
            echo "✓ Doppler configuration found: $info"
            echo "✓ Formatted prompt: $(doppler_prompt_info)"
            if _doppler_is_p10k; then
                echo "✓ Powerlevel10k detected - use 'doppler_p10k_setup' for configuration"
            fi
        else
            echo "✗ No Doppler environment variables found"
            echo "  Set DOPPLER_PROJECT and DOPPLER_CONFIG, or run 'doppler run -- your-command'"
        fi
    else
        echo "✗ Doppler CLI not found"
        echo "  Install from: https://docs.doppler.com/docs/install-cli"
    fi
}