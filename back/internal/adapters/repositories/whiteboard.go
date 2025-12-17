package repositories

import (
	"miro_server/internal/domain/entities"
	"miro_server/internal/interfaces"
	"miro_server/pkg/errors"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// ----------------- WHITEBOARD REPOSITORY -----------------

type WhiteboardRepository struct {
	db           *gorm.DB
	errorHandler *errors.RepositoryErrorHandler
}

func (r *WhiteboardRepository) AddUsers(wbID uint, users []entities.User) error {
	//TODO implement me
	panic("implement me")
}

func NewWhiteboardRepository(db *gorm.DB, eh *errors.RepositoryErrorHandler) interfaces.WhiteboardRepository {
	return &WhiteboardRepository{db: db, errorHandler: eh}
}

func (r *WhiteboardRepository) CreateWhiteboard(wb entities.Whiteboard) (entities.Whiteboard, error) {
	op := "repo.Whiteboard.CreateWhiteboard"

	err := r.db.Clauses(clause.Returning{}).Create(&wb).Error
	if err != nil {
		return entities.Whiteboard{}, r.errorHandler.Handle(op, err)
	}

	return wb, nil
}

func (r *WhiteboardRepository) GetBoardByID(id uint) (entities.Whiteboard, error) {
	op := "repo.Whiteboard.GetBoardByID"

	var wb entities.Whiteboard
	err := r.db.Preload("Elements").Preload("Users").First(&wb, id).Error
	if err != nil {
		return entities.Whiteboard{}, r.errorHandler.Handle(op, err)
	}

	return wb, nil
}

func (r *WhiteboardRepository) UpdateBoard(id uint, updateMap map[string]interface{}) (entities.Whiteboard, error) {
	op := "repo.Whiteboard.UpdateBoard"

	var wb entities.Whiteboard
	result := r.db.Model(&entities.Whiteboard{}).Where("id = ?", id).Clauses(clause.Returning{}).Updates(updateMap)
	if result.Error != nil {
		return entities.Whiteboard{}, r.errorHandler.Handle(op, result.Error)
	}

	// Получаем актуальную запись после обновления
	if err := r.db.Preload("Users").Preload("Elements").First(&wb, id).Error; err != nil {
		return entities.Whiteboard{}, r.errorHandler.Handle(op, err)
	}

	return wb, nil
}

func (r *WhiteboardRepository) DeleteBoard(id uint) error {
	op := "repo.Whiteboard.DeleteBoard"

	result := r.db.Delete(&entities.Whiteboard{}, id)
	if result.Error != nil {
		return r.errorHandler.Handle(op, result.Error)
	}

	return nil
}

func (r *WhiteboardRepository) GetAllBoards(limit, offset int) ([]entities.Whiteboard, int64, error) {
	op := "repo.Whiteboard.GetAllBoards"
	var empty []entities.Whiteboard

	var wbs []entities.Whiteboard
	var total int64

	query := r.db.Model(&entities.Whiteboard{}).Preload("Users")

	if err := query.Count(&total).Error; err != nil {
		return empty, 0, r.errorHandler.Handle(op, err)
	}

	if err := query.Limit(limit).Offset(offset).Find(&wbs).Error; err != nil {
		return empty, 0, r.errorHandler.Handle(op, err)
	}

	return wbs, total, nil
}
