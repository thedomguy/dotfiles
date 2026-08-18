function ow --wraps='=cd ~/open-webui && docker compose up -d' --wraps='cd ~/open-webui && docker compose up -d' --wraps='docker start ollama && docker start open-webui' --description 'alias ow=docker start ollama && docker start open-webui'
  docker start ollama && docker start open-webui $argv
        
end
