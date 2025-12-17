package entities

import (
	"time"

	"gorm.io/gorm"
)

// User представляет пользователя в системе
type User struct {
	ID             uint           `gorm:"primaryKey;autoIncrement" json:"id" example:"1" rus:"ID пользователя"`
	Email          string         `gorm:"type:varchar(100);uniqueIndex;not null" json:"email" example:"user@example.com" rus:"Электронная почта"`
	HashedPassword string         `gorm:"type:varchar(255);not null" json:"hashed_password" example:"$2a$12$abc..." rus:"Хеш пароля"`
	Username       string         `gorm:"type:varchar(100);not null" json:"name" example:"Иван Иванов" rus:"Имя пользователя"`
	AvatarURL      string         `gorm:"type:varchar(255)" json:"avatar_url,omitempty" example:"https://example.com/avatar.jpg" rus:"URL аватара"`
	CreatedAt      time.Time      `gorm:"autoCreateTime" json:"created_at" example:"2025-12-03T10:15:30Z" rus:"Дата создания"`
	UpdatedAt      time.Time      `gorm:"autoUpdateTime" json:"last_seen" example:"2025-12-03T12:00:00Z" rus:"Дата последнего посещения"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-" rus:"Мягкое удаление"`

	Whiteboards []Whiteboard `gorm:"many2many:user_whiteboards;" json:"whiteboards" rus:"Доски пользователя"` // связь многие-ко-многим
}

func (User) TableName() string {
	return "mkadd.users"
}
