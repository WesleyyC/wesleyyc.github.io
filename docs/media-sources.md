# Media sources

## Osmo Studio launch film

- File: `public/media/osmo-studio-launch.mp4`
- Creator: Osmo. Original launch video from May 6, 2026.
- [Original post](https://www.linkedin.com/posts/osmolabs_scent-has-always-told-stories-now-you-can-activity-7457798157297467392-irv4)
- [Wesley’s repost](https://www.linkedin.com/feed/update/urn:li:activity:7457801665895776256/)
- Source: the film on [Osmo for brands](https://www.osmo.ai/for-brands), downloaded September 4, 2026, at Wesley’s request and approved as the replacement source.
- [Website MP4](https://cdn.prod.website-files.com/69d56de91b59477a7776fadd%2F69f7997ce42d516b20237540_OSMO_Product%20Demo-v2_mp4.mp4): H.264 Main, 1280×720, 30 fps, 27.1 seconds, 813 frames, no audio stream, 2,546,975 bytes.
- Source SHA-256: `60e765f6f2961d9620d97ad546204956a2957664ddc8246c19f422e27b610628`
- Deployed rendition: the unmodified website MP4, restored at Wesley’s request. No sharpening, resizing, or re-encoding is applied.
- Deployed size: 2,546,975 bytes. SHA-256: `60e765f6f2961d9620d97ad546204956a2957664ddc8246c19f422e27b610628` (identical to the source).
- The source, earlier LinkedIn download, and comparison frames remain in ignored `output/`. Only the selected film ships. The homepage media URL includes the first 12 checksum characters to invalidate previously cached copies.
- Attribution and links to the original post are recorded here; the player shows only the video and its controls. This record does not assert an additional media license.

### Source preservation

The downloaded website MP4 is copied directly into `public/media/`. Keep its bytes unchanged and update the homepage URL’s checksum prefix whenever the source changes. The site remains below the 3 MB total artifact budget, with the core below 500 KB.

The earlier sharpening experiments remain in ignored `output/video-enhancement/` for reference; they are not deployed.

The homepage loads no video data until the linked product phrase is activated. Its ordinary href also works without JavaScript. The implementation uses the browser’s [native dialog](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/dialog) and [video controls](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/video).
