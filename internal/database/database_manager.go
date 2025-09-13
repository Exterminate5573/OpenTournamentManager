package OpenTournamentManager

import (
	"database/sql"
	_ "embed"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
	"os"
)

//go:embed create_db.ddl
var ddl string

type DatabaseManager struct {
	db *sql.DB
}

func NewDatabaseManager(dbPath string) (*DatabaseManager, error) {
	// Check if the database file exists
	_, err := os.Stat(dbPath)
	dbExists := !os.IsNotExist(err)

	// Open the database connection
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %v", err)
	}

	// If the database file did not exist, create the necessary tables
	if !dbExists {
		if err := createTables(db); err != nil {
			_ = db.Close()
			return nil, fmt.Errorf("failed to create tables: %v", err)
		}
	} else {
		//Validate existing database schema
		if err := validateSchema(db); err != nil {
			_ = db.Close()
			return nil, fmt.Errorf("database schema validation failed: %v", err)
		}
	}

	return &DatabaseManager{db: db}, nil
}

func createTables(db *sql.DB) error {
	_, err := db.Exec(ddl)
	if err != nil {
		return fmt.Errorf("failed to execute DDL: %w", err)
	}
	return nil
}

func validateSchema(db *sql.DB) error {
	// TODO: Implement schema validation logic
	return nil
}

func (dm *DatabaseManager) Close() error {
	return dm.db.Close()
}

func (dm *DatabaseManager) GetDB() *sql.DB {
	return dm.db
}
