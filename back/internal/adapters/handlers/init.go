package handlers

import (
	"miro_server/internal/config"
	"miro_server/internal/interfaces"
	"miro_server/internal/middleware/logging"
	"miro_server/internal/middleware/swagger"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/gin-gonic/gin"
	_ "github.com/swaggo/files"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

type Handler struct {
	logger  *logging.Logger
	usecase interfaces.Usecases
}

// NewHandler создает новый экземпляр HttpHandler со всеми зависимостями
func NewHandler(usecase interfaces.Usecases, parentLogger *logging.Logger) *Handler {
	handlerLogger := parentLogger.WithPrefix("HANDLER")
	handlerLogger.Info("Handler initialized",
		"component", "GENERAL",
	)
	return &Handler{
		logger:  handlerLogger,
		usecase: usecase,
	}
}

// ProvideRouter создает и настраивает маршруты
func ProvideRouter(h *Handler, cfg *config.Config, swagCfg *swagger.Config) http.Handler {
	gin.SetMode(cfg.App.GinMode)
	r := gin.Default()

	// r.Use(cors.New(cors.Config{
	// 	AllowOrigins:     []string{"*"}, // или укажи конкретные: ["http://localhost:53273"]
	// 	AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
	// 	AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
	// 	ExposeHeaders:    []string{"Content-Length"},
	// 	AllowCredentials: true,
	// }))

	// Swagger-роутер
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler, ginSwagger.InstanceName("mkadd_service")))

	// LoggerMiddleware
	r.Use(LoggingMiddleware(h.logger))

	// Общая группа для API
	baseRouter := r.Group("/api")

	// Группа для авторизации
	auth := baseRouter.Group("/auth")
	auth.POST("", h.Auth)
	auth.POST("/register", h.Register)

	// Создаём базовую группу с JWT middleware
	authGroup := baseRouter.Group("/")
	authGroup.Use(CheckTokenMiddleware(cfg.Security.JWTSecret, h.ErrorResponse))

	// --- Users ---
	users := authGroup.Group("/users")
	{
		users.GET("", h.GetAllUsers)
		users.GET("/:id", h.GetUser)
		users.PUT("/:id", h.UpdateUser)
		users.DELETE("/:id", h.DeleteUser)
	}

	// --- Whiteboards ---
	whiteboards := authGroup.Group("/whiteboards")
	{
		whiteboards.POST("", h.CreateWhiteboard)
		whiteboards.GET("", h.GetAllWhiteboards)
		whiteboards.GET("/:id", h.GetWhiteboard)
		whiteboards.PUT("/:id", h.UpdateWhiteboard)
		whiteboards.DELETE("/:id", h.DeleteWhiteboard)
	}

	// Подключение
	// connectGroup := baseRouter.Group("/connect")
	// СЮДА ПРОПИСАТЬ РОУТЫ HTTP
	// connectGroup.POST("/", h.AddConnection) // Добавить соединение

	// WebSocket endpoint
	r.GET("/ws", h.HandleWebSocket)

	// Запуск WS-распределителя
	InitWSServer(h.logger)

	return r
}
