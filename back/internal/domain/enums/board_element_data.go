package enums

type BoardElementData interface {
	ElementType() string
}

type TextElement struct {
	Text     string `json:"text"`
	Position Point  `json:"position"`
	Color    string `json:"color"`
}

func (t TextElement) ElementType() string { return "text" }

type ShapeElement struct {
	Position Point  `json:"position"`
	Size     Size   `json:"size"`
	Color    string `json:"color"`
}

func (s ShapeElement) ElementType() string { return "shape" }

// Point Точка
type Point struct {
	X float64 `json:"x" example:"10.5" rus:"Координата X"`
	Y float64 `json:"y" example:"20.0" rus:"Координата Y"`
}

// Size Размер
type Size struct {
	Width  float64 `json:"width" example:"100.0" rus:"Ширина"`
	Height float64 `json:"height" example:"50.0" rus:"Высота"`
}
