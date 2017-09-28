<?php

	setcookie("WLEUserId",'', time()-3600*12);
	setcookie("WLEUserName",'', time()-3600*12);
	setcookie("WLEUserEmail",'',time()-3600*12);
	setcookie ( "WLEUserEmailSignedIn", '', time ()- 3600 * 12 );
	header('location: signin.php')
?>