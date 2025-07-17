# Addon for Hugo

This is patches for [Hugo](https://github.com/gohugoio/hugo) to add custom (Goldmark) addons like wikilink.

## Build

```bash
git clone --recurse-submodules https://github.com/qgp9/hugo-addon
cd hugo-addon
./bin/patch.sh prepare
./bin/patch.sh apply
cp -r addons/wikilink/addon hugo/

cd hugo
go mod tidy
go build -tags wikilink
# "hugo" binary is built in the current directory. 
go test -tags wikilink addon/wikilink/tests/*
```

## Directory Structure of Addon

```txt
Hugo
├── addon/
|  ├── common/
|  ├── registry.go
|  ├── <addon-name>/
|  ├── register-<addon-name>.go
|  ├── ...
```

## Registering Addon

* Example: `wikilink` addon

```go
// register-wikilink.go
//go:build wikilink

package addon

import (
 "github.com/gohugoio/hugo/addon/wikilink"
 "github.com/gohugoio/hugo/markup/converter"
 "github.com/yuin/goldmark"
 "github.com/yuin/goldmark/renderer"
)

func init() {
 AddonBuildTags = append(AddonBuildTags, "wikilink")
 RegisterAddon(loadWikilinkAddon)
}

// loadWikilinkAddon loads the wikilink addon if enabled in configuration.
func loadWikilinkAddon(pcfg converter.ProviderConfig) ([]goldmark.Extender, []renderer.Option, error) {
 var extensions []goldmark.Extender
 var rendererOptions []renderer.Option

 wikilink.Load(pcfg, &extensions, &rendererOptions)

 return extensions, rendererOptions, nil
}

```

## A Note from the Developer

This addon system was created for personal use (for wikilink) and involves some "creative" Hugo system hacking. Here are some honest thoughts:

1. **No PR intended**: This was built for personal convenience, not as a contribution to Hugo core. The implementation takes some liberties with Hugo's internals that wouldn't pass a proper code review.
1. **Addon system**: While not strictly necessary, the addon system makes it much easier to add experimental features without cluttering the main codebase. It's like having a sandbox for my wild ideas.
1. **Addon location**: `markup/goldmark/` is more neutral but I put it in root because I'm lazy. Now I have to re-export internal packages which is gross, but at least I don't have to `cd` around. ¯\_(ツ)_/¯
1. **`params.addon.*`**: I didn't want to touch `markup.goldmark.*`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
