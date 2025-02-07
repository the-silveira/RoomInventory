
<?php

include_once 'api_ri_SQL.php';
include_once 'api_ri_P.php';
include_once 'api_ri_E.php';


header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header('Content-Type: application/json');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost:3306";
$username = "itg_inventory_admin";
$password = "AAbb#1122";
$dbname = "itg_roominventary";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
$conn->set_charset("utf8mb4");

if ($_SERVER["REQUEST_METHOD"] == "POST") 
{
    if (isset($_POST['query_param'])) 
	{
        return match($_POST['query_param'])
        {
            'P1' => P1($conn),
			'E1' => E1($conn),
	
			
			
			
			default => 'Invalid Query',
        };
    }
}
?>
