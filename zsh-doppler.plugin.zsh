#!/usr/bin/env zsh

# Zsh Doppler Plugin
# Shows current Doppler project and config in your prompt

# Configuration variables with defaults
: ${DOPPLER_PROMPT_ENABLED:=true}
: ${DOPPLER_PROMPT_PREFIX:="["}
: ${DOPPLER_PROMPT_SUFFIX:="]"}
: ${DOPPLER_PROMPT_SEPARATOR:="/"}
: ${DOPPLER_PROMPT_FORMAT:="%project%separator%config"}
: ${DOPPLER_PROMPT_COLOR:="cyan"}

# No caching needed - environment variables are already fast

# Check if doppler CLI is available
function _doppler_check_cli() {
    command -v doppler >/dev/null 2>&1
}

# Get current doppler project and config from environment variables only
function _doppler_get_info() {
    # Check environment variables (fast and simple)
    if [[ -n "$DOPPLER_PROJECT" ]] && [[ -n "${DOPPLER_CONFIG:-$DOPPLER_ENVIRONMENT}" ]]; then
        echo "$DOPPLER_PROJECT:${DOPPLER_CONFIG:-$DOPPLER_ENVIRONMENT}"
        return 0
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
        local formatted=$(_doppler_format_prompt "$info")
        echo "%F{$DOPPLER_PROMPT_COLOR}${DOPPLER_PROMPT_PREFIX}${formatted}${DOPPLER_PROMPT_SUFFIX}%f"
    fi
}

# Alias for shorter usage
alias doppler_prompt='doppler_prompt_info'

# Auto-update prompt if PROMPT contains doppler_prompt_info
function _doppler_precmd() {
    # This function runs before each prompt is displayed
    # The prompt will be updated automatically if it contains $(doppler_prompt_info)
}

# Enable prompt substitution
setopt prompt_subst

# Add precmd hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _doppler_precmd

# Helper functions for manual prompt setup
function doppler_prompt_setup() {
    cat << 'EOF'
# Add Doppler info to your prompt:

# For left side of prompt (PROMPT or PS1):
PROMPT='$(doppler_prompt_info) %~ $ '

# For right side of prompt (RPROMPT or RPS1):
RPROMPT='$(doppler_prompt_info)'

# Or integrate with existing prompt:
PROMPT='%F{green}%n@%m%f $(doppler_prompt_info)%F{blue}%~%f $ '

# Configuration options:
export DOPPLER_PROMPT_ENABLED=true        # Enable/disable the prompt
export DOPPLER_PROMPT_PREFIX="["          # Text before doppler info
export DOPPLER_PROMPT_SUFFIX="]"          # Text after doppler info
export DOPPLER_PROMPT_SEPARATOR="/"       # Separator between project and config
export DOPPLER_PROMPT_FORMAT="%project%separator%config"  # Format template
export DOPPLER_PROMPT_COLOR="cyan"        # Color (red, green, blue, yellow, magenta, cyan, white)
export DOPPLER_PROMPT_CACHE_TTL=5         # Cache duration in seconds
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
    echo "  DOPPLER_PROMPT_COLOR: $DOPPLER_PROMPT_COLOR"
    echo "  DOPPLER_PROMPT_CACHE_TTL: $DOPPLER_PROMPT_CACHE_TTL"
    echo ""
    echo "Current doppler info: $(doppler_prompt_info)"
    echo "Formatted output: $(doppler_prompt_info)"
}

# =============================================================================
# POWERLEVEL10K SUPPORT
# =============================================================================

# Powerlevel10k configuration variables
: ${POWERLEVEL9K_DOPPLER_BACKGROUND:=none}
: ${POWERLEVEL9K_DOPPLER_FOREGROUND:=51}
: ${POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION:='🔐'}
: ${POWERLEVEL9K_DOPPLER_PREFIX:='['}
: ${POWERLEVEL9K_DOPPLER_SUFFIX:=']'}

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
        
        # Use p10k segment API
        p10k segment -f "$POWERLEVEL9K_DOPPLER_FOREGROUND" \
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
        
        p10k segment -f "$POWERLEVEL9K_DOPPLER_FOREGROUND" \
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
        echo "  Quick add to right prompt: echo 'doppler' | sed -i '1s/^/&/' ~/.p10k.zsh"
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