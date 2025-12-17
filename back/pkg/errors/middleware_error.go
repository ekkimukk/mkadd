package errors

import (
	errs "errors"
)

var (
	MidErrUnauthorized error = errs.New("unauthorized")
)
