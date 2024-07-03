CREATE TABLE IF NOT EXISTS Musics(
    uuid TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    musicUri TEXT NOT NULL,
    artUri TEXT,
    duration INTEGER NOT NULL,
    type TEXT NOT NULL,
    stars REAL NOT NULL,
    upload_at INTEGER NOT NULL,
    better_moment INTEGER NOT NULL,
    favorite INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS UserListMusics(
    uuid TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    description TEXT NOT NULL,
    image TEXT
);

CREATE TABLE IF NOT EXISTS MusicsLists(
    music_id TEXT NOT NULL,
    list_id TEXT NOT NULL,
    PRIMARY KEY (music_id, list_id),
    FOREIGN KEY (music_id) REFERENCES Musics(uuid),
    FOREIGN KEY (list_id) REFERENCES UserListMusics(uuid)
)