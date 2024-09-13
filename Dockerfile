FROM node:16-slim

RUN runDeps="python2 python3 jq openssl ca-certificates git bsdmainutils build-essential libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb patch make wget nano" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $runDeps \
 && apt-get clean \
 && npm install -g wait-on mrs-developer \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/frontend \
 && chown -R node /opt/frontend

WORKDIR /opt/frontend/
USER node

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cypress", "run"]