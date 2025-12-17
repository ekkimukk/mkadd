package tests

import (
	"context"
	"miro_server/internal/domain/models"
	userclient "miro_server/pkg/whiteboardclient"
	"testing"
	"time"
)

func TestUserCRUD(t *testing.T) {
	ctx := context.Background()
	client := userclient.NewClient(URL)

	// --- CREATE ---
	createReq := models.CreateUserRequest{
		Email:          "testuser@example.com" + time.Now().Format("2006-01-02"),
		HashedPassword: "$2a$12$examplehash", // заранее захешированный пароль
		Username:       "Test User",
		AvatarURL:      "https://example.com/avatar.jpg",
	}

	created, _, err := client.CreateUser(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateUser failed: %v", err)
	}
	t.Logf("Created User ID: %d", created.ID)

	// --- GET BY ID ---
	got, _, err := client.GetUser(ctx, created.ID)
	if err != nil {
		t.Fatalf("GetUser failed: %v", err)
	}
	if got == nil {
		t.Fatalf("GetUser returned nil")
	}
	t.Logf("Got User Email: %s", got.Email)

	// --- UPDATE ---
	newName := "Updated User"
	newAvatar := "https://example.com/new-avatar.jpg"
	updateReq := models.UpdateUserRequest{
		Username:  newName,
		AvatarURL: newAvatar,
	}
	updated, _, err := client.UpdateUser(ctx, created.ID, updateReq)
	if err != nil {
		t.Fatalf("UpdateUser failed: %v", err)
	}
	if updated == nil {
		t.Fatalf("UpdateUser returned nil")
	}
	// t.Logf("Updated User Username: %s, Avatar: %s", updated.Name, updated.AvatarURL)

	// --- GET ALL ---
	all, _, err := client.GetAllUsers(ctx, 10, 0)
	if err != nil {
		t.Fatalf("GetAllUsers failed: %v", err)
	}
	t.Logf("Total Users returned: %d", len(all))

	// --- DELETE ---
	err = client.DeleteUser(ctx, created.ID)
	if err != nil {
		t.Fatalf("DeleteUser failed: %v", err)
	}
	t.Log("Deleted User successfully")

	// --- VERIFY DELETE ---
	_, _, err = client.GetUser(ctx, created.ID)
	if err != nil {
		t.Fatalf("GetUser after delete failed: %v", err)
	}

	t.Log("Verified User deletion")
}
