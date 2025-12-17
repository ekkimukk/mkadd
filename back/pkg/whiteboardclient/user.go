package whiteboardclient

import (
	"context"
	"encoding/json"
	"fmt"
	"miro_server/internal/domain/entities"
	"miro_server/internal/domain/models"
	"net/http"
	"strconv"
)

// --- CRUD Methods ---

func (c *Client) CreateUser(ctx context.Context, req models.CreateUserRequest) (entities.User, *http.Response, error) {
	b, resp, err := c.do(ctx, http.MethodPost, "/users", req)
	if err != nil {
		return entities.User{}, nil, err
	}

	user, err := unmarshalResponse[entities.User](b)
	return user, resp, err
}

func (c *Client) GetUser(ctx context.Context, id uint) (*entities.User, *http.Response, error) {
	b, resp, err := c.do(ctx, http.MethodGet, "/users/"+strconv.Itoa(int(id)), nil)
	if err != nil {
		return nil, resp, err
	}

	user, err := unmarshalResponse[entities.User](b)
	return &user, resp, err
}

func (c *Client) UpdateUser(ctx context.Context, id uint, req models.UpdateUserRequest) (*entities.User, *http.Response, error) {
	b, resp, err := c.do(ctx, http.MethodPut, "/users/"+strconv.Itoa(int(id)), req)
	if err != nil {
		return nil, nil, err
	}

	user, err := unmarshalResponse[entities.User](b)
	return &user, resp, err
}

func (c *Client) DeleteUser(ctx context.Context, id uint) error {
	_, _, err := c.do(ctx, http.MethodDelete, "/users/"+strconv.Itoa(int(id)), nil)
	return err
}

func (c *Client) GetAllUsers(ctx context.Context, limit, offset int) ([]entities.User, *http.Response, error) {
	path := fmt.Sprintf("/users?limit=%d&offset=%d", limit, offset)
	b, resp, err := c.do(ctx, http.MethodGet, path, nil)
	if err != nil {
		return nil, resp, err
	}

	// распаковка в GetAllUsersResponse (аналогично whiteboards)
	var data struct {
		Users []entities.User `json:"users"`
		Total int             `json:"total"`
	}
	if err := json.Unmarshal(b, &data); err != nil {
		return nil, resp, err
	}

	return data.Users, resp, nil
}
