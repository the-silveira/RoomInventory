<?php

	include_once 'api_Sado_SQL.php';
	include_once 'api_Sado_Logis.php';
	include_once 'api_Sado_Mail.php';

	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');
    require_once 'PHPMailer/src/Exception.php';
    require_once 'PHPMailer/src/PHPMailer.php';
    require_once 'PHPMailer/src/SMTP.php';
    use PHPMailer\PHPMailer\PHPMailer;
    use PHPMailer\PHPMailer\Exception;



	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



function U1($log, $pwd, $conn)
	{
		$sql = "select coduser from userdata where mail='$log';";
		$result = SQL_Fetch($sql, $conn);
		if ($result && $result->num_rows > 0) 
		{
			$row = $result->fetch_assoc();
			$id = $row['coduser'];
			$sql = "SELECT salt FROM users WHERE iduser = $id;";
			$results = SQL_Fetch($sql, $conn);
			if ($results != "Error Fetching") 
			{
				$row = $results->fetch_assoc();
				$salt = $row['salt'];
				$hash = crypt($pwd, '$2a$12$' . $salt);
				$sql = "SELECT u.iduser, d.coduser as codmaster FROM users u, userdata d WHERE d.mail = '$log' AND u.pwd = '$hash' and u.iduser=d.coduser";
				$result = SQL_Fetch($sql, $conn);
				if ($result != "Error Fetching") {
					$row = $result->fetch_assoc();
					
					$sql="select c.codmaster from companies c, users u, companiesperuser p where u.iduser=p.coduser and p.codcompany=c.idcompany and u.iduser=$id limit 1 ";
					$results = SQL_Fetch($sql, $conn);
					if ($results && $results->num_rows > 0) 
                	{
						$companyRow = $results->fetch_assoc();
                    	// Successfully fetched a company, add it to the response
                    	$row['codmaster'] = $companyRow['codmaster'];
                	} 
                	
					
					
					echo json_encode($row);
					
					
					
					
					
					
					
					

					/*$id = $row['iduser'];
					$rawSalt = random_bytes(20);
					$formattedSalt = bin2hex($rawSalt);
					$pass = crypt($pwd, '$2a$12$' . $formattedSalt);

					$sql = "UPDATE users SET pwd='$pass', salt='$formattedSalt' WHERE iduser=$id;";
					//echo $sql;
					SQL_Update($sql, $conn); // Pass $conn to SQL_Update*/
					
				} 
				else 
				{
					echo json_encode("Wrong Pass");
				}
			} 
			else 
			{
				echo json_encode("No Users Found");
			}
		}
		else
		{
			echo json_encode(0);
		}
		
	}



	function U2($email, $op, $conn)
	{
		if (empty($email)) 
		{
			die('Email address is required.');
		} 
		else 
		{
			$VM=Verify_Mail($email, $conn);
			//echo $VM;
			if($VM==1 && $op ==0)
			{
				echo json_encode(0);
			}
			else 
			{
				if($op==0||$op==1)
				{			
					$random_code=Uni_Code_Usr($conn);
					if($op==0)
					{ 
						$sql="insert into users (pwd) values ('$random_code');";
						SQL_Update($sql, $conn);
						
						$sql="select * from users where pwd='$random_code';";
						SQL_Fetch($sql, $conn);
						
						$results = SQL_Fetch($sql, $conn);
						if ($results != "Error Fetching") 
						{
							$row = $results->fetch_assoc();
							$id = $row['IdUser'];
							$random_code=Uni_Code($conn);
							$sql="insert into userdata(iddata, mail, coduser) values($id, '$email', $id);";
							SQL_Update($sql, $conn);
							$sql="insert into usercod(idcode, tempcod, coduser) values($id, '$random_code', $id);";
							SQL_Update($sql, $conn);
							$subject='Registration Confirmation Code';			
						}	
					}
					else
					{
						$random_code=Uni_Code($conn);
						$sql="update usercod c, userdata d set c.tempcod='$random_code' where c.coduser=d.coduser and d.mail='$email';";
						SQL_Update($sql, $conn);
						$subject="Resend Registration Confirmation Code";
					}
					$body = "Here is your registration code: " . $random_code . "<br>" .
									"This is an automatic email. Please don't respond.</p><br><br>
									With best regards;<br>
									Sado Team.";
					
					Mandar_Mail($email, $subject, $body);	

				}	
			}	
		}
	}
	


	function U3($cod, $conn)
	{
		$sql = "select coduser from usercod where tempcod='$cod';";
		$result = SQL_Fetch($sql, $conn);
		if ($result != "Error Fetching") 
		{
			$row = $result->fetch_assoc();
			echo json_encode($row);
		} 
		else 
		{
			echo "fuck";
		}
	}



	function U4($pwd, $id, $conn)
	{
		$rawSalt = random_bytes(20);
		$formattedSalt = bin2hex($rawSalt);
		$pass = crypt($pwd, '$2a$12$' . $formattedSalt);

		$sql = "update users set pwd='$pass', salt='$formattedSalt' where iduser=$id;";
		$result = SQL_Update($sql, $conn);
		if ($result != "Error Fetching") 
		{
			echo "yup";
		} 
		else 
		{
			echo "fuck";
		}

	}



	function U5($firstname, $lastname, $phone, $date, $nif, $country, $id, $conn)
	{
		$sql = "update userdata set firstname='$firstname', lastname='$lastname', phone='$phone', birthdate='$date', nif='$nif',   country='$country 'where coduser=$id;";
		$result = SQL_Update($sql, $conn);
		if ($result != "Error Fetching") 
		{
			$sql = "Select mail from users where IdUser=$id;";
			$result = SQL_Fetch($sql, $conn);
			$row = $result->fetch_assoc();
			echo json_encode($row);
			
			$sql="INSERT INTO userprofiles (Name, Access, CodMaster) VALUES 
					('Admin', 4, $id), 
					('Creator', 3, $id), 
					('Editor', 2, $id), 
					('Reader', 1, $id), 
					('No Access', 0, $id);";	
			$result = SQL_Update($sql, $conn);
			Mandar_Mail($row['mail'],'Welcome to Sado!',"Welcome to Sado More <br>This is an automatic email. Please don't respond.</p><br><br>
									With best regards;<br>
									Sado Team.");
		} 
		else 
		{
			echo "fuck";
		}
	}

	
	function U6($email, $op, $conn)
	{
		if (empty($email)) 
		{
			die('Email address is required.');
		} 
		else 
		{
			$VM=Verify_Mail_Exists($email, $conn);
			if($VM==0)
			{
				echo json_encode(0);
			}
			else 
			{
				if($op==0||$op==1||$op==2)
				{			
					$random_code=Uni_Code($conn);
					$sql="update users set tempcod='$random_code' where mail='$email';";
					SQL_Update($sql, $conn);
					
			
					$subject = match ($op) 
					{
						'0' => 'Password Recovery',
						'1' => 'Resend Password Confirmation Code',
						'2' => 'Changed the Password',
						default => 'Assunto Desconhecido',
					};

					$body = match ($op) 
					{
						'0', '1' => "Here is your password recovery code: " . $random_code . "<br>" ."This is an automatic email. Please don't respond.</p><br><br>
									With best regards;<br>
									Sado Team.",
						'2' => "Your password has been changed successfully.<br>
								If you have not changed your password, please contact us.<br>
								This is an automatic email. Please don't respond.<br><br>
								With best regards;<br>
								Sado Team.",
						default => 'Conteúdo Desconhecido',
					};
					Mandar_Mail($email, $subject, $body);	
				}			
			}	
		}
	}
	function U7($id, $conn)
	{
		$sql="select firstname from userdata where coduser=$id;";
		$result = SQL_Fetch($sql, $conn);
		$row = $result->fetch_assoc();
		if(empty($row['firstname']))
		{
			echo json_encode(0);
		}
		else
		{
			echo json_encode(1);
		}
		
		
	}
?>