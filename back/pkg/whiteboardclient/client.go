package whiteboardclient

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/models"
	"net/http"
)

// APIResponse обёртка ответа сервера
type APIResponse[T any] struct {
	Message string `json:"message"`
	Status  string `json:"status"`
	Data    T      `json:"data"`
}

// Распаковка data[T]
func unmarshalResponse[T any](b []byte) (T, error) {
	var resp APIResponse[T]
	err := json.Unmarshal(b, &resp)
	return resp.Data, err
}

type ClientAPI interface {
	CreateWhiteboard(ctx context.Context, req models.CreateWhiteboardRequest) (entities.Whiteboard, *http.Response, error)
	GetWhiteboard(ctx context.Context, id uint) (entities.Whiteboard, *http.Response, error)
	UpdateWhiteboard(ctx context.Context, id uint, req models.UpdateWhiteboardRequest) (entities.Whiteboard, *http.Response, error)
	DeleteWhiteboard(ctx context.Context, id uint) (*http.Response, error)
	GetAllWhiteboards(ctx context.Context, limit, offset int) ([]entities.Whiteboard, int64, *http.Response, error)

	CreateUser(ctx context.Context, req models.CreateUserRequest) (entities.User, *http.Response, error)
	GetUser(ctx context.Context, id uint) (*entities.User, *http.Response, error)
	UpdateUser(ctx context.Context, id uint, req models.UpdateUserRequest) (*entities.User, *http.Response, error)
	DeleteUser(ctx context.Context, id uint) error
	GetAllUsers(ctx context.Context, limit, offset int) ([]entities.User, *http.Response, error)
}

type Client struct {
	baseURL string
	client  *http.Client
}

func NewClient(baseURL string) ClientAPI {
	return &Client{
		baseURL: baseURL,
		client:  &http.Client{},
	}
}

func (c *Client) do(ctx context.Context, method, path string, body any) ([]byte, *http.Response, error) {
	var buf bytes.Buffer
	if body != nil {
		if err := json.NewEncoder(&buf).Encode(body); err != nil {
			return nil, nil, fmt.Errorf("encode body: %w", err)
		}
	}

	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+path, &buf)
	if err != nil {
		return nil, nil, fmt.Errorf("new request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, nil, fmt.Errorf("request: %w", err)
	}

	b, _ := io.ReadAll(resp.Body)
	resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, resp, fmt.Errorf("server returned %d: %s", resp.StatusCode, string(b))
	}

	return b, resp, nil
}
