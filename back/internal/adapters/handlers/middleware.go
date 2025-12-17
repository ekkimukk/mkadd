package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"miro_server/internal/middleware/logging"
	"miro_server/pkg/errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"github.com/gin-gonic/gin"
)

// --- Константы и типы ---

type ContextKey string

const CtxKeyValues ContextKey = "app_context"

const (
	HeaderUserId = "X-User-Id"
)

type ContextAppData struct {
	UserId   int
	UserName string
}

type RequestInfo struct {
	RemoteAddr string              `json:"remote_addr"`
	Method     string              `json:"method"`
	Path       string              `json:"path"`
	Headers    map[string][]string `json:"headers"`
}

// --- Middleware ---

func LoggingMiddleware(parentLogger *logging.Logger) gin.HandlerFunc {
	logger := parentLogger.WithPrefix("REQUEST_LOGGING")

	return func(c *gin.Context) {
		if c.Request.Method == http.MethodOptions {
			c.Next()
			return
		}

		start := time.Now()

		// Извлечение заголовков
		userIdStr := c.GetHeader(HeaderUserId)

		var userId int
		if userIdStr != "" {
			if parsed, err := strconv.Atoi(userIdStr); err == nil {
				userId = parsed
			}
		}

		// Добавляем контекст с информацией о пользователе
		ctx := context.WithValue(c.Request.Context(), CtxKeyValues, ContextAppData{
			UserId: userId,
		})
		c.Request = c.Request.WithContext(ctx)

		// Формируем JSON с информацией о запросе
		reqInfo := RequestInfo{
			RemoteAddr: c.Request.RemoteAddr,
			Method:     c.Request.Method,
			Path:       c.Request.URL.Path,
			Headers:    c.Request.Header,
		}
		reqJson, _ := json.Marshal(reqInfo)

		logger.Info("➡️ Request started",
			"method", c.Request.Method,
			"path", c.Request.URL.Path,
			"user_id", userId,
			"remote_addr", c.Request.RemoteAddr,
			"details", string(reqJson),
		)

		// Выполняем обработку запроса
		c.Next()

		status := c.Writer.Status()
		latency := time.Since(start)

		logger.Info("✅ Request completed",
			"status", status,
			"latency", latency,
			"user_id", userId,
			"client_ip", c.ClientIP(),
		)
	}
}

func CheckTokenMiddleware(secret string, errorResponse func(c *gin.Context, err error, code int, message string, isUserFacing bool)) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			errorResponse(c, errors.MidErrUnauthorized, http.StatusUnauthorized, "Authorization header required", true)
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
			errorResponse(c, errors.MidErrUnauthorized, http.StatusUnauthorized, "Authorization header invalid", true)
			c.Abort()
			return
		}

		tokenStr := parts[1]

		// Парсим JWT
		token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method")
			}
			return []byte(secret), nil
		})
		if err != nil || !token.Valid {
			errorResponse(c, err, http.StatusUnauthorized, "Token invalid or expired", true)
			c.Abort()
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			errorResponse(c, errors.MidErrUnauthorized, http.StatusUnauthorized, "Token claims invalid", true)
			c.Abort()
			return
		}

		// Извлекаем данные
		userID := 0
		if v, ok := claims["userId"].(float64); ok {
			userID = int(v)
		}

		// Добавляем данные в контекст
		ctx := context.WithValue(c.Request.Context(), CtxKeyValues, ContextAppData{
			UserId: userID,
		})
		c.Request = c.Request.WithContext(ctx)

		c.Next()
	}
}

// --- Вспомогательные функции ---

func ParseContext(ctx context.Context) (ContextAppData, error) {
	data, ok := ctx.Value(CtxKeyValues).(ContextAppData)
	if !ok {
		return ContextAppData{}, fmt.Errorf("parse context value error")
	}
	return data, nil
}
