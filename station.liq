#!/usr/bin/env liquidsoap

%include "vars.liq"

def meta2json(m) = # Return metadata as JSON string
  meta_json = json()
  meta_json.add("artist", m["artist"])
  meta_json.add("album_artist", m["album_artist"])
  meta_json.add("title", m["title"])
  meta_json.add("duration_seconds", request.duration(m["filename"]))
  meta_json.add("filename", path.basename(m["filename"]))
  meta_json.add("local_usage_note", m["local usage note"])
  meta_json.add("local_license_tag", m["local license tag"])
  meta_json.add("local_download_url", m["local download url"])
  json.stringify(meta_json)
end

def insert_metadata(m) = # maps locally generated metadata into stream
  [("comment", meta2json(m))]
end

settings.server.socket := true
settings.server.socket.path := unixsocket

enable_replaygain_metadata()
source = replaygain(playlist(id="playlist", playlist_file))

source = metadata.map(insert_metadata, source)

output.icecast(
  %vorbis,
  host=icecast_host,
  port=icecast_port,
  password=icecast_pass,
  description=icecast_desc,
  genre=icecast_genre,
  name=icecast_name,
  mount=icecast_mount,
  mksafe(crossfade(source))
)
