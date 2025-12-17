package usecases

import (
	"miro_server/pkg/errors"
	"miro_server/pkg/fields"
	"time"

	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/models"
	"miro_server/internal/interfaces"
)

type WhiteboardUsecase struct {
	boardRepo    interfaces.WhiteboardRepository
	userRepo     interfaces.UserRepository
	elementRepo  interfaces.ElementRepository
	errorHandler *errors.UsecaseErrorHandler
}

// NewWhiteboardUsecase конструктор
func NewWhiteboardUsecase(repo interfaces.WhiteboardRepository, userRepo interfaces.UserRepository,
	elementRepo interfaces.ElementRepository, eh *errors.UsecaseErrorHandler) interfaces.WhiteboardUsecase {
	return &WhiteboardUsecase{
		boardRepo:    repo,
		userRepo:     userRepo,
		elementRepo:  elementRepo,
		errorHandler: eh,
	}
}

// CreateWhiteboard создает новую доску
func (u *WhiteboardUsecase) CreateWhiteboard(userID uint, req models.CreateWhiteboardRequest) (entities.Whiteboard, error) {
	empty := entities.Whiteboard{}

	wb := entities.Whiteboard{
		Title:     req.Title,
		CreatedBy: userID,
		CreatedAt: time.Now(),
	}

	// 1. Создание доски
	created, err := u.boardRepo.CreateWhiteboard(wb)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	// 2. Создание элементов
	if len(req.Elements) > 0 {
		for _, el := range req.Elements {
			el.WhiteboardID = created.ID
			if _, err := u.elementRepo.CreateElement(el); err != nil {
				return empty, u.errorHandler.Handle(err)
			}
		}
	}

	// 3. Участники
	if len(req.Users) > 0 {
		users := make([]entities.User, len(req.Users))
		for i, uid := range req.Users {
			usr, err := u.userRepo.GetUserByID(uid)
			if err != nil {
				return empty, u.errorHandler.Handle(err)
			}
			users[i] = usr
		}

		if err := u.boardRepo.AddUsers(created.ID, users); err != nil {
			return empty, u.errorHandler.Handle(err)
		}
	}

	// Загружаем доску полностью
	result, err := u.boardRepo.GetBoardByID(created.ID)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	return result, nil
}

// GetWhiteboard возвращает доску по ID
func (u *WhiteboardUsecase) GetWhiteboard(userID, id uint) (entities.Whiteboard, error) {
	empty := entities.Whiteboard{}

	board, err := u.boardRepo.GetBoardByID(id)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	// Проверка: пользователь — создатель
	if board.CreatedBy == userID {
		return board, nil
	}

	// Проверка: пользователь — участник
	for _, user := range board.Users {
		if user.ID == userID {
			return board, nil
		}
	}

	// Если ни создатель, ни участник — доступ запрещён
	return empty, errors.From(errors.UscErrForbidden, fields.F(errors.KeyDetail, "insufficient permissions to get a whiteboard"))
}

// UpdateWhiteboard обновляет доску
func (u *WhiteboardUsecase) UpdateWhiteboard(userID, id uint, req models.UpdateWhiteboardRequest) (entities.Whiteboard, error) {
	empty := entities.Whiteboard{}

	board, err := u.boardRepo.GetBoardByID(id)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	// Проверка: пользователь — создатель
	if board.CreatedBy == userID {
		return empty, errors.From(errors.UscErrForbidden, fields.F(errors.KeyDetail, "insufficient permissions to update a whiteboard"))

	}

	ok := false
	// Проверка: пользователь — участник
	for _, user := range board.Users {
		if user.ID == userID {
			ok = true
		}
	}
	if !ok {
		return empty, errors.From(errors.UscErrForbidden, fields.F(errors.KeyDetail, "insufficient permissions to update a whiteboard"))
	}

	// Создаем карту для обновления
	updateMap := map[string]interface{}{
		"elements": req.Elements,
		"title":    req.Title,
	}

	if req.Users != nil {
		// Преобразуем слайс ID пользователей в объекты User для связи many2many
		users := make([]entities.User, len(req.Users))
		for i, particID := range req.Users {
			usr, err_2 := u.userRepo.GetUserByID(particID)
			if err_2 != nil {
				return empty, u.errorHandler.Handle(err_2)
			}
			users[i] = usr
		}
		updateMap["users"] = users
	}

	// Обновляем доску через репозиторий
	updatedBoard, err := u.boardRepo.UpdateBoard(id, updateMap)
	if err != nil {
		return entities.Whiteboard{}, u.errorHandler.Handle(err)
	}

	return updatedBoard, nil
}

// DeleteWhiteboard удаляет доску
func (u *WhiteboardUsecase) DeleteWhiteboard(userID, id uint) (entities.Whiteboard, error) {
	empty := entities.Whiteboard{}

	board, err := u.boardRepo.GetBoardByID(id)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	// Проверка: пользователь — создатель
	if board.CreatedBy != userID {
		return empty, errors.From(errors.UscErrForbidden, fields.F(errors.KeyDetail, "insufficient permissions to delete a whiteboard"))
	}

	updateMap := map[string]interface{}{
		"is_deleted": true,
	}

	deleted, err := u.boardRepo.UpdateBoard(id, updateMap)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	return deleted, nil
}

// GetAllWhiteboards возвращает все доски
func (u *WhiteboardUsecase) GetAllWhiteboards(limit, offset int) ([]entities.Whiteboard, int64, error) {
	boards, count, err := u.boardRepo.GetAllBoards(limit, offset)
	if err != nil {
		return []entities.Whiteboard{}, 0, err
	}
	return boards, count, nil
}
