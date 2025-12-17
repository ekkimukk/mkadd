package handlers

import (
	"fmt"
	"net/http"

	"miro_server/pkg/errors"

	errs "errors"

	"github.com/gin-gonic/gin"
)

func (h *Handler) HandleUsecaseError(c *gin.Context, er error) {
	if er == nil {
		panic("nil error send to handleUsecaseError")
	}

	e, ok := er.(*errors.Err)
	if !ok {
		panic("not *err.Err send to handleUsecaseError")
	}

	dict := e.Fields().ToDict()

	switch {
	case errs.Is(e, errors.MidErrUnauthorized):
		h.ErrorResponse(c, e, http.StatusUnauthorized, fmt.Sprintf("%s: %s", http.StatusText(http.StatusUnauthorized), dict.GetValueToString(errors.KeyDetail)), false)
	case errs.Is(e, errors.UscErrBadRequest):
		h.ErrorResponse(c, e, http.StatusBadRequest, fmt.Sprintf("%s: %s", http.StatusText(http.StatusBadRequest), dict.GetValueToString(errors.KeyDetail)), false)

	case errs.Is(e, errors.UscErrUnprocessableEntity):
		h.ErrorResponse(c, e, http.StatusUnprocessableEntity, fmt.Sprintf("%s: %s", http.StatusText(http.StatusUnprocessableEntity), dict.GetValueToString(errors.KeyDetail)), false)

	case errs.Is(e, errors.UscErrDataNotFound):
		h.ErrorResponse(c, e, http.StatusNotFound, "Data not found", false)

	case errs.Is(e, errors.UscErrEmptyAction):
		h.ErrorResponse(c, e, http.StatusBadRequest, fmt.Sprintf("%s: %s", http.StatusText(http.StatusBadRequest), dict.GetValueToString(errors.KeyDetail)), false)

	case errs.Is(e, errors.UscErrForbidden):
		h.ErrorResponse(c, e, http.StatusForbidden, fmt.Sprintf("%s: %s", http.StatusText(http.StatusForbidden), dict.GetValueToString(errors.KeyDetail)), false)

	default:
		h.ErrorResponse(c, e, http.StatusInternalServerError, fmt.Sprintf("%s: %s", http.StatusText(http.StatusInternalServerError), dict.GetValueToString(errors.KeyDetail)), false)
	}
}
