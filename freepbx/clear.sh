for i in `fwconsole ma list |grep Commercial |awk {'print $2'}`; do echo $i; fwconsole ma delete $i ; done;

