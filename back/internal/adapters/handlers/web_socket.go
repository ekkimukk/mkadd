package handlers

import (
	"encoding/json"
	"miro_server/internal/domain/models"
	"miro_server/internal/middleware/logging"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// --- Структуры для маршрутизации по boardId ---

type clientConn struct {
	conn    *websocket.Conn
	boardId string
}

type boardMessage struct {
	boardId string
	msg     models.Message
}

// --- Хранилище по boardId ---
var (
	// clientsByBoard[boardId][conn] = true
	clientsByBoard = make(map[string]map[*websocket.Conn]bool)

	// boardDataByBoard[boardId] = []Message
	boardDataByBoard = make(map[string][]models.Message)

	// Каналы для передачи событий
	register   = make(chan clientConn)
	unregister = make(chan clientConn)
	broadcast  = make(chan boardMessage)

	// Общий мьютекс для защиты мап
	mutex sync.RWMutex
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Для разработки
	},
}

// HandleWebSocket обрабатывает подключение к определённой доске
func (h *Handler) HandleWebSocket(c *gin.Context) {
	boardID := c.Query("boardId")
	if boardID == "" {
		h.logger.Warn("Missing boardId in WebSocket connection")
		c.AbortWithStatus(http.StatusBadRequest)
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		h.logger.Error("WebSocket upgrade error", "err", err)
		return
	}
	defer conn.Close()

	client := clientConn{conn: conn, boardId: boardID}
	register <- client
	defer func() { unregister <- client }()

	// Отправляем историю только этой доски
	mutex.RLock()
	if history, ok := boardDataByBoard[boardID]; ok {
		for _, msg := range history {
			if err := conn.WriteJSON(msg); err != nil {
				h.logger.Warn("Failed to send history", "err", err)
				unregister <- client
				mutex.RUnlock()
				return
			}
		}
	}
	mutex.RUnlock()

	// Чтение входящих сообщений
	for {
		var msg models.Message
		err := conn.ReadJSON(&msg)
		if err != nil {
			h.logger.Warn("Error reading WebSocket message", "err", err)
			unregister <- client
			break
		}
		msg.Timestamp = time.Now()

		switch msg.Type {
		case models.DrawMessage:
			h.handleDraw(boardID, msg)
		case models.PointerMessage:
			h.handlePointer(boardID, msg)
		case models.ClearMessage:
			h.handleClear(boardID, msg)
		default:
			h.logger.Warn("Unknown message type", "type", msg.Type)
			continue
		}

		broadcast <- boardMessage{boardId: boardID, msg: msg}
	}
}

// Обработка рисования — с привязкой к boardId
func (h *Handler) handleDraw(boardId string, msg models.Message) {
	var draw models.DrawData
	if err := json.Unmarshal(msg.Data, &draw); err != nil {
		h.logger.Error("draw: invalid data", "err", err)
		return
	}

	mutex.Lock()
	boardDataByBoard[boardId] = append(boardDataByBoard[boardId], msg)
	mutex.Unlock()

	h.logger.Info("✏️ Draw", "board", boardId, "points", len(draw.Path), "color", draw.Color)
}

func (h *Handler) handlePointer(boardId string, msg models.Message) {
	h.logger.Info("🖱 Pointer update", "board", boardId)
}

func (h *Handler) handleClear(boardId string, msg models.Message) {
	mutex.Lock()
	boardDataByBoard[boardId] = []models.Message{}
	mutex.Unlock()

	h.logger.Info("🧹 Board cleared", "board", boardId)
}

// InitWSServer — фоновый worker для маршрутизации сообщений
func InitWSServer(logger *logging.Logger) {
	go func() {
		for {
			select {
			case client := <-register:
				mutex.Lock()
				if clientsByBoard[client.boardId] == nil {
					clientsByBoard[client.boardId] = make(map[*websocket.Conn]bool)
				}
				clientsByBoard[client.boardId][client.conn] = true
				total := len(clientsByBoard[client.boardId])
				mutex.Unlock()
				logger.Info("✅ Client connected", "board", client.boardId, "total", total)

			case client := <-unregister:
				mutex.Lock()
				if conns, ok := clientsByBoard[client.boardId]; ok {
					if _, exists := conns[client.conn]; exists {
						delete(conns, client.conn)
						client.conn.Close()
						total := len(conns)
						if total == 0 {
							delete(clientsByBoard, client.boardId)
							delete(boardDataByBoard, client.boardId)
							logger.Info("🗑 All clients gone — cleaned up board", "board", client.boardId)
						}
						mutex.Unlock()
						logger.Info("❌ Client disconnected", "board", client.boardId, "total", total)
						continue
					}
				}
				mutex.Unlock()

			case msg := <-broadcast:
				mutex.RLock()
				if conns, ok := clientsByBoard[msg.boardId]; ok {
					for conn := range conns {
						if err := conn.WriteJSON(msg.msg); err != nil {
							logger.Warn("Broadcast error", "err", err, "board", msg.boardId)
							// Планируем отключение
							go func() {
								unregister <- clientConn{conn: conn, boardId: msg.boardId}
							}()
						}
					}
				}
				mutex.RUnlock()
			}
		}
	}()
}
