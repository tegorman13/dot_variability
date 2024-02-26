<?php
// get the data from the POST message
$post_data = json_decode(file_get_contents('php://input'), true);
$data = $post_data['filedata'];
// use the provided filename or generate a unique ID for the file
$file = $post_data['filename'] ?? uniqid("sbj-");
// the directory "data" must be writable by the server
$name = "../data/{$file}"; 
// write the file to disk
file_put_contents($name, $data);
?>
