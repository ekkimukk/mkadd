package whiteboardclient

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	httpUrl "net/url"
	"strings"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

type ClientServiceConfig struct {
	Host string
}

type ClientService struct {
	HTTPClient *http.Client
	Host       string
}

func NewClientService(host string) *ClientService {
	Host, _ := strings.CutSuffix(host, "/")

	client := &http.Client{
		Transport: otelhttp.NewTransport(http.DefaultTransport),
	}

	return &ClientService{
		HTTPClient: client,
		Host:       Host,
	}
}

// createRequestJSON to create request with embedded json header
func (s *ClientService) createRequestJSON(httpMethod, urlPath string, queryParams, additionalHeaders map[string]string, reqBody io.Reader) (*http.Request, error) {
	ctx := context.TODO()

	processedUrlPath, _ := strings.CutPrefix(urlPath, "/")
	url := fmt.Sprintf("%s/%s", s.Host, processedUrlPath) // Simplified

	if len(queryParams) > 0 {
		params := httpUrl.Values{}
		for param, value := range queryParams {
			params.Add(param, value)
		}
		url += "?" + params.Encode()
	}

	req, err := http.NewRequestWithContext(ctx, httpMethod, url, reqBody)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json") // Embedded
	for key, value := range additionalHeaders {
		req.Header.Set(key, value)
	}

	return req, nil
}

// createRequestJSON to create request with embedded json header
func (s *ClientService) createRequestJSONWithContext(ctx context.Context, httpMethod, urlPath string, queryParams, additionalHeaders map[string]string, reqBody io.Reader) (*http.Request, error) {
	processedUrlPath, _ := strings.CutPrefix(urlPath, "/")
	url := fmt.Sprintf("%s/%s", s.Host, processedUrlPath) // Simplified

	if len(queryParams) > 0 {
		params := httpUrl.Values{}
		for param, value := range queryParams {
			params.Add(param, value)
		}
		url += "?" + params.Encode()
	}

	req, err := http.NewRequestWithContext(ctx, httpMethod, url, reqBody)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json") // Embedded
	for key, value := range additionalHeaders {
		req.Header.Set(key, value)
	}

	return req, nil
}

// doRequest return body of response, response structure and error
// :returned param: []byte - cached body of response
func (s *ClientService) doRequest(req *http.Request) ([]byte, *http.Response, error) {
	resp, err := s.HTTPClient.Do(req)
	if err != nil {
		return nil, resp, err
	}
	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, resp, err
	}

	resp.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	if resp.StatusCode != http.StatusOK {
		return nil, resp, fmt.Errorf("response code error: error code - %d, body - %s", resp.StatusCode, string(bodyBytes))
	}

	return bodyBytes, resp, nil
}
