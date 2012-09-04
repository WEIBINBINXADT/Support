# --
# Kernel/Language/es_MX_Support.pm - translation file
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: es_MX_Support.pm,v 1.1 2012-09-04 04:17:54 cg Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::es_MX_Support;

use strict;

sub Data {
    my $Self = shift;

    # Template: AdminSupport
    $Self->{Translation}->{'Support Assessment'} = 'Valoraciones de soporte';
    $Self->{Translation}->{'Start support'} = 'Comenzar soporte';
    $Self->{Translation}->{'SQL benchmark'} = 'Comparativa SQL';
    $Self->{Translation}->{'For quick help please submit your system information and create a support ticket at the vendor\'s site.'} =
        'Para ayuda rápida por favor suministre su información y cree un ticket de soporte en el sitio del proveedor';
    $Self->{Translation}->{'For more info please check'} = 'Para mas información por favor visite';
    $Self->{Translation}->{'Admin Support Info'} = 'Información de soporte para administración';
    $Self->{Translation}->{'Admin-Support Overview.'} = 'Resumen de información de soporte para administración.';
    $Self->{Translation}->{'Confidential information'} = 'Información confidencial';
    $Self->{Translation}->{'Vendor Support'} = 'Soporte de proveedor';
    $Self->{Translation}->{'Bugzilla ID'} = 'Identificador Bugzilla';
    $Self->{Translation}->{'If you\'ve already added a Bugzilla report at bugs.otrs.org, please add your Bugzilla ID here.'} =
        'Si ya ha agregado un reporte de error en bugs.otrs.org, por favor agregue su identificador de Bugzilla aqui.';
    $Self->{Translation}->{'Service Subscription'} = 'Servicio de suscripción';
    $Self->{Translation}->{'Please recommend me a Service Subscription to optimize my OTRS'} =
        'Por favor recomiendeme un servicio de suscripción para optimizar mi instalación de OTRS';
    $Self->{Translation}->{'Can\'t create support package, because you work currently with the system user root@localhost and your admin email address is not yet configured. Please define the admin email setting in the SysConfig module and don\'t use the user root@localhost for working with OTRS.'} =
        'No es posible crear un paquete de soporte, debido a que se encuentra actualmente utilizando el usuario de sistema root@localhost, y su cuenta de correo electrónico para administración no se encuentra configurada, por favor defina las configuraciones pertinentes para dicho correo electrónico en el modulo de Configuración del sistema y no utilize el usuario root@localhost para trabajar con OTRS.';
    $Self->{Translation}->{'Please confirm the confidential information to continue.'} = 'Por favor confirme su información confidencial para continuar.';
    $Self->{Translation}->{'Looks fine!'} = 'Se ve bien';
    $Self->{Translation}->{'Ok'} = 'Ok';
    $Self->{Translation}->{'Should not take more than'} = 'No debería tardar mas de ';
    $Self->{Translation}->{'on an average system'} = 'en un sistema promedio';
    $Self->{Translation}->{'Benchmark'} = 'Comparativa';
    $Self->{Translation}->{'Execute a SQL benchmark test on your database to find out how fast your database is (done on dedicated benchmark table).'} =
        'Ejecuta una comparativa SQL para conocer que tan rápida es su base de datos (Se realiza en una tabla dedicada para dicha comparativa).';
    $Self->{Translation}->{'This should not be done on production systems!'} = 'No deberá ser ejecutada en un sistema en producción!';
    $Self->{Translation}->{'Multiplier'} = 'Multiplicador';
    $Self->{Translation}->{'Please select a multiplier and press start button.'} = 'Por favor seleccione un multiplicador y presione el botón de iniciar.';

    # Template: AdminSupportLicenseText

    # SysConfig

    $Self->{Translation}->{'The used sender mail address.'} = 'Dirección de correo para enviar paquetes de soporte.';
    $Self->{Translation}->{'Definition of the Cron checks.'} = 'Definición de las verificaciones para Cron';
    $Self->{Translation}->{'Definition of the OTRS checks.'} = 'Definición de las verificaciones para OTRS';
    $Self->{Translation}->{'Definition of the Operating System checks.'} = 'Definición de las verificaciones para el Sistema Operativo';
    $Self->{Translation}->{'Definition of the database checks for the DB2 database.'} = 'Definición de las verificaciones para la base de datos DB2';
    $Self->{Translation}->{'Definition of the database checks for the MSSQL database.'} = 'Definición de las verificaciones para la base de datos MSSQL';
    $Self->{Translation}->{'Definition of the database checks for the MySQL database.'} = 'Definición de las verificaciones para la base de datos MySQL';
    $Self->{Translation}->{'Definition of the database checks for the Oracle database.'} = 'Definición de las verificaciones para la base de datos Oracle';
    $Self->{Translation}->{'Definition of the database checks for the PostgreSQL database.'} = 'Definición de las verificaciones para la base de datos PostgreSQL';
    $Self->{Translation}->{'Definition of the webserver checks for the Apache webserver.'} = 'Definición de las verificaciones para el servidor web Apache';
    $Self->{Translation}->{'Definition of the webserver checks for the IIS webserver.'} = 'Definición de las verificaciones para el servidor web IIS';
    $Self->{Translation}->{'Frontend module registration for the AdminSystemStatus object in the admin area.'} = 'Registro en el sistema del modulo de soporte.';

    # Database
    $Self->{Translation}->{'Database'} = 'Base de datos';

    # mysql
    $Self->{Translation}->{'No MySQL version found.'} = 'No fue encontrada ninguna versión de MySQL';
    $Self->{Translation}->{'MySQL version'} = 'Versión de MySQL';
    $Self->{Translation}->{'you should use 4.1 or higher.'} = 'debería de usar la versión 4.1 o superior.';
    $Self->{Translation}->{'Unknown MySQL version'} = 'Versión de base de datos MySQL desconocida';
    $Self->{Translation}->{'Database Version.'} = 'Versión de base de datos';
    $Self->{Translation}->{'Check database version.'} = 'Verifica la versión de base de datos';

    $Self->{Translation}->{'Database (utf8)'} = 'Base de datos (utf8)';
    $Self->{Translation}->{'Check database utf8 support.'} = 'Verifica soporte para utf8 en la base de datos.';
    $Self->{Translation}->{'No database version found.'} = 'No fue encontrada versión para la base de datos';
    $Self->{Translation}->{'Your database version supports utf8.'} = 'La versión de base de datos soporta utf8';
    $Self->{Translation}->{'utf8 is not supported'} = 'utf8 no es soportado';

    $Self->{Translation}->{'No character_set_client setting found.'} = 'No fue encontrada la configuración character_set_client';
    $Self->{Translation}->{'Your client connection is'} = 'Tu conexion de cliente es';
    $Self->{Translation}->{"Found character_set_client, but it's set to"} = 'Se encontró character_set_client, pero tiene un valor de';
    $Self->{Translation}->{'needs to be utf8'} = 'necesita ser utf8';
    $Self->{Translation}->{'Client Connection (utf8)'} = 'Conexion de cliente (utf8)';
    $Self->{Translation}->{'Check if the client uses utf8 for the connection.'} = 'Verifica si el cliente utiliza utf8 para la conexión';

    $Self->{Translation}->{'No character_set_database setting found.'} = 'No se ha encontrado la configuración "character_set_database"';
    $Self->{Translation}->{"Character_set_database setting found, but it's set to"} = 'Se ha encontrado la configuración "character_set_database", pero con un valor de';
    $Self->{Translation}->{'needs to be utf8'} = 'necesita ser utf8';
    $Self->{Translation}->{'Your database charset setting is'} = 'La configuración de juego de caracteres para tu base de datos es';
    $Self->{Translation}->{'Database Charset (utf8)'} = 'Juego de caracteres de la base de datos (utf8)';
    $Self->{Translation}->{'Check if the database uses utf8 as charset.'} = 'Verifica si la base de datos utiliza utf8 como juego de caracteres.';

    $Self->{Translation}->{'Invalid charset collation for'} = 'Cotejado de juego de caracteres invalido para';
    $Self->{Translation}->{'Table Collation (utf8)'} = 'Cotejado de tabla (utf8)';
    $Self->{Translation}->{'Check the utf8 table charset collation.'} = 'Verifica el cotejado de juego de caracteres utf8 de las tablas';
    $Self->{Translation}->{'Your charset collation is set to'} = 'El cotejado de juego de caracteres se encuentra colocado a';

    $Self->{Translation}->{'No "max_allowed_packet" configuration found.'} = 'No se ha encontrado la configuración "max_allowed_packet"';
    $Self->{Translation}->{"should be higher than 7 MB (it's"} = 'Debería ser mayor a 7 MB (es';
    $Self->{Translation}->{'Your configuration setting is'} = 'La opción de configuración es';
    $Self->{Translation}->{'Max Package Size'} = 'Tamaño máximo de paquete';
    $Self->{Translation}->{'Check "max_allowed_packet" setting.'} = 'Verifica la configuración "max_allowed_packet"';

    $Self->{Translation}->{'No "query_cache_size" setting found.'} = 'No se ha encontrado la configuración "query_cache_size".';
    $Self->{Translation}->{'The setting "query_cache_size" should be used.'} = 'La configuración "query_cache_size" debe ser usada';
    $Self->{Translation}->{"The setting 'query_cache_size' should be higher than 10 MB (it's"} = 'La configuración "query_cache_size" debe ser mayor a 10 MB (es';
    $Self->{Translation}->{'Query Cache Size'} = 'tamaño del cache para consulta';
    $Self->{Translation}->{'Check "query_cache_size" setting.'} = 'Verifica la configuración "query_cache_size"';

    $Self->{Translation}->{'There is no difference between application server time and database server time.'} = 'No existe diferencia entre el tiempo del servidor y el de la base de datos';
    $Self->{Translation}->{'There is a material difference ('} = 'Existe una diferencia notable (';
    $Self->{Translation}->{' seconds) between application server ('} = ' segundos) entre el servidor de aplicación (';
    $Self->{Translation}->{') and database server ('} = ') y el servidor de base de datos (';
    $Self->{Translation}->{') time.'} = ') tiempo';
    $Self->{Translation}->{'Current Timestamp Check'} = 'Verificación de la marca de tiempo actual';
    $Self->{Translation}->{'Check "System Time" vs "Current Timestamp".'} = 'Verifica las variables de tiempo "System Time" contra "Current Timestamp".';

    $Self->{Translation}->{'unable to check table'} = 'No es posible verificar la tabla';
    $Self->{Translation}->{'tables checked.'} = 'tablas verificadas.';
    $Self->{Translation}->{'Table Check'} = 'Verificación de tabla';
    $Self->{Translation}->{'Check existing framework tables.'} = 'Verifica las tablas existentes para el sistema base';
    $Self->{Translation}->{"Can't open file"} = 'No se puede abrir el archivo';
    $Self->{Translation}->{"Can't find file"} = 'No se puede encontrar el archivo';

    $Self->{Translation}->{'Could not determine database size.'} = 'No se ha podido determinar el tamaño de la base de datos';
    $Self->{Translation}->{'Database size is'} = 'El tamaño de base de datos es';
    $Self->{Translation}->{'Could not determine database name.'} = 'No ha sido posible determinar el nombre de la base de datos.';
    $Self->{Translation}->{'Database Size'} = 'Tamaño de la base de datos';
    $Self->{Translation}->{'Size of the current database.'} = 'Tamaño actual de la base de datos.';

    # webserver
    $Self->{Translation}->{'Webserver'} = 'Servidor web';

    # apache
    $Self->{Translation}->{'You are running'} = 'Se encuentra ejecutando';
    $Self->{Translation}->{'Could not determine Apache version.'} = 'No ha sido posible determinar la versión de Apache';
    $Self->{Translation}->{'Apache Version'} = 'Versión de Apache';
    $Self->{Translation}->{'Display web server version.'} = 'Muestra la versión del servidor web';

    $Self->{Translation}->{'Apache::DBI should be used to get a better performance (pre-establish database connections).'} = 'Apache::DBI debe ser usado para obtener un mejor rendimiento (conexiones pre-establecidas a base de datos)';
    $Self->{Translation}->{'Check if the system uses Apache::DBI.'} = 'Verifica si el sistema utiliza Apache::DBI';

    $Self->{Translation}->{'Apache::Reload or Apache2::Reload should be used as PerlModule and PerlInitHandler to prevent web server restarts when installing and upgrading modules.'} = 'Apache::Reload or Apache2::Reload deben ser usados como PerlModule y PerlInitHandler para prevenir el reinicio del servidor al momento de instalar o actualizar modulos';
    $Self->{Translation}->{'Check if the system uses Apache::Reload/Apache2::Reload.'} = 'Verifica si el sistema utliza Apache::Reload/Apache2::Reload.';

    $Self->{Translation}->{'You use a beta version of mod_perl'} = 'Se encuentra utilizando una version preeliminar de mod_perl';
    $Self->{Translation}->{'you should upgrade to a stable version.'} = 'Debe actualizar a una versión estable';
    $Self->{Translation}->{'You should update mod_perl to'} = 'Debe actualizar mod_perl a';
    $Self->{Translation}->{'You are using FastCGI.'} = 'FastCGI se está utilizando';
    $Self->{Translation}->{'You should use FastCGI or mod_perl to increase your performance.'} = 'Debe usar FastCGI o mod_perl para incrementar el rendimiento.';
    $Self->{Translation}->{'CGI Accelerator'} = 'Acelerador CGI';
    $Self->{Translation}->{'Check for CGI Accelerator.'} = 'Verifica un acelerador CGI';

    # os
    $Self->{Translation}->{'OS'} = 'Sistema operativo';

    $Self->{Translation}->{'Distribution'} = 'Distribución';
    $Self->{Translation}->{'Shows the used distribution.'} = 'Muestra la distribución usada';
    $Self->{Translation}->{'is used.'} = 'esta en uso.';
    $Self->{Translation}->{'Distribution unknown.'} = 'Distribución desconocida';
    $Self->{Translation}->{'Can\'t determine distribution.'} = 'No es posible determinar la distribución';

    $Self->{Translation}->{'Kernel Version'} = 'Versión de Kernel';
    $Self->{Translation}->{'Shows the used Kernel version.'} = 'Muestra la versión del Kernel en uso';
    $Self->{Translation}->{'Can\'t execute uname -a...'} = 'No es posible ejecutar uname -a...';

    $Self->{Translation}->{'PerlCheck'} = 'Verificación Perl';
    $Self->{Translation}->{'Check Perl version.'} = 'Verifica la versión de Perl';
    $Self->{Translation}->{'Your Perl'} = 'La versión de Perl';
    $Self->{Translation}->{'is to old, you should upgrade to Perl 5.8.8 or higher.'} = 'es muy antigüa, debe actualizar a Perl 5.8.8 o superior';
    $Self->{Translation}->{'Unable to parse version string'} = 'No es posible analizar la cadena de versión';

    $Self->{Translation}->{'PerlModulesCheck'} = 'Verificación de los módulos Perl';
    $Self->{Translation}->{'Check Perl Modules installed.'} = 'Verificación módulos Perl instalados.';
    $Self->{Translation}->{'There is an error in your installed perl modules configuration. Please contact your administrator.'} = 'Existe un error en la configuración de los módulos Perl instalados. Por favor contacte a su administrador.';
    $Self->{Translation}->{'All Perl modules needed are currently installed.'} = 'Todos los modulos Perl necesarios se encuentran instalados.';
    $Self->{Translation}->{'Unable to check Perl modules.'} = 'No es posible verificar modulos Perl';

    $Self->{Translation}->{'The Host System has'} = 'El sistema anfitrión tiene';
    $Self->{Translation}->{'MB Memory total'} = 'MB memoria total';
    $Self->{Translation}->{'MB Memory free'} = 'MB memoria libre';
    $Self->{Translation}->{'MB Swap total'} = 'MB swap total';
    $Self->{Translation}->{'MB Swap free'} = 'MB swap libre';
    $Self->{Translation}->{'Memory Swap Check'} = 'Verifica la memoria de intercambio';
    $Self->{Translation}->{'A Memory Check. We try to find out if SwapFree : SwapTotal < 60 % or if more than 200 MB Swap is used.'} = 'Una verificación de memoria. Se trata de encontrar si la memoria de intercamibo libre es menor al 60% del total o si mas de 200 MB de memoria de intercambio estan en uso.';
    $Self->{Translation}->{'No Swap enabled!'} = '!No hay memoria de intercambio habilitada!';

    $Self->{Translation}->{'The Host System has a load'} = 'El sistema anfitrión ha cargado';
    $Self->{Translation}->{'in the last 1 minute'} = 'en el ultimo minuto';
    $Self->{Translation}->{'in the last 5 minutes'} = 'en los últimos 5 minutos';
    $Self->{Translation}->{'in the last 15 minutes'} = 'en los últimos 15 minutos';
    $Self->{Translation}->{'CPU Load'} = 'Carga de la UCP';
    $Self->{Translation}->{'A CPU load check. We try to find out if the system load in the last 15 minutes > 1.'} = 'Verificación de la carga de UCP. Se intenta verificar si el sistema ha cargado en los ultimos 15 minutos mas de 1 vez';
    $Self->{Translation}->{'A CPU load check. We try to find out if the system load in the last 15 minutes > 1.'} = 'Verificación de la carga de UCP. Se intenta verificar si el sistema ha cargado en los ultimos 15 minutos menos de 1 vez';

    $Self->{Translation}->{'Disk is full'} = 'Disco lleno';
    $Self->{Translation}->{'Disk usage'} = 'Uso de disco';
    $Self->{Translation}->{'Check disk usage.'} = 'Verifica uso de disco';

}

1;
