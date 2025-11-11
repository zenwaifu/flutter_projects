<?php
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "myfuwudb";

    // Create connection
    // defined connqection variable, mysqli object -> from mysql library which is used to connect to mysql database
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection 
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
?>