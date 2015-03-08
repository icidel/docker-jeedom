docker-jeedom (armhf)
=============

Jeedom in a docker container, **for Raspberry Pi 2 and other ARMv7 CPU with hardware float computation**

JEEDOM is a home automation project that aims to connect his house, electronic products, its automation projects all together.
You can control your home locally or from distance at all times and be alerted of an event. 
JEEDOM is an open source and free project supports Z-Wave, which allows for its own automation solution.

##Build JEEDOM container

Before build JEEDOM container, I advise you to change trivial password in Dockerfile with your own passwords.

To build container, you have to go in the directory with the Dockerfile and run :
``` docker build .```

You can choose a name for docker image with :
``` docker build -t username/name .```

If you only want to test Jeedom and the default password is not a problem for you, you can just... huh, no, you can't do this. (for now).

##Launch JEEDOM container

This container provides SSH (22) , supervisord (9001) and Jeedom (8080)

```docker run -p 22 -p 8080 -p 9001 --restart=always -d icidel/armhf:jeedom```

If you have build your own image, you have to replace icidel/armhf:jeedom by your image name

By default Jeedom interface login and password are admin/admin, you can change them after the first identification. 



