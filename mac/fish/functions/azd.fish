function azd
    set project (git config --local azure.devops.project 2>/dev/null)
    set org (git config --local azure.devops.organization 2>/dev/null)

    if test -z "$project"
        echo "No Azure DevOps project configured in this repo."
        return 1
    end

    az devops configure --defaults organization=$org project=$project >/dev/null 2>&1
    az $argv
end
