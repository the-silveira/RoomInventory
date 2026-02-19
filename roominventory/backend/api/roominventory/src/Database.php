<?php
// /src/Database.php
namespace API;

use PDO;
use PDOException;
use API\Config\Database as DatabaseConfig;

class Database
{
    private $connection;
    private $config;
    
    public function __construct()
    {
        $this->config = DatabaseConfig::getConfig();
    }
    
    public function getConnection()
    {
        if ($this->connection === null) {
            try {
                $dsn = "mysql:host={$this->config['host']};dbname={$this->config['dbname']};charset={$this->config['charset']}";
                $this->connection = new PDO($dsn, $this->config['username'], $this->config['password']);
                $this->connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                $this->connection->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
                $this->connection->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
            } catch (PDOException $e) {
                error_log("Database connection failed: " . $e->getMessage());
                http_response_code(500);
                echo json_encode(['error' => 'Database connection failed']);
                exit();
            }
        }
        
        return $this->connection;
    }
}