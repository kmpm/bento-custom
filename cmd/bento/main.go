package main

import (
	"context"
	"runtime/debug"
	"time"

	"github.com/warpstreamlabs/bento/public/service"

	// Import all plugins defined within the repo.
	_ "github.com/kmpm/bento-custom/public/components/common"
	_ "github.com/kmpm/bento-custom/public/components/msgstream"
)

var (
	// Version version set at compile time.
	Version string
	// DateBuilt date built set at compile time.
	DateBuilt string
	// BinaryName binary name.
	BinaryName string = "bento"
	Revision   string
	LastCommit time.Time
	DirtyBuild bool
)

func init() {
	info, ok := debug.ReadBuildInfo()
	if !ok {
		return
	}
	if info.Main.Version != "" {
		Version = info.Main.Version
	}
	for _, kv := range info.Settings {
		if kv.Value == "" {
			continue
		}
		switch kv.Key {
		case "vcs.revision":
			Revision = kv.Value
		case "vcs.time":
			LastCommit, _ = time.Parse(time.RFC3339, kv.Value)
		case "vcs.modified":
			DirtyBuild = kv.Value == "true"
		}
	}
}

func main() {
	service.RunCLI(
		context.Background(),
		service.CLIOptSetVersion(Version, DateBuilt),
		service.CLIOptSetBinaryName(BinaryName),
		service.CLIOptSetProductName("Bento"),
		service.CLIOptSetDocumentationURL("https://warpstreamlabs.github.io/bento/docs"),
		service.CLIOptSetShowRunCommand(true),
	)
}
