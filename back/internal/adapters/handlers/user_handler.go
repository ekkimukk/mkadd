package handlers

import (
	"strconv"

	"miro_server/internal/domain/models"

	"github.com/gin-gonic/gin"
)

// GetUser godoc
//
//	@Summary	Получить пользователя по ID
//	@Tags		User
//	@Security	BearerAuth
//	@Produce	json
//	@Param		id	path		int	true	"ID пользователя"
//	@Success	200	{object}	entities.User
//	@Failure	401	{object}	ResultError	"Не авторизован"
//	@Failure	404	{object}	ResultError	"Пользователь не найден"
//	@Failure	500	{object}	ResultError	"Внутренняя ошибка сервера"
//
//	@Router		/users/{id} [get]
func (h *Handler) GetUser(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	user, err := h.usecase.GetUserByID(uint(id))
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Success User get", Object, user)
}

// UpdateUser godoc
//
//	@Summary		Обновить пользователя
//	@Description	Обновить инфу может только сам пользователь
//	@Tags			User
//	@Security		BearerAuth
//	@Accept			json
//	@Produce		json
//	@Param			id		path		int							true	"ID пользователя"
//	@Param			request	body		models.UpdateUserRequest	true	"Данные для обновления"
//	@Success		200		{object}	entities.User
//	@Failure		401		{object}	ResultError	"Не авторизован"
//	@Failure		403		{object}	ResultError	"Доступ запрещен"
//	@Failure		404		{object}	ResultError	"Пользователь не найден"
//	@Failure		500		{object}	ResultError	"Внутренняя ошибка сервера"
//
//	@Router			/users/{id} [put]
func (h *Handler) UpdateUser(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	var req models.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	contextData, err := ParseContext(c.Request.Context())
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	user, err := h.usecase.UpdateUser(uint(contextData.UserId), uint(id), req)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Success User update", Object, user)
}

// DeleteUser godoc
//
//	@Summary		Удалить пользователя
//	@Description	Удалить инфу может только сам пользователь. Из бд не удаляется полностью.
//	@Tags			User
//	@Security		BearerAuth
//	@Produce		json
//	@Param			id	path		int	true	"ID пользователя"
//	@Success		200	{object}	entities.User
//	@Failure		401	{object}	ResultError	"Не авторизован"
//	@Failure		403	{object}	ResultError	"Доступ запрещен"
//	@Failure		404	{object}	ResultError	"Пользователь не найден"
//	@Failure		500	{object}	ResultError	"Внутренняя ошибка сервера"
//
//	@Router			/users/{id} [delete]
func (h *Handler) DeleteUser(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	contextData, err := ParseContext(c.Request.Context())
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	if _, err := h.usecase.DeleteUser(uint(contextData.UserId), uint(id)); err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Success User Delete", Empty, nil)
}

// GetAllUsers godoc
//
//	@Summary	Получить всех пользователей
//	@Tags		User
//	@Security	BearerAuth
//	@Produce	json
//	@Param		limit	query		int	false	"Лимит"		default(10)
//	@Param		offset	query		int	false	"Смещение"	default(0)
//	@Success	200		{object}	models.GetAllUsersResponse
//	@Failure	401		{object}	ResultError	"Не авторизован"
//	@Failure	500		{object}	ResultError	"Внутренняя ошибка сервера"
//
//	@Router		/users [get]
func (h *Handler) GetAllUsers(c *gin.Context) {
	limit, err := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if err != nil {
		limit = 10
	}
	offset, err := strconv.Atoi(c.DefaultQuery("offset", "0"))
	if err != nil {
		offset = 0
	}

	users, total, err := h.usecase.GetAllUsers(limit, offset)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	resp := models.GetAllUsersResponse{
		Users: users,
		Total: int(total),
	}

	h.ResultResponse(c, "Success Users get", Array, resp)
}
