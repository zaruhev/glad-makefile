# GLAD Makefile script
A Makefile compilation/installation script for version 2.0 of [Dav1dde's GLAD library](https://github.com/Dav1dde/glad).

## Usage
To install GLAD using the Makefile, call `make` from the root directory of your GLAD folder:
```sh
# your folder may look like this:
glad
├── Makefile # <-- Makefile should be here
├── include
│   ├── KHR
│   │   └── khrplatform.h
│   └── glad
│       └── glad.h
└── src
    └── glad.c
```
```sh
make
```

If the build is successful, the archive and includes should be generated in `./build`.

Navigate into the `./build` directory and call `sudo make install`:
```sh
cd build
sudo make install
```

To test whether GLAD has installed correctly, search for glad.pc with `pkg-config`:
```sh
pkg-config --cflags --libs glad
```

To uninstall GLAD from pkgconfig, call `sudo make uninstall` from within the build directory:
```sh
sudo make uninstall
```

## Contributing
This installation script is still in its "it works on my system" phase, so any and all contributions are welcome.

TODOs are written sporadically in Makefile.

