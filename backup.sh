#!/usr/bin/env bash

WP_PATH=$(pwd)
BACKUP_DIR=~/Backups
FILE_NAME=database
TYPE=dir
SSH=
S3_PATH=

function usage() {
    echo "WordPress Database backup tool."
    echo ""
    echo -e "  -h \t--help\n"

    echo "  [--path=<path>]"
    echo -e "\tPath to the WordPress installation. Required if the current directory is not a WordPress installation."
    echo ""

    echo "  [--type=<type>]"
    echo -e "\tType of backup. Default: dir. Possible values include 'dir', 'scp', 's3'."
    echo ""

    echo "  [--backup-dir=<dir>]"
    echo -e "\tPath to your backup directory if --type=dir."
    echo ""

    echo "  [--ssh=<path>]"
    echo -e "\tPath to your remote directory if --type=scp. e.g. --ssh=user@host:/path/to/dir"
    echo ""

    echo "  [--s3path=<path>]"
    echo -e "\tPath to your s3 directory if --type=s3. e.g. --s3path=path/to/dir. s3:// will be prepended automatically."
    echo ""

    echo "  [--filename=<name>]"
    echo -e "\tThe file name for the backup file. The date name will be automatically appended."
    echo -e "\t.e.g <filename>-<year-month-date>.sql.gz. Default is 'database'"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --path)
            WP_PATH=$VALUE
            ;;
        --type)
            TYPE=$VALUE
            ;;
        --ssh)
            SSH=$VALUE
            ;;
        --s3path)
            S3_PATH=$VALUE
            ;;
        --backup-dir)
            BACKUP_DIR=${VALUE%/*} # remove traling slash from value
            ;;
        --name)
            FILE_NAME=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

FULL_NAME=$FILE_NAME-$(date +%Y-%m-%d-%H%M%S).sql.gz

if [ "$TYPE" == "dir" ]; then
    echo "Backing up database to directory..."

    wp db export - --path=$WP_PATH | gzip > "$BACKUP_DIR/$FULL_NAME"
    echo "Backup complete and stored in: $BACKUP_DIR/$FULL_NAME"

elif [ "$TYPE" == "scp" ]; then
    echo "Copying to remote SSH. Backing up..."

    if [[  -z "$SSH" ]]; then
        echo "Please provide your SFTP details. Example: --ssh=user@host:path"
        exit 1
    fi

    wp db export - --path=$WP_PATH | gzip > "./$FULL_NAME"

    echo "Backup created, copying to remote host..."
    scp "./$FULL_NAME" "$SSH"

    if [ "$?" -eq "0" ];
    then
        echo "Successfully copied to remote host."
    else
        echo "Copying backup to remote host failed."
    fi

    echo "Deleting local copy"
    rm "./$FULL_NAME"

elif [ "$TYPE" == "s3" ]; then

    if [[  -z "$S3_PATH" ]]; then
        echo "Please provide your S3 path. Example: --s3path=path/to/dir. s3:// will be prepended automatically."
        exit 1
    fi

    echo "Copying to S3 destination"

    wp db export - --path=$WP_PATH | gzip > "./$FULL_NAME"
    s3cmd put "./$FULL_NAME" "s3://$S3_PATH"

    echo "Deleting local copy"
    rm "./$FULL_NAME"
else
    echo "Not a valid backup type."
    exit 1
fi
