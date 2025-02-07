<?php

	include_once 'api_Sado_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function W1($id, $conn)
	{
		$list=array();
		$sql="select d.* from userdata d, users u, companiesperuser p, companies c where d.coduser=u.iduser and u.iduser=p.coduser and p.codcompany=c.idcompany and c.codmaster=$id AND d.deleted=0;";
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

	function W2($fname, $lname, $mail, $phone, $bdate, $nif, $country, $pwd, $codcompany, $codaccess ,$conn)
	{
		if($pwd='')
		{
			$pwd=Uni_Code_Usr($conn);
			$sql="insert into users (pwd) values ('$pwd');";
		}
		else
		{
			$rawSalt = random_bytes(20);
			$formattedSalt = bin2hex($rawSalt);
			$pwd = crypt($pwd, '$2a$12$' . $formattedSalt);
			$sql="insert into users (pwd, salt) values ('$pwd', '$formattedSalt');";
		}
		
		
		SQL_Update($sql, $conn);
			
		$sql="select iduser from users where pwd='$pwd';";
		SQL_Fetch($sql, $conn);
		$results = SQL_Fetch($sql, $conn);
			
		if ($results != "Error Fetching") 
		{
			$row = $results->fetch_assoc();
			$id = $row['iduser'];
			$sql="insert into userdata values ($id, '$lname', '$lname', '$mail', '$phone', '$bdate', '$nif', '$country', $id, 0, '')";
			SQL_Update($sql, $conn);
			$sql="insert into companiesperuser values ($codcompany, $id, $codaccess);";
			SQL_Update($sql, $conn);
			//$sql="insert into logs (codcompany, coduser, type, selectedtable, idobject, date) values ()"
		}
		
		
		
		
		
	
	}
	function W3($id, $idcompany, $conn)
	{
		$list=array();
		$sql="select d.* from userdata d, users u, companiesperuser p, companies c where d.coduser=u.iduser and u.iduser=p.coduser and p.codcompany=c.idcompany and c.codmaster=$id and c.idcompany=$idcompany and d.deleted=0;";
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

	function W4($fname, $lname, $mail, $phone, $bdate, $nif, $country, $description, $id, $conn)
	{
		$list=array();
		$sql="update userdata set firstname='$fname', lastname='$lname', mail='$mail', phone='$phone', birthdate='$bdate', nif='$nif', country='$country', description='$description' where coduser=$id";
		SQL_Update($sql, $conn);

	}

	function W5($id, $conn)
	{
		$sql="update userdata set deleted=1 where coduser=$id;";
		SQL_Update($sql, $conn);
	}


	
?>