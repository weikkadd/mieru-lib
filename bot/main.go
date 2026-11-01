package main

import "C"

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/enfein/mieru/v3/pkg/appctl"
	pb "github.com/enfein/mieru/v3/pkg/appctl/proto"
	"github.com/enfein/mieru/v3/pkg/common"
)

type StartPayload struct {
	Config     string `json:"config"`
	WorkingDir string `json:"workingDir"`
}

//export StartBot
func StartBot(payload *C.char) C.int {
	p := C.GoString(payload)
	var sp StartPayload
	if err := json.Unmarshal([]byte(p), &sp); err != nil {
		fmt.Println("[bot] payload parse error:", err)
		return 2
	}
	if sp.Config == "" {
		fmt.Println("[bot] config path is empty")
		return 2
	}
	if sp.WorkingDir != "" {
		if err := os.Chdir(sp.WorkingDir); err != nil {
			fmt.Println("[bot] chdir error:", err)
			return 2
		}
	}
	b, err := os.ReadFile(sp.Config)
	if err != nil {
		fmt.Println("[bot] read config error:", err)
		return 2
	}
	cfg := &pb.ServerConfig{}
	if err := common.UnmarshalJSON(b, cfg); err != nil {
		fmt.Println("[bot] config parse error:", err)
		return 2
	}
	if err := appctl.StartServerProxy(cfg); err != nil {
		fmt.Println("[bot] start error:", err)
		return 1
	}
	fmt.Println("[bot] server proxy started")
	return 0
}

//export StopBot
func StopBot() C.int {
	return 0
}

func main() {}