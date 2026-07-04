#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Print current Python version
python --version


if [ ! -d .git ]; then
    if [ -n "${GIT_ADDRESS}" ]; then
        git clone "${GIT_ADDRESS}" .temp
        mv .temp/* .temp/.* . 2>/dev/null
        rm -rf .temp
    else
        exit 1
    fi
elif [[ "${AUTO_UPDATE}" == "1" ]]; then
    git pull
fi

if [ ! -d "venv"]; then
    python -m venv venv
    ./venv/bin/pip install --upgrade pip
fi

source venv/bin/activate

if [ -f "${REQUIREMENTS_FILE}"]; then
    pip install --no-cache-dir -r "${REQUIREMENTS_FILE}"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e $(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
