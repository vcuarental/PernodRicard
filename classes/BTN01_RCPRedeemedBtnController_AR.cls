/****************************************************
*Dev: Denis Aranda  Version: 1  Consulting: Valuenet*
*  Descripción: Boton en Recibo que deja al usuario *
*  AR_Vendedor redimir Recibos y cambios los campos *
*  RedemptionNo_AR__c y estado del objeto recibos.  *
****************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

global with sharing class BTN01_RCPRedeemedBtnController_AR {
    
    webService static String Verify(){
        return 'ok';
    }   
    
    webService static String rcpButton(list<id> idsRegister ){
        
        String idContact = UserInfo.getProfileId();
        Profile profileUser = [SELECT id, Name FROM Profile WHERE id =: idContact];
        string profileUserName = profileUser.Name;
        system.debug('token idContact' + idContact );
        
        integer numberOfIdsSelected = idsRegister.size();
        if (numberOfIdsSelected < 1){ 
            return Label.BTN01_00001_AR;
        }

        if(!checkAllowReceiptCreation()){
            return Label.LAT_AR_AP01_RCP_002;
        }
        
        list<RCP_Receipt_ARG__c> recibo = [SELECT Id, Name, RedemptionDateTime_AR__c, RedemptionNo_AR__c, Status_AR__c FROM RCP_Receipt_ARG__c WHERE Id =: idsRegister];
        list<RCP_Receipt_ARG__c> updatefields = new list<RCP_Receipt_ARG__c>();
        
        CS003_ReceiptRedemptionNo_ARG__c csRnum = CS003_ReceiptRedemptionNo_ARG__c.getOrgDefaults();
        system.debug('Token csRnum : ' + csRnum);
        
        integer RedemptionNo;
        if(csRnum.Id==null){
            AggregateResult maximo = [SELECT MAX(RedemptionNo_AR__c) max FROM RCP_Receipt_ARG__c];
            RedemptionNo = integer.valueOf(String.ValueOf(maximo.get('max')).substring(2, 10));
            RedemptionNo++;
        }else{
            RedemptionNo = Integer.ValueOf(csRnum.RedemptionNo__c)+1;
        }
        
        String RedemptionNoString = 'RE';
        for(Integer i=(String.valueOf(RedemptionNo).length()); i<=7;i++){
            RedemptionNoString += '0';
        }
        RedemptionNoString = RedemptionNoString+RedemptionNo;
        
        if(profileUserName == 'LAT_AR2_Vendedor' || profileUserName == 'LAT_SystemAdministrator' || profileUserName == 'LAT_AR2_CredYCob'){
            for(RCP_Receipt_ARG__c rec: recibo){
                if(rec.Status_AR__c == 'Receipt printed Deposit done' || rec.Status_AR__c == 'Receipt printed with Value in Custody'){
                    rec.Status_AR__c = 'Receipt Sent to Treasury';
                    rec.RedemptionNo_AR__c = RedemptionNoString;
                    rec.RedemptionDateTime_AR__c = Datetime.now();
                    rec.LAT_ValidationStatus__c = 'Sin Validar';
                    updatefields.add(rec);
                }else if(rec.Status_AR__c == 'Receipt of Applying Documents'){
                    rec.Status_AR__c = 'Receipt Verified';
                    rec.RedemptionNo_AR__c = RedemptionNoString;
                    rec.RedemptionDateTime_AR__c = Datetime.now();
                    rec.LAT_ValidationStatus__c = 'Sin Validar';
                    updatefields.add(rec);                
                }else{
                    return Label.BTN01_00002_AR;
                }
            }
        }else{
            return Label.BTN01_00003_AR;
        }
        Savepoint sp = Database.setSavepoint();
        try{
            upsert updatefields;
            csRnum.RedemptionNo__c = RedemptionNo;
            upsert csRnum;
        }catch(Exception e){Database.rollback(sp); return 'Error: '+e.getMessage();}
        return Label.BTN01_00004_AR + RedemptionNoString ;
    }

    public static boolean checkAllowReceiptCreation(){
        Boolean tmpAllow = True;
        String[] allow = LAT_GeneralConfigDao.getValueAsStringArray('ALLOW_CREATE_RECEIPT', ' ');
        try{
            if(allow != null && allow.size()>0)tmpAllow = Boolean.valueOf(allow[0]);
        }catch(Exception ex){

        }
        return tmpAllow;
    }


    /*TEST CODE IN BTN01_RCPRedeemedBtnController_Arg_Test CLASS*/
}