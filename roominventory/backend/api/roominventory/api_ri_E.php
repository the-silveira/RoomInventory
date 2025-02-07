<?php

	include_once 'api_ri_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function E1($conn)
	{
		$list=array();
		$sql="select * from Events;";
		$result = SQL_Fetch($sql, $conn);
		if ($result && $result->num_rows > 0) 
		{
			while($row = $result->fetch_assoc())
			{
				$list[]=$row;
			}
			echo json_encode($list);
		}
		else
		{
			echo json_encode(0);
		}	
	}
?>