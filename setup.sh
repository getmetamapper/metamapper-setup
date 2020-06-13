#!/usr/bin/env bash
set -e

dc="docker-compose --no-ansi"

# Generate a secret key that length of "$1"
function secret() {
   dd if=/dev/urandom bs="$1" count=1 2>/dev/null | openssl enc -A -base64
}

# Step 1: Check current system dependencies.
if [ ! -f .env ]; then cp -f .env.dist .env ; fi

# Step 2: Create persistent storage.
#
$dc down --rmi local --remove-orphans

echo ""
echo "Creating Docker volumes..."
echo "Created $(docker volume create --name=metamapper-postgres)."
echo "Created $(docker volume create --name=metamapper-msgbroker)."

# Step 3: Copy configurations and generate secret keys, if needed.
#
# You can update the configuration paths here if you want to rename the default files.
#
echo ""
echo "Checking if configuration files exist..."
echo ""

CELERY_CONFIG_PY='metamapper/config/celery.py'
CELERY_TEMPLATE_PY='config_templates/celery.default.py'

if [ ! -f "$CELERY_CONFIG_PY" ]; then
    echo "Copying default Celery configuration."
    cp $CELERY_TEMPLATE_PY $CELERY_CONFIG_PY
else
    echo "File already exists: $CELERY_CONFIG_PY"
fi

DJANGO_CONFIG_PY='metamapper/config/settings.py'
DJANGO_TEMPLATE_PY='config_templates/settings.default.py'

if [ ! -f "$DJANGO_CONFIG_PY" ]; then
    echo "Copying default Django override settings."
    cp $DJANGO_TEMPLATE_PY $DJANGO_CONFIG_PY
else
    echo "File already exists: $DJANGO_CONFIG_PY"
fi

GUNICORN_CONFIG_PY='metamapper/config/gunicorn.py'
GUNICORN_TEMPLATE_PY='config_templates/gunicorn.default.py'

if [ ! -f "$GUNICORN_CONFIG_PY" ]; then
    echo "Copying default Gunicorn configuration."
    cp $GUNICORN_TEMPLATE_PY $GUNICORN_CONFIG_PY
else
    echo "File already exists: $GUNICORN_CONFIG_PY"
fi

# Write out the secrets into the .env file. You can change these if you want.
if  ! grep -q "METAMAPPER_SECRET_KEY" .env ; then
    echo ""
    echo "Generating secret key..."
    echo "METAMAPPER_SECRET_KEY=$(secret 50)" >> .env
    echo "Secret key written to the .env file"
fi

# Write out the secrets into the .env file. You can change these if you want.
if  ! grep -q "METAMAPPER_FERNET_KEY" .env ; then
    echo ""
    echo "Generating encryption key..."
    echo "METAMAPPER_FERNET_KEY=$(secret 32)" >> .env
    echo "Encryption key written to the .env file"
fi

# Step 4: Fetch any Docker dependencies.
#
echo ""
echo "Fetching and updating Docker images..."
echo ""

MM_IMAGE=${METAMAPPER_IMAGE:-metamapper/metamapper}
MM_VERSION=${METAMAPPER_VERSION:-latest}

docker pull $MM_IMAGE:$MM_VERSION

# Step 5: Build the local Docker image using their Metamapper configuration.
#
echo ""
echo "Building and tagging on-premise Docker image..."
echo ""

$dc build --build-arg METAMAPPER_IMAGE=$MM_IMAGE --force-rm webserver

echo ""
echo "Docker image has been built."

# Step 6: Set up the database and run the migrations.
#
echo ""
echo "Creating database..."

$dc run -e DB_SETUP=1 webserver manage initdb --close-sessions --noinput --verbosity 0
$dc run -e DB_SETUP=1 webserver migrate

echo ""
echo "Database has been created and migrations have been run."

# Step 7: Clean up and exit the build process.

$dc stop &> /dev/null

echo ""
echo "----------------"
echo ""
echo "Setup is complete! Run the following command to spin up Metamapper:"
echo ""
echo "  docker-compose up -d"
echo ""
echo "Access to the web UI defaults to: http://localhost:5050"
echo ""
