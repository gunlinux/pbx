
DB_FREEPBX_PASSWORD=123123
AMI_PASSWD=123123

sed -i "s/$amp_conf\['AMPMGRPASS'\] = md5(uniqid());/$amp_conf\['AMPMGRPASS'\] = '${AMI_PASSWD}';/" /usr/src/freepbx/installlib/installcommand.class.php  
sed -i "s/$amp_conf\['AMPMANAGERHOST'\] = 'localhost';/$amp_conf\['AMPMANAGERHOST'\] = '127.0.0.1';/" /usr/src/freepbx/installlib/installcommand.class.php 
#sed -i "s/$amp_conf\['AMPDBPASS'] = md5(uniqid());/$amp_conf\['AMPDBPASS'\] = '${DB_FREEPBX_PASSWD}';/" /usr/src/freepbx/installlib/installcommand.class.php  
#sed -i "s/\['AMPDBUSER'\] . \"'@'\".\$amp_conf\['AMPDBHOST'\].\"' IDENTIFIED BY '\"/['AMPDBUSER'\] . \"'@'%' IDENTIFIED BY '\"/g" /usr/src/freepbx/installlib/installcommand.class.php 
sed -i "s/'AMPMGRPASS'     => array(CONF_TYPE_TEXT, 'amp111'),/'AMPMGRPASS'     => array(CONF_TYPE_TEXT, '${AMI_PASSWD}'),/" /usr/src/freepbx/amp_conf/htdocs/admin/libraries/BMO/Config.class.php
