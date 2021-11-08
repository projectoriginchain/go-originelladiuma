# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gprog android ios gprog-cross evm all test clean
.PHONY: gprog-linux gprog-linux-386 gprog-linux-amd64 gprog-linux-mips64 gprog-linux-mips64le
.PHONY: gprog-linux-arm gprog-linux-arm-5 gprog-linux-arm-6 gprog-linux-arm-7 gprog-linux-arm64
.PHONY: gprog-darwin gprog-darwin-386 gprog-darwin-amd64
.PHONY: gprog-windows gprog-windows-386 gprog-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gprog:
	build/env.sh go run build/ci.go install ./cmd/gprog
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gprog\" to launch gprog."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gprog.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gprog.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gprog-cross: gprog-linux gprog-darwin gprog-windows gprog-android gprog-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gprog-*

gprog-linux: gprog-linux-386 gprog-linux-amd64 gprog-linux-arm gprog-linux-mips64 gprog-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-*

gprog-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gprog
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep 386

gprog-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gprog
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep amd64

gprog-linux-arm: gprog-linux-arm-5 gprog-linux-arm-6 gprog-linux-arm-7 gprog-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep arm

gprog-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gprog
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep arm-5

gprog-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gprog
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep arm-6

gprog-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gprog
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep arm-7

gprog-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gprog
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep arm64

gprog-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gprog
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep mips

gprog-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gprog
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep mipsle

gprog-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gprog
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep mips64

gprog-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gprog
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gprog-linux-* | grep mips64le

gprog-darwin: gprog-darwin-386 gprog-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gprog-darwin-*

gprog-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gprog
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-darwin-* | grep 386

gprog-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gprog
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-darwin-* | grep amd64

gprog-windows: gprog-windows-386 gprog-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gprog-windows-*

gprog-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gprog
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-windows-* | grep 386

gprog-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gprog
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gprog-windows-* | grep amd64
