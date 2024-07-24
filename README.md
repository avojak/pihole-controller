# Pi-hole Controller

## Building

To make sure you have the correct Flatpak runtime and SDK installed, run:

```bash
make init
```

To run the Flatpak build, run:

```bash
make flatpak # or just `make`
```

### Development Environment

For consistency and simplicity, a Visual Studio Code dev container definition is provided. This container contains all the required development libraries, plus some useful Visual Studio Code plugins. When actually developing, however, you'll want to run the build commands from your local host instead of within the container.