#!/usr/bin/env bash

PRIVATE_KEY=/root/ssh/id_rsa
[[ -f ${PRIVATE_KEY} ]] || { echo "no private key found." >2 ; ls -la /root/ ; exit 1 ; }

WAITTIME=${WAITTIME:-10}

log() {
    echo "$(date) - $@"
}

main() {
    while true ; do
        REBOOT_REQUIRED=$(ssh -i ${PRIVATE_KEY} rancher@${NODE_IP} [[ -f /var/run/reboot-required ]] && echo TRUE)
        if [[ "${REBOOT_REQUIRED}" == "TRUE"]] ; then
            log "reboot required - cancel updating"
            sleep ${WAITTIME}
            continue
        fi

        ROS_LIST=$(ssh -i ${PRIVATE_KEY} rancher@${NODE_IP} sudo ros os list)
        CURRENT_ROS_VERSION=$(ssh -i ${PRIVATE_KEY} rancher@${NODE_IP} sudo ros os)
        NUMBER_OF_LIST=$(grep -n "${CURRENT_ROS_VERSION}" <<< "${LIST}" | grep -o '^[0-9]*')

        if [[ ${NUMBER_OF_LIST} -eq 1 ]] ; then
            log "on latest version - cancel updating"
            sleep ${WAITTIME}
            continue
        fi

        NUMBER_OF_LIST=$(( NUMBER_OF_LIST - 1 ))
        NEW_ROS_VERSION=$(awk "NR==${NUMBER_OF_LIST} { print \$1 }" <<< ${LIST})

        log "updating RancherOS from ${CURRENT_ROS_VERSION} to ${NEW_ROS_VERSION}"

        # install without reboot
        ssh -i ${PRIVATE_KEY} rancher@${NODE_IP} sudo ros os upgrade -i ${NEW_ROS_VERSION} --no-reboot -f

        # mark for reboot required
        ssh -i ${PRIVATE_KEY} rancher@${NODE_IP} sudo touch /var/run/reboot-required

        sleep ${WAITTIME}
    done
}