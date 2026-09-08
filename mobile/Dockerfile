FROM nginx:mainline-alpine-slim

# Copy the config files
ADD ./conf/ /etc/nginx/
# Clears the static files
RUN rm -rf /usr/share/nginx/html
# Copy the static web content
COPY web.zip /tmp/web.zip
RUN unzip /tmp/web.zip -d /usr/share/nginx/html/ && rm /tmp/web.zip
