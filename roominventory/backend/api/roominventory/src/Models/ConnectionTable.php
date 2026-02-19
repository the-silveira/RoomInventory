<?php
// /src/Models/ConnectionTable.php
namespace API\Models;

use API\Database;
use PDO;

class ConnectionTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function findAll()
    {
        $sql = "SELECT * FROM Connections";
        $stmt = $this->conn->query($sql);
        return $stmt->fetchAll();
    }
    
    public function saveAll($states, $connections)
    {
        try {
            $this->conn->beginTransaction();
            
            // Clear all connections
            $this->conn->exec("TRUNCATE TABLE Connections");
            
            // Update channel states
            $channelTable = new ChannelTable();
            $channelTable->updateStates($states);
            
            // Insert new connections
            if (!empty($connections)) {
                $sql = "INSERT INTO Connections (source_channel_id, target_channel_id) VALUES (:source, :target)";
                $stmt = $this->conn->prepare($sql);
                
                foreach ($connections as $conn) {
                    $stmt->execute([
                        'source' => $conn['source'],
                        'target' => $conn['target']
                    ]);
                }
            }
            
            $this->conn->commit();
            return true;
        } catch (\Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }
}