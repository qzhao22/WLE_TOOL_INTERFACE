<!-- THis page is used to register the signup information of new users in the database system and also it will provide error information to the user if the registration fails. -->
<?php

include "linkdatabase.php";
$name = $_POST ['InputName'];
$email = $_POST ['InputEmail'];
$pwd = $_POST ['inputPassword'];
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

$tsql = "SELECT COUNT(*) FROM Users WHERE Email = '".$email."'; ";

$stmt = sqlsrv_query ( $conn, $tsql );

if(sqlsrv_fetch( $stmt ) === false )
{
	echo "Error in retrieving row.\n";
	die( print_r( sqlsrv_errors(), true));
}

$num = sqlsrv_get_field( $stmt, 0 );
if ($num > 0) {
	echo $num;
	header ( 'Location: Signup.php?emailused=1;' );
	die ( print_r ( sqlsrv_errors (), true ) );
}

/* Set up the parameterized query. */
$tsql = "INSERT INTO Users(Name,Pwd,Email) VALUES('" . $name . "','" . $pwd . "','" . $email . "') ";
/* Prepare and execute the query. */
echo $stmt;
$stmt = sqlsrv_query ( $conn, $tsql );
if ($stmt) {
	
} 

else {
	echo "Row insertion failed.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
$tsql = "SELECT * FROM Users WHERE Email = '".$email."'; ";

$stmt = sqlsrv_query ( $conn, $tsql );

/* Execute the query. */
if ($stmt === false) {
	echo "Error in statement execution.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

else {
	while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
		$id = $row[UserId];
		if(isset($_COOKIE['WLEUserId']))
		{
			setcookie("WLEUserId",'', time()-3600*12);
			setcookie("WLEUserName",'', time()-3600*12);
			setcookie("WLEUserEmail",'',time()-3600*12);
		}
		setcookie("WLEUserId",$id, time()+3600*12);
		setcookie("WLEUserName",$name, time()+3600*12);
        setcookie("WLEUserEmail",$email,time()+3600*12);
		
	}echo "Sign Up Successfully!";
	$url = signin.php;
	header("Location: Signin.php"); 
}

sqlsrv_free_stmt ( $stmt );
sqlsrv_close ( $conn );
?>
