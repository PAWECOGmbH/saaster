***Backup for the Production Environment***

**Purpose**

This directory contains the configurations and scripts for backing up and restoring the database, user data, and the Lucee image. These backups are intended only for the production environment.

By utilizing Docker Compose and shell scripts, the backup process is automated to ensure consistent and reliable data backups with minimal manual intervention.

**Structure**

- compose-backup.yml: This file defines the container services needed to create backups. Each service performs a backup for the database, user data, or the Lucee image.

- backup.sh: A shell script that automates the process of backing up the database, user data, and Lucee image. It uses Docker Compose and secure copying (SCP) to transfer backups to the designated backup server.

- restore.sh: A shell script that automates the process of restoring the database, user data, and Lucee image. It retrieves backups from the backup server and restores them to the appropriate volumes.

**Usage**

*Backup*

To create a backup, run the following command from this directory:

    sh backup.sh

This will:
1.  Backup the database volume.
2.  Backup the user data volume.
3.  Backup the Lucee image.
4.  Securely transfer all backups to the remote backup server.

*Restore*
To restore from a backup, run the following command:

    sh restore.sh

This will:

1.  Retrieve the latest backups from the remote backup server.
2.  Restore the database volume.
3.  Restore the user data volume.
4.  Load the Lucee image into Docker.

**Notes**
-   The backups created by this process are only for the **production environment**. Please ensure that the environment variables in the `.env` file are configured correctly before running any backups or restores.

-   Make sure to update the `.env` file with the correct values (such as volume names, SSH keys, and server IP) specific to the production setup.