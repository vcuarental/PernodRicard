public class ASI_MFM_PH_PlanNewPORedirectCtrl
{
	private ASI_MFM_Plan__c plan;
    
    public ASI_MFM_PH_PlanNewPORedirectCtrl(ApexPages.StandardController controller)
    {
        plan = (ASI_MFM_Plan__c)controller.getRecord();
        plan = [Select id , RecordTypeId, ASI_MFM_Plan_Name__c from ASI_MFM_Plan__c where Id=: plan.Id];
    }
    
    public PageReference redirect()
    {
        string FieldId_Plan = '';
        string FieldId_Prefix = '';
        string FieledId_PlanName = '';
    
        List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
        for (ASI_MFM_Field_ID_Mappings__c Setting : Settings)
        {
            if(Setting.ASI_MFM_Object_Name__c == 'ASI_MFM_PO__c')
            {                    
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Plan__c')
                    FieldId_Plan = Setting.ASI_MFM_Field_ID__c;
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Prefix__c')
                    FieldId_Prefix = Setting.ASI_MFM_Field_ID__c;
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_PO_Name__c' )
                    FieledId_PlanName = Setting.ASI_MFM_Field_ID__c;
            }
            
        }
        
        String url;
        
        if(plan.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DP_Plan_Read_Only')){
            url = '/' + ASI_MFM_PO__c.SObjectType.getDescribe().getKeyPrefix() + 
                '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DP_PO')).subString(0,15) + 
                //'&CF' + FieledId_PlanName +'='+ plan.ASI_MFM_Plan_Name__c +
                '&planname=' + EncodingUtil.urlEncode(plan.ASI_MFM_Plan_Name__c, 'UTF-8')+
                '&retURL=%2F' + plan.Id+'&pid=' + plan.id;
            
            
        } 
        else if(plan.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan_Read_Only')){
            url = '/' + ASI_MFM_PO__c.SObjectType.getDescribe().getKeyPrefix() + 
                '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO')).subString(0,15) + 
               // '&CF' + FieledId_PlanName + plan.ASI_MFM_Plan_Name__c +
                '&planname=' + EncodingUtil.urlEncode(plan.ASI_MFM_Plan_Name__c, 'UTF-8')+
                '&retURL=%2F' + plan.Id +'&pid=' + plan.id;
            
        }
        //url = EncodingUtil.urlEncode(url, 'UTF-8');
       
        return new PageReference(url);
     
    }
}