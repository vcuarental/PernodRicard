public class ASI_MFM_KR_PlanNewPRRedirectCtrl {
    private ASI_MFM_Plan__c plan;
    
    public ASI_MFM_KR_PlanNewPRRedirectCtrl(ApexPages.StandardController controller)
    {
        plan = (ASI_MFM_Plan__c)controller.getRecord();
        
        //Added by Kammy at 18 Dec 2015 Start://
        plan = [select id, name,ASI_MFM_Status__c, ASI_MFM_Plan_Name__c,ASI_MFM_Budget_Type__c from ASI_MFM_Plan__c where Id =: plan.id];
        //Added by Kammy at 18 Dec 2015 End.//
    }
    
    public PageReference redirect()
    {
        //check if need PR/ PO
        boolean PRPO_Needed=false;
        for(ASI_MFM_Plan_Line_Item__c planlinelist: [select id,name,ASI_MFM_PRPO_Needed__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: plan.id]){
            if(planlinelist.ASI_MFM_PRPO_Needed__c) PRPO_Needed=true;
        }
        if(!PRPO_Needed){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'No need create PR/PO. Please create payment directly.'));
            return null;
        }
        
        
        if(plan.ASI_MFM_Budget_Type__c=='DISC'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Budget Type is \' DISC \'.  No need create PR/PO. '));
            return null; 
        }
        String url;
        
        /*
        // Get PR Type End
        String PRType='';
        Map<Id,User> userMap 
            = new Map<Id,User>([SELECT Id, Name,
                                ASI_KOR_Commission_Code__c 
                                FROM User 
                                WHERE ASI_KOR_Commission_Code__c!=NULL]); //get all user with cimmission code
        List<ASI_eForm_HR_MDM__c> mdmList 
            = new List<ASI_eForm_HR_MDM__c>([SELECT Id, Name,
                                             ASI_eForm_Employee_Company_Code__c,
                                             ASI_eForm_Employee_Company_Name_MDM__c
                                             FROM ASI_eForm_HR_MDM__c
                                             WHERE recordType.developerName LIKE 'ASI_eForm_KR_HR_MDM']); //get all mdm record
        Map<String,ASI_eForm_HR_MDM__c> mdmMap = new Map<String,ASI_eForm_HR_MDM__c>();
        
        for(ASI_eForm_HR_MDM__c mdm: mdmList)
        {
            mdmMap.put(mdm.Name, mdm);//put mdm list to map
        }//end for
        
        
        //Check Null PRType mdmMap.get(userMap.get(userInfo.getUserId()).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Name_MDM__c
        if(userMap.containsKey(userInfo.getUserId())){
            if(mdmMap.containsKey(userMap.get(userInfo.getUserId()).ASI_KOR_Commission_Code__c)){
                PRType=mdmMap.get(userMap.get(userInfo.getUserId()).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Name_MDM__c;
            }    
        }else{
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'The user is not entitled to create PR.'));
            return null;
        }
        //Get PR Type End
        */
        
        if(plan.ASI_MFM_Status__c!='Approved'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Only Status is \'Approved\' can  make Purchase Request.'));
            return null;
        }else {
            /*
            string FieldId_PRname = '';
            string FieldId_PRType = '';
            List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
            for (ASI_MFM_Field_ID_Mappings__c Setting : Settings) {
                if(Setting.ASI_MFM_Object_Name__c == 'ASI_MFM_Purchase_Request__c')
                {                    
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_PR_Name__c')
                        FieldId_PRname = Setting.ASI_MFM_Field_ID__c;
                    if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Type__c')
                        FieldId_PRType = Setting.ASI_MFM_Field_ID__c;
                    
                }
            }    
            url = '/' + ASI_MFM_Purchase_Request__c.SObjectType.getDescribe().getKeyPrefix() +'/e?nooverride=1';
            // Copy Plan Id to Purchase Request Object(Field: ASI_MFM_Plan__c)
            string field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Purchase_Request__c','ASI_MFM_Plan__c');     
            url += '&CF' + field_id + '_lkid=' + plan.id + '&CF' + field_id + '=' + plan.name + '&' + FieldId_PRname + '=' +  EncodingUtil.urlEncode(plan.ASI_MFM_Plan_Name__c, 'UTF-8') + '&' + FieldId_PRType + '=' +PRType  ;
       		*/
            
            url='/apex/ASI_MFM_KR_SelectPRPrefixPage?scontrolCaching=1&planid='+plan.id;
            
        }

        
        
        
        
        /* 
         *  integer PRnum=[select count() from ASI_MFM_Purchase_Request__c where ASI_MFM_Plan__c=: plan.id];
        
		string Project_Code = [select ASI_MFM_Project_Code__c from asi_mfm_plan__c where id = :plan.id limit 1].ASI_MFM_Project_Code__c;
		string ProjectCodeName = [select ASI_MFM_Project_Code__r.name from asi_mfm_plan__c where id = :plan.id limit 1].ASI_MFM_Project_Code__r.name;
		string field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Purchase_Request__c','ASI_MFM_Project_Code__c');
		url += '&CF' + field_id + '_lkid=' + Project_Code + '&CF' + field_id + '=' + ProjectCodeName;
		*/
        return new PageReference(url);
    }
}