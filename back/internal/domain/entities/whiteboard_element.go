package entities

import (
	"miro_server/internal/domain/enums"
)

// WhiteboardElement Элемент на доске (текст, фигура, путь)
type WhiteboardElement struct {
	ID           uint                   `gorm:"primaryKey;autoIncrement" json:"id" example:"1" rus:"ID элемента"`
	WhiteboardID uint                   `gorm:"not null;index" json:"whiteboard_id" example:"1" rus:"ID доски"`
	Type         enums.BoardElementType `gorm:"type:varchar(50);not null" json:"type" example:"text" rus:"Тип элемента"` // "text", "shape", "path"
	Data         enums.BoardElementData `gorm:"type:jsonb" json:"data" rus:"Данные элемента"`                            // хранится как JSON
}
