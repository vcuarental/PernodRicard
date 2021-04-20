/**********************************************************************************************************************
*                                 Company: ValueNet
*-----------------------------------------------------------------------------------------------------------------------
*   Clase que funciona con el boton "Go To Link" en el objeto LAT_BR_ClientChannelSegmentation__c
***********************************************************************************************************************/

global with sharing class LAT_BR_BTN03_RedirectToLink {
  
    webService static String getsLink(String IdAccount){
    
        Account acc = [SELECT id, RecordTypeId FROM Account WHERE id =: IdAccount LIMIT 1];
        
        List<LAT_CS002_Links__c> listLinks = [SELECT Id, LAT_OffTradeURL__c, LAT_OnTradeURL__c FROM LAT_CS002_Links__c];
        
        Boolean missingData = false;
        
        if(!listLinks.isEmpty()){
            if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade')){
                if(listLinks[0].LAT_OnTradeURL__c != null){
                    return listLinks[0].LAT_OnTradeURL__c;
                }else{
                    missingData = true;
                }
            }
            if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')){
                if(listLinks[0].LAT_OffTradeURL__c != null){
                    return listLinks[0].LAT_OffTradeURL__c;
                }else{
                    missingData = true;
                }      
            }
            
            if(missingData){
                return 'Error: '  + Label.LAT_BR_BTN02_CCS_001;
            }
        }
           
        return null;
    }
}