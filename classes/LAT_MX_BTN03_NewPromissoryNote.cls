/*************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                               *                                                                                      *
*   Date:25/09/2013     Descripcion: Valida que el cliente sea de Tipo = Pagador y Canal = Mayorista. Si cumple con la   *
*                                    condicion redirecciona a la pagina de creacion.                                     *
**************************************************************************************************************************/

global with sharing class LAT_MX_BTN03_NewPromissoryNote {
   
    webService static String CreateNewPromissoryNote(String idAccount){
        try{                
            Account acc = [SELECT Id, Type, Name, Channel__c FROM Account WHERE Id =: idAccount];
            
            if (!(acc.Type == 'Payer' && acc.Channel__c == 'WS')){       
                return label.LAT_MX_BTN03_00001;
                //LAT_MX_BTN03_00001: Error: Canal de cliente no necesita Pagaré
            }
            
            String rtId = Global_RecordTypeCache.getRtId('LAT_MX_PMN_PromissoryNote__c' + 'LAT_MX_PMN_Standard');
            
            String idCampo =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='LAT_MX_Executor__c' AND ObjectApiName__c='LAT_MX_PMN_PromissoryNote__c'].FieldId__c;
            
            String prefixObj = LAT_MX_PMN_PromissoryNote__c.SObjectType.getDescribe().getKeyPrefix();    
            String accName = acc.Name;
            String accId = acc.Id;
                    
            String urlReturn = prefixObj + '/e?';
            urlReturn += '&retURL=%2F' + idAccount;
            urlReturn += '&RecordType=' + rtId;
            urlReturn += '&nooverride=1';
            urlReturn += '&ent=LAT_MX_PMN_PromissoryNote__c';
            urlReturn += '&' + idCampo + '=' + EncodingUtil.urlEncode(acc.Name,'UTF-8');
            urlReturn += '&' + idCampo + '_lkid=' + acc.Id;
            
            return urlReturn;
            
        } catch(Exception e) {
            String error;
            if(e.getMessage().contains('List has no rows')){
                error = 'Error: '  + label.LAT_MX_BTN03_00002;
                //LAT_MX_BTN03_00002: La 'Configuración personalizada' CS002_FIeldsIds no ha sido cargada.
            } else {
                error = 'Error: '+e.getMessage();
            }
            return error;
        }
    
    }
    
}