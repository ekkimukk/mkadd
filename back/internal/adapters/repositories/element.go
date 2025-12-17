package repositories

import (
	"miro_server/internal/domain/models"
	"miro_server/internal/interfaces"
	"miro_server/pkg/errors"

	"gorm.io/gorm"
)

type ElementRepository struct {
	db           *gorm.DB
	errorHandler *errors.RepositoryErrorHandler
}

func NewElementRepository(db *gorm.DB, eh *errors.RepositoryErrorHandler) interfaces.ElementRepository {
	return &ElementRepository{db: db, errorHandler: eh}
}

func (r *ElementRepository) CreateElement(el models.WhiteboardElement) (models.WhiteboardElement, error) {
	op := "repo.Element.CreateElement"

	if err := r.db.Create(&el).Error; err != nil {
		return models.WhiteboardElement{}, r.errorHandler.Handle(op, err)
	}
	return el, nil
}
