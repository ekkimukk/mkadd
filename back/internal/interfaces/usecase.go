package interfaces

import (
	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/models"
)

// WhiteboardUsecase интерфейс для работы с досками
type WhiteboardUsecase interface {
	CreateWhiteboard(userID uint, req models.CreateWhiteboardRequest) (entities.Whiteboard, error)
	GetWhiteboard(userID, id uint) (entities.Whiteboard, error)
	UpdateWhiteboard(userID uint, id uint, req models.UpdateWhiteboardRequest) (entities.Whiteboard, error)
	DeleteWhiteboard(userID uint, id uint) (entities.Whiteboard, error)
	GetAllWhiteboards(limit, offset int) ([]entities.Whiteboard, int64, error) // возвращаем массив досок и общее количество
}

// UserUsecase интерфейс для работы с пользователями
type UserUsecase interface {
	UpdateUser(userID, id uint, req models.UpdateUserRequest) (entities.User, error)
	GetUserByID(id uint) (entities.User, error)
	GetAllUsers(limit, offset int) ([]entities.User, int64, error)
	DeleteUser(userID uint, id uint) (entities.User, error)
}

type AuthUsecase interface {
	Auth(req models.AuthRequest) (models.AuthResponse, error)
	Register(req models.RegisterRequest) error
}

// Usecases объединяет все юскейсы
type Usecases interface {
	WhiteboardUsecase
	UserUsecase
	AuthUsecase
}
