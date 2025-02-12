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
		$sql="SELECT * 
FROM Events 
ORDER BY 
  CASE 
    WHEN Date = CURDATE() THEN 1  -- Today's events (highest priority)
    WHEN Date > CURDATE() THEN 2  -- Future events (second priority)
    WHEN Date < CURDATE() THEN 3  -- Past events (lowest priority)
  END, 
  Date DESC;  -- Sort by date within each category (ascending order)
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
function E2($id, $conn)
	{
		$list=array();
		$sql="SELECT i.*, d.*, p.*, z.*
			FROM items i
			JOIN item_event it ON it.FK_IdItem = i.IdItem
			JOIN events e ON e.IdEvent = it.FK_IdEvent
			JOIN details d on d.FK_IdItem=i.IdItem
            JOIN zones z on z.IdZone=i.FK_Idzone
            JOIN places p on p.IdPlace=z.FK_IdPlace
			WHERE e.IdEvent = '$id';
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