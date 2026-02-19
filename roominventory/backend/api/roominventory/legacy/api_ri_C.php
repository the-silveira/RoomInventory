<?php

	include_once 'api_ri_SQL.php';


	header("Access-Control-Allow-Origin: *");
	header("Content-Type: application/json; charset=UTF-8");
	header('Content-Type: application/json');




	// Enable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 1);


    function D1($conn)
    {
        $list = array();
        $sql = "
            SELECT 
                c.IdChannel,
                c.Position,
                c.Type,
                c.State,
                GROUP_CONCAT(CONCAT(src.Position, '→', dest.Position) SEPARATOR ', ') AS Connections
            FROM Channels c
            LEFT JOIN Connections con ON c.IdChannel = con.source_channel_id
            LEFT JOIN Channels src ON con.source_channel_id = src.IdChannel
            LEFT JOIN Channels dest ON con.target_channel_id = dest.IdChannel
            GROUP BY c.IdChannel
            ORDER BY 
                CASE 
                    WHEN c.Type = 'fixture' THEN 1 
                    WHEN c.Type = 'dmx' THEN 2 
                    ELSE 3 
                END,
                c.Position;
        ";
        
        $result = SQL_Fetch($sql, $conn);
        if ($result && $result->num_rows > 0) 
        {
            while($row = $result->fetch_assoc())
            {
                $list[] = $row;    
            }
            echo json_encode($list);
        }
        else
        {
            echo json_encode(0);
        }    
    }
?> 