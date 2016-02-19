Out-of-the-box LAMP image (PHP+MySQL)

#All Changes

###Apache2 Conf Changes
-----

This aims to optimize Apache2 for web server that does not have too much memory.

	KeepAlive Off
	
	...
	<IfModule mpm_prefork_module>
	StartServers 2
	MinSpareServers 6
	MaxSpareServers 12
	MaxClients 30
	MaxRequestsPerChild 3000
	</IfModule>

###MySQL Conf Changes
-----

This aims to optimize MySQL for web server that does not have too much memory.

**Comment out all lines beginning with key_buffer**
	
	...
	
**Change**

	max_connections = 75
	max_allowed_packet = 1M
	thread_stack = 128K
	
	...
	
**Add**

	table_open_cache = 32M
	key_buffer_size = 32M

###PHP Conf Changes
------------------------------

This aims to optimize PHP for web server that does not have too much memory.

	error_reporting = E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR


#Usage
-----

To create the image, execute the following command on the folder:
	
	docker build -t yangpeilyn/lamp:basic .
	
To run the image and bind to port 8080:

	docker run -d -p 8080:80 --name=web yangpeilyn/lamp:basic

To enter the existing container (*web* is the name of the container):

    docker exec -ti web bash


The first time that you run your container, a new user admin with all privileges will be created in MySQL with a random password. To get the password, check the logs of the container by running:

    docker logs <CONTAINER_ID>
You will see an output like the following:

    ========================================================================
    You can now connect to this MySQL Server using:

        mysql -uadmin -p47nnf4FweaKu -h<host> -P<port>

    Please remember to change the above password as soon as possible!
    MySQL user 'root' has no password but only allows local connections.
    ========================================================================
In this case, 47nnf4FweaKu is the password allocated to the admin user.

Remember that the root user has no password, but it's only accessible from within the container.

You can now test your deployment:

    mysql -uadmin -p
Done!


###Setting a specific password for the admin account
-----
If you want to use a preset password instead of a random generated one, you can set the environment variable MYSQL_PASS to your specific password when running the container:

    docker run -d -p 8080:80 -e MYSQL_PASS="mypass" --name=web yangpeilyn/lamp:basic
You can now test your deployment:

    mysql -uadmin -p"mypass"
The admin username can also be set via the MYSQL_USER environment variable.

###Creating a database on container creation
-----
If you want a database to be created inside the container when you start it up for the first time you can set the environment variable ON_CREATE_DB to a string that names the database.

    docker run -d -p 8080:80 -e ON_CREATE_DB="newdatabase" --name=web yangpeilyn/lamp:basic
If this is combined with importing SQL files, those files will be imported into the created database.

###Mounting the database file volume
-----
In order to persist the database data, you can mount a local folder from the host on the container to store the database files. To do so:

    docker run -d -v /path/in/host:/var/lib/mysql --name=web yangpeilyn/lamp:basic /bin/bash -c "/usr/bin/mysql_install_db"
This will mount the local folder /path/in/host inside the docker in /var/lib/mysql (where MySQL will store the database files by default). mysql_install_db creates the initial database structure.

Remember that this will mean that your host must have /path/in/host available when you run your docker image!

After this you can start your MySQL image, but this time using /path/in/host as the database folder:

    docker run -d -p 8080:80 -v /path/in/host:/var/lib/mysql --name=web yangpeilyn/lamp:basic
    
###Migrating an existing MySQL Server
-----
In order to migrate your current MySQL server, perform the following commands from your current server:

To dump your databases structure:

    mysqldump -u<user> -p --opt -d -B <database name(s)> > /tmp/dbserver_schema.sql
To dump your database data:

    mysqldump -u<user> -p --quick --single-transaction -t -n -B <database name(s)> > /tmp/dbserver_data.sql
To import a SQL backup which is stored for example in the folder /tmp in the host, run the following:

    sudo docker run -d -v /tmp:/tmp yangpeilyn/lamp:basic /bin/bash -c "/import_sql.sh <user> <pass> /tmp/<dump.sql>"
Also, you can start the new database initializing it with the SQL file:

    sudo docker run -d -v /path/in/host:/tmp/ -e STARTUP_SQL="/tmp/<dump.sql>" --name=web yangpeilyn/lamp:basic
Where <user> and <pass> are the database username and password set earlier and <dump.sql> is the name of the SQL file to be imported.


###Setting alias of PHPMyAdmin
-----
	docker run -d -p 8080:80 -e PHPMYADMIN_ALIAS="phpmyadmin_alias" --name=web yangpeilyn/lamp:basic
	
	
###Adding site name
-----
Adding the site name so that there will be an automatically generated server file folder for it. Alos, Apache2 will make that folder as the default server file folder.

	docker run -d -p 8080:80 -e SITENAME="sitename" --name=web yangpeilyn/lamp:basic
	
This can be togethered with the option ```-v path/to/server/file:/var/www/{sitename}/public_html/``` to mount a local folder for server files.

###Enable run docker container inside docker container (docker-in-docker)
-----	
If we actually just need a "sibling" container (i.e. not a "child" container) we can use the following starter command (we also need to install "lxc" for the original container):

	docker run -d -p 8080:80 -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker --name=web yangpeilyn/lamp:basic
	
Then call "docker" inside the original container can be viewed as running container in the hosting system.
	
###All-in-One Starter
-----
	docker run -d -p 8080:80 -e ON_CREATE_DB="db_name" -e SITENAME="sitename" -e STARTUP_SQL="/tmp/sql_file_name" -v /path/to/server/files/:/var/www/sitename/public_html/ -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker -v /path/to/backup/sql/file/:/tmp --name=web yangpeilyn/lamp:basic

	
###Environment variables
-----
*MYSQL_USER*: Set a specific username for the admin account (default 'admin').

*MYSQL_PASS*: Set a specific password for the admin account (default a randomly generated password).

*STARTUP_SQL*: Defines one or more SQL scripts separated by spaces to initialize the database. Note that the scripts must be inside the container, so you may need to mount them.

*PHPMYADMIN_ALIAS*: Alias of PHPMyAdmin (default 'dba').
