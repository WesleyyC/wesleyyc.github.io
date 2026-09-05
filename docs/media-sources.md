# Media sources

## Osmo Studio launch film

- File: `public/media/osmo-studio-launch.mp4`
- Creator: Osmo. Original launch video from May 6, 2026.
- [Original post](https://www.linkedin.com/posts/osmolabs_scent-has-always-told-stories-now-you-can-activity-7457798157297467392-irv4)
- [Wesley’s repost](https://www.linkedin.com/feed/update/urn:li:activity:7457801665895776256/)
- Source: the film on [Osmo for brands](https://www.osmo.ai/for-brands), downloaded September 4, 2026, at Wesley’s request and approved as the replacement source.
- [Website MP4](https://cdn.prod.website-files.com/69d56de91b59477a7776fadd%2F69f7997ce42d516b20237540_OSMO_Product%20Demo-v2_mp4.mp4): H.264 Main, 1280×720, 30 fps, 27.1 seconds, 813 frames, no audio stream, 2,546,975 bytes.
- Source SHA-256: `60e765f6f2961d9620d97ad546204956a2957664ddc8246c19f422e27b610628`
- Deployed rendition: light, luma-only contrast-adaptive sharpening, followed by H.264 High encoding. Dimensions, frame rate, duration, and BT.709 color are preserved. This is a modest sharpening treatment, not recovered resolution or generated detail.
- Deployed size: 2,225,187 bytes. SHA-256: `2f31d9711944c5b8d0b544b4f1e69e5f1691406a39fa1bd59822ad83bcbce75e`
- The source, earlier LinkedIn download, and comparison frames remain in ignored `output/`. Only the selected film ships. The homepage media URL includes the first 12 checksum characters to invalidate previously cached copies.
- Attribution and links to the original post are recorded here; the player shows only the video and its controls. This record does not assert an additional media license.

### Processing

The selected [FFmpeg contrast-adaptive sharpening filter](https://ffmpeg.org/ffmpeg-filters.html#cas) uses strength `0.25` on luma only. A weak deblocking pass and conventional unsharp masking were also compared; neither added enough benefit to retain. Frames with text, photographs, transitions, and the closing logo were compared with the website source. The final encode keeps the core site below 500 KB and the complete artifact below the revised 3 MB budget for the approved film upgrade.

Recreate from the original download with FFmpeg and libx264 (output bytes can vary between encoder versions):

```sh
ffmpeg -i output/artifacts/osmo-studio-launch-website-720p.mp4 \
  -map 0:v:0 -an -vf 'cas=strength=0.25:planes=1' \
  -c:v libx264 -preset slow -crf 22 -threads 2 \
  -pix_fmt yuv420p -profile:v high -level:v 3.1 \
  -movflags +faststart -map_metadata -1 \
  -color_primaries bt709 -color_trc bt709 -colorspace bt709 \
  output/video-enhancement/enhanced.mp4
```

Inspect the result before replacing the shipped asset, then update its checksum and homepage URL. `+faststart` places MP4 metadata before the video payload for progressive playback.

The homepage loads no video data until the linked product phrase is activated. Its ordinary href also works without JavaScript. The implementation uses the browser’s [native dialog](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/dialog) and [video controls](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/video).
