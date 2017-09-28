<?php
$serverName = "(local)";
$connectionInfo = array( "Database"=>"WLE_TOOL");

/* Connect using Windows Authentication. */
$conn = sqlsrv_connect( $serverName, $connectionInfo);
if( $conn === false )
{
	echo "Unable to connect.</br>";
	die( print_r( sqlsrv_errors(), true));
}

?>