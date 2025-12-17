package repositories

// import (
// 	"context"
// 	"miro_server/internal/middleware/logging"
// 	"strings"

// 	"go.mongodb.org/mongo-driver/bson"
// 	"go.mongodb.org/mongo-driver/mongo"
// 	"go.mongodb.org/mongo-driver/mongo/options"
// )

// // func RunMigrations(ctx context.Context, db *mongo.Database, logger *logging.Logger) error {

// // 	migrations := []func(context.Context, *mongo.Database, *logging.Logger) error{
// // 		createUsers,
// // 		createWhiteboards,
// // 	}

// // 	for _, migrate := range migrations {
// // 		if err := migrate(ctx, db, logger); err != nil {
// // 			return fmt.Errorf("migration failed: %w", err)
// // 		}
// // 	}

// // 	logger.Info("✅ All migrations executed successfully")
// // 	return nil
// // }

// //
// // ========== USERS ==========
// //

// func createUsers(ctx context.Context, db *mongo.Database, logger *logging.Logger) error {
// 	name := "users"

// 	if err := db.CreateCollection(ctx, name); err != nil && !isExists(err) {
// 		return err
// 	}

// 	col := db.Collection(name)

// 	// Индексы
// 	indexes := []mongo.IndexModel{
// 		{
// 			Keys:    bson.D{{Key: "email", Value: 1}},
// 			Options: options.Index().SetName("idx_email").SetUnique(true),
// 		},
// 		{
// 			Keys:    bson.D{{Key: "createdAt", Value: -1}},
// 			Options: options.Index().SetName("idx_createdAt"),
// 		},
// 	}

// 	_, _ = col.Indexes().CreateMany(ctx, indexes)

// 	logger.Info("📁 users collection ready")
// 	return nil
// }

// //
// // ========== WHITEBOARDS ==========
// //

// func createWhiteboards(ctx context.Context, db *mongo.Database, logger *logging.Logger) error {
// 	name := "whiteboards"

// 	if err := db.CreateCollection(ctx, name); err != nil && !isExists(err) {
// 		return err
// 	}

// 	col := db.Collection(name)

// 	// Индексы
// 	indexes := []mongo.IndexModel{
// 		{
// 			Keys:    bson.D{{Key: "title", Value: 1}},
// 			Options: options.Index().SetName("idx_title"),
// 		},
// 		{
// 			Keys:    bson.D{{Key: "createdAt", Value: -1}},
// 			Options: options.Index().SetName("idx_createdAt"),
// 		},
// 	}

// 	_, _ = col.Indexes().CreateMany(ctx, indexes)

// 	logger.Info("📁 whiteboards collection ready")
// 	return nil
// }

// //
// // Utility
// //

// func isExists(err error) bool {
// 	return err != nil &&
// 		(mongo.IsDuplicateKeyError(err) ||
// 			strings.Contains(err.Error(), "already exists"))
// }
