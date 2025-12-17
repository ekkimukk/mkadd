package models

type AuthRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type AuthResponse struct {
	UserId   uint   `json:"user_id"`
	Username string `json:"username"`
	Token    string `json:"token"`
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type RegisterResponse struct {
	UserId int    `json:"user_id"`
	Token  string `json:"token"`
}
