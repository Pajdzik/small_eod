FROM node:16.5.0-slim@sha256:c4236688f1255d88994f5fb639108f756b107d27a0089f80c361f2b7eaa60d4b

RUN apt update && apt install -y g++ git make python3

WORKDIR /code

EXPOSE 8000

CMD ["bash", "-c", "yarn && yarn start"]
