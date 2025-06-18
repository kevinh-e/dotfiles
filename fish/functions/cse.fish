# Set your zID (change this as needed)
set -gx _SSHFS_ZID z5478535

# Set your desired mountpoint for your CSE home directory
set -gx _SSHFS_CSE_MOUNT $HOME/cse

# Function to mount using sshfs (equivalent to alias csemnt)
function csemnt
    # Get the last character of the zID using fish's string sub command.
    set login_suffix (string sub -s -1 $_SSHFS_ZID)
    # Construct and execute the sshfs command.
    sshfs -o idmap=user -C "$_SSHFS_ZID@login$login_suffix.cse.unsw.edu.au:" "$_SSHFS_CSE_MOUNT"
end

# Function to unmount (equivalent to alias cseumount)
function cseumount
    fusermount -zu "$_SSHFS_CSE_MOUNT"
end

# Function to open a remote shell or execute a remote command,
# handling the case where you are inside the mounted CSE directory.
function cse
    # Determine where we are relative to the mountpoint.
    # This removes the mountpoint prefix from the current working directory.
    set rel (string replace -r "^$_SSHFS_CSE_MOUNT" "" (pwd))
    # Determine the login suffix again.
    set login_suffix (string sub -s -1 $_SSHFS_ZID)
    # Build the remote host address.
    set remote_host "$_SSHFS_ZID@login$login_suffix.cse.unsw.edu.au"

    # When no arguments are given.
    if test (count $argv) -eq 0
        # If current directory is NOT inside the mountpoint, then rel will be identical to (pwd)
        if test (pwd) = $rel
            # In this case, simply open a shell in the user's home directory on the remote machine.
            ssh $remote_host
        else
            # If you're within the mountpoint, change to the equivalent directory on the remote.
            ssh $remote_host -t "cd (printf '%q' "./$rel"); exec \$SHELL -l"
        end
    else
        # When arguments are provided, treat them as a command to execute.
        if test (pwd) = $rel
            ssh -qt $remote_host $argv
        else
            ssh $remote_host -qt "cd (printf '%q' "./$rel") && (printf '%q ' $argv)"
        end
    end
end
