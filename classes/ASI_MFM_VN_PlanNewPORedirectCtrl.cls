/***************************************************************************************************************************
 * Name:        ASI_MFM_VN_PlanNewPORedirectCtrl
 * Description: Controller for ASI_MFM_VN_PlanNewPORedirectPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-02-13       Calvin Chiu (LAPUTA)    Cloned from ASI_MFM_PH_PlanNewPORedirectPage
 ****************************************************************************************************************************/
public class ASI_MFM_VN_PlanNewPORedirectCtrl
{
	private ASI_MFM_Plan__c plan;
    
    public ASI_MFM_VN_PlanNewPORedirectCtrl(ApexPages.StandardController controller)
    {
        plan = (ASI_MFM_Plan__c)controller.getRecord();
        plan = [Select id , RecordTypeId, ASI_MFM_Plan_Name__c, ASI_MFM_PH_Total_Plan_Amount__c, ASI_MFM_PH_Sub_Brand_Allocation__c  from ASI_MFM_Plan__c where Id=: plan.Id];
    }
    
    public PageReference redirect()
    {
        string FieldId_Plan = '';
        string FieldId_Prefix = '';
        string FieldId_PlanName = '';
        string FieldId_TtlPOAmt = '';
        string FieldId_SbAl = '';
    
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
                    FieldId_PlanName = Setting.ASI_MFM_Field_ID__c;
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_PH_Total_PO_Amount__c')
                    FieldId_TtlPOAmt = Setting.ASI_MFM_Field_ID__c;
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_PH_Sub_Brand_Allocation__c')
                    FieldId_SbAl = Setting.ASI_MFM_Field_ID__c;
            }
            
        }
        
        String url;
        
        if(plan.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan_Read_Only')){
            url = '/' + ASI_MFM_PO__c.SObjectType.getDescribe().getKeyPrefix() + 
                '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO')).subString(0,15) + 
                //'&CF' + FieledId_PlanName +'='+ plan.ASI_MFM_Plan_Name__c +
                //'&CF' + FieldId_TtlPOAmt +'='+ plan.ASI_MFM_PH_Total_Plan_Amount__c +
                //'&CF' + FieldId_SbAl + '=' + plan.ASI_MFM_PH_Sub_Brand_Allocation__c + 
                '&planname=' + EncodingUtil.urlEncode(plan.ASI_MFM_Plan_Name__c, 'UTF-8')+
                '&retURL=%2F' + plan.Id+'&pid=' + plan.id ;
            
            
        } 
        else if(plan.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan_Read_Only')){
            url = '/' + ASI_MFM_PO__c.SObjectType.getDescribe().getKeyPrefix() + 
                '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO')).subString(0,15) + 
                // '&CF' + FieledId_PlanName + plan.ASI_MFM_Plan_Name__c +
                //'&CF' + FieldId_TtlPOAmt +'='+ plan.ASI_MFM_PH_Total_Plan_Amount__c +
                //'&CF' + FieldId_SbAl + '=' + plan.ASI_MFM_PH_Sub_Brand_Allocation__c + 
                '&planname=' + EncodingUtil.urlEncode(plan.ASI_MFM_Plan_Name__c, 'UTF-8')+
                '&retURL=%2F' + plan.Id +'&pid=' + plan.id;
            
        }
        //url = EncodingUtil.urlEncode(url, 'UTF-8');
       
        return new PageReference(url);
     
    }
}