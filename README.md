Out-of-the-box LAMP image (PHP+MySQL)


Apache2 Conf Changes
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

MySQL Conf Changes
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

PHP Conf Changes
------------------------------

This aims to optimize PHP for web server that does not have too much memory.

	max_execution_time = 30
	memory_limit = 128M
	error_reporting = E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR
	display_errors = Off
	log_errors = On
	error_log = /var/log/php/error.log
	register_globals = Off
