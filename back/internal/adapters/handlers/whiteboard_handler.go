package handlers

import (
	"log"
	"strconv"

	"miro_server/internal/domain/models"

	"github.com/gin-gonic/gin"
)

// CreateWhiteboard godoc
//
//	@Summary		Создать новую whiteboard
//	@Description	Создаёт чистую whiteboard. Админ доски - создатель.
//	@Tags			Whiteboard
//	@Security		BearerAuth
//	@Accept			json
//	@Produce		json
//	@Param			request	body		models.CreateWhiteboardRequest	true	"Данные для создания whiteboard"
//	@Success		200		{object}	entities.Whiteboard
//	@Failure		401		{object}	ResultError	"Не авторизован"
//	@Failure		404		{object}	ResultError	"Пользователь не найден"
//	@Failure		500		{object}	ResultError	"Внутренняя ошибка сервера"
//	@Router			/whiteboards [post]
func (h *Handler) CreateWhiteboard(c *gin.Context) {
	log.Println("HHEEEEEEy")

	var req models.CreateWhiteboardRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	log.Println("HHEEEEEEy")

	contextData, err := ParseContext(c.Request.Context())
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	wb, err := h.usecase.CreateWhiteboard(uint(contextData.UserId), req)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Whiteboard успешно создана", Object, wb)
}

// GetWhiteboard godoc
//
//	@Summary		Получить whiteboard по ID
//	@Description	Доступно только для участников доски.
//	@Tags			Whiteboard
//	@Security		BearerAuth
//	@Produce		json
//	@Param			id	path		int	true	"ID Whiteboard"
//	@Success		200	{object}	entities.Whiteboard
//	@Failure		401	{object}	ResultError	"Не авторизован"
//	@Failure		403	{object}	ResultError	"Доступ запрещен"
//	@Failure		404	{object}	ResultError	"Доска не найдена"
//	@Failure		500	{object}	ResultError	"Внутренняя ошибка сервера"
//	@Router			/whiteboards/{id} [get]
func (h *Handler) GetWhiteboard(c *gin.Context) {
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

	wb, err := h.usecase.GetWhiteboard(uint(contextData.UserId), uint(id))
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Whiteboard получена", Object, wb)
}

// UpdateWhiteboard godoc
//
//	@Summary	Обновить whiteboard
//	@Tags		Whiteboard
//	@Security	BearerAuth
//	@Accept		json
//	@Produce	json
//	@Param		id		path		int								true	"ID Whiteboard"
//	@Param		request	body		models.UpdateWhiteboardRequest	true	"Поля для обновления"
//	@Success	200		{object}	entities.Whiteboard
//	@Failure	401		{object}	ResultError	"Не авторизован"
//	@Failure	403		{object}	ResultError	"Доступ запрещен"
//	@Failure	404		{object}	ResultError	"Доска не найдена"
//	@Failure	500		{object}	ResultError	"Внутренняя ошибка сервера"
//	@Router		/whiteboards/{id} [put]
func (h *Handler) UpdateWhiteboard(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	var req models.UpdateWhiteboardRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	contextData, err := ParseContext(c.Request.Context())
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	wb, err := h.usecase.UpdateWhiteboard(uint(contextData.UserId), uint(id), req)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Success Whiteboard update", Object, wb)
}

// DeleteWhiteboard godoc
//
//	@Summary	Удалить whiteboard
//	@Tags		Whiteboard
//	@Security	BearerAuth
//	@Produce	json
//	@Param		id	path		int	true	"ID Whiteboard"
//	@Success	200	{object}	entities.Whiteboard
//	@Failure	401	{object}	ResultError	"Не авторизован"
//	@Failure	403	{object}	ResultError	"Доступ запрещен"
//	@Failure	404	{object}	ResultError	"Доска не найдена"
//	@Failure	500	{object}	ResultError	"Внутренняя ошибка сервера"
//	@Router		/whiteboards/{id} [delete]
func (h *Handler) DeleteWhiteboard(c *gin.Context) {
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

	_, err = h.usecase.DeleteWhiteboard(uint(contextData.UserId), uint(id))
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	h.ResultResponse(c, "Whiteboard успешно удалена", Empty, nil)
}

// GetAllWhiteboards godoc
//
//	@Summary	Получить все whiteboards
//	@Tags		Whiteboard
//	@Security	BearerAuth
//	@Produce	json
//	@Param		limit	query		int	false	"Лимит"		default(10)
//	@Param		offset	query		int	false	"Смещение"	default(0)
//	@Success	200		{object}	Response{data=models.GetAllWhiteboardsResponse}
//	@Failure	500		{object}	Response
//	@Router		/whiteboards [get]
func (h *Handler) GetAllWhiteboards(c *gin.Context) {
	limit, err := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if err != nil {
		limit = 10
	}
	offset, err := strconv.Atoi(c.DefaultQuery("offset", "0"))
	if err != nil {
		offset = 0
	}

	boards, total, err := h.usecase.GetAllWhiteboards(limit, offset)
	if err != nil {
		h.HandleUsecaseError(c, err)
		return
	}

	resp := models.GetAllWhiteboardsResponse{
		Whiteboards: boards,
		Total:       int(total),
	}

	h.ResultResponse(c, "Whiteboards получены", Array, resp)
}
