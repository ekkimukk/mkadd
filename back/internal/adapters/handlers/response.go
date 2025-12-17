package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
)

const (
	Object = "object" // Используется когда ответ содержит один объект
	Array  = "array"  // Используется когда ответ содержит массив объектов
	Empty  = "empty"  // Используется когда ответ не содержит данных
)

const (
	InternalServerError = "internal server error"
	BadRequest          = "bad request"
	Unathorized         = "unathorized"
)

type Response interface {
	ErrorResponse(c *gin.Context, err error, code int, message string, isUserFacing bool)
	ResultResponse(c *gin.Context, clientMsg string, datatype string, data any)
}

type ResultOk struct {
	Status   string `json:"status"` // ok
	Response struct {
		Message string      `json:"message"`
		Type    string      `json:"type"`           // [AVALIABLE]: object, array, empty
		Data    interface{} `json:"data,omitempty"` // [AVALIABLE]: object, array of objects, empty
	} `json:"response"`
}

type ResultError struct {
	Status   string `json:"status"` // error
	Response struct {
		Code    int    `json:"code"` // [RULE]: must be one of codes from table (Check DEV.PAGE)
		Message string `json:"message"`
	} `json:"response"`
}

func (h *Handler) ErrorResponse(c *gin.Context, err error, code int, message string, isUserFacing bool) {
	errText := "empty error"
	if err != nil {
		errText = err.Error()
	}

	appContext, _ := ParseContext(c)

	h.logger.Error("response", "request_id", 0, "user_id", appContext.UserId, "message", message, "error", errText)

	// errMessage := message
	// if err != nil && isUserFacing {
	// 	errMessage = fmt.Sprintf("%s, %s", message, err.Error())
	// }

	// httpError := apiresp.NewError(code, errMessage)
	// httpResult := apiresp.NewResult(apiresp.ERROR, httpError)

	c.Header("Content-Type", "application/json")
	c.Writer.WriteHeader(code)

	if err := json.NewEncoder(c.Writer).Encode(message); err != nil {
		h.logger.Error("invalid write resultError", "(error)", err.Error())
	}
}

func (h *Handler) ResultResponse(c *gin.Context, message string, dataType string, data interface{}) {
	response := gin.H{
		"status":  "success",
		"message": message,
		"type":    dataType,
	}

	if data != nil {
		response["data"] = data
	}

	c.JSON(http.StatusOK, response)
}
