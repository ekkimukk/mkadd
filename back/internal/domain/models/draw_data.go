package models

// Point — точка на доске
type Point struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

// DrawData — данные для рисования
type DrawData struct {
	Path        []Point `json:"path"`
	Color       string  `json:"color"`
	StrokeWidth float64 `json:"strokeWidth"`
}
