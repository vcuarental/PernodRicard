public class ASI_MFM_JP_MakePOReceiptController {
    private ASI_MFM_PO__c po;
    public ASI_MFM_JP_MakePOReceiptController(ApexPages.StandardController controller) {
        po = (ASI_MFM_PO__c)controller.getRecord();
    }
    public PageReference redirect() {
        if(po.ASI_MFM_Status__c=='Complete'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'You can only Create New PO Receipt. Because PO Status is Complete.'));
            return null;
        }else{
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Receipt__c');  
            ASI_MFM_PO_Receipt__c por=new ASI_MFM_PO_Receipt__c(recordTypeId=rt_map.get('ASI_MFM_JP_PO_Receipt'),ASI_MFM_PO__c=po.id);
            insert por;
            return new PageReference('/apex/ASI_MFM_JP_POReceiptManageAllPage?scontrolCaching=1&id='+por.id);
            
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        /*string FieldId_PO = '';
        string remarkID='00ND0000005qo0r';
        List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
        for (ASI_MFM_Field_ID_Mappings__c Setting : Settings) {
            if(Setting.ASI_MFM_Object_Name__c == 'ASI_MFM_PO_Receipt__c')
            {
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_PO__c'){
                    FieldId_PO = Setting.ASI_MFM_Field_ID__c;
                }
            }
        }
        
        system.debug(FieldId_PO +'EnterTestFieldId_PO' + po.Id);
        system.debug('Test/' + ASI_MFM_PO_Receipt__c.SObjectType.getDescribe().getKeyPrefix() + '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt')).subString(0,15)+'&CF' + FieldId_PO + '_lkid=' + po.Id);
        //return null;
        //return new PageReference('/' + ASI_MFM_PO_Receipt__c.SObjectType.getDescribe().getKeyPrefix() + '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt')).subString(0,15)+'&CF' + FieldId_PO + '_lkid=' + po.ID+'&CF'+FieldId_PO+'='+po.Name);
        return new PageReference('/' + ASI_MFM_PO_Receipt__c.SObjectType.getDescribe().getKeyPrefix() +
                                 '/e?CF'+FieldId_PO+'_lkid='+po.id+'&RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt')).subString(0,15));
       
        */
        
  
    }
}