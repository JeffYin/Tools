set tomcat_target_folder=apache-tomcat-8.5.39
set tomcat_source_folder=C:\apache-tomcat-8.5.33
set license_tomcat_folder="\\trdev-005.srb-es.com\c$\Program Files\Apache Software Foundation\Tomcat 8.5"

REM JDBC drivers
copy %tomcat_source_folder%\lib\mssql-jdbc-6.4.0.jre8.jar %tomcat_target_folder%\lib
copy %tomcat_source_folder%\lib\ojdbc8.jar %tomcat_target_folder%\lib
REM other libs
copy %tomcat_source_folder%\lib\p6spy-3.0.0.jar %tomcat_target_folder%\lib
copy %tomcat_source_folder%\lib\security-1.01.00.jar %tomcat_target_folder%\lib
copy %tomcat_source_folder%\lib\spy.properties %tomcat_target_folder%\lib
copy %tomcat_source_folder%\lib\sqlFormaterP6Spy-1.0-SNAPSHOT.jar %tomcat_target_folder%\lib
copy %tomcat_source_folder%\lib\statementLeakFinder-1.00.00-SNAPSHOT.jar %tomcat_target_folder%\lib
set extra_lib_folder= %tomcat_target_folder%\lib\lib
IF NOT EXIST %extra_lib_folder% (
md %extra_lib_folder%
)
copy %tomcat_source_folder%\lib\lib %extra_lib_folder%

REM tomcat-users
copy %tomcat_source_folder%\conf\tomcat-users.xml %tomcat_target_folder%\conf


REM allow remote access
copy %tomcat_source_folder%\webapps\host-manager\META-INF\context.xml %tomcat_target_folder%\webapps\host-manager\META-INF\context.xml

REM Licenses
Set cert_folder=%tomcat_target_folder%\certs
IF NOT EXIST %cert_folder% (
md %cert_folder%
)
copy %license_tomcat_folder%\certs %cert_folder%

