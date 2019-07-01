#WOO COMMENTS
FROM debian:testing
MAINTAINER Schade <schade@acommitteeoflunatics.net>
RUN apt-get update && apt-get install -y build-essential pkg-config cmake git checkinstall software-properties-common sudo wget
RUN add-apt-repository non-free
RUN add-apt-repository contrib
RUN apt-get update
RUN apt-get install -y libx11-dev libgl1-mesa-dev libpulse-dev libxcomposite-dev libxinerama-dev libv4l-dev libudev-dev libfreetype6-dev libfontconfig-dev qtbase5-dev libqt5x11extras5-dev libx264-dev libxcb-xinerama0-dev libxcb-shm0-dev libjack-jackd2-dev libcurl4-openssl-dev libav-tools libavcodec-dev libavfilter-dev libavdevice-dev libfdk-aac-dev ffmpeg
RUN export uid=1000 gid=1000
RUN mkdir -p /home/obs
RUN echo "obs:x:${uid}:${gid}:OpenBroadcastSoftware,,,:/home/obs:/bin/bash" >> /etc/passwd
RUN echo "obs:x:${uid}:" >> /etc/group
RUN echo "obs ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chmod 0440 /etc/sudoers
RUN chown ${uid}:${gid} -R /home/obs
USER obs
ENV HOME /home/obs
WORKDIR /home/obs
RUN git clone https://github.com/jp9000/obs-studio.git
RUN cd ./obs-studio && mkdir ./build
RUN cd ./obs-studio/ && cmake -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=/usr
RUN cd ./obs-studio/ && make -j4
RUN cd ./obs-studio/ && sudo checkinstall --pkgname=FFmpeg --fstrans=no --backup=no --pkgversion="$(date +%Y%m%d)-git" --deldoc=yes

# VNC Configuration
RUN mkdir "$HOME/.vnc" && chmod go-rwx "$HOME/.vnc" ; 

COPY vncserver        /etc/init.d/vncserver
COPY vncservers.conf  /etc/vncserver/vncservers.conf
COPY startup          /home/obs/.vnc/xstartup

RUN \
    /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd"; echo; \
    sudo chown obs:obs ~/.vnc/xstartup; \
    sudo chmod +x ~/.vnc/xstartup; \
    touch ~/.Xauthority ;

ENTRYPOINT export USER=obs; export DISPLAY=1; vncserver :1 && /bin/bash
