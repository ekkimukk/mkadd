package models

import "miro_server/internal/domain/entities"

// CreateUserRequest структура для создания нового пользователя
type CreateUserRequest struct {
	Email          string `json:"email" validate:"required,email" example:"user@example.com" rus:"Электронная почта"`
	HashedPassword string `json:"hashed_password" validate:"required" example:"$2a$12$abc..." rus:"Хеш пароля"`
	Username       string `json:"username" validate:"required" example:"Иван Иванов" rus:"Имя пользователя"`
	AvatarURL      string `json:"avatar_url,omitempty" example:"https://example.com/avatar.jpg" rus:"URL аватара"`
}

// UpdateUserRequest структура для обновления пользователя
type UpdateUserRequest struct {
	Email     string `json:"email" validate:"omitempty,email" example:"user@example.com" rus:"Электронная почта"`
	Username  string `json:"username" example:"Иван Иванов" rus:"Имя пользователя"`
	AvatarURL string `json:"avatar_url" example:"https://example.com/avatar.jpg" rus:"URL аватара"`
}

// GetAllUsersResponse ответ на получение всех пользователей с пагинацией
type GetAllUsersResponse struct {
	Users []entities.User `json:"whiteboards" rus:"Список пользователей"`
	Total int             `json:"total" rus:"Общее количество досок" example:"42"`
}
