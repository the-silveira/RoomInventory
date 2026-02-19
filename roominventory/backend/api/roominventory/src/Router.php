<?php
// /src/Router.php
namespace API;

class Router
{
    private $routes = [];
    private $notFoundHandler;
    
    public function addRoute($method, $path, $handler)
    {
        $this->routes[] = [
            'method' => strtoupper($method),
            'path' => $path,
            'handler' => $handler
        ];
    }
    
    public function setNotFoundHandler($handler)
    {
        $this->notFoundHandler = $handler;
    }
    
    public function dispatch($method, $uri)
    {
        // Remove query string and base path
        $uri = parse_url($uri, PHP_URL_PATH);
        $uri = str_replace('/index.php', '', $uri);
        $uri = rtrim($uri, '/');
        
        // Handle empty URI
        if (empty($uri)) {
            $uri = '/';
        }
        
        foreach ($this->routes as $route) {
            if ($route['method'] !== $method && $route['method'] !== 'ANY') {
                continue;
            }
            
            $pattern = $this->convertToRegex($route['path']);
            if (preg_match($pattern, $uri, $matches)) {
                // Remove full match
                array_shift($matches);
                
                // Parse handler
                list($controllerName, $methodName) = explode('@', $route['handler']);
                $controllerClass = "API\\Controllers\\" . $controllerName;
                
                if (class_exists($controllerClass)) {
                    $controller = new $controllerClass();
                    if (method_exists($controller, $methodName)) {
                        call_user_func_array([$controller, $methodName], $matches);
                        return;
                    }
                }
            }
        }
        
        // No route found
        if ($this->notFoundHandler) {
            call_user_func($this->notFoundHandler);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint not found']);
        }
    }
    
    private function convertToRegex($path)
    {
        // Convert {id} to named capture group
        $pattern = preg_replace('/\{([a-zA-Z0-9_]+)\}/', '(?<$1>[a-zA-Z0-9_]+)', $path);
        $pattern = str_replace('/', '\/', $pattern);
        return '/^' . $pattern . '$/';
    }
}