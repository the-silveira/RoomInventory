<?php

	include_once 'api_Sado_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function S1($id, $idcompany, $conn)
	{
		$list=array();
		$sql="select s.* from suppliers s, companies c where s.codcompany=c.idcompany and c.codmaster=$id and c.idcompany=$idcompany and s.deleted=0";
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



	function S2($name, $type, $address, $phone, $mail, $id, $conn)
	{
		$list=array();
		$sql="insert into suppliers (name, type, address, phone, mail, codcompany, deleted) values ('$name', '$type', '$address', '$phone', '$mail', $id, 0);";
		SQL_Update($sql, $conn);
	}



	function S3($id, $conn)
	{
		$sql="update suppliers set deleted=1 where idsupplier=$id";
		SQL_Update($sql, $conn);
	}



	function S4($name, $type, $address, $phone, $mail, $description, $id, $conn)
	{

		$sql="update suppliers set name='$name', type='$type', address='$address', phone='$phone', mail='$mail', description='$description' where idsupplier=$id;";
		SQL_Update($sql, $conn);
	}
	
?>