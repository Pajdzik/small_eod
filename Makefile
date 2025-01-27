.PHONY: all test clean docs
REFERENCE_OPENAPI?="https://dev.small-eod.siecobywatelska.pl/api/swagger.json"
GIT_COMMIT := $(shell git rev-parse HEAD)
TEST?=small_eod
BRANCH?=dev
TAG?=latest

start: wait_mysql wait_minio
	docker-compose up -d

stop:
	docker-compose stop

logs:
	docker-compose logs --tail 100 -f

clean:
	docker-compose down

build:
	docker-compose build backend

test: wait_mysql wait_minio test_backend test_openapi_spec

test_backend:
	docker-compose run -e SOCIAL_AUTH_USE_FAKE_OAUTH=False backend coverage run manage.py test --keepdb --parallel $(nproc) --verbosity=2 ${TEST}

coverage_html_backend:
	docker-compose run backend coverage html

coverage_send_backend:
	docker-compose run -e GITHUB_ACTIONS -e GITHUB_REF -e GITHUB_SHA -e GITHUB_HEAD_REF -e GITHUB_REPOSITORY -e GITHUB_RUN_ID -e GITHUB_TOKEN -e COVERALLS_REPO_TOKEN backend coveralls

test_openapi_spec:
	docker-compose run --rm backend python manage.py generate_swagger --format json -o openapi.json
	docker run -v $$(pwd)/backend-project/openapi.json:/openapi.json --rm p1c2u/openapi-spec-validator --schema 2.0 /openapi.json
	docker-compose run --rm backend rm openapi.json

diff_openapi: SHELL:=/bin/bash
diff_openapi:
	diff -c -C 10 <( curl -s "${REFERENCE_OPENAPI}"  | jq '.') <( docker-compose run -T --rm backend python manage.py generate_swagger --format json | jq '.' ) || true

wait_mysql:
	docker-compose up -d db
	docker-compose run --rm backend bash -c 'wait-for-it db:5432'

wait_minio:
	docker-compose up -d minio
	docker-compose run --rm backend bash -c 'wait-for-it minio:9000'

migrate:
	docker-compose run --rm backend python manage.py migrate

makemigrations:
	docker-compose run --rm backend python manage.py makemigrations

pyupgrade:
	docker run --rm -v /$$(pwd)/backend-project:/data quay.io/watchdogpolska/pyupgrade --py37-plus

lint:
	docker run --rm -v /$$(pwd)/backend-project:/apps alpine/flake8 .
	docker run --rm -v /$$(pwd)/backend-project:/data cytopia/black --check .

fmt:
	docker run --rm --user $$(id -u):$$(id -u) -v /$$(pwd):/data cytopia/black ./backend-project

check: wait_mysql wait_minio
	docker-compose run --rm backend python manage.py makemigrations --check

migrations: wait_mysql wait_minio
	docker-compose run --rm backend python manage.py makemigrations

settings:
	docker-compose run --rm backend python manage.py diffsettings

createsuperuser: wait_minio
	docker-compose run --rm -e DJANGO_SUPERUSER_PASSWORD=root backend python manage.py createsuperuser --username root --email root@example.com --noinput

test_local: lint build check test

openapi:
	docker-compose run --rm backend python manage.py generate_swagger

docs:
	docker-compose run backend bash -c 'cd ../docs&&sphinx-build -b html -d _build/doctrees . _build/html'

build_balancer:
	docker build -t docker-registry.siecobywatelska.pl/small_eod/balancer:${TAG} balancer/

build_frontend:
	docker build -t docker-registry.siecobywatelska.pl/small_eod/frontend:${TAG} frontend-project/

build_backend:
	docker build --target prod -t docker-registry.siecobywatelska.pl/small_eod/backend:${TAG} backend-project/

push_balancer:
	docker push docker-registry.siecobywatelska.pl/small_eod/balancer:${TAG}

push_frontend:
	docker push docker-registry.siecobywatelska.pl/small_eod/frontend:${TAG}

push_backend:
	docker push docker-registry.siecobywatelska.pl/small_eod/backend:${TAG}
