/****************************************************
*Dev: Denis Aranda  Version: 1  Consulting: Valuenet*
* Descripción: Boton en Recibo que deja al usuario  *
* ARG_Tesorería verificar Recibos y cambia el campo *
*             estado del objeto recibos.            *
****************************************************/

global without sharing class BTN07_VerifyButton_AR {
	
	webService static String Verify(){
		return 'ok';
	}	
    
    webService static String rcpVerify(list<id> idsRegister ){
        
        String idContact = UserInfo.getProfileId();
        Profile profileUser = [SELECT id, Name FROM Profile WHERE id =: idContact];
        string profileUserName = profileUser.Name;
        
        integer numberOfIdsSelected = idsRegister.size();
        if (numberOfIdsSelected < 1){ 
            return Label.BTN07_00002_AR;
        }
        
        list<RCP_Receipt_ARG__c> recibo = [SELECT Id, Name, RedemptionDateTime_AR__c, RedemptionNo_AR__c, Status_AR__c, LAT_ValidationStatus__c FROM RCP_Receipt_ARG__c WHERE Id =: idsRegister];
        list<RCP_Receipt_ARG__c> updatefields = new list<RCP_Receipt_ARG__c>();
        for (RCP_Receipt_ARG__c rec: recibo) {
            if(rec.LAT_ValidationStatus__c == 'Error en Validacion' || rec.LAT_ValidationStatus__c == 'Sin Validar') {
                return 'Solo se pueden verificar Recibos que estén Validados, por favor corrija la selección.';
            }
        } 
        if(profileUserName == 'ARG_Tesorería' || profileUserName == 'LAT_AR2_Tesoreria' || profileUserName == 'LAT_SystemAdministrator' || profileUserName == 'Administrador del sistema' || profileUserName == 'Administrador do sistema'){
            for(RCP_Receipt_ARG__c rec: recibo){
                if(rec.Status_AR__c == 'Receipt Sent to Treasury'){
                    rec.Status_AR__c = 'Receipt Verified';
                    updatefields.add(rec);
                }else{
                    return Label.BTN07_00001_AR;
                }
            }
        }else{
            return Label.BTN07_00004_AR;
        }
        try{
            upsert updatefields;
        }catch(Exception e){return 'Error: '+e.getMessage();}
        return Label.BTN07_00003_AR;
    }
    /*TEST CODE IN BTN07_VerifyButton_Arg_Test CLASS*/
}