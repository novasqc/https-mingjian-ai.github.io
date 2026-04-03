# 播客音频文件目录

本目录存放播客音频文件（MP3 格式）。

## 文件命名规范

```
podcast_{slug}.mp3
```

例如：
- podcast_three-body-review.mp3
- podcast_dark-forest-vs-symbiosis.mp3

## 音频要求

- 格式：MP3
- 比特率：128kbps 或更高
- 采样率：44.1kHz

## 生成方式

```bash
python3 ~/.openclaw/workspace/skills/podcast-generator/scripts/batch_generate.py --category all
```

