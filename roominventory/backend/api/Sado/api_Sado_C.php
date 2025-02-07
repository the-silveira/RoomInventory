<?php

	include_once 'api_Sado_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function C1($id, $conn)
	{
		$list=array();
		$sql="select * from companies where codmaster=$id and deleted=0; ";
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
    function C2($mail, $nif, $duns, $name, $address, $phone, $colour, $country, $codmaster, $conn)
    {
        $sql="insert into companies (mail, nif, duns, name, address, phone, colour, country, codmaster) values ('$mail', '$nif', '$duns', '$name', '$address', '$phone', '$colour', '$country', $codmaster);";
		$result = SQL_Create($sql, $conn);
    }

	function C3($id, $conn)
    {
        $sql="update companies set deleted=1 where idcompany=$id);";
		SQL_Update($sql, $conn);
    }

	function C4($mail, $nif, $duns, $name, $address, $phone, $colour, $country, $id, $description, $conn)
    {
        $sql="update companies set name='$name', mail='$mail', nif='$nif', duns='$duns', address='$address', country='$country', phone='$phone', colour='$colour', description='$description' where idcompany=$id;";
		SQL_Update($sql, $conn);
    }
	
?>