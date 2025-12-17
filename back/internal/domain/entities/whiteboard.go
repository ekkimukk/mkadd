package entities

import (
	"time"
)

// Whiteboard Доска для рисования
type Whiteboard struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"ID" example:"1" rus:"ID доски"`
	Title     string    `gorm:"type:varchar(255);not null" json:"title" example:"Проект 1" rus:"Название доски"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at" example:"2025-12-03T10:15:30Z" rus:"Дата создания"`

	CreatedBy uint `gorm:"type:int;not null" json:"created_by" example:"1" rus:"ID создателя"` // FK на User.ID
	Creator   User `gorm:"foreignKey:CreatedBy;references:ID" json:"creator" rus:"Создатель доски"`

	Elements []WhiteboardElement `gorm:"foreignKey:WhiteboardID;constraint:OnDelete:CASCADE" json:"elements" rus:"Элементы доски"`

	Users []User `gorm:"many2many:user_whiteboards;" json:"users" rus:"Пользователи доски"` // связь многие-ко-многим
}

func (Whiteboard) TableName() string {
	return "mkadd.whiteboards"
}
