# ---- build stage ----
FROM golang:1.22 AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# 关键：生成两个名字，兼容 Railway 当前错误的启动命令
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" -o /app/out . \
 && cp /app/out /app/crm-erp-system \
 && chmod +x /app/out /app/crm-erp-system

# ---- run stage ----
FROM gcr.io/distroless/static-debian12
WORKDIR /app
COPY --from=builder /app/out /app/out
COPY --from=builder /app/crm-erp-system /app/crm-erp-system

# Railway 会提供 PORT；你的 Go 代码要监听 0.0.0.0:$PORT
EXPOSE 8080

# 默认启动 out；但就算 Railway 强行跑 ./crm-erp-system 也已经存在了
CMD ["/app/out"]
