.PHONY: help run tui test lint check format build deploy ci

help:
	@echo "Available targets:"
	@echo "  make run     - Sync COROS data from .env and regenerate activities.json"
	@echo "  make tui     - Run the Textual TUI"
	@echo "  make test    - Run Python tests"
	@echo "  make lint    - Run frontend lint"
	@echo "  make check   - Run frontend format check"
	@echo "  make format  - Format frontend files"
	@echo "  make build   - Build frontend assets"
	@echo "  make deploy  - Build and deploy to Vercel"
	@echo "  make ci      - Run test, lint, check, and build"

run:
	@test -f .env || (echo "Missing .env. Copy .env.example or create COROS_ACCOUNT/COROS_PASSWORD first."; exit 1)
	@set -a; . ./.env; set +a; \
	uv run python -c 'import asyncio, hashlib, os, sys; sys.path.insert(0, "run_page"); from coros_sync import download_and_generate; account = os.environ["COROS_ACCOUNT"]; password = os.environ["COROS_PASSWORD"]; only_run = os.environ.get("COROS_ONLY_RUN", "false").lower() in ("1", "true", "yes"); file_type = os.environ.get("COROS_FILE_TYPE", "fit"); asyncio.run(download_and_generate(account, hashlib.md5(password.encode()).hexdigest(), only_run, file_type))'

tui:
	uv run run_page

test:
	uv run python -m unittest discover -s . -p 'test_*.py'

lint:
	pnpm run lint

check:
	pnpm run check

format:
	pnpm run format

build:
	pnpm run build

deploy: build
	npx --yes vercel --prod --yes

ci: test lint check build
