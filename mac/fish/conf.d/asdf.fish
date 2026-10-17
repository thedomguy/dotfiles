# Ensure asdf shims are first so project-local .tool-versions are honored.
if test -z "$ASDF_DATA_DIR"
    set -gx ASDF_DATA_DIR $HOME/.asdf
end

if test -d "$ASDF_DATA_DIR/shims"
    if not contains "$ASDF_DATA_DIR/shims" $PATH
        set -gx PATH "$ASDF_DATA_DIR/shims" $PATH
    end
end
