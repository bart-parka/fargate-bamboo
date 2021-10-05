FROM atlassian/bamboo-agent-base

ARG AWS_CLI_VERSION

USER root
RUN apt-get update && \
    apt-get install gnupg2 -y && \
    apt-get install git -y && \
    apt-get install unzip -y && \
    apt-get install sudo 

# Install AWS CLI v2
# Verify the signature of the zip
COPY assets/aws-public.key /
RUN gpg --import /aws-public.key && \
    curl -sLO https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip.sig && \
    curl -sLO https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip && \
    gpg --verify awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip.sig awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip && \
    unzip awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip && \
    aws/install && \
    rm -rf \
      aws-public.key \
      awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip* \
      aws \
      /usr/local/aws-cli/v2/*/dist/aws_completer \
      /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
      /usr/local/aws-cli/v2/*/dist/awscli/examples

WORKDIR ${BAMBOO_USER_HOME}
USER ${BAMBOO_USER}
COPY --chown=bamboo:bamboo runAgent.sh runAgent.sh
RUN chmod 777 runAgent.sh
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.aws.executable" /usr/local/bin/aws && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.aws.executable" /usr/bin/docker


