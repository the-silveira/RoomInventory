<?php
// /src/Controllers/ChannelController.php
namespace API\Controllers;

use API\Models\ChannelTable;
use API\Models\ConnectionTable;

class ChannelController extends BaseController
{
    private $channelTable;
    private $connectionTable;
    
    public function __construct()
    {
        $this->channelTable = new ChannelTable();
        $this->connectionTable = new ConnectionTable();
    }
    
    public function getAll()
    {
        $channels = $this->channelTable->findAll();
        $this->sendResponse(200, $channels ?: []);
    }
    
    public function getAllWithConnections()
    {
        $channels = $this->channelTable->findAllWithConnections();
        $this->sendResponse(200, $channels ?: []);
    }
    
    public function getOne($id)
    {
        $channel = $this->channelTable->find($id);
        
        if (!$channel) {
            $this->sendError(404, 'Channel not found');
            return;
        }
        
        $this->sendResponse(200, $channel);
    }
    
    public function saveState()
    {
        $data = $this->getRequestData();
        
        if (!isset($data['states'])) {
            $this->sendError(422, 'Missing states field');
            return;
        }
        
        if (!isset($data['connections'])) {
            $this->sendError(422, 'Missing connections field');
            return;
        }
        
        try {
            $this->connectionTable->saveAll($data['states'], $data['connections']);
            $this->sendSuccess('Channel states and connections saved successfully');
        } catch (\Exception $e) {
            error_log("Failed to save channel state: " . $e->getMessage());
            $this->sendError(500, 'Failed to save channel state');
        }
    }
    
    public function getConnections()
    {
        $connections = $this->connectionTable->findAll();
        $this->sendResponse(200, $connections ?: []);
    }
}