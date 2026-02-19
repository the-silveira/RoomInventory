<?php
// /src/Controllers/PlaceController.php
namespace API\Controllers;

use API\Models\PlaceTable;
use API\Models\ZoneTable;

class PlaceController extends BaseController
{
    private $placeTable;
    private $zoneTable;
    
    public function __construct()
    {
        $this->placeTable = new PlaceTable();
        $this->zoneTable = new ZoneTable();
    }
    
    public function getAll()
    {
        $places = $this->placeTable->findAll();
        $this->sendResponse(200, $places ?: []);
    }
    
    public function getOne($id)
    {
        $place = $this->placeTable->find($id);
        
        if (!$place) {
            $this->sendError(404, 'Place not found');
            return;
        }
        
        $this->sendResponse(200, $place);
    }
    
    public function getZones($id)
    {
        $place = $this->placeTable->find($id);
        if (!$place) {
            $this->sendError(404, 'Place not found');
            return;
        }
        
        $zones = $this->zoneTable->findByPlace($id);
        $this->sendResponse(200, $zones ?: []);
    }
    
    public function create()
    {
        $data = $this->getRequestData();
        
        $errors = $this->validate($data);
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        try {
            $id = $this->placeTable->insert($data);
            $place = $this->placeTable->find($id);
            $this->sendResponse(201, $place);
        } catch (\Exception $e) {
            error_log("Failed to create place: " . $e->getMessage());
            $this->sendError(500, 'Failed to create place');
        }
    }
    
    public function update($id)
    {
        $place = $this->placeTable->find($id);
        if (!$place) {
            $this->sendError(404, 'Place not found');
            return;
        }
        
        $data = $this->getRequestData();
        
        $errors = $this->validate($data);
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        try {
            $this->placeTable->update($id, $data);
            $place = $this->placeTable->find($id);
            $this->sendResponse(200, $place);
        } catch (\Exception $e) {
            error_log("Failed to update place: " . $e->getMessage());
            $this->sendError(500, 'Failed to update place');
        }
    }
    
    public function delete($id)
    {
        $place = $this->placeTable->find($id);
        if (!$place) {
            $this->sendError(404, 'Place not found');
            return;
        }
        
        try {
            $this->placeTable->delete($id);
            http_response_code(204);
        } catch (\Exception $e) {
            error_log("Failed to delete place: " . $e->getMessage());
            $this->sendError(500, 'Failed to delete place');
        }
    }
    
    private function validate($data)
    {
        $errors = [];
        
        if (empty($data['PlaceName'])) {
            $errors['PlaceName'] = 'Place name is required';
        }
        
        return $errors;
    }
}