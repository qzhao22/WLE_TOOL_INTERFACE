<!-- Send a email to the developer if a contact request has been submitted. -->

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agent Based Model Web Based Application</title>
<meta name="description"
	content="Run Model|Agent Based Model Web Based Application.">
<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="./bootstrap/js/bootstrap.min.js"></script>
<h3>
<?php
include "Title.php";
require 'PHPMailer/PHPMailerAutoload.php';

$mail = new PHPMailer;

$mail->isSMTP();                                      // Set mailer to use SMTP
$mail->Host = 'smtp.gmail.com';  // Specify main and backup SMTP servers
$mail->SMTPAuth = true;                               // Enable SMTP authentication
$mail->Username = 'wlebasintoolcontact@gmail.com';                 // SMTP username
$mail->Password = 'abmswatmodel';                           // SMTP password
$mail->SMTPSecure = 'tls';                            // Enable encryption, 'ssl' also accepted

$mail->From = 'wlebasintoolcontact@gmail.com';
$mail->FromName = 'ABM Web';
$mail->addAddress('qzhao22@illinois.edu');     // Add a recipient
//$mail->addAddress('ellen@example.com');               // Name is optional
$mail->addCC('zhaoqiankun07@gmail.com');

$mail->WordWrap = 50;                                 // Set word wrap to 50 characters
$mail->isHTML(true);                                  // Set email format to HTML

$mail->Subject = $_GET['mailsubject'];
$content = $_GET['from']."<br>
		".$_GET['mailbody']."<br>
				".$_GET['email'];
$mail->Body    = $content;
$mail->AltBody = $content;

if(!$mail->send()) {
	echo 'Message could not be sent.';
	echo 'Please try again later!';
} else {
	echo 'Message has been sent! We will contact you later.';
}
?>
</h3>