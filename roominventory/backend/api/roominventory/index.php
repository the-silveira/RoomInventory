<?php
// /index.php - Front Controller
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Autoloader
spl_autoload_register(function ($class) {
    $prefix = 'API\\';
    $base_dir = __DIR__ . '/src/';
    
    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }
    
    $relative_class = substr($class, $len);
    $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';
    
    if (file_exists($file)) {
        require $file;
    }
});

// CORS headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Router
require_once __DIR__ . '/src/Router.php';
$router = new API\Router();

// ==================== PLACES ROUTES ====================
$router->addRoute('GET', '/places', 'PlaceController@getAll');
$router->addRoute('GET', '/places/{id}', 'PlaceController@getOne');
$router->addRoute('GET', '/places/{id}/zones', 'PlaceController@getZones');
$router->addRoute('POST', '/places', 'PlaceController@create');
$router->addRoute('PUT', '/places/{id}', 'PlaceController@update');
$router->addRoute('DELETE', '/places/{id}', 'PlaceController@delete');

// ==================== ZONES ROUTES ====================
$router->addRoute('GET', '/zones', 'ZoneController@getAll');
$router->addRoute('GET', '/zones/{id}', 'ZoneController@getOne');
$router->addRoute('GET', '/zones/place/{placeId}', 'ZoneController@getByPlace');
$router->addRoute('GET', '/zones/{id}/items', 'ZoneController@getItems');
$router->addRoute('POST', '/zones', 'ZoneController@create');
$router->addRoute('PUT', '/zones/{id}', 'ZoneController@update');
$router->addRoute('DELETE', '/zones/{id}', 'ZoneController@delete');

// ==================== ITEMS ROUTES ====================
$router->addRoute('GET', '/items', 'ItemController@getAll');
$router->addRoute('GET', '/items/simple', 'ItemController@getAllSimple');
$router->addRoute('GET', '/items/with-details', 'ItemController@getAllWithDetails');
$router->addRoute('GET', '/items/{id}', 'ItemController@getOne');
$router->addRoute('GET', '/items/zone/{zoneId}', 'ItemController@getByZone');
$router->addRoute('GET', '/items/available-for-event/{eventId}', 'ItemController@getAvailableForEvent');
$router->addRoute('POST', '/items', 'ItemController@create');
$router->addRoute('PUT', '/items/{id}', 'ItemController@update');
$router->addRoute('DELETE', '/items/{id}', 'ItemController@delete');

// ==================== DETAILS ROUTES ====================
$router->addRoute('GET', '/items/{id}/details', 'ItemController@getDetails');
$router->addRoute('POST', '/items/{id}/details', 'ItemController@addDetail');
$router->addRoute('DELETE', '/details/{id}', 'DetailController@delete');

// ==================== EVENTS ROUTES ====================
$router->addRoute('GET', '/events', 'EventController@getAll');
$router->addRoute('GET', '/events/{id}', 'EventController@getOne');
$router->addRoute('GET', '/events/{id}/items', 'EventController@getItems');
$router->addRoute('POST', '/events', 'EventController@create');
$router->addRoute('PUT', '/events/{id}', 'EventController@update');
$router->addRoute('DELETE', '/events/{id}', 'EventController@delete');
$router->addRoute('POST', '/events/{id}/items', 'EventController@addItems');
$router->addRoute('DELETE', '/events/{id}/items/{itemId}', 'EventController@removeItem');

// ==================== CHANNELS/CABLES ROUTES ====================
$router->addRoute('GET', '/channels', 'ChannelController@getAll');
$router->addRoute('GET', '/channels/with-connections', 'ChannelController@getAllWithConnections');
$router->addRoute('GET', '/channels/{id}', 'ChannelController@getOne');
$router->addRoute('POST', '/channels/save', 'ChannelController@saveState');
$router->addRoute('GET', '/connections', 'ChannelController@getConnections');

// ==================== STATS/REPORTS ROUTES ====================
$router->addRoute('GET', '/stats/items-by-zone', 'StatsController@itemsByZone');
$router->addRoute('GET', '/stats/events-timeline', 'StatsController@eventsTimeline');

// 404 handler
$router->setNotFoundHandler(function() {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint not found']);
});

// Dispatch the request
$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);