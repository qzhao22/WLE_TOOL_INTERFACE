<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agent Based Model Web Based Application</title>
<meta name="description"
	content="Agent Based Model Web Based Application.">
<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="./bootstrap/js/bootstrap.min.js"></script>

</head>
<body>
<div class='col-md-12'>
<div class="jumbotron">
<h1>WLE-BASIN TOOL</h1>
</div>
</div>

<!-- Sign in page, require email and pwd from user. -->
<?php
				
if (isset ( $_COOKIE ['WLEUserId'] )) {
$uname = $_COOKIE['WLEUserName'];
$uemail = $_COOKIE['WLEUserEmail'];
}
else {
	$uname = '';
	$uemail = '';
}
?>
<div class="container">
<div class='row'>
<div class = 'col-md-4'>
</div>
<div class = 'col-md-4'>
<?php if (isset ( $_GET ['Password'] )) {
	echo "<p><font color='red'><strong>Password does not match<strong></font></p>";
}
?>
<form class="form-signin" action = 'SigninResult.php' method = 'post'>
<h2 class="form-signin-heading">Sign in</h2>
<label for="inputEmail" class="sr-only">Email address</label>
<input <?php if($uemail<>'') echo 'value="'.$uemail.'"'?> type="email" name='inputEmail' id="inputEmail" class="form-control" placeholder="Email address" required autofocus>
<label for="inputPassword" class="sr-only">Password</label>
<input type="password" id="inputPassword" name = "inputPassword" class="form-control" placeholder="Password" required>
<button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
<p><a href = "Signup.php">Sign up</a> if you do not have an account.</p>
</form>
</div>
</div>

</div> <!-- /container -->
</body>
</html>
