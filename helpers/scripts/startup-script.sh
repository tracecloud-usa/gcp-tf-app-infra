#!/bin/bash

# Define the SSH configuration file paths
SSHD_CONFIG_FILE="/etc/ssh/sshd_config.d/60-cloudimg-settings.conf"
DISABLE_PASSWORD_FILE="/etc/ssh/sshd_config.d/99-no-password-ssh.conf"

# Check if PasswordAuthentication is set to no in the custom SSH config
grep -E '^\s*PasswordAuthentication\s+no' "$SSHD_CONFIG_FILE" > /dev/null 2>&1

# Capture the return code of the grep command to determine if the setting exists
if [[ $? -eq 0 ]]; then
    echo "Password-based SSH is already disabled."
else
    echo "Disabling password-based SSH authentication..."
    # Create a file to disable password-based SSH if not found
    cat << EOF > "$DISABLE_PASSWORD_FILE"
# Disables password-based SSH authentication
PasswordAuthentication no
EOF
    
    # Set permissions for the configuration file
    chown root:root "$DISABLE_PASSWORD_FILE"
    chmod 0644 "$DISABLE_PASSWORD_FILE"

    # Restart the SSH service to apply changes
    systemctl restart sshd
fi

# Define the username variable using Terraform interpolation
USERNAME="trace"
SSH_PUBKEY_PATH="~/.ssh/id_rsa.pub"

# Check if the user exists
if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists. Skipping other tasks."
else
    # Create the user
    echo "Creating user '$USERNAME'..."
    useradd -m "$USERNAME"

    # Add user to sudoers
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
    chmod 0440 "/etc/sudoers.d/$USERNAME"

    # Add SSH public key to authorized_keys
    if [[ -f "$SSH_PUBKEY_PATH" ]]; then
        mkdir -p "/home/$USERNAME/.ssh"
        cat "$SSH_PUBKEY_PATH" > "/home/$USERNAME/.ssh/authorized_keys"
        chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
        chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
    else
        echo "SSH public key file not found at '$SSH_PUBKEY_PATH'. Skipping key addition."
    fi

    # Set ownership and permissions for the home directory
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
    chmod 0755 "/home/$USERNAME"
fi
