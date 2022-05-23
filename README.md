# Cut the rope

An experiment to simulate ropes in Zig.

## Usage

| Key | Effect |
| --- | --- |
| q | quit |
| space | toggle pause |

## Installing dependencies

### Using Nix

Install direnv and Nix. Enable flakes. Run `direnv allow` (in the source repository).

### Without Nix

Install Zig and SDL2.

## Build and run

```console
git clone github.com/gabriel-doriath-dohler/cut-the-rope
cd cut-the-rope
zig build run
```

## Git hooks

You can add a pre-commit git hook to make sure that files are formatted using:
```console
chmod +x .githooks/*
git config --local core.hooksPath .githooks
```
