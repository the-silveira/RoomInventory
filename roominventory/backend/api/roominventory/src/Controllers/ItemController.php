<?php
// /src/Controllers/ItemController.php
namespace API\Controllers;

use API\Models\ItemTable;
use API\Models\DetailTable;
use API\Models\ZoneTable;

class ItemController extends BaseController
{
    private $itemTable;
    private $detailTable;
    private $zoneTable;
    
    public function __construct()
    {
        $this->itemTable = new ItemTable();
        $this->detailTable = new DetailTable();
        $this->zoneTable = new ZoneTable();
    }
    
    public function getAll()
    {
        $items = $this->itemTable->findAllWithDetails();
        $this->sendResponse(200, $items ?: []);
    }
    
    public function getAllSimple()
    {
        $items = $this->itemTable->findAllSimple();
        $this->sendResponse(200, $items ?: []);
    }
    
    public function getAllWithDetails()
    {
        $items = $this->itemTable->findAllWithDetails();
        $this->sendResponse(200, $items ?: []);
    }
    
    public function getOne($id)
    {
        $item = $this->itemTable->find($id);
        
        if (!$item) {
            $this->sendError(404, 'Item not found');
            return;
        }
        
        $this->sendResponse(200, $item);
    }
    
    public function getByZone($zoneId)
    {
        $zone = $this->zoneTable->find($zoneId);
        if (!$zone) {
            $this->sendError(404, 'Zone not found');
            return;
        }
        
        $items = $this->itemTable->findByZone($zoneId);
        $this->sendResponse(200, $items ?: []);
    }
    
    public function getAvailableForEvent($eventId)
    {
        $items = $this->itemTable->findAvailableForEvent($eventId);
        $this->sendResponse(200, $items ?: []);
    }
    
    public function create()
    {
        $data = $this->getRequestData();
        
        $errors = $this->validateItem($data);
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        // Verify zone exists
        $zone = $this->zoneTable->find($data['FK_IdZone']);
        if (!$zone) {
            $this->sendError(422, 'Invalid zone ID');
            return;
        }
        
        try {
            $result = $this->itemTable->insert($data);
            
            if (isset($result['error']) && $result['code'] === 'DUPLICATE') {
                $this->sendError(409, 'Item already exists');
                return;
            }
            
            $item = $this->itemTable->find($data['IdItem']);
            $this->sendResponse(201, $item);
            
        } catch (\Exception $e) {
            error_log("Failed to create item: " . $e->getMessage());
            $this->sendError(500, 'Failed to create item');
        }
    }
    
    public function update($id)
    {
        $item = $this->itemTable->find($id);
        if (!$item) {
            $this->sendError(404, 'Item not found');
            return;
        }
        
        $data = $this->getRequestData();
        
        // Validate if fields are present
        $errors = [];
        if (isset($data['ItemName']) && empty($data['ItemName'])) {
            $errors['ItemName'] = 'Item name cannot be empty';
        }
        
        if (isset($data['FK_IdZone'])) {
            $zone = $this->zoneTable->find($data['FK_IdZone']);
            if (!$zone) {
                $errors['FK_IdZone'] = 'Invalid zone ID';
            }
        }
        
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        try {
            $this->itemTable->update($id, $data);
            $item = $this->itemTable->find($id);
            $this->sendResponse(200, $item);
        } catch (\Exception $e) {
            error_log("Failed to update item: " . $e->getMessage());
            $this->sendError(500, 'Failed to update item');
        }
    }
    
    public function delete($id)
    {
        $item = $this->itemTable->find($id);
        if (!$item) {
            $this->sendError(404, 'Item not found');
            return;
        }
        
        try {
            $this->itemTable->delete($id);
            http_response_code(204);
        } catch (\Exception $e) {
            error_log("Failed to delete item: " . $e->getMessage());
            $this->sendError(500, 'Failed to delete item');
        }
    }
    
    public function getDetails($id)
    {
        $item = $this->itemTable->find($id);
        if (!$item) {
            $this->sendError(404, 'Item not found');
            return;
        }
        
        $details = $this->detailTable->findByItem($id);
        $this->sendResponse(200, $details ?: []);
    }
    
    public function addDetail($id)
    {
        $item = $this->itemTable->find($id);
        if (!$item) {
            $this->sendError(404, 'Item not found');
            return;
        }
        
        $data = $this->getRequestData();
        
        if (empty($data['DetailsName'])) {
            $this->sendError(422, 'DetailsName is required');
            return;
        }
        
        if (empty($data['Details'])) {
            $this->sendError(422, 'Details is required');
            return;
        }
        
        try {
            $detailId = $this->detailTable->insert($id, $data);
            $this->sendResponse(201, [
                'id' => $detailId,
                'message' => 'Detail added successfully'
            ]);
        } catch (\Exception $e) {
            error_log("Failed to add detail: " . $e->getMessage());
            $this->sendError(500, 'Failed to add detail');
        }
    }
    
    private function validateItem($data)
    {
        $errors = [];
        
        if (empty($data['IdItem'])) {
            $errors['IdItem'] = 'Item ID is required';
        }
        
        if (empty($data['ItemName'])) {
            $errors['ItemName'] = 'Item name is required';
        }
        
        if (empty($data['FK_IdZone'])) {
            $errors['FK_IdZone'] = 'Zone ID is required';
        }
        
        return $errors;
    }
}