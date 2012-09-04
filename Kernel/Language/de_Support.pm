# --
# Kernel/Language/de_Support.pm - translation file
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: de_Support.pm,v 1.2 2012-09-04 04:17:03 cg Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_Support;

use strict;

sub Data {
    my $Self = shift;

    # Template: AdminSupport
    $Self->{Translation}->{'Support Assessment'} = '';
    $Self->{Translation}->{'Start support'} = '';
    $Self->{Translation}->{'SQL benchmark'} = '';
    $Self->{Translation}->{'For quick help please submit your system information and create a support ticket at the vendor\'s site.'} =
        'Para ayuda rapida por favor suministre su información y cree un ticket de soporte en el sitio del proveedor';
    $Self->{Translation}->{'For more info please check'} = '';
    $Self->{Translation}->{'Admin Support Info'} = '';
    $Self->{Translation}->{'Admin-Support Overview.'} = '';
    $Self->{Translation}->{'Confidential information'} = '';
    $Self->{Translation}->{'Vendor Support'} = '';
    $Self->{Translation}->{'Bugzilla ID'} = '';
    $Self->{Translation}->{'If you\'ve already added a Bugzilla report at bugs.otrs.org, please add your Bugzilla ID here.'} =
        'Si ya ha agregado un reporte de error en bugs.otrs.org, por favor agregaue su identificador de Bugzilla aqui.';
    $Self->{Translation}->{'Service Subscription'} = '';
    $Self->{Translation}->{'Please recommend me a Service Subscription to optimize my OTRS'} =
        'Por favor recomiendeme un servicio de suscripción para optimizar mi instalación de OTRS';
    $Self->{Translation}->{'Can\'t create support package, because you work currently with the system user root@localhost and your admin email address is not yet configured. Please define the admin email setting in the SysConfig module and don\'t use the user root@localhost for working with OTRS.'} =
        'No es posible crear un paquete de soporte, debido a que se encuetra actualmente utilizando el usuario de sistema root@localhost, y su cuenta de correo electronico para administracion no se encuentra configurada, por favor defina las configuraciones pertinentes para dicho correo electronico en el modulo de Configuración del sistema y no utilize el usuario root@localhost para trabajar con OTRS.';
    $Self->{Translation}->{'Please confirm the confidential information to continue.'} = '';
    $Self->{Translation}->{'Looks fine!'} = '';
    $Self->{Translation}->{'Ok'} = '';
    $Self->{Translation}->{'Should not take more than'} = '';
    $Self->{Translation}->{'on an average system'} = '';
    $Self->{Translation}->{'Benchmark'} = '';
    $Self->{Translation}->{'Execute a SQL benchmark test on your database to find out how fast your database is (done on dedicated benchmark table).'} =
        'Ejecuta una comparativa SQL para conocer que tan rapida es su base de datos (Se realiza en una tabla dedicada para dicha comparativa).';
    $Self->{Translation}->{'This should not be done on production systems!'} = '';
    $Self->{Translation}->{'Multiplier'} = '';
    $Self->{Translation}->{'Please select a multiplier and press start button.'} = '';

    # Template: AdminSupportLicenseText

    # SysConfig
    $Self->{Translation}->{'The used sender mail address.'} = '';
    $Self->{Translation}->{'Definition of the Cron checks.'} = '';
    $Self->{Translation}->{'Definition of the OTRS checks.'} = '';
    $Self->{Translation}->{'Definition of the Operating System checks.'} = '';
    $Self->{Translation}->{'Definition of the database checks for the DB2 database.'} = '';
    $Self->{Translation}->{'Definition of the database checks for the MSSQL database.'} = '';
    $Self->{Translation}->{'Definition of the database checks for the MySQL database.'} = '';
    $Self->{Translation}->{'Definition of the database checks for the Oracle database.'} = '';
    $Self->{Translation}->{'Definition of the database checks for the PostgreSQL database.'} =
        '';
    $Self->{Translation}->{'Definition of the webserver checks for the Apache webserver.'} =
        '';
    $Self->{Translation}->{'Definition of the webserver checks for the IIS webserver.'} = '';
    $Self->{Translation}->{'Frontend module registration for the AdminSystemStatus object in the admin area.'} =
        '';

    # Database
    $Self->{Translation}->{'Database'} = '';

    # mysql
    $Self->{Translation}->{'No MySQL version found.'} = '';
    $Self->{Translation}->{'MySQL version'} = '';
    $Self->{Translation}->{'you should use 4.1 or higher.'} = '';
    $Self->{Translation}->{'Unknown MySQL version'} = '';
    $Self->{Translation}->{'Database Version.'} = '';
    $Self->{Translation}->{'Check database version.'} = '';

    $Self->{Translation}->{'Database (utf8)'} = '';
    $Self->{Translation}->{'Check database utf8 support.'} = '';
    $Self->{Translation}->{'No database version found.'} = '';
    $Self->{Translation}->{'Your database version supports utf8.'} = '';
    $Self->{Translation}->{'utf8 is not supported'} = '';

    $Self->{Translation}->{'No character_set_client setting found.'} = '';
    $Self->{Translation}->{'Your client connection is'} = '';
    $Self->{Translation}->{"Found character_set_client, but it's set to"} = '';
    $Self->{Translation}->{'needs to be utf8'} = '';
    $Self->{Translation}->{'Client Connection (utf8)'} = '';
    $Self->{Translation}->{'Check if the client uses utf8 for the connection.'} = '';

    $Self->{Translation}->{'No character_set_database setting found.'} = '';
    $Self->{Translation}->{"Character_set_database setting found, but it's set to"} = '';
    $Self->{Translation}->{'needs to be utf8'} = '';
    $Self->{Translation}->{'Your database charset setting is'} = '';
    $Self->{Translation}->{'Database Charset (utf8)'} = '';
    $Self->{Translation}->{'Check if the database uses utf8 as charset.'} = '';

    $Self->{Translation}->{'Invalid charset collation for'} = '';
    $Self->{Translation}->{'Table Collation (utf8)'} = '';
    $Self->{Translation}->{'Check the utf8 table charset collation.'} = '';
    $Self->{Translation}->{'Your charset collation is set to'} = '';

    $Self->{Translation}->{'No "max_allowed_packet" configuration found.'} = '';
    $Self->{Translation}->{"should be higher than 7 MB (it's"} = '';
    $Self->{Translation}->{'Your configuration setting is'} = '';
    $Self->{Translation}->{'Max Package Size'} = '';
    $Self->{Translation}->{'Check "max_allowed_packet" setting.'} = '';

    $Self->{Translation}->{'No "query_cache_size" setting found.'} = '';
    $Self->{Translation}->{'The setting "query_cache_size" should be used.'} = '';
    $Self->{Translation}->{"The setting 'query_cache_size' should be higher than 10 MB (it's"} = '';
    $Self->{Translation}->{'Query Cache Size'} = '';
    $Self->{Translation}->{'Check "query_cache_size" setting.'} = '';

    $Self->{Translation}->{'There is no difference between application server time and database server time.'} = '';
    $Self->{Translation}->{'There is a material difference ('} = '';
    $Self->{Translation}->{' seconds) between application server ('} = '';
    $Self->{Translation}->{') and database server ('} = '';
    $Self->{Translation}->{') time.'} = '';
    $Self->{Translation}->{'Current Timestamp Check'} = '';
    $Self->{Translation}->{'Check "System Time" vs "Current Timestamp".'} = '';

    $Self->{Translation}->{'unable to check table'} = '';
    $Self->{Translation}->{'tables checked.'} = '';
    $Self->{Translation}->{'Table Check'} = '';
    $Self->{Translation}->{'Check existing framework tables.'} = '';
    $Self->{Translation}->{"Can't open file"} = '';
    $Self->{Translation}->{"Can't find file"} = '';

    $Self->{Translation}->{'Could not determine database size.'} = '';
    $Self->{Translation}->{'Database size is'} = '';
    $Self->{Translation}->{'Could not determine database name.'} = '';
    $Self->{Translation}->{'Database Size'} = '';
    $Self->{Translation}->{'Size of the current database.'} = '';

    # webserver
    $Self->{Translation}->{'Webserver'} = '';

    # apache
    $Self->{Translation}->{'You are running'} = '';
    $Self->{Translation}->{'Could not determine Apache version.'} = '';
    $Self->{Translation}->{'Apache Version'} = '';
    $Self->{Translation}->{'Display web server version.'} = '';

    $Self->{Translation}->{'Apache::DBI should be used to get a better performance (pre-establish database connections).'} = '';
    $Self->{Translation}->{'Check if the system uses Apache::DBI.'} = '';

    $Self->{Translation}->{'Apache::Reload or Apache2::Reload should be used as PerlModule and PerlInitHandler to prevent web server restarts when installing and upgrading modules.'} = '';
    $Self->{Translation}->{'Check if the system uses Apache::Reload/Apache2::Reload.'} = '';

    $Self->{Translation}->{'You use a beta version of mod_perl'} = '';
    $Self->{Translation}->{'you should upgrade to a stable version.'} = '';
    $Self->{Translation}->{'You should update mod_perl to'} = '';
    $Self->{Translation}->{'You are using FastCGI.'} = '';
    $Self->{Translation}->{'You should use FastCGI or mod_perl to increase your performance.'} = '';
    $Self->{Translation}->{'CGI Accelerator'} = '';
    $Self->{Translation}->{'Check for CGI Accelerator.'} = '';

    # os
    $Self->{Translation}->{'OS'} = '';

    $Self->{Translation}->{'Distribution'} = '';
    $Self->{Translation}->{'Shows the used distribution.'} = '';
    $Self->{Translation}->{'is used.'} = '';
    $Self->{Translation}->{'Distribution unknown.'} = '';
    $Self->{Translation}->{'Can\'t determine distribution.'} = '';

    $Self->{Translation}->{'Kernel Version'} = '';
    $Self->{Translation}->{'Shows the used Kernel version.'} = '';
    $Self->{Translation}->{'Can\'t execute uname -a...'} = '';

    $Self->{Translation}->{'PerlCheck'} = '';
    $Self->{Translation}->{'Check Perl version.'} = '';
    $Self->{Translation}->{'Your Perl'} = '';
    $Self->{Translation}->{'is to old, you should upgrade to Perl 5.8.8 or higher.'} = '';
    $Self->{Translation}->{'Unable to parse version string'} = '';

    $Self->{Translation}->{'PerlModulesCheck'} = '';
    $Self->{Translation}->{'Check Perl Modules installed.'} = '';
    $Self->{Translation}->{'There is an error in your installed perl modules configuration. Please contact your administrator.'} = '';
    $Self->{Translation}->{'All Perl modules needed are currently installed.'} = '';
    $Self->{Translation}->{'Unable to check Perl modules.'} = '';

    $Self->{Translation}->{'The Host System has'} = '';
    $Self->{Translation}->{'MB Memory total'} = '';
    $Self->{Translation}->{'MB Memory free'} = '';
    $Self->{Translation}->{'MB Swap total'} = '';
    $Self->{Translation}->{'MB Swap free'} = '';
    $Self->{Translation}->{'Memory Swap Check'} = '';
    $Self->{Translation}->{'A Memory Check. We try to find out if SwapFree : SwapTotal < 60 % or if more than 200 MB Swap is used.'} = '';
    $Self->{Translation}->{'No Swap enabled!'} = '';

    $Self->{Translation}->{'The Host System has a load'} = '';
    $Self->{Translation}->{'in the last 1 minute'} = '';
    $Self->{Translation}->{'in the last 5 minutes'} = '';
    $Self->{Translation}->{'in the last 15 minutes'} = '';
    $Self->{Translation}->{'CPU Load'} = '';
    $Self->{Translation}->{'A CPU load check. We try to find out if the system load in the last 15 minutes > 1.'} = '';
    $Self->{Translation}->{'A CPU load check. We try to find out if the system load in the last 15 minutes < 1.'} = '';

    $Self->{Translation}->{'Disk is full'} = '';
    $Self->{Translation}->{'Disk usage'} = '';
    $Self->{Translation}->{'Check disk usage.'} = '';

}

1;
