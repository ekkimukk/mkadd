package models

import (
	"encoding/json"
	"time"
)

// Message — стандартное сообщение WebSocket
type Message struct {
	Type      string          `json:"type"`
	Data      json.RawMessage `json:"data"`
	Timestamp time.Time       `json:"timestamp"`
}

// Типы сообщений
const (
	DrawMessage    = "draw"
	PointerMessage = "pointer"
	ClearMessage   = "clear"
)
