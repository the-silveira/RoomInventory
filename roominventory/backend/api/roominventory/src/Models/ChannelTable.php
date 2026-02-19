<?php
// /src/Models/ChannelTable.php
namespace API\Models;

use API\Database;
use PDO;

class ChannelTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function findAllWithConnections()
    {
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
                c.Position
        ";
        $stmt = $this->conn->query($sql);
        return $stmt->fetchAll();
    }
    
    public function findAll()
    {
        $sql = "SELECT * FROM Channels ORDER BY Position";
        $stmt = $this->conn->query($sql);
        return $stmt->fetchAll();
    }
    
    public function find($id)
    {
        $sql = "SELECT * FROM Channels WHERE IdChannel = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['id' => $id]);
        return $stmt->fetch();
    }
    
    public function updateStates($states)
    {
        $sql = "UPDATE Channels SET State = :state WHERE IdChannel = :id";
        $stmt = $this->conn->prepare($sql);
        
        foreach ($states as $id => $state) {
            $stmt->execute([
                'state' => $state,
                'id' => $id
            ]);
        }
        
        return true;
    }
}