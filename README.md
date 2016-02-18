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
	
To run the image and bind to port 3306:

	docker run -d -p 8080:80 -name web yangpeilyn/lamp:basic

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

    docker run -d -p 8080:80 -e MYSQL_PASS="mypass" -name web yangpeilyn/lamp:basic
You can now test your deployment:

    mysql -uadmin -p"mypass"
The admin username can also be set via the MYSQL_USER environment variable.

