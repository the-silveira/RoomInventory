<?php

	include_once 'api_ri_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function I1($conn)
	{
		$list=array();
		$sql="Select i.* from Items i, Details d where i.IdItem=d.FK_IdItem;  -- Sort by date within each category (ascending order)
";
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