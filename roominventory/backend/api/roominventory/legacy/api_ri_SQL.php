<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database configuration
$servername = "localhost:3306";
$username = "itg_inventory_admin";
$password = "AAbb#1122";
$dbname = "itg_roominventary";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
$conn->set_charset("utf8mb4");

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

function SQL_Fetch($sql, $conn)
{
    $result = $conn->query($sql);
    if ($result->num_rows > 0) 
	{
        return $result;
    }
    else
    {
        //echo "Error Fetching";
    }
}

function SQL_Update($sql, $conn)
{
    if ($conn->query($sql) === TRUE) 
    {
        //echo "Create Successful";
    } 
    else 
    {
        echo "Create Failed: " . $conn->error;
    }
    
}

function SQL_Create($sql, $conn)
{
    if ($conn->query($sql) === TRUE) 
    {
        echo "Create Successful";
    } 
    else 
    {
        echo "Create Failed: " . $conn->error;
    }
}





// Close the connection at the end of the file
$conn->close();

?>
