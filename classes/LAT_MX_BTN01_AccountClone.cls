/***********************************************************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                                                                             *
*   Date:19/09/2013     Descripcion: Clona un cliente exceptuando algunos campos que se pasan por un custom setting                                                    *
***********************************************************************************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016 
*
********************************************************************************/
global with sharing class LAT_MX_BTN01_AccountClone {
    
    webService static String AccountClone(String idAccount){
    
        String error;
    
        String userProfileId = UserInfo.getProfileId();
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id =: userProfileId];
        
        system.debug('PROFIEL NAME: ' + userProfile.Name);
        
        if(userProfile.Name == 'LAT_MX_Vendedor' || userProfile.Name == 'LAT_MX2_Vendedor'  
            || userProfile.Name == 'LAT_MX_On Premise' || userProfile.Name == 'LAT_MX2_OnPremise' || userProfile.Name == 'LAT_MX2_Coordinador_CRM'
            || userProfile.Name == 'LAT_MX2_Vendedor_OnPremise' || userProfile.Name == 'LAT_MX_System Administrator' 
            || userProfile.Name == 'LAT_SystemAdministrator' || userProfile.Name == 'System Administrator' 
            || userProfile.Name == 'Administrador de sistema' || userProfile.Name == 'Administrador do sistema'){
        
            try{    
                Account acc = [SELECT Id, Segmentation_Type_on_trade__c, Name, ParentId, RecordTypeId FROM Account WHERE id=:idAccount];
                     
                String accName = acc.Name;
                String accId = acc.id;
                String Perent;
                String PerentName;
                
                map<String, CS002_FIeldsIds__c> mapAPINameFieldIds = new map<String, CS002_FIeldsIds__c>();            
                list<CS002_FIeldsIds__c> csfield = [SELECT Id, FieldId__c, FieldApiName__c FROM CS002_FIeldsIds__c WHERE ObjectApiName__c='Account'];
                for(CS002_FIeldsIds__c fieldId: csfield){
                    mapAPINameFieldIds.put(fieldid.FieldApiName__c, fieldId);
                }
                
                if(acc.ParentId == null){
                    Perent = acc.id;
                    PerentName = acc.Name;
                }else{
                    Perent = acc.ParentId;
                    Account accPAdre = [SELECT Id, Name FROM Account WHERE id =: Perent];
                    PerentName = accPAdre.Name;
                }
                
                String falso = 'false';
              
                String urlReturn = '/' + accId +'/e?clone=1';
                system.debug('Entro');
                system.debug('mapAPINameFieldIds'+ mapAPINameFieldIds);
                system.debug('mapAPINameFieldIds.get(Client_code_AN8__c).FieldId__c' + mapAPINameFieldIds.get('Client_code_AN8__c'));
                system.debug('FieldId__c' + mapAPINameFieldIds.get('Client_code_AN8__c').FieldId__c);  
                urlReturn += '&' + mapAPINameFieldIds.get('Client_code_AN8__c').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('Credit_line__c').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('Reason_for_Inactivation__c').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('Status__c').FieldId__c + '=Novo cadastro';
                if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')){
                    urlReturn += '&' + mapAPINameFieldIds.get('ParentId').FieldId__c + '=' + Perent;
                    urlReturn += '&' + mapAPINameFieldIds.get('ParentName').FieldId__c + '=' + EncodingUtil.urlEncode(PerentName,'UTF-8');
                }
                if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')){
                    urlReturn += '&' + mapAPINameFieldIds.get('ParentId').FieldId__c + '=+';
                    urlReturn += '&' + mapAPINameFieldIds.get('ParentName').FieldId__c + '=+';
                    urlReturn += '&' + mapAPINameFieldIds.get('CNPJ__c').FieldId__c + '=+';
                }
                urlReturn += '&' + mapAPINameFieldIds.get('SaveDuplicatedFiscalID_AR__c').FieldId__c + '=' + falso;
                urlReturn += '&' + mapAPINameFieldIds.get('Reason_for_not_approved__c').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('Rating').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('LAT_MX_APStep__c').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('LAT_MX_MissingDocuments__c').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('Return_JDE_Integration__c').FieldId__c + '=+';
                urlReturn += '&' + mapAPINameFieldIds.get('Contact_Schedule__c').FieldId__c + '=+';
                urlReturn += '&retURL=' + idAccount;
                
                return urlReturn;
                
            } catch(Exception e) {
                if(e.getMessage().contains('List has no rows')){
                    error = 'Error: '  + label.LAT_MX_BTN01_00002;
                    //LAT_MX_BTN01_00002: La 'Configuración personalizada' CS002_FIeldsIds no ha sido cargada.
                } else {
                    error = 'Error: '+e.getMessage();
                }
                return error;
            }
        }else{
            error = 'Error: ' + label.LAT_MX_BTN01_00003;
            //LAT_MX_BTN01_00003: Su perfil no le permite clonar clientes.
            return error;
        }
    }
}