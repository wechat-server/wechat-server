# WeChat Server · Docker 一键部署

基于 Docker Compose 部署 **WeChat Server**（微信协议 HTTP API 服务），编排 **应用 + MySQL 8.0 + Redis 6**，开箱即用。

所有编排文件集中在 `deploy/` 目录。

## 功能概要

- 使用预构建镜像启动，无需克隆业务源码  
- MySQL / Redis 健康检查，应用等待数据库就绪后再启动  
- 数据卷持久化：数据库、Redis、日志、登录二维码目录  
- 通过 `.env` 与 `setting.docker.json` 调整端口、账号密码与部分业务参数

## 环境要求

- [Docker](https://docs.docker.com/get-docker/)  
- [Docker Compose](https://docs.docker.com/compose/install/) v2

## 快速开始

```bash
git clone git@github.com:wechat-server/wechat-server.git
cd wechat-server
cd deploy

# 按需编辑 .env（镜像名、端口、数据库密码等）
# 按需编辑 setting.docker.json（与 .env 中 MySQL/Redis 保持一致）

docker compose pull
docker compose up -d
```

启动成功后（默认端口见 `.env` 中 `APP_PORT`）：

- 服务根地址：`http://<主机>:8848`  
- Swagger 文档：`http://<主机>:8848/docs/`

查看日志：

```bash
docker compose logs -f wechat-server
```

## 目录结构（对齐 WeChatPadPro 习惯）

```
wechat-server/
├── README.md
├── LICENSE
├── .gitignore
├── assets/
│   └── images/          # README 等文档用图（社群二维码等）
└── deploy/
    ├── docker-compose.yml
    ├── .env
    ├── setting.docker.json
    └── docker-entrypoint.sh   # 与业务镜像 Dockerfile 中 COPY 的脚本一致；仅拉镜像运行时以镜像内为准，此文件便于你自行重建镜像时同步
```

## 配置说明


| 文件                           | 说明                                                                                                     |
| ---------------------------- | ------------------------------------------------------------------------------------------------------ |
| `deploy/.env`                | `WECHAT_SERVER_IMAGE`、端口、`MYSQL_*`、`REDIS_*`、消息队列开关等；启动时由 `docker-entrypoint.sh` 合并进运行时 `setting.json` |
| `deploy/setting.docker.json` | 应用 JSON 配置模板；容器内会复制为可写 `assets/setting.json` 并应用 `.env` 覆盖                                             |


**重要：** 若修改 MySQL 用户名、密码或库名，请同时更新 `.env` 中的 `MYSQL_`*、`MYSQL_CONNECT_STR`，以及 `setting.docker.json` 里的 `mySqlConnectStr`，三者保持一致。

**国内拉取基础镜像：** 在 `.env` 中设置 `REGISTRY`（例如 `docker.m.daocloud.io`），用于 `mysql`、`redis` 镜像前缀。

## 应用镜像

默认 `.env` 中：

```env
WECHAT_SERVER_IMAGE=wechatserver/wechat-server:1.0.0
```

请替换为你有权拉取的镜像（Docker Hub / 私有仓库等）。私有仓库需先执行 `docker login`。

## 常用命令

```bash
cd deploy

docker compose ps
docker compose restart wechat-server
docker compose down
# 删除数据卷（会清空数据库）
docker compose down -v
```

## 社群交流

| 釘釘交流群 | 微信付費專業群 |
| :--: | :--: |
| ![釘釘交流群](assets/images/钉钉群二维码.JPG) | ![微信付費專業群](assets/images/微信收款二维码.JPG) |

- **釘釘交流群**：使用钉钉「扫一扫」加入外部群，交流部署与使用问题（二维码见上表左）。  
- **微信付費專業群**：微信支付 ¥99.00，付款后入群请私聊群主（二维码见上表右）。

## 免责声明

本项目仅用于技术研究与合法合规场景。请遵守当地法律法规及微信相关用户协议，勿用于违法违规用途。使用本部署方案产生的一切后果由使用者自行承担。

## 许可证

MIT License（见 `LICENSE`）。