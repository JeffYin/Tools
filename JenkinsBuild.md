# Frame build
- Pipline 
- Use Groovy Sandbox
- Script
~~~
node {
   def mvnHome
   stage('Preparation') { // for display purposes
      dir('GlobalConfig') {
       git branch: 'v.2018.04.00', url: 'git@gitswarm.powerschool.com:SRB-Trillium/mavenProjectConfig_GlobalConfig.git'
      }
       dir('frame-common') {
        git branch: 'v.2018.04.00', url: 'git@gitswarm.powerschool.com:SRB-Trillium/eTWebFrame_frame-common.git'
       }
      
      dir('frame-dao') {
        git branch: 'v.2018.04.00', url: 'git@gitswarm.powerschool.com:SRB-Trillium/eTWebFrame_frame-dao.git'
       }
       
       dir('frame-service') {
          git branch: 'v.2018.04.00', url: 'git@gitswarm.powerschool.com:SRB-Trillium/eTWebFrame_frame-service.git'
       }
      
       dir('frame-web') {
         git branch: 'v.2018.04.00', url: 'git@gitswarm.powerschool.com:SRB-Trillium/eTWebFrame_frame-web.git'
       }
      
      dir('frame-war') {
          git branch: 'v.2018.04.00', url: 'git@gitswarm.powerschool.com:SRB-Trillium/eTWebFrame_frame-war.git'
       }
   }

   stage('Build') { // 
    dir('GlobalConfig') {
     // Run the maven build
        sh "mvn clean install -U -Dmaven.test.skip=true -PbuildAllFrameComponent,backupFiles -DreleasedMainModule=frame-common -DbackupAllModules=frame-war"
    }
   }
}
~~~

# Parallelly Deploy TWebOLR
- Execute Python script
- Script
~~~
from distutils.dir_util import copy_tree
from shutil import copy2
import time
from os import path
import fileinput
import zipfile

# Generate the version based on the current time. 
REMOTE_SERVER = "PSBUR-trbld02"
SOURCE_FILE = r"\\HYPER-V-001\Trillium\TRDEV\WebDev\TWEBOLR\release\v.1.72.10-SNAPSHOT\build\twebolr_1.72.10-SNAPSHOT.zip"
TOMCAT_FOLDER = r"\\PSBUR-trbld02\C$\Program Files\Apache Software Foundation\Tomcat 8.5.31"
DOC_BASE = r"C:\workEnv\webapps\twebolr_1.72.10"
CONTEXT_TEMPLATE_English_XML = "twebolr.xml"
CONTEXT_TEMPLATE_French_XML = "twebolrFr.xml"
APP_PACKAGE_NAME_ENGLISH = "twebolr_Q_HALTON_2018"
APP_PACKAGE_NAME_FRENCH = "twebolr_Q_CSP"
text_to_search= r'docBase="c:/workEnv/webapps/twebOLR_1.72.10"'

if (not REMOTE_SERVER.isspace()):
    DEST_FOLDER_PATH_TEMPLATE="\\\\{remoteServer}\\{docBase}".format(remoteServer=REMOTE_SERVER, docBase=DOC_BASE)
    DEST_FOLDER_PATH_TEMPLATE = DEST_FOLDER_PATH_TEMPLATE.replace(":", "$") 
else:
    DEST_FOLDER_PATH_TEMPLATE = DOC_BASE

print("Target folder is: "+DEST_FOLDER_PATH_TEMPLATE)

VERSION_DECRIMINATOR = "##"
time.ctime()
current_time = time.strftime("%Y%m%d%H%M%S"); 
version = "{0}{1}".format(VERSION_DECRIMINATOR, current_time)
#print(version)

#dest_app_name="{app}{ver}".format(app = APP_PACKAGE_NAME, ver=version)
destDir = "{folder}_{moment}".format(folder=DEST_FOLDER_PATH_TEMPLATE, moment=current_time)
#print(destDir)

#Unzip package to the destnation
print("unzipping "+SOURCE_FILE)
zip_ref = zipfile.ZipFile(SOURCE_FILE)
zip_ref.extractall(destDir)
zip_ref.close()

# Backup the original file. 
copy2(SOURCE_FILE, destDir)

