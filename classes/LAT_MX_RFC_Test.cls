/*************************************************************************
*   Company:Zimmic    Developers:Bruno Vuono  Date:29/07/2014    *
**************************************************************************/

@istest
public with sharing class LAT_MX_RFC_Test {

    static testMethod void unitTest() {
        LAT_RFC__c tmpRFC = getRFC();
        User usuario = getMXGerenteAdm();
        if(usuario!=null){
            system.runAs(usuario){     
                tmpRFC.status__c = 'Eliminado';
                update tmpRFC;
            }
        }
   }
   
   
   static testMethod LAT_RFC__c getRFC() {
        User usuario = getMXGerenteAdm();
            
       
        
        if(usuario!=null){
            system.runAs(usuario){       
               LAT_RFC__c tmpRFC = new LAT_RFC__c();
                tmpRFC.rfc__c = '1234';
                insert tmpRFC;
                return tmpRFC;
            }
        }
        return null;
   }
   
   static testMethod User getMXGerenteAdm() {
          list<UserRole> roles = [SELECT Id, Name FROM UserRole WHERE Name = 'MX - Gerente de Administracion de Ventas' LIMIT 1]; 

       User usuario;
            
        try {
            usuario = [SELECT Id, Name, UserRoleId FROM User WHERE UserRoleId IN: roles AND IsActive = true LIMIT 1];
        } catch(Exception e){ }
        return usuario;
   }

}