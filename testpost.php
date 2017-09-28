<?php
include "sendpost.php";
$post_data = array('Name'=>'2_var');
send_post('getelectivevarinfor.php', $post_data);
?>