<?php
// /src/Controllers/EventController.php
namespace API\Controllers;

use API\Models\EventTable;
use API\Models\ItemEventTable;
use API\Models\ItemTable;

class EventController extends BaseController
{
    private $eventTable;
    private $itemEventTable;
    private $itemTable;
    
    public function __construct()
    {
        $this->eventTable = new EventTable();
        $this->itemEventTable = new ItemEventTable();
        $this->itemTable = new ItemTable();
    }
    
    public function getAll()
    {
        $events = $this->eventTable->findAll();
        $this->sendResponse(200, $events ?: []);
    }
    
    public function getOne($id)
    {
        $event = $this->eventTable->find($id);
        
        if (!$event) {
            $this->sendError(404, 'Event not found');
            return;
        }
        
        $this->sendResponse(200, $event);
    }
    
    public function getItems($id)
    {
        $event = $this->eventTable->find($id);
        if (!$event) {
            $this->sendError(404, 'Event not found');
            return;
        }
        
        $items = $this->eventTable->findItemsWithDetails($id);
        $this->sendResponse(200, $items ?: []);
    }
    
    public function create()
    {
        $data = $this->getRequestData();
        
        $errors = $this->validateEvent($data);
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        try {
            $id = $this->eventTable->insert($data);
            $event = $this->eventTable->find($id);
            $this->sendResponse(201, $event);
        } catch (\Exception $e) {
            error_log("Failed to create event: " . $e->getMessage());
            $this->sendError(500, 'Failed to create event');
        }
    }
    
    public function update($id)
    {
        $event = $this->eventTable->find($id);
        if (!$event) {
            $this->sendError(404, 'Event not found');
            return;
        }
        
        $data = $this->getRequestData();
        
        $errors = $this->validateEvent($data);
        if (!empty($errors)) {
            $this->sendError(422, 'Validation failed', $errors);
            return;
        }
        
        try {
            $this->eventTable->update($id, $data);
            $event = $this->eventTable->find($id);
            $this->sendResponse(200, $event);
        } catch (\Exception $e) {
            error_log("Failed to update event: " . $e->getMessage());
            $this->sendError(500, 'Failed to update event');
        }
    }
    
    public function delete($id)
    {
        $event = $this->eventTable->find($id);
        if (!$event) {
            $this->sendError(404, 'Event not found');
            return;
        }
        
        try {
            $this->eventTable->delete($id);
            http_response_code(204);
        } catch (\Exception $e) {
            error_log("Failed to delete event: " . $e->getMessage());
            $this->sendError(500, 'Failed to delete event');
        }
    }
    
    public function addItems($id)
    {
        $event = $this->eventTable->find($id);
        if (!$event) {
            $this->sendError(404, 'Event not found');
            return;
        }
        
        $data = $this->getRequestData();
        
        if (empty($data['items']) || !is_array($data['items'])) {
            $this->sendError(422, 'Items array is required');
            return;
        }
        
        // Verify all items exist
        foreach ($data['items'] as $item) {
            $itemData = $this->itemTable->find($item['IdItem']);
            if (!$itemData) {
                $this->sendError(422, "Item {$item['IdItem']} not found");
                return;
            }
        }
        
        try {
            $this->itemEventTable->addItemsToEvent($id, $data['items']);
            $this->sendSuccess('Items added to event successfully');
        } catch (\Exception $e) {
            error_log("Failed to add items to event: " . $e->getMessage());
            $this->sendError(500, 'Failed to add items to event');
        }
    }
    
    public function removeItem($id, $itemId)
    {
        $event = $this->eventTable->find($id);
        if (!$event) {
            $this->sendError(404, 'Event not found');
            return;
        }
        
        $item = $this->itemTable->find($itemId);
        if (!$item) {
            $this->sendError(404, 'Item not found');
            return;
        }
        
        if (!$this->itemEventTable->itemInEvent($id, $itemId)) {
            $this->sendError(404, 'Item not found in this event');
            return;
        }
        
        try {
            $this->itemEventTable->removeItemFromEvent($id, $itemId);
            $this->sendSuccess('Item removed from event successfully');
        } catch (\Exception $e) {
            error_log("Failed to remove item from event: " . $e->getMessage());
            $this->sendError(500, 'Failed to remove item from event');
        }
    }
    
    private function validateEvent($data)
    {
        $errors = [];
        
        $required = ['IdEvent', 'EventName', 'EventPlace', 'NameRep', 'EmailRep', 'Date'];
        foreach ($required as $field) {
            if (empty($data[$field])) {
                $errors[$field] = ucfirst($field) . ' is required';
            }
        }
        
        if (!empty($data['EmailRep']) && !filter_var($data['EmailRep'], FILTER_VALIDATE_EMAIL)) {
            $errors['EmailRep'] = 'Valid email is required';
        }
        
        return $errors;
    }
}