<?php
// /src/Models/EventTable.php
namespace API\Models;

use API\Database;
use PDO;
use DateTime;

class EventTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function findAll()
    {
        $today = (new DateTime())->format('Y-m-d');
        
        $sql = "
            SELECT * FROM Events 
            ORDER BY 
                CASE 
                    WHEN Date = :today THEN 1
                    WHEN Date > :today THEN 2
                    WHEN Date < :today THEN 3
                END,
                Date DESC
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['today' => $today]);
        return $stmt->fetchAll();
    }
    
    public function find($id)
    {
        $sql = "SELECT * FROM Events WHERE IdEvent = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['id' => $id]);
        return $stmt->fetch();
    }
    
    public function findItemsWithDetails($eventId)
    {
        $sql = "
            SELECT i.*, d.*, p.*, z.*
            FROM items i
            JOIN item_event it ON it.FK_IdItem = i.IdItem
            JOIN events e ON e.IdEvent = it.FK_IdEvent
            LEFT JOIN details d ON d.FK_IdItem = i.IdItem
            LEFT JOIN zones z ON z.IdZone = i.FK_IdZone
            LEFT JOIN places p ON p.IdPlace = z.FK_IdPlace
            WHERE e.IdEvent = :eventId
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['eventId' => $eventId]);
        return $stmt->fetchAll();
    }
    
    public function insert($data)
    {
        $sql = "
            INSERT INTO Events (IdEvent, EventName, EventPlace, NameRep, EmailRep, TecExt, Date) 
            VALUES (:id, :name, :place, :repName, :repEmail, :tecExt, :date)
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            'id' => $data['IdEvent'],
            'name' => $data['EventName'],
            'place' => $data['EventPlace'],
            'repName' => $data['NameRep'],
            'repEmail' => $data['EmailRep'],
            'tecExt' => $data['TecExt'] ?? '',
            'date' => $data['Date']
        ]);
        return $data['IdEvent'];
    }
    
    public function update($id, $data)
    {
        $sql = "
            UPDATE Events 
            SET EventName = :name, 
                EventPlace = :place, 
                NameRep = :repName, 
                EmailRep = :repEmail, 
                TecExt = :tecExt, 
                Date = :date 
            WHERE IdEvent = :id
        ";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            'id' => $id,
            'name' => $data['EventName'],
            'place' => $data['EventPlace'],
            'repName' => $data['NameRep'],
            'repEmail' => $data['EmailRep'],
            'tecExt' => $data['TecExt'] ?? '',
            'date' => $data['Date']
        ]);
    }
    
    public function delete($id)
    {
        try {
            $this->conn->beginTransaction();
            
            // Delete from item_event junction table
            $sql1 = "DELETE FROM item_event WHERE FK_IdEvent = :id";
            $stmt1 = $this->conn->prepare($sql1);
            $stmt1->execute(['id' => $id]);
            
            // Delete the event
            $sql2 = "DELETE FROM Events WHERE IdEvent = :id";
            $stmt2 = $this->conn->prepare($sql2);
            $stmt2->execute(['id' => $id]);
            
            $this->conn->commit();
            return true;
        } catch (\Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }
}