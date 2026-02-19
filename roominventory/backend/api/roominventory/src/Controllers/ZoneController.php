<?php
// /src/Controllers/ZoneController.php
namespace API\Controllers;

use API\Models\ZoneTable;
use API\Models\PlaceTable;
use API\Models\ItemTable;

class ZoneController extends BaseController
{
    private $zoneTable;
    private $placeTable;
    private $itemTable;
    
    public function __construct()
    {
        $this->zoneTable = new ZoneTable();
        $this->placeTable = new PlaceTable();
        $this->itemTable = new ItemTable();
    }
    
    public function getAll()
    {
        $zones = $this->zoneTable->findAll();
        $this->sendResponse(200, $zones ?: []);
    }
    
    public function getOne($id)
    {
        $zone = $this->zoneTable->find($id);
        
        if (!$zone) {
            $this->sendError(404, 'Zone not found');
            return;
        }
        
        $this->sendResponse(200, $zone);
    }
    
    public function getByPlace($placeId)
    {
        $place = $this->placeTable->find($placeId);
        if (!$place) {
            $this->sendError(404, 'Place not found');
            return;
        }
        
        $zones = $this->zoneTable->findByPlace($placeId);
        $this->sendResponse(200, $zones ?: []);
    }
    
    public function getItems($id)
    {
        $zone = $this->zoneTable->find($id);
        if (!$zone) {
            $this->sendError(404, 'Zone not found');
            return;
        }
        
        $items = $this->itemTable->findByZone($id);
        $this->sendResponse(200, $items ?: []);
    }
    
    public function create()
    {
        $data = $this->getRequestData();
        
        $errors = $this->validate($data);
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        // Verify place exists
        $place = $this->placeTable->find($data['FK_IdPlace']);
        if (!$place) {
            $this->sendError(422, 'Invalid place ID');
            return;
        }
        
        try {
            $id = $this->zoneTable->insert($data);
            $zone = $this->zoneTable->find($id);
            $this->sendResponse(201, $zone);
        } catch (\Exception $e) {
            error_log("Failed to create zone: " . $e->getMessage());
            $this->sendError(500, 'Failed to create zone');
        }
    }
    
    public function update($id)
    {
        $zone = $this->zoneTable->find($id);
        if (!$zone) {
            $this->sendError(404, 'Zone not found');
            return;
        }
        
        $data = $this->getRequestData();
        
        $errors = $this->validate($data);
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        // Verify place exists if being changed
        if (isset($data['FK_IdPlace'])) {
            $place = $this->placeTable->find($data['FK_IdPlace']);
            if (!$place) {
                $this->sendError(422, 'Invalid place ID');
                return;
            }
        }
        
        try {
            $this->zoneTable->update($id, $data);
            $zone = $this->zoneTable->find($id);
            $this->sendResponse(200, $zone);
        } catch (\Exception $e) {
            error_log("Failed to update zone: " . $e->getMessage());
            $this->sendError(500, 'Failed to update zone');
        }
    }
    
    public function delete($id)
    {
        $zone = $this->zoneTable->find($id);
        if (!$zone) {
            $this->sendError(404, 'Zone not found');
            return;
        }
        
        try {
            $this->zoneTable->delete($id);
            http_response_code(204);
        } catch (\Exception $e) {
            error_log("Failed to delete zone: " . $e->getMessage());
            $this->sendError(500, 'Failed to delete zone');
        }
    }
    
    private function validate($data)
    {
        $errors = [];
        
        if (empty($data['ZoneName'])) {
            $errors['ZoneName'] = 'Zone name is required';
        }
        
        if (empty($data['FK_IdPlace'])) {
            $errors['FK_IdPlace'] = 'Place ID is required';
        }
        
        return $errors;
    }
}