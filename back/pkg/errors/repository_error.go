package errors

import (
	errs "errors"

	"miro_server/pkg/fields"

	"github.com/jackc/pgx/v5/pgconn"
	"gorm.io/gorm"
)

var (
	RepoErrEmptyAction          error = errs.New("empty action")
	RepoErrDataNotFound         error = errs.New("data not found")
	RepoErrForeignKeyConstraint error = errs.New("foreign key constraint")
	RepoErrUniqueConstraint     error = errs.New("unique constraint")
	RepoErrUnknownError         error = errs.New("unknown error")

	RepoErrTxNotFoundInCtx error = errs.New("transactional manager: ctx not contatins tx")
	RepoErrTxExistedInCtx  error = errs.New("transactional manager: attempt set tx to ctx with existed tx")
)

type RepositoryErrorHandler struct {
}

func NewRepositoryErrorHandler() *RepositoryErrorHandler {
	return &RepositoryErrorHandler{}
}

func (h *RepositoryErrorHandler) Handle(op string, e error) *Err {
	if e == nil {
		return nil
	}

	var pgErr *pgconn.PgError
	if errs.As(e, &pgErr) {
		switch pgErr.Code {
		case "23503":
			return From(RepoErrForeignKeyConstraint, fields.F(KeyDetail, pgErr.Detail), fields.F(KeyOperation, op), fields.F(KeyMessage, pgErr.Message))
		case "23505":
			return From(RepoErrUniqueConstraint, fields.F(KeyDetail, pgErr.Detail), fields.F(KeyOperation, op), fields.F(KeyMessage, pgErr.Message))
		}
	}

	if errs.Is(e, gorm.ErrRecordNotFound) {
		return From(RepoErrDataNotFound, fields.F(KeyDetail, "data not found"), fields.F(KeyOperation, op), fields.F(KeyMessage, e.Error()))
	}

	return From(RepoErrUnknownError, fields.F(KeyDetail, "unknown error"), fields.F(KeyOperation, op), fields.F(KeyMessage, e.Error()))
}

func (h *RepositoryErrorHandler) NewRepositoryEmptyActionError(op string) *Err {
	return From(RepoErrEmptyAction, fields.F(KeyDetail, "empty action"), fields.F(KeyOperation, op), fields.F(KeyMessage, "action not did affect to data"))
}
