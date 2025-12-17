package app

import (
	"context"
	"errors"
	"log"
	"miro_server/internal/adapters/handlers"
	"miro_server/internal/adapters/repositories"
	"miro_server/internal/config"
	"miro_server/internal/middleware/logging"
	"miro_server/internal/middleware/swagger"
	"miro_server/internal/usecases"
	"net/http"

	"go.uber.org/fx"
)

func New() *fx.App {
	return fx.New(
		fx.Provide(
			config.LoadConfig,
		),
		LoggingModule,
		RepositoryModule,
		//ProducerModule,
		//ServiceModule,
		UsecaseModule,
		HttpServerModule,
	)
}

func ProvideLoggers(cfg *config.Config) *logging.Logger {
	loggerCfg := &logging.Config{
		Enabled:    cfg.Logging.Enable,
		Level:      cfg.Logging.Level,
		LogsDir:    cfg.Logging.LogsDir,
		SavingDays: intToUint(cfg.Logging.SavingDays),
	}

	logger := logging.NewLogger(loggerCfg, "APP", cfg.App.Version)
	return logger
}

var LoggingModule = fx.Module("logging_module",
	fx.Provide(
		ProvideLoggers,
	),
	fx.Invoke(func(l *logging.Logger) {
		l.Info("Logging system initialized")
	}),
)

// InvokeHttpServer запускает HTTP-сервер
func InvokeHttpServer(lc fx.Lifecycle, h http.Handler) {
	server := &http.Server{
		Addr:    ":8080",
		Handler: h,
	}

	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			go func() {
				if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
					log.Printf("HTTP server failed: %v", err)
				}
			}()
			return nil
		},
		OnStop: func(ctx context.Context) error {
			log.Println("Shutting down HTTP server...")
			return server.Shutdown(ctx)
		},
	})
}

// NewSwaggerConfig Swagger-конфигуратор
func NewSwaggerConfig(cfg *config.Config) *swagger.Config {
	return &swagger.Config{
		Enabled: true,
		Path:    "/swagger",
	}
}

var HttpServerModule = fx.Module("http_server_module",
	fx.Provide(
		NewSwaggerConfig,
		handlers.NewHandler,
		handlers.ProvideRouter,
	),
	fx.Invoke(InvokeHttpServer),
)

var RepositoryModule = fx.Module("repository_module",
	fx.Provide(repositories.NewRepository),
)

var UsecaseModule = fx.Module("usecases_module",
	fx.Provide(usecases.NewUsecases),
)

func intToUint(c int) uint {
	if c < 0 {
		panic([2]any{"a negative number", c})
	}
	return uint(c)
}
