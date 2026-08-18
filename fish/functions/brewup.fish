function brewup --wraps='brew update && brew upgrade && brew cleanup' --description 'alias brewup=brew update && brew upgrade && brew cleanup'
  brew update && brew upgrade && brew cleanup $argv
        
end
