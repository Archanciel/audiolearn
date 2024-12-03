## GitHub Copilot Chat

- Extension Version: 0.22.4 (prod)
- VS Code: vscode/1.95.3
- OS: Windows

## Network

User Settings:
```json
  "github.copilot.advanced": {
    "debug.useElectronFetcher": true,
    "debug.useNodeFetcher": false
  }
```

Connecting to https://api.github.com:
- DNS ipv4 Lookup: 140.82.121.6 (709 ms)
- DNS ipv6 Lookup: Error: getaddrinfo ENOTFOUND api.github.com
- Electron Fetcher (configured): HTTP 200 (378 ms)
- Node Fetcher: HTTP 200 (198 ms)
- Helix Fetcher: HTTP 200 (269 ms)

Connecting to https://api.individual.githubcopilot.com/_ping:
- DNS ipv4 Lookup: 140.82.113.22 (57 ms)
- DNS ipv6 Lookup: Error: getaddrinfo ENOTFOUND api.individual.githubcopilot.com
- Electron Fetcher (configured): HTTP 200 (553 ms)
- Node Fetcher: HTTP 200 (604 ms)
- Helix Fetcher: HTTP 200 (481 ms)

## Documentation

In corporate networks: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).