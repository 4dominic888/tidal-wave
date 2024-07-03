SELECT Musics.*
FROM Musics
JOIN MusicsLists ON Musics.uuid = MusicsLists.music_id
WHERE MusicsLists.list_id = ?