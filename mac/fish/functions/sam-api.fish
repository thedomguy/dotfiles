function sam-api
    if not docker info &>/dev/null
        echo "Docker is not running. Please start Docker Desktop..."
        return 1
    end
    sam local start-api $argv
end
