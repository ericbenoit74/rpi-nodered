# DOCKER-VERSION 1.0.0
FROM resin/rpi-raspbian

# install required packages, in one command
RUN apt-get update  && \
    apt-get install -y  python-dev

ENV PYTHON /usr/bin/python2

# install nodejs for rpi
RUN apt-get install -y wget && \
    wget http://node-arm.herokuapp.com/node_latest_armhf.deb && \
    dpkg -i node_latest_armhf.deb && \
    rm node_latest_armhf.deb && \
    apt-get autoremove -y wget

# install RPI.GPIO python libs
RUN apt-get install -y wget && \
     wget http://downloads.sourceforge.net/project/raspberry-gpio-python/raspbian-jessie/python-rpi.gpio_0.6.1-1~jessie_armhf.deb && \
     dpkg -i python-rpi.gpio_0.6.1-1~jessie_armhf.deb && \
     rm python-rpi.gpio_0.6.1-1~jessie_armhf.deb && \
     apt-get autoremove -y wget

# copy a wiringpi installer in order to use the official repo: git://git.drogon.net/wiringPi
COPY ./install /root
RUN chmod 777 /root/install-wiringpi.sh

# install node-red wiringPi and raspi-io
RUN apt-get install -y build-essential git && \
    npm install -g --unsafe-perm  node-red && \
    /root/install-wiringpi.sh && \
    npm install raspi-io && \
    apt-get autoremove -y build-essential  git

# install nodered nodes
RUN touch /usr/share/doc/python-rpi.gpio
COPY ./source /usr/local/lib/node_modules/node-red/nodes/core/hardware
RUN chmod 777 /usr/local/lib/node_modules/node-red/nodes/core/hardware/nrgpio

WORKDIR /root/bin
RUN ln -s /usr/bin/python2 ~/bin/python
RUN ln -s /usr/bin/python2-config ~/bin/python-config
env PATH ~/bin:$PATH

WORKDIR /root/.node-red
RUN npm install node-red-node-redis && \
    npm install node-red-contrib-googlechart && \
    npm install node-red-node-web-nodes && \
    npm install node-red-contrib-gpio

# run application
EXPOSE 1880
#CMD ["/bin/bash"]
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
