/// Sample niconico watch data, shaped like the response of
/// `https://www.nicovideo.jp/api/watch/v3*`.
///
/// `video1` and `audio1`/`audio2` are available, while `video2` and `audio3`
/// are not, so tests can verify that unavailable streams are skipped.
Map<String, dynamic> sampleWatchDataJson() {
  return {
    'client': {
      'nicosid': 'nicosid-value',
      'watchId': 'watch-id',
      'watchTrackId': 'track-id',
    },
    'media': {
      'domand': {
        'videos': [
          {
            'id': 'video1',
            'isAvailable': true,
            'label': '1080p',
            'bitRate': 4000000,
            'width': 1920,
            'height': 1080,
            'qualityLevel': 2,
            'recommendedHighestAudioQualityLevel': 0,
          },
          {
            'id': 'video2',
            'isAvailable': false,
            'label': '720p',
            'bitRate': 2000000,
            'width': 1280,
            'height': 720,
            'qualityLevel': 1,
            'recommendedHighestAudioQualityLevel': 0,
          },
        ],
        'audios': [
          {
            'id': 'audio1',
            'isAvailable': true,
            'label': {'quality': 'AAC', 'bitrate': '128kbps'},
            'bitRate': 128000,
            'samplingRate': 48000.0,
            'integratedLoudness': -10.5,
            'truePeak': 0.5,
            'qualityLevel': 1,
            'loudnessCollection': [
              {'type': 'integrated', 'value': -10.5},
            ],
          },
          {
            'id': 'audio2',
            'isAvailable': true,
            'label': {'quality': 'AAC', 'bitrate': '64kbps'},
            'bitRate': 64000,
            'samplingRate': 48000.0,
            'integratedLoudness': -10.5,
            'truePeak': 0.5,
            'qualityLevel': 0,
            'loudnessCollection': <Map<String, dynamic>>[],
          },
          {
            'id': 'audio3',
            'isAvailable': false,
            'label': {'quality': 'AAC', 'bitrate': '32kbps'},
            'bitRate': 32000,
            'samplingRate': 48000.0,
            'integratedLoudness': -10.5,
            'truePeak': 0.5,
            'qualityLevel': 0,
            'loudnessCollection': <Map<String, dynamic>>[],
          },
        ],
        'accessRightKey': 'access-right-key',
      },
    },
    'owner': {
      'id': 42,
      'nickname': 'uploader',
      'iconUrl': 'https://example.com/icon.png',
    },
    'video': {
      'id': 'sm9',
      'contentType': 'video',
      'title': 'テスト曲',
      'description': '説明',
      'count': {'view': 100, 'comment': 10, 'mylist': 5, 'like': 3},
      'thumbnail': {
        'url': 'https://example.com/thumb.png',
        'middleUrl': null,
        'largeUrl': null,
        'player': null,
        'ogp': null,
        'short': null,
      },
      'registeredAt': '2024-01-02T03:04:05+09:00',
    },
  };
}
