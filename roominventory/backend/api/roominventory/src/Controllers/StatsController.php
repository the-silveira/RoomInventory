<?php
// /src/Controllers/StatsController.php
namespace API\Controllers;

use API\Database;
use PDO;

class StatsController extends BaseController
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function itemsByZone()
    {
        $sql = "
            SELECT 
                z.IdZone,
                z.ZoneName,
                COUNT(i.IdItem) as item_count
            FROM zones z
            LEFT JOIN items i ON z.IdZone = i.FK_IdZone
            GROUP BY z.IdZone, z.ZoneName
            ORDER BY item_count DESC
        ";
        $stmt = $this->conn->query($sql);
        $stats = $stmt->fetchAll();
        $this->sendResponse(200, $stats);
    }
    
    public function eventsTimeline()
    {
        $sql = "
            SELECT 
                DATE_FORMAT(Date, '%Y-%m') as month,
                COUNT(*) as event_count
            FROM Events
            GROUP BY DATE_FORMAT(Date, '%Y-%m')
            ORDER BY month DESC
        ";
        $stmt = $this->conn->query($sql);
        $stats = $stmt->fetchAll();
        $this->sendResponse(200, $stats);
    }
}