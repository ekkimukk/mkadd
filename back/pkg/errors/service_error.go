package errors

import errs "errors"

var (
	// Ошибки валидации
	SrvErrInvalidValue = errs.New("invalid value")
	SrvErrEmptyValue   = errs.New("empty value")

	// Прокинутые ошибки репозиториев
	SrvErrEmptyAction         = errs.New("empty action")
	SrvErrDataNotFound        = errs.New("not found")
	SrvErrUnprocessableEntity = errs.New("unprocessable entity")
	SrvErrInternal            = errs.New("internal error")
)

type ServiceErrorHandler struct{}

func NewServiceErrorHandler() *ServiceErrorHandler {
	return &ServiceErrorHandler{}
}

func (h *ServiceErrorHandler) Handle(e error) error {
	if e == nil {
		panic("nil error send to handleRepositoryError")
	}

	er, ok := e.(*Err)
	if !ok {
		return e
	}

	switch {
	case errs.Is(er, RepoErrUnknownError):
		return From(SrvErrInternal, er.Fields()...)

	case errs.Is(er, RepoErrForeignKeyConstraint):
		return From(SrvErrUnprocessableEntity, er.Fields()...)

	case errs.Is(er, RepoErrUniqueConstraint):
		return From(SrvErrUnprocessableEntity, er.Fields()...)

	case errs.Is(er, RepoErrDataNotFound):
		return From(SrvErrDataNotFound, er.Fields()...)

	case errs.Is(er, RepoErrEmptyAction):
		return From(SrvErrEmptyAction, er.Fields()...)

	default:
		return From(SrvErrInternal, er.Fields()...)
	}
}
