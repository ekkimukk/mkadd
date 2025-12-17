package errors

import (
	errs "errors"
	"miro_server/pkg/fields"
)

var (
	UscErrUnauthorized        error = errs.New("unauthorized")
	UscErrBadRequest          error = errs.New("bad request")
	UscErrDataNotFound        error = errs.New("data not found")
	UscErrUnprocessableEntity error = errs.New("unprocessable entity")
	UscErrInternal            error = errs.New("internal error")
	UscErrEmptyAction         error = errs.New("empty action")
	UscErrForbidden           error = errs.New("forbidden")
)

type UsecaseErrorHandler struct {
}

func NewUsecaseErrorHandler() *UsecaseErrorHandler {
	return &UsecaseErrorHandler{}
}

func (h *UsecaseErrorHandler) Handle(e error) error {
	if e == nil {
		panic("nil error send to handleRepositoryError")
	}

	er, ok := e.(*Err)
	if !ok {
		return e
	}

	switch {
	// Обработка ошибок репозиториев
	case errs.Is(er, RepoErrUnknownError):
		return From(UscErrInternal, er.Fields()...)

	case errs.Is(er, RepoErrForeignKeyConstraint) || errs.Is(er, RepoErrUniqueConstraint):
		return From(UscErrUnprocessableEntity, er.Fields()...)

	case errs.Is(er, RepoErrDataNotFound) || errs.Is(er, SrvErrDataNotFound):
		return From(UscErrDataNotFound, er.Fields()...)

	case errs.Is(er, RepoErrEmptyAction) || errs.Is(er, SrvErrEmptyAction):
		return From(UscErrEmptyAction, er.Fields()...)

		// 422 - ошибка валидации, некорректный запрос, пустое действие
	case errs.Is(er, SrvErrInvalidValue) || errs.Is(er, SrvErrEmptyValue) || errs.Is(er, SrvErrUnprocessableEntity):
		return From(UscErrUnprocessableEntity, er.Fields()...)

	case errs.Is(er, SrvErrInternal):
		return From(UscErrInternal, er.Fields()...)

	default:
		return From(UscErrBadRequest, er.Fields()...)
	}
}

func (h *UsecaseErrorHandler) NewRepositoryEmptyActionError(op string) error {
	return From(UscErrEmptyAction, fields.F(KeyDetail, "empty action"), fields.F(KeyOperation, op), fields.F(KeyMessage, "action not did affect to data"))
}
