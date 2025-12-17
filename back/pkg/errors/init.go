package errors

// ErrorHandler Интерфейс обработчика ошибок
type ErrorHandler interface {
	PostgresErrorHandlerImpl
	RepositoryErrorHandlerImpl
}

// PostgresErrorHandlerImpl - интерфейс обработки ошибок Postgres
// *pgconn.PgError -> PgErr
type PostgresErrorHandlerImpl interface {
	Handle(op string, e error) *Err
}

// RepositoryErrorHandlerImpl - интерфейс обработки ошибок уровня репозитория
// PgErr -> RepoError
type RepositoryErrorHandlerImpl interface {
	Handle(op string, e error) *Err
}
