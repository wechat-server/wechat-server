#!/bin/sh
# Docker 启动入口：从只读模板生成 setting.json，并用 .env 环境变量覆盖字段

CONFIG_SRC="/app/config/setting.docker.json"
CONFIG_FILE="/app/assets/setting.json"

if [ -f "$CONFIG_SRC" ]; then
  cp -f "$CONFIG_SRC" "$CONFIG_FILE"
fi

override_config() {
  local tmp="/tmp/setting_tmp.json"
  cp "$CONFIG_FILE" "$tmp"

  [ -n "$APP_PORT" ]       && jq --arg v "$APP_PORT"       '.port = $v'       "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$ADMIN_KEY" ]      && jq --arg v "$ADMIN_KEY"      '.adminKey = $v'   "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$GH_WXID" ]        && jq --arg v "$GH_WXID"        '.ghWxid = $v'     "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"

  [ -n "$WORKER_POOL_SIZE" ]    && jq --argjson v "$WORKER_POOL_SIZE"    '.workerpoolsize = $v'    "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$MAX_WORKER_TASK_LEN" ] && jq --argjson v "$MAX_WORKER_TASK_LEN" '.maxworkertasklen = $v'  "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"

  [ -n "$MYSQL_CONNECT_STR" ] && jq --arg v "$MYSQL_CONNECT_STR" '.mySqlConnectStr = $v' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"

  [ -n "$REDIS_HOST" ] && jq --arg v "$REDIS_HOST" '.redisConfig.Host = $v' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$REDIS_PORT" ] && jq --argjson v "$REDIS_PORT" '.redisConfig.Port = $v' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$REDIS_PASS" ] && jq --arg v "$REDIS_PASS" '.redisConfig.Pass = $v' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"

  [ -n "$TOPIC" ]              && jq --arg v "$TOPIC"              '.topic = $v'          "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$ROCKET_MQ_ENABLED" ]  && jq --argjson v "$ROCKET_MQ_ENABLED"  '.rocketMq = $v'   "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$ROCKET_MQ_HOST" ]     && jq --arg v "$ROCKET_MQ_HOST"     '.rocketMqHost = $v'   "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$RABBIT_MQ_ENABLED" ]  && jq --argjson v "$RABBIT_MQ_ENABLED"  '.rabbitMq = $v'   "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$RABBIT_MQ_URL" ]      && jq --arg v "$RABBIT_MQ_URL"      '.rabbitMqUrl = $v'    "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$KAFKA_ENABLED" ]      && jq --argjson v "$KAFKA_ENABLED"      '.kafka = $v'      "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  [ -n "$KAFKA_URL" ]          && jq --arg v "$KAFKA_URL"          '.kafkaUrl = $v'        "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"

  [ -n "$NEWS_SYN_WXID" ] && jq --argjson v "$NEWS_SYN_WXID" '.newsSynWxId = $v' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"

  cp "$tmp" "$CONFIG_FILE"
  rm -f "$tmp"
}

override_config

echo "========================================="
echo "  当前 setting.json 配置:"
echo "========================================="
cat "$CONFIG_FILE"
echo ""
echo "========================================="

MYSQL_HOST=$(jq -r '.mySqlConnectStr' "$CONFIG_FILE" | sed -n 's/.*tcp(\([^:]*\):\([0-9]*\)).*/\1/p')
MYSQL_PORT_NUM=$(jq -r '.mySqlConnectStr' "$CONFIG_FILE" | sed -n 's/.*tcp(\([^:]*\):\([0-9]*\)).*/\2/p')

if [ -n "$MYSQL_HOST" ] && [ -n "$MYSQL_PORT_NUM" ]; then
  echo "等待 MySQL ($MYSQL_HOST:$MYSQL_PORT_NUM) 就绪..."
  for i in $(seq 1 60); do
    if nc -z "$MYSQL_HOST" "$MYSQL_PORT_NUM" 2>/dev/null; then
      echo "MySQL 已就绪 (第${i}次检测)"
      break
    fi
    if [ "$i" = "60" ]; then
      echo "警告: 等待 MySQL 超时，仍将尝试启动应用"
    fi
    sleep 2
  done
fi

exec /app/wechat-server
