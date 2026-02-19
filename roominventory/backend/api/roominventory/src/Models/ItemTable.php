<?php
// /src/Models/ItemTable.php
namespace API\Models;

use API\Database;
use PDO;

class ItemTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function findAllWithDetails()
    {
        $sql = "
            SELECT i.*, d.*, p.*, z.*
            FROM items i
            LEFT JOIN details d ON d.FK_IdItem = i.IdItem
            LEFT JOIN zones z ON z.IdZone = i.FK_IdZone
            LEFT JOIN places p ON p.IdPlace = z.FK_IdPlace
            ORDER BY z.IdZone, i.IdItem
        ";
        $stmt = $this->conn->query($sql);
        return $stmt->fetchAll();
    }
    
    public function findAllSimple()
    {
        $sql = "SELECT * FROM items ORDER BY IdItem";
        $stmt = $this->conn->query($sql);
        return $stmt->fetchAll();
    }
    
    public function find($id)
    {
        $sql = "
            SELECT i.*, d.*, z.*, p.*
            FROM items i
            LEFT JOIN details d ON d.FK_IdItem = i.IdItem
            LEFT JOIN zones z ON z.IdZone = i.FK_IdZone
            LEFT JOIN places p ON p.IdPlace = z.FK_IdPlace
            WHERE i.IdItem = :id
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['id' => $id]);
        return $stmt->fetch();
    }
    
    public function findByZone($zoneId)
    {
        $sql = "SELECT * FROM items WHERE FK_IdZone = :zoneId ORDER BY ItemName";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['zoneId' => $zoneId]);
        return $stmt->fetchAll();
    }
    
    public function findAvailableForEvent($eventId)
    {
        $sql = "
            SELECT i.*
            FROM items i
            LEFT JOIN item_event e ON i.IdItem = e.FK_IdItem AND e.FK_IdEvent = :eventId
            WHERE e.FK_IdEvent IS NULL
            ORDER BY i.IdItem
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['eventId' => $eventId]);
        return $stmt->fetchAll();
    }
    
    public function insert($data)
    {
        // First check if item already exists
        if ($this->exists($data['IdItem'])) {
            return ['error' => 'Item already exists', 'code' => 'DUPLICATE'];
        }
        
        $sql = "INSERT INTO items (IdItem, ItemName, FK_IdZone) VALUES (:id, :name, :zoneId)";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            'id' => $data['IdItem'],
            'name' => $data['ItemName'],
            'zoneId' => $data['FK_IdZone']
        ]);
        
        return ['success' => true, 'id' => $data['IdItem']];
    }
    
    public function update($id, $data)
    {
        $sql = "UPDATE items SET ItemName = :name, FK_IdZone = :zoneId WHERE IdItem = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            'id' => $id,
            'name' => $data['ItemName'] ?? '',
            'zoneId' => $data['FK_IdZone'] ?? null
        ]);
    }
    
    public function delete($id)
    {
        try {
            $this->conn->beginTransaction();
            
            // Delete from item_event junction table first
            $sql1 = "DELETE FROM item_event WHERE FK_IdItem = :id";
            $stmt1 = $this->conn->prepare($sql1);
            $stmt1->execute(['id' => $id]);
            
            // Delete details
            $sql2 = "DELETE FROM details WHERE FK_IdItem = :id";
            $stmt2 = $this->conn->prepare($sql2);
            $stmt2->execute(['id' => $id]);
            
            // Delete the item
            $sql3 = "DELETE FROM items WHERE IdItem = :id";
            $stmt3 = $this->conn->prepare($sql3);
            $stmt3->execute(['id' => $id]);
            
            $this->conn->commit();
            return true;
        } catch (\Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }
    
    public function exists($id)
    {
        $sql = "SELECT COUNT(*) as count FROM items WHERE IdItem = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['id' => $id]);
        $result = $stmt->fetch();
        return $result['count'] > 0;
    }
}