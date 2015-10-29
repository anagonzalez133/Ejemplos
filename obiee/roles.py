wl_usuario = os.getenv('WLS_USER')
wl_clave = os.getenv('WLS_PW')
wl_admin = os.getenv('ADM_URL')
connect(wl_usuario,wl_clave,wl_admin)

def createCustomAppRole(appStripe=None, appRoleName=None, displayName=None, description=None) :
    from oracle.security.jps.mas.mgmt.jmx.util import JpsJmxConstants;
    from javax.management import MBeanException
    from java.util import ArrayList
    import wlstModule
    try :
        wlstModule.domainRuntime()
        on = wlstModule.ObjectName(JpsJmxConstants.MBEAN_JPS_APPLICATION_POLICY_STORE)

        params = [appStripe, appRoleName, displayName, description, None]

        sign = ["java.lang.String", "java.lang.String", "java.lang.String", "java.lang.String", "java.lang.String"]
        wlstModule.mbs.invoke(on, "createApplicationRole", params, sign)
    except MBeanException, e:
        # msg = opss_resourceBundle.getString(WlstResources.MSG_WLST_COMMAND_FAILED)
        msg = "MSG_WLST_COMMAND_FAILED"
        print msg + e.getLocalizedMessage() + "\n"
        #raise e
    except :
        # msg = opss_resourceBundle.getString(WlstResources.MSG_WLST_UNKNOWN_REASON)
        msg = "MSG_WLST_UNKNOWN_REASON"
        print msg
        raise

# function ends


def grantCustomAppRole(appStripe=None, appRoleName=None, principalClass=None, principalName=None, principalType=None) :
    from javax.management.openmbean import CompositeData
    from oracle.security.jps.mas.mgmt.jmx.policy import PortableApplicationRole
    from oracle.security.jps.mas.mgmt.jmx.policy import PortableRoleMember
    from oracle.security.jps.mas.mgmt.jmx.policy.PortablePrincipal import PrincipalType
    from oracle.security.jps.mas.mgmt.jmx.util import JpsJmxConstants
    from javax.management import MBeanException
    from java.util import ArrayList
    import wlstModule

    try :
        wlstModule.domainRuntime()
        on = wlstModule.ObjectName(JpsJmxConstants.MBEAN_JPS_APPLICATION_POLICY_STORE)
        r = PortableApplicationRole(appRoleName, "", "", "", appStripe)

        if principalType == 'CUSTOM':
          princType = PrincipalType.CUSTOM
        elif principalType == 'APP_ROLE':  
          princType = PrincipalType.APP_ROLE
        else:
          print "No hay role"   
          
        pm = PortableRoleMember(principalClass, principalName, princType, appStripe)
        marr = wlstModule.array([pm.toCompositeData(None)], CompositeData)
        params = [appStripe, r.toCompositeData(None), marr]

        sign = ["java.lang.String", "javax.management.openmbean.CompositeData", "[Ljavax.management.openmbean.CompositeData;"]
        wlstModule.mbs.invoke(on, "addMembersToApplicationRole", params, sign)
    except MBeanException, e:
        # msg = opss_resourceBundle.getString(WlstResources.MSG_WLST_COMMAND_FAILED)
        msg = "MSG_WLST_COMMAND_FAILED"
        print msg + e.getLocalizedMessage() + "\n"
        #raise e
    except :
        # msg = opss_resourceBundle.getString(WlstResources.MSG_WLST_UNKNOWN_REASON)
        msg = "MSG_WLST_UNKNOWN_REASON"
        print msg
        raise

# function ends


createCustomAppRole("obi", "UXXIEC_COSTES_ADMINISTRADOR", "UXXIEC_COSTES_ADMINISTRADOR", "Dara acceso a todos los paneles, pestanas e informes existentes, asi como a las funcionalidades de creacion, edicion y publicacion existentes en OBIEE.")
grantCustomAppRole("obi", "BIConsumer", "oracle.security.jps.service.policystore.ApplicationRole", "UXXIEC_COSTES_ADMINISTRADOR","APP_ROLE")
grantCustomAppRole("obi", "UXXIEC_COSTES_ADMINISTRADOR", "weblogic.security.principal.WLSGroupImpl", "UXXIEC_COSTES_ADMINISTRADOR","CUSTOM")
print "Creado Role UXXIEC_COSTES_ADMINISTRADOR"
