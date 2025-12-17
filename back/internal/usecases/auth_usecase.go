package usecases

import (
	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/models"
	"miro_server/internal/interfaces"
	"miro_server/pkg/errors"
	"miro_server/pkg/fields"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthUsecase struct {
	jwtSecret    string
	repo         interfaces.UserRepository
	errorHandler *errors.UsecaseErrorHandler
}

// NewAuthUsecase конструктор для AuthUsecase
func NewAuthUsecase(repo interfaces.UserRepository, jwtSecret string, eh *errors.UsecaseErrorHandler) interfaces.AuthUsecase {
	return &AuthUsecase{
		repo:         repo,
		jwtSecret:    jwtSecret,
		errorHandler: eh,
	}
}

func (u *AuthUsecase) Auth(req models.AuthRequest) (models.AuthResponse, error) {
	empty := models.AuthResponse{}

	// Получение пользователя по имени
	user, err := u.repo.GetUserByEmail(req.Email)
	if err != nil {
		return empty, u.errorHandler.Handle(err)
	}
	if !CheckPassword(user.HashedPassword, req.Password) {
		return empty, errors.From(errors.UscErrBadRequest, fields.F(errors.KeyDetail, "invalid user credentials"))
	}

	token, _ := GenerateToken(user.ID, u.jwtSecret)

	return models.AuthResponse{
		UserId: user.ID,
		Token:  token,
	}, nil
}

func (u *AuthUsecase) Register(req models.RegisterRequest) error {
	hash, err := HashPassword(req.Password)
	if err != nil {
		return u.errorHandler.Handle(err)
	}

	create := entities.User{
		Email:          req.Email,
		HashedPassword: hash,
		Username:       req.Username,
	}

	_, err = u.repo.CreateUser(create)
	if err != nil {
		return u.errorHandler.Handle(err)
	}

	return nil
}

func GenerateToken(userID uint, secret string) (string, error) {
	claims := jwt.MapClaims{
		"userId":    userID,
		"expiresAt": time.Now().Add(24 * time.Hour).Unix(),
		"issuedAt":  time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString([]byte(secret))
}

// CheckPassword сравнивает хэш пароля с plain-паролем.
// Возвращает true при совпадении.
func CheckPassword(hashedPassword string, plainPassword string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(plainPassword))
	return err == nil
}

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}
