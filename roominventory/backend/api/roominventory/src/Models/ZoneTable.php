<?php
// /src/Models/ZoneTable.php
namespace API\Models;

use API\Database;
use PDO;

class ZoneTable
{
    private $conn;
    
    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }
    
    public function findAll()
    {
        $sql = "SELECT * FROM zones ORDER BY IdZone";
        $stmt = $this->conn->query($sql);
        return $stmt->fetchAll();
    }
    
    public function findByPlace($placeId)
    {
        $sql = "SELECT * FROM zones WHERE FK_IdPlace = :placeId ORDER BY IdZone";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['placeId' => $placeId]);
        return $stmt->fetchAll();
    }
    
    public function find($id)
    {
        $sql = "SELECT * FROM zones WHERE IdZone = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute(['id' => $id]);
        return $stmt->fetch();
    }
    
    public function insert($data)
    {
        $sql = "INSERT INTO zones (ZoneName, FK_IdPlace) VALUES (:name, :placeId)";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            'name' => $data['ZoneName'] ?? '',
            'placeId' => $data['FK_IdPlace'] ?? null
        ]);
        return $this->conn->lastInsertId();
    }
    
    public function update($id, $data)
    {
        $sql = "UPDATE zones SET ZoneName = :name, FK_IdPlace = :placeId WHERE IdZone = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            'id' => $id,
            'name' => $data['ZoneName'] ?? '',
            'placeId' => $data['FK_IdPlace'] ?? null
        ]);
    }
    
    public function delete($id)
    {
        $sql = "DELETE FROM zones WHERE IdZone = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute(['id' => $id]);
    }
}