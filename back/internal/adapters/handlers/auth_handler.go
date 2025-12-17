package handlers

import (
	"miro_server/internal/domain/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Auth godoc
//
//	@Summary		Авторизация пользователя
//	@Description	Принимает логин и пароль, проверяет пользователя и выдаёт JWT-токен
//	@Tags			Authorize
//	@Accept			json
//	@Produce		json
//	@Param			request	body		models.AuthRequest	true	"Данные для авторизации"
//	@Success		200		{object}	models.AuthResponse
//	@Failure		400		{object}	ResultError	"Некорректный запрос"
//	@Failure		401		{object}	ResultError	"Неверные логин или пароль"
//	@Failure		500		{object}	ResultError	"Внутренняя ошибка сервера"
//
//	@Router			/auth [post]
func (h *Handler) Auth(c *gin.Context) {
	var req models.AuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.ErrorResponse(c, err, http.StatusBadRequest, BadRequest, true)
		return
	}

	resp, err := h.usecase.Auth(req)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Authorized successfully", Object, resp)
}

// Register godoc
//
//	@Summary		Регистрация нового пользователя
//	@Description	Создаёт учётную запись, хэширует пароль
//	@Tags			Authorize
//	@Accept			json
//	@Produce		json
//	@Param			request	body		models.RegisterRequest	true	"Данные для регистрации"
//	@Success		200		{object}	models.RegisterResponse
//	@Failure		400		{object}	ResultError	"Некорректный запрос"
//	@Failure		500		{object}	ResultError	"Внутренняя ошибка сервера"
//	@Router			/auth/register [post]
func (h *Handler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.ErrorResponse(c, err, http.StatusBadRequest, BadRequest, true)
		return
	}

	err := h.usecase.Register(req)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Registration successful", Empty, nil)
}
