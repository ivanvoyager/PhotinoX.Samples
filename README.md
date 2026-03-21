# PhotinoX.Samples

[![Build](https://github.com/ivanvoyager/PhotinoX.Samples/actions/workflows/build.yml/badge.svg)](https://github.com/ivanvoyager/PhotinoX.Samples/actions/workflows/build.yml)
[![License](https://img.shields.io/github/license/ivanvoyager/PhotinoX.Samples?label=license)](https://github.com/ivanvoyager/PhotinoX.Samples/blob/master/LICENSE)

Sample projects showcasing **PhotinoX** — a lightweight, cross‑platform framework for building native desktop apps using Web UI technologies (Blazor, React, Vue, Angular, or plain HTML/JS).
PhotinoX uses OS‑native WebView engines:
- **Windows**: WebView2
- **macOS**: WKWebView
- **Linux**: WebKitGTK 4.1

> **Note:** `PhotinoX.Samples` is an independent fork of [tryphotino/photino.Samples](https://github.com/tryphotino/photino.Samples) under the Apache‑2.0 license and is **not affiliated** with the original project or organization.

## What is PhotinoX?

`PhotinoX` is a lightweight, open‑source platform for building native desktop applications using modern **Web UI** stacks.
It keeps application size small and memory usage low by depending on the system’s built‑in **WebView** engines (instead of bundling Chromium).

Core packages:
- [**PhotinoX**](https://github.com/ivanvoyager/PhotinoX) (.NET wrapper)
- [**PhotinoX.Native**](https://github.com/ivanvoyager/PhotinoX.Native) (native binaries for Windows/macOS/Linux)
- [**PhotinoX.Blazor**](https://github.com/ivanvoyager/PhotinoX.Blazor) (Blazor integration)
- [**PhotinoX.Server**](https://github.com/ivanvoyager/PhotinoX.Server) (optional static‑file server to avoid CORS/ESM issues)

## Samples included

This repository contains examples using a variety of frontend technologies:

### Web frameworks

- **Vue.js**
- **React**
- **Angular**

### Other sample types

- Plain HTML/CSS/JS
- WebAPI local communication
- gRPC local communication
- 3D graphics using Three.js
- 3D graphics with React + Three.js
- Multi‑window example
- Static File Server sample (useful for ESM/CORS limitations)
- TestBench (WebAPI, OS calls, PowerShell calls, etc.)

Each folder starting with `Photino.HelloPhotino.*` is a self‑contained sample project.

## Tooling

The `tools/` directory contains convenience scripts for building and running the samples.

### SPA build modes
- `build-all-spa.cmd` – production build (`npm ci`)
- `build-all-spa-clean.cmd` – clean + production build
- `build-all-spa-restore-install.cmd` – development build (`npm install`)

Use `npm ci` for reproducible builds.  
Use `npm install` for local development or when modifying the frontend code.

### Run SPA samples (development)
- `run-dev.cmd -List` — list detected SPA projects  
- `run-dev.cmd -Project <Name> -Port <port>` — start dev server + PhotinoX host  
- Shorthand launchers:
  - `run-dev-Photino.HelloPhotino.React.cmd`
  - `run-dev-Photino.HelloPhotino.Vue.cmd`
  - `run-dev-Photino.HelloPhotino.Angular.cmd`
  - `run-dev-Photino.HelloPhotino.3d.React.cmd`

### Run pure .NET samples (no npm)
- `run-dotnet-Photino.HelloPhotino.3d.cmd`
- `run-dotnet-Photino.HelloPhotino.GRpc.cmd`
- `run-dotnet-Photino.HelloPhotino.MultiWindow.cmd`
- `run-dotnet-Photino.HelloPhotino.NET.cmd`
- `run-dotnet-Photino.HelloPhotino.StaticFileServer.cmd`
- `run-dotnet-Photino.HelloPhotino.TestBench.cmd`

These scripts are optional but greatly simplify both development (npm dev servers) and .NET‑only runs.

## Requirements

- **.NET**: 8, 9, or 10
- Node.js + npm (for SPA samples)
- **Windows**: WebView2 Runtime
- **macOS**: WKWebView (built-in)
- **Linux**: WebKitGTK 4.1 (runtime + dev packages)

## Troubleshooting

- Ensure **NuGet packages** are restored (PhotinoX.*, etc.)
- Build for **x64** or **ARM64**, not x86
- For SPA samples:
  - Use `npm install` for development inside each sample folder
  - Use `npm ci` when running the production build scripts (`build-all-spa*.cmd`)
  - Ensure assets are served over HTTP (`PhotinoX.Server`) when needed

On Windows, ensure the **WebView2 Runtime** is installed.
Most modern Windows versions include it, but clean or corporate installations may not.

## Contributing

Issues and PRs are welcome. Keep PRs focused, minimal, and consistent with the rest of PhotinoX.

## License

PhotinoX.Samples is licensed under **Apache‑2.0**.