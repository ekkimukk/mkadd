package usecases

import (
	"miro_server/internal/config"
	"miro_server/internal/interfaces"
	"miro_server/pkg/errors"
)

type Usecases struct {
	interfaces.AuthUsecase
	interfaces.UserUsecase
	interfaces.WhiteboardUsecase
}

func NewUsecases(r interfaces.Repository, cfg *config.Config) interfaces.Usecases {
	eh := &errors.UsecaseErrorHandler{}

	return Usecases{
		NewAuthUsecase(r, cfg.Security.JWTSecret, eh),
		NewUserUsecase(r, eh),
		NewWhiteboardUsecase(r, r, r, eh),
	}
}
