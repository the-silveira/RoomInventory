<?php
// /src/Models/DetailTable.php
namespace API\Models;

use API\Database;
use PDO;

class DetailTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function findByItem($itemId)
    {
        $sql = "SELECT * FROM details WHERE FK_IdItem = :itemId";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['itemId' => $itemId]);
        return $stmt->fetchAll();
    }
    
    public function insert($itemId, $data)
    {
        $sql = "INSERT INTO details (DetailsName, Details, FK_IdItem) VALUES (:name, :details, :itemId)";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            'name' => $data['DetailsName'],
            'details' => $data['Details'],
            'itemId' => $itemId
        ]);
        return $this->conn->lastInsertId();
    }
    
    public function delete($id)
    {
        $sql = "DELETE FROM details WHERE IdDetail = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute(['id' => $id]);
    }
}