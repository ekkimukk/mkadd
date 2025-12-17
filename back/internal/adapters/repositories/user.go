package repositories

import (
	"miro_server/internal/domain/entities"
	"miro_server/internal/interfaces"
	"miro_server/pkg/errors"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// ----------------- USER REPOSITORY -----------------

type UserRepository struct {
	db           *gorm.DB
	errorHandler *errors.RepositoryErrorHandler
}

// NewUserRepository - конструктор
func NewUserRepository(db *gorm.DB, eh *errors.RepositoryErrorHandler) interfaces.UserRepository {
	return &UserRepository{db: db, errorHandler: eh}
}

func (r *UserRepository) CreateUser(user entities.User) (entities.User, error) {
	op := "repo.User.CreateUser"

	err := r.db.Clauses(clause.Returning{}).Create(&user).Error
	if err != nil {
		return entities.User{}, r.errorHandler.Handle(op, err)
	}
	return user, nil
}

func (r *UserRepository) GetUserByID(id uint) (entities.User, error) {
	op := "repo.User.GetUserByID"
	empty := entities.User{}

	var user entities.User
	err := r.db.Preload("Whiteboards").First(&user, id).Error
	if err != nil {
		return empty, r.errorHandler.Handle(op, err)
	}

	return user, nil
}

func (r *UserRepository) GetUserByUsername(username string) (entities.User, error) {
	op := "repo.User.GetUserByUsername"
	empty := entities.User{}

	var user entities.User
	err := r.db.Where("username = ?", username).First(&user).Error
	if err != nil {
		return empty, r.errorHandler.Handle(op, err)
	}

	return user, nil
}

func (r *UserRepository) GetUserByEmail(email string) (entities.User, error) {
	op := "repo.User.GetUserByEmail"
	empty := entities.User{}

	var user entities.User
	err := r.db.Where("email = ?", email).First(&user).Error
	if err != nil {
		return empty, r.errorHandler.Handle(op, err)
	}

	return user, nil
}

func (r *UserRepository) UpdateUser(id uint, updateMap map[string]interface{}) (entities.User, error) {
	op := "repo.User.UpdateUser"
	empty := entities.User{}

	var user entities.User
	result := r.db.
		Clauses(clause.Returning{}).
		Model(&user).
		Where("id = ?", id).
		Updates(updateMap)

	if result.Error != nil {
		return empty, r.errorHandler.Handle(op, result.Error)
	}

	return user, nil
}

func (r *UserRepository) DeleteUser(id uint) error {
	op := "repo.User.DeleteUser"

	result := r.db.Delete(&entities.User{}, id)
	if result.Error != nil {
		return r.errorHandler.Handle(op, result.Error)
	}

	return nil
}

func (r *UserRepository) GetAllUsers(limit, offset int) ([]entities.User, int64, error) {
	op := "repo.User.GetAllUsers"

	var users []entities.User
	var total int64

	query := r.db.Model(&entities.User{}).Preload("Whiteboards")

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, r.errorHandler.Handle(op, err)
	}

	if err := query.Limit(limit).Offset(offset).Find(&users).Error; err != nil {
		return nil, 0, r.errorHandler.Handle(op, err)
	}

	return users, total, nil
}
