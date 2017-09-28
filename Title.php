
<div class='col-md-12'>
	<div class="jumbotron">
		<h1>WLE-BASIN TOOL</h1>
	</div>
</div>
<?php
if (! isset ( $_COOKIE ['WLEUserId'] )) {
	header ( 'Location : Signin.php' );
}
?>
<div class='col-md-12'>
	<nav class="navbar navbar-default">
		<ul class="nav nav-tabs">
			<li class="active"><a href="home.php">Home</a></li>
			<li><a href="Docs/QuickStartV2.pdf">Quick Start</a></li>
			<li><a href="https://github.com/">Source Code</a></li>
			<li><a href="contactus.php">Contact us</a></li>
				<?php
				
				if (isset ( $_COOKIE ['WLEUserId'] )) {
					echo '<li class="pull-right"><a href="logout.php">Logout</a></li><li class="pull-right"><a id="username">Hello,<strong>' . $_COOKIE ['WLEUserName'] . '</strong>!</a></li>';
				}
				
				?>
				</ul>
