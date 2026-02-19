<?php
// /src/Models/ItemEventTable.php
namespace API\Models;

use API\Database;
use PDO;

class ItemEventTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function addItemsToEvent($eventId, $items)
    {
        try {
            $this->conn->beginTransaction();
            
            $sql = "INSERT INTO item_event (FK_IdEvent, FK_IdItem) VALUES (:eventId, :itemId)";
            $stmt = $this->conn->prepare($sql);
            
            foreach ($items as $item) {
                $stmt->execute([
                    'eventId' => $eventId,
                    'itemId' => $item['IdItem']
                ]);
            }
            
            $this->conn->commit();
            return true;
        } catch (\Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }
    
    public function removeItemFromEvent($eventId, $itemId)
    {
        $sql = "DELETE FROM item_event WHERE FK_IdEvent = :eventId AND FK_IdItem = :itemId";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            'eventId' => $eventId,
            'itemId' => $itemId
        ]);
    }
    
    public function itemInEvent($eventId, $itemId)
    {
        $sql = "SELECT COUNT(*) as count FROM item_event WHERE FK_IdEvent = :eventId AND FK_IdItem = :itemId";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            'eventId' => $eventId,
            'itemId' => $itemId
        ]);
        $result = $stmt->fetch();
        return $result['count'] > 0;
    }
}