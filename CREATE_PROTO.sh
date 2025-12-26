#!/bin/bash
protoc --dart_out=grpc:lib/protos -Iprotos protos/models.proto
