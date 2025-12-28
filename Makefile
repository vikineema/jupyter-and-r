#!make
SHELL := /usr/bin/env bash

include  .env

ENV_FILE =  $(abspath .env)
export ENV_FILE

activate-env:
	nix develop

lint-src:
	ruff check --select I --fix src/         
	ruff format --verbose src/
	
start-local-jupyter:
	nohup uv run jupyter lab --config=jupyter_lab_config.py > /dev/null 2>&1 &
	sleep 10s
	uv run jupyter lab list