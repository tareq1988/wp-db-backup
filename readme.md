# WordPress Database Backup

A commandline tool for backing up your WordPress site to local folder, remote location using SFTP (SCP) and Amazon S3.

## How it works

This is just a shell script that uses the combination of [WP-CLI](https://wp-cli.org/) to backup your WordPress database, Linux [SCP](http://manpages.ubuntu.com/manpages/bionic/man1/scp.1.html) (Secure Copy) to move the backup to a remote destination of SSH, and [s3cmd](https://github.com/s3tools/s3cmd) - a CLI tool to copy files to Amazon S3. The backup file will be gzipped automatically.

## Installation

Just run the command in your terminal, the required dependencies will be installed.

**Dependencies:**

 * [WP-CLI](https://github.com/wp-cli/wp-cli)
 * [s3cmd](https://github.com/s3tools/s3cmd)

```bash
wget -O - https://raw.github.com/tareq1988/wp-db-backup/master/setup.sh | bash
```

## Using

This is just as simple as executing a shell script, which is stored in `/usr/local/bin/wp-db-backup` path. So you can invoke the script anywhere using just `wp-db-backup` command.

~~~
wp-db-backup
~~~

**OPTIONS**

	  -h 	--help
	
	  [--path=<path>]
		Path to the WordPress installation. Required if the current directory is not a WordPress installation.
	
	  [--type=<type>]
		Type of backup. Default: dir. Possible values include 'dir', 'scp', 's3'.
	
	  [--backup-dir=<dir>]
		Path to your backup directory if --type=dir.
	
	  [--ssh=<path>]
		Path to your remote directory if --type=scp. e.g. --ssh=user@host:/path/to/dir
	
	  [--s3path=<path>]
		Path to your s3 directory if --type=s3. e.g. --s3path=path/to/dir. s3:// will be prepended automatically.
	
	  [--filename=<name>]
		The file name for the backup file. The date name will be automatically appended.
		.e.g <filename>-<year-month-date>.sql.gz. Default is 'database'
		
**Types of Backup:**

 1. Local Backup. `--type=dir`, this is the default one.
 2. Remote Backup using SFTP. `--type=scp`
 3. Remote Backup to Amazon S3. `--type=s3`

### 1. Local Backup

**Type:**
If you want to backup your database to the same machine, this is the default backup type and you don't need to pass the additional `--type=dir` parameter. 

**Directory:** 
By default the backup will be stored in `Backups` folder in your home directory (`~/Backups`). But you can override that with the `--backup-dir=/path/to/your/backup`, this has to be the absolute path.

~~~
wp-db-backup --path=/var/www/example.com/htdocs --backup-dir=/home/user/dir
~~~

### 2. Remote Backup - SFTP

We are using the [SCP](http://manpages.ubuntu.com/manpages/bionic/man1/scp.1.html) command to push the backup file to a remote location accessible by your host machine.

~~~
wp-db-backup --path=/var/www/example.com/htdocs --type=scp --ssh=user@host:/path/to/directory
~~~

### 3. Remote Backup - Amazon S3

[s3cmd](https://github.com/s3tools/s3cmd) - A very popular Amazon S3 client is being used for this type of backup. The setup script should automatically install the script for you if you're using debian based distributions. Otherwise you can install the tool manually.

After installation, please configure your S3 client using `s3cmd --configure` and make sure you can upload files to your S3 bucket.

**s3path:** Let's say your S3 bucket name is `my-backup` and the backup directory is `sitename`, the s3cmd compatible way of putting a file is: `s3cmd put filename.zip s3://my-backup/sitename`. So your backup command will be:

~~~
wp-db-backup --path=/var/www/example.com/htdocs --type=s3 --s3path=my-backup/sitename
~~~

You don't need to put the full `s3://my-backup/sitename` path, `s3://` will be automatically prepended for you.

## Cron Job

Example cronjob for 3 types of backup.

**Daily Backup:**

~~~
0 0 * * *	wp-db-backup --path=/var/www/example.com/htdocs --backup-dir=/home/user/dir
0 0 * * *	wp-db-backup --path=/var/www/example.com/htdocs --type=scp --ssh=user@host:/path/to/directory
0 0 * * *	wp-db-backup --path=/var/www/example.com/htdocs --type=s3 --s3path=my-backup/sitename
~~~

**Daily Backup:**

~~~
0 0 * * 0	wp-db-backup --path=/var/www/example.com/htdocs --backup-dir=/home/user/dir
0 0 * * 0	wp-db-backup --path=/var/www/example.com/htdocs --type=scp --ssh=user@host:/path/to/directory
0 0 * * 0	wp-db-backup --path=/var/www/example.com/htdocs --type=s3 --s3path=my-backup/sitename
~~~

## Credits

This is an open-source project developed by [Tareq Hasan](https://github.com/tareq1988). You are free to contribute to improve the project :)