--Selecciona todas las canciones que pueda contener una lista en base a la ID
SELECT Musics.*
FROM Musics
JOIN UserListMusics ON Musics.uuid = UserListMusics.music_id
WHERE UserListMusics.list_id = ?