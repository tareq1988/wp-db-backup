#!/usr/bin/env bash

BACKUP_DIR="$HOME/Backups"

if [ ! -d "$DIRECTORY" ]; then
    echo "No backup directory present, creating in: $BACKUP_DIR"
    mkdir $BACKUP_DIR
fi

if [ ! -f /usr/local/bin/wp ]; then
    printf "\n"
    echo "Installing WP-CLI..."
    printf "\n"
    wget -qO /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

    # Executable permission
    chmod a+x /usr/local/bin/wp

    # Download auto completion
    wget -qO /etc/bash_completion.d/wp-completion.bash https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash

    echo "WP-CLI Installed!"
fi

if ! command -v s3cmd --version; then
    printf "\n"
    echo "Installing s3cmd..."
    printf "\n"
    sudo apt-get install -y s3cmd python-magic

    printf "\n"
    echo "s3cmd Installed!"
    echo "Now please configure using: s3cmd --configure"
fi

if [ ! -f /usr/local/bin/wp-db-backup ]; then
    printf "\n"
    echo "Installing Backup Script..."
    printf "\n"
    wget -qO /usr/local/bin/wp-db-backup https://raw.githubusercontent.com/tareq1988/wp-db-backup/master/backup.sh

    # Executable permission
    chmod a+x /usr/local/bin/wp-db-backup

    echo "Backup Script Installed!"
fi

echo "Finished Installation!"
