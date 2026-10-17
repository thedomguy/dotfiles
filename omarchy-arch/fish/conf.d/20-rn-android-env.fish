set -gx JAVA_HOME /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
set -gx ANDROID_HOME $HOME/Library/Android/sdk
set -gx ANDROID_SDK_ROOT $ANDROID_HOME
set -gx PATH $JAVA_HOME/bin $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools $ANDROID_HOME/cmdline-tools/latest/bin $PATH

function __emit_rn_android_env_sh
    set -l q_java (string replace -a "'" "'\\''" -- $JAVA_HOME)
    set -l q_android (string replace -a "'" "'\\''" -- $ANDROID_HOME)
    set -l q_android_sdk_root (string replace -a "'" "'\\''" -- $ANDROID_SDK_ROOT)
    set -l q_path (string replace -a "'" "'\\''" -- "$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH")

    printf "export JAVA_HOME='%s'\n" $q_java
    printf "export ANDROID_HOME='%s'\n" $q_android
    printf "export ANDROID_SDK_ROOT='%s'\n" $q_android_sdk_root
    printf "export PATH='%s'\n" $q_path
end
