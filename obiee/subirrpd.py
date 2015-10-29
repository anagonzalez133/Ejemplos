wl_usuario = os.getenv('WLS_USER')
wl_clave = os.getenv('WLS_PW')
wl_admin = os.getenv('ADM_URL')
host = os.getenv('WLS_HOST')
port = os.getenv('WLS_PORT')
rpdpath = os.getenv('SCRIPTS_PERSONALIZACION') + "/UXXIEC.rpd"
rpdPassword = 'ora10gas'

print("URL de administracion del Weblogic " + wl_admin + " nos conectamos con usuario " + wl_usuario)
print("Host " + host + " y puerto de conexion " + port)
print("Repositorio personalizado " + rpdpath)

# connect('weblogic','claveweblogic','http://h15383.redocu.lan:7011/em')
connect(wl_usuario,wl_clave,wl_admin)

# Be sure we are in the root
cd("..\..")

print(host + ": Connecting to Domain ...")
try:
  domainCustom()
except:
  print(host + ": Already in domainCustom")

print(host + ": Go to biee admin domain")
cd("oracle.biee.admin")



# go to the server configuration
print(host + ": Go to BIDomain.BIInstance.ServerConfiguration MBean")

cd ('oracle.biee.admin:type=BIDomain,group=Service')
biinstances = get('BIInstances')
biinstance = biinstances[0]


# Lock the System
print(host + ": Calling lock ...")
cd("..")
cd("oracle.biee.admin:type=BIDomain,group=Service")
objs = jarray.array([], java.lang.Object)
strs = jarray.array([], java.lang.String)
try:
  invoke("lock", objs, strs)
except:
  print(host + ": System already locked")

cd("..")

# Upload the RPD
cd (biinstance.toString())
print(host + ": Uploading RPD")
biserver = get('ServerConfiguration')
cd('..')
cd(biserver.toString())
ls()
argtypes = jarray.array(['java.lang.String','java.lang.String'],java.lang.String)
argvalues = jarray.array([rpdpath,rpdPassword],java.lang.Object)

invoke('uploadRepository',argvalues,argtypes)

# Commit the system
print(host + ": Commiting Changes")


cd('..')
cd('oracle.biee.admin:type=BIDomain,group=Service')
objs = jarray.array([],java.lang.Object)
strs = jarray.array([],java.lang.String)
invoke('commit',objs,strs)


# Restart the system
print(host + ": Restarting OBIEE processes")

cd("..\..")
cd("oracle.biee.admin")
cd("oracle.biee.admin:type=BIDomain.BIInstance,biInstance=coreapplication,group=Service")

print(host + ": Stopping the BI instance")
params = jarray.array([], java.lang.Object)
signs = jarray.array([], java.lang.String)
invoke("stop", params, signs)

BIServiceStatus = get("ServiceStatus")
print(host + ": BI ServiceStatus " + BIServiceStatus)

print(host + ": Starting the BI instance")
params = jarray.array([], java.lang.Object)
signs = jarray.array([], java.lang.String)
invoke("start", params, signs)

BIServerStatus = get("ServiceStatus")
print(host + ": BI ServerStatus " + BIServerStatus)
