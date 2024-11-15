# Use an official Ubuntu base image
FROM --platform=linux/arm64 ubuntu:24.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV SSH_USERNAME="ubuntu"
ENV SSHD_CONFIG_ADDITIONAL=""
ENV SSH_PORT="2222"

# Install OpenSSH server, clean up, create directories, set permissions, and configure SSH
RUN apt-get update \
    && apt-get install -y iproute2 iputils-ping openssh-server telnet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /run/sshd \
    && chmod 755 /run/sshd \
    && if ! id -u "$SSH_USERNAME" > /dev/null 2>&1; then useradd -ms /bin/bash "$SSH_USERNAME"; fi \
    && chown -R "$SSH_USERNAME":"$SSH_USERNAME" /home/"$SSH_USERNAME" \
    && chmod 755 /home/"$SSH_USERNAME" \
    && mkdir -p /home/"$SSH_USERNAME"/.ssh \
    && chown "$SSH_USERNAME":"$SSH_USERNAME" /home/"$SSH_USERNAME"/.ssh \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    
#RUN adduser -D -g $SSH_USERNAME -h /app -s /bin/sh $SSH_USERNAME
#USER $SSH_USERNAME:$SSH_USERNAME

# Copy the script to configure the user's password and authorized keys
COPY configure-ssh-user.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure-ssh-user.sh

# Expose SSH port
EXPOSE $SSH_PORT 22

# Start SSH server
CMD ["/usr/local/bin/configure-ssh-user.sh"]
