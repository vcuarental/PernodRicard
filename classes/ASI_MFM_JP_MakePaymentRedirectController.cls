public with sharing class ASI_MFM_JP_MakePaymentRedirectController {
    
    private ASI_MFM_PO__c po;
    
    public ASI_MFM_JP_MakePaymentRedirectController(ApexPages.StandardController controller) {
        
        po = (ASI_MFM_PO__c)controller.getRecord();
        po = [Select id , RecordTypeId, ASI_MFM_Currency__c,ASI_MFM_Status__c,ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Supplier_Name__c from ASI_MFM_PO__c where Id=: po.Id];
    }
    
    public PageReference redirect() {
        if(po.ASI_MFM_Status__c=='Complete'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'You can NOT Create Payment. Because PO Status is Complete.'));
            return null;
        }else{
            
            string FieldId_Supplier = '';
            string FieldId_Currency = '';
            
            List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
            for (ASI_MFM_Field_ID_Mappings__c Setting : Settings) {
                if(Setting.ASI_MFM_Object_Name__c == 'ASI_MFM_Payment__c')
                {                    
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Supplier_Name__c')
                        FieldId_Supplier = Setting.ASI_MFM_Field_ID__c;
                    
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Currency__c')
                        FieldId_Currency = Setting.ASI_MFM_Field_ID__c;
                    
                }
            }
           
                
            
            return new PageReference('/' + ASI_MFM_Payment__c.SObjectType.getDescribe().getKeyPrefix() + 
                                     '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment')).subString(0,15) +
                                     '&CF' + FieldId_Supplier + '=' + EncodingUtil.urlEncode(po.ASI_MFM_Supplier_Name__r.Name, 'UTF-8') + '&CF' + FieldId_Supplier + '_lkid=' + po.ASI_MFM_Supplier_Name__c +
                                     '&' + FieldId_Currency + '=' + po.ASI_MFM_Currency__c +
                                     '&retURL=%2F' + po.Id);
            
        }
    }
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        /*
    system.debug('TestURL'+'/' + ASI_MFM_Payment__c.SObjectType.getDescribe().getKeyPrefix() + 
                                 '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment')).subString(0,15) +
                                 '&CF' + FieldId_Supplier + '=' + po.ASI_MFM_Supplier_Name__r.Name + '&CF' + FieldId_Supplier + '_lkid=' + po.ASI_MFM_Supplier_Name__c +
                                 '&' + FieldId_Currency + '=' + po.ASI_MFM_Currency__c +
                                 '&retURL=%2F' + po.Id);
        */
    
    
        /*
        //Test Only 
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
        px_list =[select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c from asi_mfm_role_prefix_relationship__c  where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name];
        system.debug(u+'Test_UserInfo'+px_list);
        //ASI_MFM_Role_Prefix_Relationship__c rpr=[select ASI_MFM_Prefix__c from ASI_MFM_Role_Prefix_Relationship__c where ];
        
        
        
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');  
        ASI_MFM_Payment__c pay=new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_JP_Payment'),ASI_MFM_Supplier_Name__c=po.ASI_MFM_Supplier_Name__c,ASI_MFM_Prefix__c='a9FL000000001Ue', ASI_MFM_Tax_Code__c='aCZL0000000CaWl');
        insert pay;
        return new PageReference('/apex/ASI_MFM_JP_PaymentManageAllPage?scontrolCaching=1&id='+pay.id);
        
            }
    */
}