package main

import (
	"crm-erp-system/config"
	"crm-erp-system/database"
	"crm-erp-system/router"
	"log"
	"os"
)

func main() {
	// 加载配置
	config.LoadConfig()

	// 初始化数据库
	if err := database.InitDB(); err != nil {
		log.Fatalf("数据库初始化失败: %v", err)
	}
	defer database.CloseDB()

	// 初始化路由
	r := router.SetupRouter()

	// 启动服务
	// port := config.AppConfig.Port
	// Railway 等平台会注入 PORT，必须优先使用；本地仍可走配置文件
	port := os.Getenv("PORT")
	if port == "" {
		port = config.AppConfig.Port
	}
	if port == "" {
		port = "8080"
	}

	log.Printf("服务启动在端口: %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("服务启动失败: %v", err)
	}
}
