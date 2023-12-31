.PHONY: docs clean

COMMAND = docker-compose run --rm djangoapp /bin/bash -c

build:
	docker-compose build

run:
	docker-compose up

migrate:
	$(COMMAND) 'cd core; for db in default; do ./manage.py migrate --database=$${db}; done'

collectstatic:
	docker-compose run --rm djangoapp core/manage.py collectstatic --no-input

clean:
	rm -rf build
	rm -rf core.egg-info
	rm -rf dist
	rm -rf htmlcov
	rm -rf .cache
	find . -type f -name "*.pyc" -delete
	rm -rf $(find . -type d -name __pycache__)
	rm .coverage
	rm .coverage.*

dockerclean:
	docker system prune -f
	docker system prune -f --volumes