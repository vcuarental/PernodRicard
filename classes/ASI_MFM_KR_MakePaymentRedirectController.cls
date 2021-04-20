public with sharing class ASI_MFM_KR_MakePaymentRedirectController {
    
    private ASI_MFM_PO__c po;
    
    public ASI_MFM_KR_MakePaymentRedirectController(ApexPages.StandardController controller) {
        
        po = (ASI_MFM_PO__c)controller.getRecord();
        po=[select id, name,ASI_MFM_Project_Code__r.ASI_MFM_Pre_Payment__c,ASI_MFM_Prefix__c,ASI_MFM_Prefix__r.name,ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Status__c,ASI_MFM_Currency__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Project_Code__r.name,ASI_MFM_Project_Code__c, ASI_MFM_Plan__r.Name, ASI_MFM_Plan__c from ASI_MFM_PO__c where id=:po.id ];
    }
    
    public PageReference redirect() {
         if(po.ASI_MFM_Status__c=='Complete'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'You can NOT Create Payment. Because PO Status is Complete.'));
            return null;
        }else{
            
            string FieldId_Supplier = '';
            string FieldId_Currency = '';
            string FieldId_projectcode = '';
             // Added by 2017-12-14 Linus@introv
            string FieldId_plan = '';
            
            List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
            for (ASI_MFM_Field_ID_Mappings__c Setting : Settings) {
                if(Setting.ASI_MFM_Object_Name__c == 'ASI_MFM_Payment__c')
                {                    
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Supplier_Name__c')
                        FieldId_Supplier = Setting.ASI_MFM_Field_ID__c;                    
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Currency__c')
                        FieldId_Currency = Setting.ASI_MFM_Field_ID__c;
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Project_Code__c')
                        FieldId_projectcode = Setting.ASI_MFM_Field_ID__c;
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Plan__c')
                        FieldId_plan = Setting.ASI_MFM_Field_ID__c;    
                }
            }
            
            List<ASI_MFM_Prefix__c> px_id=new List<ASI_MFM_Prefix__c>();
            if(po.ASI_MFM_Prefix__r.name!=null) px_id=[select id from ASI_MFM_Prefix__c where ASI_MFM_Inactive__c = false and ASI_MFM_country_name__c='KR' and ASI_MFM_Module__c='Payment' and name=: po.ASI_MFM_Prefix__r.name limit 1 ];
            
            
            
            string url='';
            url='/' + ASI_MFM_Payment__c.SObjectType.getDescribe().getKeyPrefix() + 
                                     '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment')).subString(0,15) +
                                     '&CF' + FieldId_Supplier + '=' + EncodingUtil.urlEncode(po.ASI_MFM_Supplier_Name__r.Name, 'UTF-8') + '&CF' + FieldId_Supplier + '_lkid=' + po.ASI_MFM_Supplier_Name__c +
                                     '&CF' + FieldId_projectcode + '=' + po.ASI_MFM_Project_Code__r.name + '&CF' + FieldId_projectcode + '_lkid=' + po.ASI_MFM_Project_Code__c +
                                     '&CF' + FieldId_plan + '=' + po.ASI_MFM_Plan__r.Name + '&CF' + FieldId_plan + '_lkid=' + po.ASI_MFM_Plan__c +  // Added by 2017-12-14 Linus@introv
                                     '&' + FieldId_Currency + '=' + po.ASI_MFM_Currency__c +
                                     '&retURL=%2F' + po.Id;
            
            if(px_id.size()>0) url+='&prefixid='+px_id[0].id;
            
            return new PageReference(url);
            
        }
    }
        
    
}