#Copy CONTEXT
def copyContext(contextTemplate, appName, version):
    context_dir = path.join(TOMCAT_FOLDER, r"conf\Catalina\localhost")
    source_context_xml_path = path.join(TOMCAT_FOLDER, r"conf\Catalina\localhost\templates", contextTemplate)
    dest_context_xml = "{file}{ver}.xml".format(file=appName, ver=version)
    dest_context_xml_path = path.join(context_dir, dest_context_xml)

    task = "Copying context {} for {}".format(dest_context_xml_path, appName)    
    print("Start "+task)
    copy2(source_context_xml_path, dest_context_xml_path)

    # Modify DocBase in the context. 
    resourceFile=dest_context_xml_path
    
    replacement_text='docBase="{appFolder}_{moment}"'.format(appFolder=DOC_BASE, moment=current_time)
    with open(resourceFile,'r') as file: 
        filedata = file.read()
    filedata = filedata.replace(text_to_search, replacement_text)
    with open(resourceFile, 'w') as file:
        file.write(filedata)
    print("Finished "+task)    

copyContext(CONTEXT_TEMPLATE_English_XML, APP_PACKAGE_NAME_ENGLISH, version)
copyContext(CONTEXT_TEMPLATE_French_XML, APP_PACKAGE_NAME_FRENCH, version)

print("deploy is done" )

~~~

# Parallaly Deploy TA 
- Python Script
- Script
~~~
from distutils.dir_util import copy_tree
from shutil import copy2
import time
from os import path
import fileinput
import zipfile

# Generate the version based on the current time. 
REMOTE_SERVER = "PSBUR-trbld02"
SOURCE_FILE = r"\\HYPER-V-001\Trillium\TRDEV\WebDev\TrilliumAgent\Release\v.2.91.00\build\etif.trillium.agent-2.91.00-SNAPSHOT.zip"
TOMCAT_FOLDER = r"\\PSBUR-trbld02\C$\Program Files\Apache Software Foundation\Tomcat 8.5"
DOC_BASE = r"C:\workEnv\webapps\trilliumAgent_2.91.00"

if (not REMOTE_SERVER.isspace()):
    DEST_FOLDER_PATH_TEMPLATE="\\\\{remoteServer}\\{docBase}".format(remoteServer=REMOTE_SERVER, docBase=DOC_BASE)
    DEST_FOLDER_PATH_TEMPLATE = DEST_FOLDER_PATH_TEMPLATE.replace(":", "$") 
else:
    DEST_FOLDER_PATH_TEMPLATE = DOC_BASE

print("Target folder is: "+DEST_FOLDER_PATH_TEMPLATE)

CONTEXT_TEMPLATE_French_XML = "trilliumAgentFr.xml"
CONTEXT_TEMPLATE_English_XML = "trilliumAgent.xml"

#APP_PACKAGE_NAME = "trilliumAgent"


VERSION_DECRIMINATOR = "##"
time.ctime()
current_time = time.strftime("%Y%m%d%H%M%S"); 
version = "{0}{1}".format(VERSION_DECRIMINATOR, current_time)
#print(version)

#dest_app_name="{app}{ver}".format(app = APP_PACKAGE_NAME, ver=version)
destDir = "{folder}{ver}".format(folder=DEST_FOLDER_PATH_TEMPLATE, ver=version)
#print(destDir)

#Unzip package to the destnation
print("unzipping "+SOURCE_FILE)
zip_ref = zipfile.ZipFile(SOURCE_FILE)
zip_ref.extractall(destDir)
zip_ref.close()

#Copy CONTEXT
def copyContext(contextTemplate, appName, version):
    context_dir = path.join(TOMCAT_FOLDER, r"conf\Catalina\localhost")
    source_context_xml_path = path.join(TOMCAT_FOLDER, r"conf\Catalina\localhost\templates", contextTemplate)
    dest_context_xml = "{file}{ver}.xml".format(file=appName, ver=version)
    dest_context_xml_path = path.join(context_dir, dest_context_xml)

    task = "Copying context {} for {}".format(dest_context_xml_path, appName)    
    print("Start "+task)
    copy2(source_context_xml_path, dest_context_xml_path)

    # Modify DocBase in the context. 
    resourceFile=dest_context_xml_path
    text_to_search= r'docBase="c:/workEnv/webapps/trilliumAgent_2.91.00"'
    replacement_text='docBase="{appFolder}{ver}"'.format(appFolder=DOC_BASE, ver=version)
    with open(resourceFile,'r') as file: 
        filedata = file.read()
    filedata = filedata.replace(text_to_search, replacement_text)
    with open(resourceFile, 'w') as file:
        file.write(filedata)
    print("Finished "+task)    

copyContext(CONTEXT_TEMPLATE_English_XML, "trilliumAgent", version)
copyContext(CONTEXT_TEMPLATE_French_XML, "trilliumAgentFr", version)

print("deploy is done" )
~~~

# Parallally Deploy TWebSchAdmin


