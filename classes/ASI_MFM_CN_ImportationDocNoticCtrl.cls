public With Sharing class ASI_MFM_CN_ImportationDocNoticCtrl {
    
    Public ASI_MFM_CN_ImportationDocNoticCtrl(){
        
    }
    
    Public PageReference redirect(){
        
        ASI_MFM_Importation_Document__c impdoc = new ASI_MFM_Importation_Document__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document__cASI_MFM_CN_Importation_Document'));
        
        try{
            
            Insert impdoc;
        }catch(dmlException dmle){apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage()));Return Null;}
        
        return new pageReference('/' + impdoc.id + '/e?retURL=%2F' + impdoc.id);
    }
}