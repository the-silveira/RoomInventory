<?php
	include_once 'api_Sado_SQL.php';

	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);



	function Verify_Mail($email, $conn)
	{
		$sql = "select coduser from userdata where mail='$email';";
		
        $result = SQL_Fetch($sql, $conn);
		//echo json_encode($result);
        if ($result && $result->num_rows > 0) 
        {
			//echo "Olá";
			return 1;
        } 
        else{
			//echo "Olewfdmsfjkhdgsfjmbá";
            return 0;
			
        }
    }
    function Verify_Mail_Exists($email, $conn)
	{
		$sql = "select iduser from users where mail='$email';";
        $result = SQL_Fetch($sql, $conn);
        if ($result && $result->num_rows > 0) 
        {
            return 1;	
		
        } 
        else{
            return 0;
        }
    }



    function Uni_Code($conn)
    {
        $ok=0;
        do
        {
            $random_code = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);
            $sql = "select idcode from usercod where tempcod='$random_code';";
            $result=SQL_Fetch($sql, $conn);
            if ($result && $result->num_rows > 0) 
            {
                $ok=0;
            }
			else
			{
				$ok=1;
			}
        }while ($ok==0);
		return $random_code;
    }



	function Uni_Code_Usr($conn)
    {
        $ok=0;
        do
        {
            $random_code = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);
            $sql = "select iduser from users where pwd='$random_code';";
            $result=SQL_Fetch($sql, $conn);
            if ($result && $result->num_rows > 0) 
            {
                $ok=0;
            }
			else
			{
				$ok=1;
			}
        }while ($ok==0);
		return $random_code;
    }
    
?>
