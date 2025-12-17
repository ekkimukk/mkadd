package usecases

import (
	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/models"
	"miro_server/internal/interfaces"
	"miro_server/pkg/errors"
	"miro_server/pkg/fields"
	"time"
)

type UserUsecase struct {
	repo         interfaces.UserRepository
	errorHandler *errors.UsecaseErrorHandler
}

// NewUserUsecase конструктор
func NewUserUsecase(repo interfaces.UserRepository, eh *errors.UsecaseErrorHandler) interfaces.UserUsecase {
	return &UserUsecase{
		repo:         repo,
		errorHandler: eh,
	}
}

// UpdateUser обновляет существующего пользователя
func (u *UserUsecase) UpdateUser(userID, id uint, req models.UpdateUserRequest) (entities.User, error) {
	empty := entities.User{}

	if userID != id {
		return empty, errors.From(errors.UscErrForbidden, fields.F(errors.KeyDetail, "insufficient permissions to update user"))
	}

	updateMap := map[string]interface{}{
		"email":      req.Email,
		"name":       req.Username,
		"avatar_url": req.AvatarURL,
		"updated_at": time.Now(),
	}

	updatedUser, err := u.repo.UpdateUser(id, updateMap)
	if err != nil {
		return updatedUser, u.errorHandler.Handle(err)
	}

	return updatedUser, nil
}

// GetUserByID возвращает пользователя по ID
func (u *UserUsecase) GetUserByID(id uint) (entities.User, error) {
	empty := entities.User{}

	user, err := u.repo.GetUserByID(id)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	return user, nil
}

// GetAllUsers возвращает список пользователей с пагинацией
func (u *UserUsecase) GetAllUsers(limit, offset int) ([]entities.User, int64, error) {
	users, total, err := u.repo.GetAllUsers(limit, offset)
	if err != nil {
		return nil, 0, u.errorHandler.Handle(err)
	}
	return users, total, nil
}

// DeleteUser удаляет пользователя
func (u *UserUsecase) DeleteUser(userID, id uint) (entities.User, error) {
	empty := entities.User{}

	if userID != id {
		return empty, errors.From(errors.UscErrForbidden, fields.F(errors.KeyDetail, "insufficient permissions to delete user"))
	}

	updateMap := map[string]interface{}{
		"is_deleted": true,
	}

	deleted, err := u.repo.UpdateUser(id, updateMap)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}

	return deleted, nil
}
