#
# Celery (https://docs.celeryproject.org/en/stable/userguide/configuration.html)
#
# Metamapper supports a pretty basic Celery setup with an optional
# results backend. We recommend using either Redis or RabbitMQ as your broker.
#
#

import os


broker_url = os.getenv('METAMAPPER_CELERY_BROKER_URL')

accept_content = ['application/json']

result_serializer = 'json'

task_serializer = 'json'

task_always_eager = False

task_eager_propagates = task_always_eager

result_backend = os.getenv('METAMAPPER_CELERY_RESULT_BACKEND')
