<?php
// /src/Controllers/DetailController.php
namespace API\Controllers;

use API\Models\DetailTable;
use API\Models\ItemTable;

class DetailController extends BaseController
{
    private $detailTable;
    private $itemTable;
    
    public function __construct()
    {
        $this->detailTable = new DetailTable();
        $this->itemTable = new ItemTable();
    }
    
    public function delete($id)
    {
        // Find the detail first to get the item ID
        // You might need to add a find method to DetailTable if you want to verify existence
        try {
            $this->detailTable->delete($id);
            http_response_code(204);
        } catch (\Exception $e) {
            error_log("Failed to delete detail: " . $e->getMessage());
            $this->sendError(500, 'Failed to delete detail');
        }
    }
}