<!-- This page is used to check the sign in information provided by the user, it will be compared with the records in the database. -->
<!-- If there is correct matches , the webpage will automatically go to the homepage. -->
<!-- Otherwise, it will return back to the login page. -->


<?php



include "linkdatabase.php";
$email = $_POST ['inputEmail'];
$pwd = $_POST ['inputPassword'];

if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

$tsql = "SELECT * FROM Users WHERE Email = '" . $email . "'; ";

$stmt = sqlsrv_query ( $conn, $tsql );

/* Execute the query. */
if ($stmt === false) {
	echo "Error in statement execution.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
} 

else {
	while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
		$psswrd = $row [ Pwd];
		$name = $row[Name];
		$id = $row[UserId];
	}
	if($psswrd===$pwd){
		if (isset ( $_COOKIE ['WLEUserId'] )) {
			setcookie ( "WLEUserId", '', time () - 3600 * 12 );
			setcookie ( "WLEUserName", '', time () - 3600 * 12 );
			setcookie ( "WLEUserEmail", '', time () - 3600 * 12 );
			setcookie ( "WLEUserEmailSignedIn", '', time () - 3600 * 12 );
		}
		setcookie ( "WLEUserId", $id, time () + 3600 * 12 );
		setcookie ( "WLEUserName", $name, time () + 3600 * 12 );
		setcookie ( "WLEUserEmail", $email, time () + 3600 * 12 );
		setcookie ( "WLEUserEmailSignedIn", 1, time ()+ 3600 * 12 );
		echo "Sign in Successfully!";
		header ( "Location: home.php" );
	}
	else 
	{
		header ( "Location: Signin.php?Password=0" );
	}
}

sqlsrv_free_stmt ( $stmt );
sqlsrv_close ( $conn );
?>