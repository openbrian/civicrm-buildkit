#!/bin/bash

## install.sh -- Create config files and databases; fill the databases

###############################################################################
## Create virtual-host and databases

amp_install

###############################################################################
## Setup Drupal (config files, database tables)

drupal_singlesite_install

###############################################################################
## Setup CiviCRM (config files, database tables)

CIVI_CORE="${WEB_ROOT}/sites/all/modules/civicrm"
CIVI_SETTINGS="${WEB_ROOT}/sites/default/civicrm.settings.php"
CIVI_FILES="${WEB_ROOT}/sites/default/files/civicrm"
CIVI_TEMPLATEC="${CIVI_FILES}/templates_c"
CIVI_UF="Drupal"

civicrm_install

###############################################################################
## Extra configuration

drush -y updatedb
drush -y en civicrm toolbar locale garland login_destination userprotect

## Setup theme
#above# drush -y en garland
drush -y vset theme_default garland
echo 'update block set region="sidebar_first" where theme="garland" and module="user" and delta="login"' | drush sql-cli
echo 'update block set region="sidebar_first" where theme="garland" and module="system" and delta="navigation"' | drush sql-cli

## Setup welcome page
drush -y scr "$SITE_CONFIG_DIR/node-welcome.php"
drush -y vset site_frontpage "welcome"

## Setup login_destination
#above# drush -y en login_destination
drush -y scr "$SITE_CONFIG_DIR/login-destination.php"

## Setup userprotect
#above# drush -y en userprotect
for perm in "change own e-mail" "change own openid" "change own password" ; do
  drush role-remove-perm "authenticated user" "$perm"
done

## Setup demo user
drush -y en civicrm_webtest
drush -y user-create --password="$DEMO_PASS" --mail="$DEMO_EMAIL" "$DEMO_USER"
drush -y user-add-role civicrm_webtest_user "$DEMO_USER"
