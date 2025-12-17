package repositories

import (
	"fmt"
	"log"
	"miro_server/internal/domain/entities"
	"miro_server/pkg/errors"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"miro_server/internal/config"
	"miro_server/internal/interfaces"
)

type Repository struct {
	interfaces.UserRepository
	interfaces.WhiteboardRepository
	interfaces.ElementRepository
}

func NewRepository(cfg *config.Config) (interfaces.Repository, error) {
	//logger := logging.NewModuleLogger("ADAPTER", "POSTGRES", parentLogger)

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		cfg.Database.Host,
		cfg.Database.Username,
		cfg.Database.Password,
		cfg.Database.DBName,
		cfg.Database.Port,
	)

	newLogger := logger.New(
		log.New(os.Stdout, "\r\n", log.LstdFlags), // Вывод в stdout
		logger.Config{
			SlowThreshold:             200 * time.Millisecond, // Порог для медленных запросов
			LogLevel:                  logger.Info,            // Уровень логирования (Info - все запросы)
			IgnoreRecordNotFoundError: true,                   // Игнорировать ошибки "запись не найдена"
			Colorful:                  true,                   // Цветной вывод
		},
	)

	// Подключение к базе данных
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{Logger: newLogger})
	if err != nil {
		return nil, fmt.Errorf("ошибка подключения к базе данных: %w", err)
	}

	// Устанавливаем search_path, если указан DBSchema
	if cfg.Database.Schema != "" {
		if err := db.Exec(fmt.Sprintf("SET search_path TO %s", cfg.Database.Schema)).Error; err != nil {
			return nil, fmt.Errorf("ошибка установки search_path: %w", err)
		}
	}

	// Создаем схему, если она не существует (опционально)
	if err := createSchema(db, cfg.Database.Schema); err != nil {
		return nil, fmt.Errorf("ошибка создания схемы: %w", err)
	}

	// Выполнение автомиграций
	if err := autoMigrate(db); err != nil {
		return nil, fmt.Errorf("ошибка выполнения автомиграций: %w", err)

	}

	eh := errors.NewRepositoryErrorHandler()

	return &Repository{
		NewUserRepository(db, eh),
		NewWhiteboardRepository(db, eh),
		NewElementRepository(db, eh)}, nil
}

// autoMigrate - выполнение автомиграций для моделей
func autoMigrate(db *gorm.DB) error {
	models := []interface{}{
		&entities.User{},
		&entities.Whiteboard{},
		&entities.WhiteboardElement{},
	}

	for _, model := range models {
		if err := db.AutoMigrate(model); err != nil {
			return fmt.Errorf("ошибка миграции модели %T: %w", model, err)
		}
	}
	return nil
}

// createSchema - создает схему, если она не существует
func createSchema(db *gorm.DB, schema string) error {
	if schema == "" {
		return nil
	}

	// Проверяем существование схемы перед созданием
	var exists bool
	if err := db.Raw("SELECT EXISTS(SELECT 1 FROM pg_namespace WHERE nspname = ?)", schema).Scan(&exists).Error; err != nil {
		return fmt.Errorf("ошибка проверки существования схемы: %w", err)
	}

	if !exists {
		if err := db.Exec(fmt.Sprintf("CREATE SCHEMA %s", schema)).Error; err != nil {
			return fmt.Errorf("ошибка создания схемы: %w", err)
		}
	}

	return nil
}
