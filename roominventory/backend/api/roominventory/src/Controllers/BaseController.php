<?php
// /src/Controllers/BaseController.php
namespace API\Controllers;

abstract class BaseController
{
    protected function getRequestData()
    {
        $raw = file_get_contents('php://input');
        $data = json_decode($raw, true);
        
        // Also check POST data for form submissions
        if (empty($data) && !empty($_POST)) {
            $data = $_POST;
        }
        
        return $data ?? [];
    }
    
    protected function getQueryParam($name, $default = null)
    {
        return $_GET[$name] ?? $default;
    }
    
    protected function sendResponse($statusCode, $data)
    {
        http_response_code($statusCode);
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    }
    
    protected function sendError($statusCode, $message, $errors = null)
    {
        http_response_code($statusCode);
        $response = ['error' => $message];
        if ($errors) {
            $response['validation_errors'] = $errors;
        }
        echo json_encode($response, JSON_PRETTY_PRINT);
    }
    
    protected function sendSuccess($message, $data = null)
    {
        $response = ['success' => true, 'message' => $message];
        if ($data) {
            $response['data'] = $data;
        }
        $this->sendResponse(200, $response);
    }
}