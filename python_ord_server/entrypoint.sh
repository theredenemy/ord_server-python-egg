#!/bin/bash
cd ${HOME}

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Print current Python version
python --version


if [ ! -d .git ]; then
    if [ -n "${GIT_ADDRESS}" ]; then
        if [[ ${GIT_ADDRESS} != *.git ]]; then
            GIT_ADDRESS=${GIT_ADDRESS}.git
        fi
        if [ -z "${USERNAME}" ] && [ -z "${ACCESS_TOKEN}" ]; then
            echo -e "using anon api call"
        else
            GIT_ADDRESS="https://${USERNAME}:${ACCESS_TOKEN}@$(echo -e ${GIT_ADDRESS} | cut -d/ -f3-)"
        fi
        git clone "${GIT_ADDRESS}" ${HOME}/.temp
        mv ${HOME}/.temp/* ${HOME}/.temp/.* ${HOME} 2>/dev/null
        rm -rf ${HOME}/.temp
    else
        exit 1
    fi
elif [[ "${AUTO_UPDATE}" == "1" ]]; then
    git pull
fi

if [ ! -d ${VENV}/lib/${PYTHON_VENV_VERSION} ]; then
    if [ -d ${VENV} ]; then
        rm -rf ${VENV}
    python -m venv ${VENV}
    ${VENV}/bin/pip install --upgrade pip
fi

source ${VENV}/bin/activate

if [ -f ${HOME}/${REQUIREMENTS_FILE} ]; then
    pip install --no-cache-dir -r ${HOME}/${REQUIREMENTS_FILE}
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e $(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
echo "SERVER SHUTDOWN $?"
exit $?