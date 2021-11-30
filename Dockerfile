FROM docker.io/library/debian:latest

RUN apt-get -y update && apt update -y && apt -y upgrade
RUN apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev libpq-dev wget supervisor -y

# Install PYTHON
RUN apt-get -y install python3-pip
RUN wget https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tgz
RUN tar -xf Python-3.9.1.tgz
RUN cd Python-3.9.1 && ./configure && make && make altinstall

# Install NODE
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

COPY . .

ARG company_name
ENV REACT_APP_COMPANY_NAME=$company_name

ARG api_uri
ENV REACT_APP_API_URL=$api_uri

ARG logo
ENV REACT_APP_COMPANY_LOGO=$logo

ARG primary_color
ENV REACT_APP_PRIMARY_COLOR=$primary_color

ARG secondary_color
ENV REACT_APP_SECONDARY_COLOR=$secondary_color

ARG thrid_color
ENV REACT_APP_THIRD_COLOR=$thrid_color

RUN cd backend/python-api && python3 -m pip install -r requirements.txt

RUN cd frontend && npm install && npm run build
RUN npm i http-server -g

EXPOSE 4000
EXPOSE 8080

CMD [ "/usr/bin/supervisord" ]





