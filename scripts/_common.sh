#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Node.js version
nodejs_version=18

#=================================================
# PERSONAL HELPERS
#=================================================

# Install Node.js
ynh_nodejs_install() {
    ynh_script_progression "Installing Node.js..."
    
    # Install Node.js using NodeSource repository
    ynh_install_nodejs --nodejs_version=$nodejs_version
    ynh_use_nodejs
}

# Execute command as app user
ynh_exec_as_app() {
    sudo -u "$app" "$@"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
