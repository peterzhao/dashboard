A ruby web application to show a dashboard. A dashboard can be configed to contains multiple grids. 
A grid can be configed to pull a dashboard plugin to display some information. 
At this moment we only have Gocd plugin available, which is used to monitor a Gocd pipeline build status.

### Developement

To have a develpment environment easily, you may use vagrant to start a virtual machine as your devolpment box. 
You need have following tools installed:

Virtual Box
Vagrant
Chef Development Kit (Chef DK)

Then you can check out this git repo to your local file system anad then from there, run the command:

       vagrant up
       # ssh to the new vm
       vagrant ssh
       # on the new vm, run following commands
       cd /vagrant
       # start the web application on you vm
       ruby app.rb

Then on your host machine, you can open a brower to access the application at http://localhost:4567/

