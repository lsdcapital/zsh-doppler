#!/usr/bin/env zsh

# Zsh Doppler Plugin
# Shows current Doppler project and config in your prompt

# Configuration variables with defaults
[[ -z "$DOPPLER_PROMPT_ENABLED" ]] && DOPPLER_PROMPT_ENABLED=true
[[ -z "$DOPPLER_PROMPT_PREFIX" ]] && DOPPLER_PROMPT_PREFIX="["
[[ -z "$DOPPLER_PROMPT_SUFFIX" ]] && DOPPLER_PROMPT_SUFFIX="]"
[[ -z "$DOPPLER_PROMPT_SEPARATOR" ]] && DOPPLER_PROMPT_SEPARATOR="/"
[[ -z "$DOPPLER_PROMPT_FORMAT" ]] && DOPPLER_PROMPT_FORMAT="%project%separator%config"
[[ -z "$DOPPLER_PROMPT_COLOR" ]] && DOPPLER_PROMPT_COLOR="cyan"

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
        local current_dir="$(pwd)"
        # Escape special regex characters in directory path for AWK pattern matching
        local escaped_dir="${current_dir//\\/\\\\}"
        escaped_dir="${escaped_dir//./\\.}"
        escaped_dir="${escaped_dir//\*/\\*}"
        escaped_dir="${escaped_dir//\[/\\[}"
        escaped_dir="${escaped_dir//\]/\\]}"
        escaped_dir="${escaped_dir//\^/\\^}"
        escaped_dir="${escaped_dir//\$/\\$}"
        local info
        info=$(awk -v dir="$escaped_dir" '
            $0 ~ "^[[:space:]]*" dir ":" {found=1}
            found && /enclave.project:/ {project=$2}
            found && /enclave.config:/ {config=$2; print project ":" config; exit}
        ' "$doppler_yaml" 2>/dev/null)

        if [[ -n "$info" ]]; then
            echo "$info"
            return 0
        fi
    fi


    return 1
}

# Format doppler prompt info
function _doppler_format_prompt() {
    local info="$1"
    local project="${info%%:*}"
    local config="${info##*:}"
    
    # Replace placeholders in format string
    local formatted="$DOPPLER_PROMPT_FORMAT"
    formatted="${formatted//\%project/$project}"
    formatted="${formatted//\%config/$config}"
    formatted="${formatted//\%separator/$DOPPLER_PROMPT_SEPARATOR}"
    
    echo "$formatted"
}

# Main function to get doppler prompt
function doppler_prompt_info() {
    # Check if plugin is enabled
    if [[ "$DOPPLER_PROMPT_ENABLED" != "true" ]]; then
        return
    fi

    local info
    if info=$(_doppler_get_info); then
        local config="${info##*:}"
        local color=$(_doppler_get_color "$config")
        local formatted=$(_doppler_format_prompt "$info")
        echo "%F{$color}${DOPPLER_PROMPT_PREFIX}${formatted}${DOPPLER_PROMPT_SUFFIX}%f"
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
    if [[ "$DOPPLER_PROMPT_ENABLED" == "true" ]]; then
        # Capture output and suppress errors to avoid prompt corruption
        DOPPLER_PROMPT_INFO=$(doppler_prompt_info 2>/dev/null) || DOPPLER_PROMPT_INFO=""
    else
        DOPPLER_PROMPT_INFO=""
    fi
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
    echo "  DOPPLER_PROMPT_INFO (cached): '$DOPPLER_PROMPT_INFO'"
    echo "  Current prompt info: $(doppler_prompt_info)"
    echo ""
    echo "Usage recommendation:"
    echo "  Use: PROMPT='\${DOPPLER_PROMPT_INFO} %~ $ '  # Cached (fast)"
    echo "  Not: PROMPT='\$(doppler_prompt_info) %~ $ ' # Function call (slow)"
}

# =============================================================================
# POWERLEVEL10K SUPPORT
# =============================================================================

# Powerlevel10k configuration variables
[[ -z "$POWERLEVEL9K_DOPPLER_BACKGROUND" ]] && POWERLEVEL9K_DOPPLER_BACKGROUND=none
[[ -z "$POWERLEVEL9K_DOPPLER_FOREGROUND" ]] && POWERLEVEL9K_DOPPLER_FOREGROUND=51
[[ -z "$POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION" ]] && POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION='🔐'
[[ -z "$POWERLEVEL9K_DOPPLER_PREFIX" ]] && POWERLEVEL9K_DOPPLER_PREFIX='['
[[ -z "$POWERLEVEL9K_DOPPLER_SUFFIX" ]] && POWERLEVEL9K_DOPPLER_SUFFIX=']'

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

        # Replace placeholders
        formatted="${formatted//\%project/$project}"
        formatted="${formatted//\%config/$config}"
        formatted="${formatted//\%separator/$DOPPLER_PROMPT_SEPARATOR}"

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
        local formatted="$DOPPLER_PROMPT_FORMAT"
        formatted="${formatted//\%project/$project}"
        formatted="${formatted//\%config/$config}"
        formatted="${formatted//\%separator/$DOPPLER_PROMPT_SEPARATOR}"

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