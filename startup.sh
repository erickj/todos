#!/bin/sh

function redis_state {
    echo $(systemctl show redis.service --property ActiveState | cut -d= -f 2)
}

function redis_is_active {
    if [ "$(redis_state)" != "active" ]; then
       return 1
    fi
    return 0
}

function maybe_start_redis {
    if redis_is_active ; then
        echo "Redis is running"
        return 0;
    fi

    echo "Starting redis.service"
    sudo systemctl start redis.service
    if ! redis_is_active ; then
        echo "Failed to start redis"
        return 1
    fi
    return 0
}

function start_sinatra_app {
    echo "Starting sinatra via shotgun..."
    echo
    bundle exec shotgun
}

maybe_start_redis

echo
start_sinatra_app
