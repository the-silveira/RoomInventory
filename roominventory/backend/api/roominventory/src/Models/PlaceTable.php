<?php
// /src/Models/PlaceTable.php
namespace API\Models;

use API\Database;
use PDO;

class PlaceTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function findAll()
    {
        $sql = "SELECT * FROM Places ORDER BY IdPlace";
        $stmt = $this->conn->query($sql);
        return $stmt->fetchAll();
    }
    
    public function find($id)
    {
        $sql = "SELECT * FROM Places WHERE IdPlace = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['id' => $id]);
        return $stmt->fetch();
    }
    
    public function insert($data)
    {
        // Adjust column names based on your actual Places table structure
        $sql = "INSERT INTO Places (PlaceName, Address) VALUES (:name, :address)";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            'name' => $data['PlaceName'] ?? '',
            'address' => $data['Address'] ?? ''
        ]);
        return $this->conn->lastInsertId();
    }
    
    public function update($id, $data)
    {
        $sql = "UPDATE Places SET PlaceName = :name, Address = :address WHERE IdPlace = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            'id' => $id,
            'name' => $data['PlaceName'] ?? '',
            'address' => $data['Address'] ?? ''
        ]);
    }
    
    public function delete($id)
    {
        $sql = "DELETE FROM Places WHERE IdPlace = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute(['id' => $id]);
    }
}