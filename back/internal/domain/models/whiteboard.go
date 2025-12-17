package models

import (
	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/enums"
)

// CreateWhiteboardRequest структура для создания новой доски
type CreateWhiteboardRequest struct {
	Title    string              `json:"title" validate:"required" example:"Проект 1" rus:"Название доски"`
	Elements []WhiteboardElement `json:"elements"  rus:"Элементы доски"`
	Users    []uint              `json:"users" example:"1,2,3" rus:"ID пользователей доски"` // привязка пользователей
}

// UpdateWhiteboardRequest структура для обновления доски
type UpdateWhiteboardRequest struct {
	Title    string                       `json:"title" example:"Новая доска" rus:"Название доски"`
	Elements []entities.WhiteboardElement `json:"elements" rus:"Элементы доски"`
	Users    []uint                       `json:"users,omitempty" example:"1,2,3" rus:"ID пользователей доски"` // обновление списка пользователей
}

// GetAllWhiteboardsResponse ответ на получение всех досок с пагинацией
type GetAllWhiteboardsResponse struct {
	Whiteboards []entities.Whiteboard `json:"whiteboards" rus:"Список досок"`
	Total       int                   `json:"total" rus:"Общее количество досок" example:"42"`
}

type WhiteboardElement struct {
	WhiteboardID uint                   `gorm:"not null;index" json:"whiteboard_id" example:"1" rus:"ID доски"`
	Type         enums.BoardElementType `gorm:"type:varchar(50);not null" json:"type" example:"text" rus:"Тип элемента"` // "text", "shape", "path"
	Data         enums.BoardElementData `gorm:"type:jsonb" json:"data" rus:"Данные элемента"`
}
