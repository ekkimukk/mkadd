package interfaces

import (
	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/models"
)

// Repository объединяет все интерфейсы репозиториев
type Repository interface {
	WhiteboardRepository
	UserRepository
	ElementRepository
}

// WhiteboardRepository интерфейс для работы с досками
type WhiteboardRepository interface {
	CreateWhiteboard(wb entities.Whiteboard) (entities.Whiteboard, error)
	GetBoardByID(id uint) (entities.Whiteboard, error)
	UpdateBoard(id uint, updateMap map[string]interface{}) (entities.Whiteboard, error)
	DeleteBoard(id uint) error
	GetAllBoards(limit, offset int) ([]entities.Whiteboard, int64, error)
	AddUsers(wbID uint, users []entities.User) error
}

// UserRepository интерфейс для работы с пользователями
type UserRepository interface {
	CreateUser(user entities.User) (entities.User, error)
	GetUserByID(id uint) (entities.User, error)
	GetUserByUsername(username string) (entities.User, error)
	GetUserByEmail(email string) (entities.User, error)
	UpdateUser(id uint, updateMap map[string]interface{}) (entities.User, error)
	DeleteUser(id uint) error
	GetAllUsers(limit, offset int) ([]entities.User, int64, error)
}

type ElementRepository interface {
	CreateElement(el models.WhiteboardElement) (models.WhiteboardElement, error)
}
