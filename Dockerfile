FROM ubuntu:22.04

# Update softwares
RUN apt update && apt -y upgrade

# Install softwares
RUN apt install -y redis rtl-sdr multimon-ng

# Copy and set file
COPY pager.sh /pager.sh
RUN chmod +x /pager.sh

# Allow entering via /bin/bash
CMD ["/bin/bash", "/pager.sh"]
