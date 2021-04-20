public class ASI_eForm_KR_CCR_TriggerClass {
    
    private final static String REISSUE     = 'Reissue';
    
    public static void routineBeforeUpsert(List<ASI_eForm_Corp_Card_Request__c> triggerNew, Map<Id, ASI_eForm_Corp_Card_Request__c> triggerOldMap) {
        Set<Id> OwnerIdSet = New Set<Id>();
        Set<Id> CorpCardEmployeeMappingIds = new Set<Id>();
        Map<Id,User> UserMap = new Map<Id,User>();
        
        Map<String,ASI_eForm_HR_MDM__c> MDMMap= new Map<String,ASI_eForm_HR_MDM__c> ();
        Map<String,ASI_MFM_Fix_Approval_Route__c>  FixApprovalRouteMap = new Map<String,ASI_MFM_Fix_Approval_Route__c>();  
        Map<String,ASI_TnE_Corp_Card_Employee_Mapping__c> CorpCardEmployeeMap = new Map<String,ASI_TnE_Corp_Card_Employee_Mapping__c>();

        for(ASI_eForm_Corp_Card_Request__c obj : triggerNew){
            String recordTypeName = Global_RecordTypeCache.getRt(obj.RecordTypeId).DeveloperName;
            if (recordTypeName.contains('ASI_eForm_KR_CC_Request_Cancellation')) {
                CorpCardEmployeeMappingIds.add(obj.ASI_eForm_Corp_Card_Employee_Mapping__c);
            }

            if (recordTypeName.contains('ASI_eForm_KR_CC_Request_Suspension')  && obj.ASI_eForm_Card_Holder__c != null) {
                OwnerIdSet.add(obj.ASI_eForm_Card_Holder__c);
            }else if(recordTypeName.contains('ASI_eForm_KR_CC_Request_New') || recordTypeName.contains('ASI_eForm_KR_CC_Request_Reissue') || recordTypeName.contains('ASI_eForm_KR_CC_Request_Change') ){
                OwnerIdSet.add(obj.OwnerId);
            }
			
			// for change of credit limit, put the Period To to the last day of the input month
			if(recordTypeName.contains('ASI_eForm_KR_CC_Request_Change') && obj.ASI_eForm_Period_To__c != null){
				Date referenceDate = obj.ASI_eForm_Period_To__c;
				Integer numberOfDays = Date.daysInMonth(referenceDate.year(), referenceDate.month());
				obj.ASI_eForm_Period_To__c = Date.newInstance(referenceDate.year(), referenceDate.month(), numberOfDays);
			}
        }

        Set<String> UserEmailSet = new Set<String>();
        Set<String> UserSalesTeamSet = new Set<String>();

        Map<String, ASI_TnE_Corp_Card_Employee_Mapping__c> CorpCardEmployeeMappingByIds = new Map<String, ASI_TnE_Corp_Card_Employee_Mapping__c>(
        [
            SELECT
                Id,ASI_TnE_Employee_Name__c,ASI_TnE_Employee_Name__r.username,ASI_TnE_Employee_Name__r.email,ASI_TnE_Card_Number_1__c
            FROM ASI_TnE_Corp_Card_Employee_Mapping__c
            WHERE Id IN :CorpCardEmployeeMappingIds
        ]
        );

        for (ASI_TnE_Corp_Card_Employee_Mapping__c mapping : CorpCardEmployeeMappingByIds.values()) {
            UserEmailSet.add(mapping.ASI_TnE_Employee_Name__r.username);
        }

        System.debug(UserEmailSet);

        for(ASI_TnE_Corp_Card_Employee_Mapping__c CCEMap: [select id,ASI_TnE_Employee_Name__c,ASI_TnE_Card_Number_1__c,ASI_TnE_Card_Number_2__c from ASI_TnE_Corp_Card_Employee_Mapping__c where ASI_TnE_Employee_Name__c in : OwnerIdSet and ASI_TnE_Inactive__c = false]){
            CorpCardEmployeeMap.put(CCEMap.ASI_TnE_Employee_Name__c,CCEMap);
        }



        List<User> UserList= [select Id,Email,username,ASI_MFM_Team__c from User where Id in : OwnerIdSet and ASI_MFM_Team__c!=null ];
        for(User u : UserList){
            UserMap.put(u.Id,u);
            UserEmailSet.add(u.username);
            UserSalesTeamSet.add(u.ASI_MFM_Team__c);
        }
        List<ASI_eForm_HR_MDM__c> ListOfMDM = [select id,ASI_eForm_Employee_Work_Email__c,ASI_eForm_Employee_Job_Title__c,ASI_eForm_Employee_Branch_Code__c
                                               from ASI_eForm_HR_MDM__c
                                               where ASI_eForm_Employee_Work_Email__c in : UserEmailSet and ASI_eForm_Employee_Work_Email__c!=null ];

        for(ASI_eForm_HR_MDM__c mdm :ListOfMDM ){
            MDMMap.put(mdm.ASI_eForm_Employee_Work_Email__c, mdm);
        }
        System.debug(MDMMap);
        List<ASI_MFM_Fix_Approval_Route__c> FARList = new List<ASI_MFM_Fix_Approval_Route__c>([SELECT Id,ASI_MFM_Team__c, ASI_MFM_Corporate_Approver_1__c
                                                                                               FROM ASI_MFM_Fix_Approval_Route__c
                                                                                               WHERE ASI_MFM_Team__c in :UserSalesTeamSet  and RecordType.DeveloperName LIKE 'ASI_MFM_KR_Fix_Approval_Route'
                                                                                               AND ASI_MFM_Module__c LIKE 'eForm' and ASI_MFM_KR_Grand_Category__c ='Corporate Card - New' AND ASI_MFM_Inactive__c = false ]);

        for(ASI_MFM_Fix_Approval_Route__c FixApprovalRoute : FARList){
            FixApprovalRouteMap.put(FixApprovalRoute.ASI_MFM_Team__c,FixApprovalRoute);
        }
            

        //ASI_eForm_Sys_Approver_1__c
        for(ASI_eForm_Corp_Card_Request__c obj : triggerNew){
            String recordTypeName = Global_RecordTypeCache.getRt(obj.RecordTypeId).DeveloperName;
            if (recordTypeName.contains('ASI_eForm_KR_CC_Request_Cancellation')) {
                ASI_TnE_Corp_Card_Employee_Mapping__c mapping = CorpCardEmployeeMappingByIds.get(obj.ASI_eForm_Corp_Card_Employee_Mapping__c);
                obj.ASI_eForm_Corp_Card_No__c = mapping.ASI_TnE_Card_Number_1__c;
                obj.ASI_eForm_Card_Holder__c = mapping.ASI_TnE_Employee_Name__c;
                ASI_eForm_HR_MDM__c mdm = MDMMap.get(mapping.ASI_TnE_Employee_Name__r.username);
                if (mdm != null) {
                    obj.ASI_eForm_Job_Title__c = mdm.ASI_eForm_Employee_Job_Title__c;
                    obj.ASI_eForm_Branch_Code__c = mdm.ASI_eForm_Employee_Branch_Code__c;
                }

            }
            if (recordTypeName.contains('ASI_eForm_KR_CC_Request_Suspension') && obj.ASI_eForm_Card_Holder__c != null) {
                if(UserMap.containsKey(obj.ASI_eForm_Card_Holder__c)  ){
                    if(MDMMap.containsKey(UserMap.get(obj.ASI_eForm_Card_Holder__c).username) ){
                        obj.ASI_eForm_Job_Title__c = MDMMap.get(UserMap.get(obj.ASI_eForm_Card_Holder__c).username).ASI_eForm_Employee_Job_Title__c;
                        obj.ASI_eForm_Branch_Code__c = MDMMap.get(UserMap.get(obj.ASI_eForm_Card_Holder__c).username).ASI_eForm_Employee_Branch_Code__c;
                    }
                    /*
                    if(FixApprovalRouteMap.containsKey(UserMap.get(obj.ASI_eForm_Card_Holder__c).ASI_MFM_Team__c) ){
                        obj.ASI_eForm_Sys_Approver_1__c = FixApprovalRouteMap.get(UserMap.get(obj.ASI_eForm_Card_Holder__c).ASI_MFM_Team__c).ASI_MFM_Corporate_Approver_1__c;
                    }
                    */



                }

                
                
            }else if(recordTypeName.contains('ASI_eForm_KR_CC_Request_New') || recordTypeName.contains('ASI_eForm_KR_CC_Request_Reissue') || recordTypeName.contains('ASI_eForm_KR_CC_Request_Change') ){
                
                if(UserMap.containsKey(obj.OwnerId) ){
                    if(MDMMap.containsKey(UserMap.get(obj.OwnerId).username)){
                        obj.ASI_eForm_Job_Title__c = MDMMap.get(UserMap.get(obj.OwnerId).username).ASI_eForm_Employee_Job_Title__c;
                        obj.ASI_eForm_Branch_Code__c = MDMMap.get(UserMap.get(obj.OwnerId).username).ASI_eForm_Employee_Branch_Code__c;
                    }
                    if(FixApprovalRouteMap.containsKey(UserMap.get(obj.OwnerId).ASI_MFM_Team__c) ){
                        obj.ASI_eForm_Sys_Approver_1__c = FixApprovalRouteMap.get(UserMap.get(obj.OwnerId).ASI_MFM_Team__c).ASI_MFM_Corporate_Approver_1__c; 
                    }
                }
                
                if(CorpCardEmployeeMap.containsKey(obj.OwnerId)){
                    if(CorpCardEmployeeMap.get(obj.OwnerId).ASI_TnE_Card_Number_1__c!=null){
                        obj.ASI_eForm_Corp_Card_No__c = CorpCardEmployeeMap.get(obj.OwnerId).ASI_TnE_Card_Number_1__c;
                        obj.ASI_eForm_Corp_Card_Employee_Mapping__c=CorpCardEmployeeMap.get(obj.OwnerId).Id;
                    }
                }else{
					if(recordTypeName.contains('ASI_eForm_KR_CC_Request_Reissue') || recordTypeName.contains('ASI_eForm_KR_CC_Request_Change')){
						// not allow to save if no credit card
						obj.addError('Cannot find a corp card registered for the selected user.');
					}
				}
                
            }
        }
        
        
    }
    
    
    public static void routineAfterUpdate(list<ASI_eForm_Corp_Card_Request__c> trigger_new, map<id, ASI_eForm_Corp_Card_Request__c> trigger_oldMap) {
        Set<Id> CorpCardEmployeeMapSet = New Set<Id>();
		
		ASI_MFM_Setting__c EmailSetting = [select id,ASI_CRM_KR_CCR_Receiver_CC__c,ASI_CRM_KR_CCR_Receiver_To__c,ASI_CRM_KR_Corporate_Card_Request_Sender__c from  ASI_MFM_Setting__c ][0];
		map<string,Id> map_templateId = new map<string,Id>();
		for(EmailTemplate e : [select id, developername from EmailTemplate where developername in (
			'ASI_eForm_KR_CorpCard_New_Approved2','ASI_eForm_KR_CorpCard_CCL_Approved2','ASI_eForm_KR_CorpCardSuspensionApproved2','ASI_eForm_KR_CCC_Approved'
		)]){
			map_templateId.put(e.developername, e.Id);
		}
		
		// get from address
		string fromAddressId;
		list<OrgWideEmailAddress> fromAddress = [select Id from OrgWideEmailAddress where Address = :EmailSetting.ASI_CRM_KR_Corporate_Card_Request_Sender__c limit 1];
		if(fromAddress.size()>0){
			fromAddressId = fromAddress[0].Id;
		}
		
		string fromUserId = [select Id from user where email = :EmailSetting.ASI_CRM_KR_Corporate_Card_Request_Sender__c limit 1][0].Id;
		
        for(ASI_eForm_Corp_Card_Request__c obj : trigger_new){
            if(trigger_oldMap.get(obj.id).ASI_eForm_Status__c == 'Submitted' && obj.ASI_eForm_Status__c == 'Approved' ){
                
                if(Global_RecordTypeCache.getRt(obj.recordTypeId).developerName.contains('ASI_eForm_KR_CC_Request_Reissue')  ){
                    SendingEmailToContractOwner(obj.Id,map_templateId.get('ASI_eForm_KR_CorpCard_New_Approved2'), EmailSetting, fromAddressId, fromUserId);
                }else if(Global_RecordTypeCache.getRt(obj.recordTypeId).developerName.contains('ASI_eForm_KR_CC_Request_Change')  ){
                    SendingEmailToContractOwner(obj.Id,map_templateId.get('ASI_eForm_KR_CorpCard_CCL_Approved2'), EmailSetting, fromAddressId, fromUserId);
                }else if(Global_RecordTypeCache.getRt(obj.recordTypeId).developerName.contains('ASI_eForm_KR_CC_Request_Suspension')  ){
                    SendingEmailToContractOwner(obj.Id,map_templateId.get('ASI_eForm_KR_CorpCardSuspensionApproved2'), EmailSetting, fromAddressId, fromUserId);
                }else if(Global_RecordTypeCache.getRt(obj.recordTypeId).developerName.contains('ASI_eForm_KR_CC_Request_Cancellation') ){
                    SendingEmailToContractOwner(obj.Id,map_templateId.get('ASI_eForm_KR_CCC_Approved'), EmailSetting, fromAddressId, fromUserId);
                }
                
                
                //For reissue & cancellation, once the request is finally approved, system should update “Inactive” flag in Corp Card Employee Mapping for previous card.
                if(Global_RecordTypeCache.getRt(obj.recordTypeId).developerName.contains('ASI_eForm_KR_CC_Request_Reissue') || 
                   Global_RecordTypeCache.getRt(obj.recordTypeId).developerName.contains('ASI_eForm_KR_CC_Request_Cancellation'))
                {
                    
                    if(obj.ASI_eForm_Corp_Card_Employee_Mapping__c !=null ){
                        CorpCardEmployeeMapSet.add(obj.ASI_eForm_Corp_Card_Employee_Mapping__c);
                    }
                }
            } 
            
        }
        
        
        if(CorpCardEmployeeMapSet.size()>0){
            List<ASI_TnE_Corp_Card_Employee_Mapping__c> MappingList= [select id,ASI_TnE_Inactive__c 
                                                                      from ASI_TnE_Corp_Card_Employee_Mapping__c 
                                                                      where Id in : CorpCardEmployeeMapSet];
            for(ASI_TnE_Corp_Card_Employee_Mapping__c Mappings:MappingList){
                Mappings.ASI_TnE_Inactive__c=true;
            }
            update MappingList;
        }
    }
    
    
    //Sender: jimin.kim@pernod-ricard.com, 
    // Receivers(To): c00068@shinhan.com, waitingho@shinhan.com, 
    //Receiver(Cc): Yoonhee.ha@pernod-ricard.com)
    
    //Sending Email To Contract Owner
    public Static void SendingEmailToContractOwner(String RecordId, id  templateId, ASI_MFM_Setting__c EmailSetting, Id fromAddressId, Id fromUserId){
        try{
            
            //ASI_TH_CRM_Contract__c ContractSelected = [select id,OwnerId from ASI_TH_CRM_Contract__c where id = : ContractId ];
            // User ContractOwner = [Select id, Email from User Where id= :ContractSelected.OwnerId ];
            
            List <String> ToAddresses=   EmailSetting.ASI_CRM_KR_CCR_Receiver_To__c.split(';');
            //ToAddresses.add(ContractOwner.Email);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
			
			// the following code cannot change the From address
            //email.setTargetObjectId(EmailSetting.ASI_CRM_KR_Corporate_Card_Request_Sender__c);
			// use this instead
			if(fromAddressId != null) email.setOrgWideEmailAddressId(fromAddressId);
			email.setTargetObjectId(fromUserId);
			
            email.setToAddresses( ToAddresses ); 
            
            String[] ccAddresses = EmailSetting.ASI_CRM_KR_CCR_Receiver_CC__c.split(';');
            email.setccAddresses(ccAddresses);
            
            email.setWhatId(RecordId);
            email.setSaveAsActivity(false);
            email.setBccSender(false);
            email.setUseSignature(false);
            email.setTemplateId(templateId);
            if(!Test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            
        }catch(dmlException e){
            //ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContracFunctionClass.SendingEmailToContractOwner <br/>  have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyContracFunctionClass','function failed! with contract Id: '+ContractId );
        }
    }
    
    
    
    
}