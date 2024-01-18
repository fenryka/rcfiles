if [ -f /user/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home) 2>/dev/null
fi
source ~/.bashrc
