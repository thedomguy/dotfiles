function owe --wraps='cd ~/open-webui && docker compose down' --wraps='docker stop open-webui ollama' --description 'alias owe=docker stop open-webui ollama'
  docker stop open-webui ollama $argv
        
end
