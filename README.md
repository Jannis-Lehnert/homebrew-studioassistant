# Studio Assistant Homebrew tap

```bash
brew install jannis-lehnert/studioassistant/studioassistant-satellite
```

Installs and starts the Studio Assistant satellite as a launchd daemon on Apple silicon. Homebrew asks
for your password once, because the daemon is installed system-wide.

`brew uninstall` stops and removes the service and keeps `/opt/studio-assistant/satellite`;
`brew uninstall --zap` removes that directory too.
