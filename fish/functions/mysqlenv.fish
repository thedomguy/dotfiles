function mysqlenv --description "Execute MySQL queries with environment-specific configs"
    set config_map "aca:aca.conf" "dev:dev.conf" "staging:staging.conf" "prod:prod.conf"
    
    set env_name $argv[1]
    set query $argv[2..-1]
    
    if test (count $argv) -lt 2
        echo "Usage: mysqlenv <environment> <query>"
        echo "Available environments: aca, dev, staging, prod"
        return 1
    end
    
    set config_file ""
    for mapping in $config_map
        set parts (string split ":" $mapping)
        if test $parts[1] = $env_name
            set config_file $parts[2]
            break
        end
    end
    
    if test -z $config_file
        echo "Unknown environment: $env_name"
        echo "Available environments: aca, dev, staging, prod"
        return 1
    end
    
    set full_config_path ~/.mysql-config/$config_file
    
    if not test -f $full_config_path
        echo "Config file not found: $full_config_path"
        echo "Please create the config file with your MySQL credentials:"
        echo "  [client]"
        echo "  host=your_host"
        echo "  user=your_username"
        echo "  password=your_password"
        echo "  database=your_database"
        echo "  port=3306"
        return 1
    end
    
    command mysql --defaults-file=$full_config_path -e "$query"
end
