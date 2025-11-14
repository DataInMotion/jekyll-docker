#!/bin/sh
export PATH=$PATH:/usr/jekyll/bin

# Generate SSH host keys if they don't exist
ssh-keygen -A

# Check if we're being asked to run sshd (default CMD) or Jekyll command
if [ "$1" = "/usr/sbin/sshd" ]; then
    # Jenkins Docker agent mode - run SSH in foreground
    exec /usr/sbin/sshd -D
elif [ "$1" = "jekyll" ] || [ "$1" = "bundle" ] || [ "$1" = "gem" ]; then
    # Jekyll command mode - start SSH in background, run Jekyll command
    /usr/sbin/sshd
    exec /usr/jekyll/bin/entrypoint "$@"
else
    # Any other command - start SSH in background, execute command
    /usr/sbin/sshd
    exec "$@"
fi
