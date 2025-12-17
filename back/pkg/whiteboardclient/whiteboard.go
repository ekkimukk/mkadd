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

func (c *Client) CreateWhiteboard(ctx context.Context, req models.CreateWhiteboardRequest) (entities.Whiteboard, *http.Response, error) {
	b, resp, err := c.do(ctx, http.MethodPost, "/whiteboards", req)
	if err != nil {
		return entities.Whiteboard{}, nil, err
	}

	wb, err := unmarshalResponse[entities.Whiteboard](b)
	return wb, resp, err
}

func (c *Client) GetWhiteboard(ctx context.Context, id uint) (entities.Whiteboard, *http.Response, error) {
	b, resp, err := c.do(ctx, http.MethodGet, "/whiteboards/"+strconv.Itoa(int(id)), nil)
	if err != nil {
		return entities.Whiteboard{}, resp, err
	}

	wb, err := unmarshalResponse[entities.Whiteboard](b)
	return wb, resp, err
}

func (c *Client) UpdateWhiteboard(ctx context.Context, id uint, req models.UpdateWhiteboardRequest) (entities.Whiteboard, *http.Response, error) {
	b, resp, err := c.do(ctx, http.MethodPut, "/whiteboards/"+strconv.Itoa(int(id)), req)
	if err != nil {
		return entities.Whiteboard{}, nil, err
	}

	wb, err := unmarshalResponse[entities.Whiteboard](b)
	return wb, resp, err
}

func (c *Client) DeleteWhiteboard(ctx context.Context, id uint) (*http.Response, error) {
	_, resp, err := c.do(ctx, http.MethodDelete, "/whiteboards/"+strconv.Itoa(int(id)), nil)
	return resp, err
}

func (c *Client) GetAllWhiteboards(ctx context.Context, limit, offset int) ([]entities.Whiteboard, int64, *http.Response, error) {
	path := fmt.Sprintf("/whiteboards?limit=%d&offset=%d", limit, offset)
	b, resp, err := c.do(ctx, http.MethodGet, path, nil)
	if err != nil {
		return nil, 0, resp, err
	}

	// Сначала распакуем обёртку GetAllWhiteboardsResponse
	var data models.GetAllWhiteboardsResponse
	if err := json.Unmarshal(b, &data); err != nil {
		return nil, 0, resp, err
	}

	return data.Whiteboards, int64(data.Total), resp, nil
}
