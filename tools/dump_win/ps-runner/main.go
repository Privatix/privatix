// +build windows

// Go generate creates a syso file which contains manifest and icon
// flags	-64=true: generate 64-bit binaries
//			-o="../resource_windows_amd64.syso": output file name
//go:generate goversioninfo -64 -o ./resource_windows_amd64.syso

package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"

	"github.com/privatix/dappctrl/util"
)

type config struct {
	Script string
	Args   []string
}

func newConfig() *config {
	return &config{}
}

func main() {
	conf := newConfig()

	if err := processedArguments(conf); err != nil {
		panic(err)
	}

	if err := executeCommand(conf.Script, conf.Args...); err != nil {
		panic(err)
	}
}

func processedArguments(conf *config) error {
	args := os.Args[1:]
	if len(args) < 2 {
		return fmt.Errorf("insufficient number of parameters")
	}

	if strings.HasPrefix(args[0], "-") {
		args[0] = args[0][1:]
	}

	switch strings.ToLower(args[0]) {
	case "config":
		if err := util.ReadJSONFile(args[1], &conf); err != nil {
			return err
		}
	case "script":
		processedScriptsArgs(conf, args...)
	default:
		return fmt.Errorf("unknown parameters")
	}

	return nil
}

func processedScriptsArgs(conf *config, args ...string) {
	s, _ := filepath.Abs(args[1])
	conf.Script = s
	if len(args) < 3 {
		return
	}

	for i := 2; i < len(args); i++ {
		conf.Args = append(conf.Args, args[i])
	}

}

func executeCommand(filename string, args ...string) (err error) {
	args = append([]string{"-ExecutionPolicy", "Bypass", "-File", filename},
		args...)
	cmd := exec.Command("powershell", args...)
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}

	var outbuf, errbuf bytes.Buffer
	cmd.Stdout = &outbuf
	cmd.Stderr = &errbuf
	if err = cmd.Run(); err != nil {
		outStr, errStr := outbuf.String(), errbuf.String()
		err = fmt.Errorf("%v\nout:\n%s\nerr:\n%s", err, outStr, errStr)
	}
	return err
}
