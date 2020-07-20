push:
	# - git push
	- cd base-php && docker build -t emtudo/base-php:latest . --network=host
	# - docker push emtudo/base-php:latest
	- cd base-php && docker build -t emtudo/base-php:php-7.4 . --network=host
	# docker push emtudo/base-php:php-7.4
