<?php

	include_once 'api_Sado_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function P1($id, $conn)
	{
		$list=array();
		$sql="select * from places where codcompany=$id and deleted=0;";
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


	function P2($name, $id, $conn)
	{
		$list=array();
		$sql="insert into places (name, codcompany, deleted) values ('$name', $id, 0);";
		SQL_Update($sql, $conn);
	}



	function P3($id, $conn)
	{
		$sql="update places set deleted=1 where idplace=$id";
		SQL_Update($sql, $conn);
	}



	function P4($name, $description, $id, $conn)
	{
		$sql="update places set name='$name', description='$description' where idplace=$id;";
		SQL_Update($sql, $conn);
	}
	
	
?>