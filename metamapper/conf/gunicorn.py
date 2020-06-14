#
# Gunicorn (https://docs.gunicorn.org/en/stable/configure.html)
#
# Metamapper uses Gunicorn to handle web requests by default. We recommend
# spinning up a few of these and putting them behind a reverse proxy like nginx.
#

bind = '0.0.0.0:5050'
