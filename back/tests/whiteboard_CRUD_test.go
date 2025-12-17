package tests

import (
	"context"
	"miro_server/internal/domain/models"
	"miro_server/pkg/whiteboardclient"
	"testing"
)

const URL = "http://localhost:8080/api"

func TestWhiteboardCRUD(t *testing.T) {
	ctx := context.Background()
	client := whiteboardclient.NewClient(URL)

	// --- CREATE ---
	createReq := models.CreateWhiteboardRequest{
		Title: "Test Board",
	}

	created, _, err := client.CreateWhiteboard(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateWhiteboard failed: %v", err)
	}
	t.Logf("Created Whiteboard ID: %d, Title: %s", created.ID, created.Title)

	// --- GET BY ID ---
	got, _, err := client.GetWhiteboard(ctx, created.ID)
	if err != nil {
		t.Fatalf("GetWhiteboard failed: %v", err)
	}
	if got.ID != created.ID {
		t.Fatalf("Expected ID %d, got %d", created.ID, got.ID)
	}
	t.Logf("Got Whiteboard Title: %s", got.Title)

	// --- UPDATE ---
	newTitle := "Updated Board"
	updateReq := models.UpdateWhiteboardRequest{
		Title: newTitle,
	}
	updated, _, err := client.UpdateWhiteboard(ctx, created.ID, updateReq)
	if err != nil {
		t.Fatalf("UpdateWhiteboard failed: %v", err)
	}
	if updated.Title != newTitle {
		t.Fatalf("Expected updated title %s, got %s", newTitle, updated.Title)
	}
	t.Logf("Updated Whiteboard Title: %s", updated.Title)

	// --- DELETE ---
	_, err = client.DeleteWhiteboard(ctx, created.ID)
	if err != nil {
		t.Fatalf("DeleteWhiteboard failed: %v", err)
	}
	t.Logf("Deleted Whiteboard ID %d successfully", created.ID)

	// --- VERIFY DELETE ---
	_, _, err = client.GetWhiteboard(ctx, created.ID)
	if err == nil {
		t.Fatalf("Expected Whiteboard ID %d to be deleted, but it still exists", created.ID)
	}
	t.Logf("Verified Whiteboard ID %d deletion", created.ID)
}
