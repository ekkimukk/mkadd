package main

import (
	"miro_server/internal/app"
)

func main() {

	//	@title						MKADD_API
	//	@version					1.0.0
	//	@description				Back-Server для MKADD
	//	@host						localhost:8080
	//	@BasePath					/api
	//
	//	@tag.name					Authorize
	//	@tag.description			Авторизация.<br>Токен передавать заголовком: `Authorization`.<br>Формат ввода токена: `Bearer {token}`
	//
	//	@securityDefinitions.apikey	BearerAuth
	//	@in							header
	//	@name						Authorization
	app.New().Run()
}
