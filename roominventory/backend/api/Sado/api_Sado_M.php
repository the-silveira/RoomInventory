<?php

	include_once 'api_Sado_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function M1($id, $idcompany, $conn)
	{
		$list=array();
		$sql="select m.* from customers m, companies c where m.codcompany=c.idcompany and c.codmaster=$id and c.idcompany=$idcompany and m.deleted=0";
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


	function M2($name, $nif, $address, $phone, $mail, $id, $conn)
	{
		$list=array();
		$sql="insert into customers (name, nif, address, phone, mail, codcompany, deleted) values ('$name', '$nif', '$address', '$phone', '$mail', $id, 0);";
		SQL_Update($sql, $conn);
	}



	function M3($id, $conn)
	{
		$sql="update customers set deleted=1 where idcustomer=$id";
		SQL_Update($sql, $conn);
	}



	function M4($name, $nif, $address, $phone, $mail, $description, $id, $conn)
	{

		$sql="update customers set name='$name', nif='$nif', address='$address', phone='$phone', mail='$mail', description='$description' where idcustomer=$id;";
		SQL_Update($sql, $conn);
	}

	
?>