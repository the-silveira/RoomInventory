<?php
// /src/Config/Database.php
namespace API\Config;

class Database
{
    private static $config = [
        'host' => 'localhost:3306',
        'dbname' => 'itg_roominventary',
        'username' => 'itg_inventory_admin',
        'password' => 'AAbb#1122',
        'charset' => 'utf8mb4'
    ];
    
    public static function getConfig()
    {
        return self::$config;
    }
}