public without sharing class ASI_TnE_KR_ClaimHeaderTriggerClass {
	    /*******************************************************************************
		 * Name: ASI_TnE_KR_ClaimHeaderTriggerClass
		 * Description: Trigger class for T&E KR Manage Claim
		 *
		 * Version History
		 * Date             Developer               Comments
		 * ---------------  --------------------    -----------------------------------------
		 * 2015-10-22		Alan Wong				Created 
		 * ????
		 * 2018-07-25		Introv Admin - 2		Edited
		 * 2018-12-10		Laputa: Hector			Add logic:
		 											1. If T&E request is rejected or recalled, delete the existing A&P claim under the T&E
		 											2. When a user re-submit T&E request, regenerated A&P claim
		 * 2019-05-16       Laputa: Hector          Edit logic:
		 *                                              Only create AnP Header if there are Detail
		*************************************************************************************/ 
    
    //claim form status
    private static String statusDraft = 'Draft';
    private static String statusReject = 'Rejected';
    private static String statusSubmitted = 'Submitted';
    private static String statusApproved = 'Approved';
    private static String statusFinal = 'Final';
    private static String statusCompleted = 'Complete';
    private static String statusPending = 'Pending for A&P Submitted';
    //getting profile name
    private static String admin = 'System Administrator';
    private static Id profileId = userinfo.getProfileId();    
    private static String profileName = [Select Id,Name from Profile where Id=:profileId].Name;    
    //record type id
    private static Id rtIdTnE = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE');
    private static Id rtIdTnEFV = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE_Finance_View');
    private static Id rtIdAnP = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP');
    private static Id rtIdAnPFV = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP_Finance_View');
    private static Id rtIdCash = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash');
    private static Id rtIdCashFV = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash_Finance_View');
    private static Id rtIdDetail = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_KR_Claim_Detail');
        
    public static void beforeInsertMethod(List<ASI_TnE_ClaimHeader__c> triggerNew){
        
        //for checking if normal user try to create TnE/AnP card manually
        for(ASI_TnE_ClaimHeader__c obj : triggerNew)
        {
            //check credit card number is existing or not (by normal user, they cannot input card number manually)
            if(obj.ASI_TnE_KR_Credit_Card_No__c == null && !profileName.contains(admin))
            {
                if(obj.RecordTypeId == rtIdAnP
                || obj.RecordTypeId == rtIdTnE
                || obj.RecordTypeId == rtIdAnPFV
                || obj.RecordTypeId == rtIdTnEFV)
                {
                    if(!Test.isRunningTest())
                        obj.addError('Not allow to create card claim statement');
                }//end if - record type check
            }//end if - credit card check, admin check
        }//end for - header loop
        
        set<String> commissionCodeSet = new Set<String>();
        Map<id,User> mapUser = new Map<id,User>([SELECT id,Name,ASI_KOR_Commission_Code__c FROM User WHERE ASI_KOR_Commission_Code__c!=null]);
        
        for( ASI_TnE_ClaimHeader__c obj : triggerNew){
            
            if(obj.ASI_TnE_KR_Payee__c==null)
                obj.ASI_TnE_KR_Payee__c = obj.ownerID;
            
            if(mapUser.get(obj.ASI_TnE_KR_Payee__c)!=null){
                commissionCodeSet.add(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c);
            }else{
                obj.addError('Payee don\'t have a commission code in user profile, please edit user profile.');
            }
        }
        
        List<ASI_eForm_HR_MDM__c> listMDM = new List<ASI_eForm_HR_MDM__c>([SELECT ID, Name,
                                                                               ASI_eForm_Employee_Branch_Code__c, 
                                                                               ASI_eForm_Employee_Company_Code__c, 
                                                                               ASI_eForm_Employee_Company_Name_MDM__c, 
                                                                               ASI_eForm_Sub_Brand__c 
                                                                               FROM ASI_eForm_HR_MDM__c 
                                                                               WHERE Name IN: commissionCodeSet 
                                                                               AND ASI_eForm_HR_MDM__c.RecordTypeId =: Global_RecordTypeCache.getRtId('ASI_eForm_HR_MDM__cASI_eForm_KR_HR_MDM')]);
        Map<String,ASI_eForm_HR_MDM__c> mapMDM = new Map<String,ASI_eForm_HR_MDM__c>();
        Map<Id,ASI_KOR_Sub_Brand__c> mapSubBrand = new Map<Id,ASI_KOR_Sub_Brand__c>([SELECT id,ASI_KOR_Manufacturer__c FROM ASI_KOR_Sub_Brand__c WHERE ASI_KOR_Manufacturer__c != null]);
        
        for(ASI_eForm_HR_MDM__c MDM : listMDM){
            mapMDM.put(MDM.Name,MDM);
        }

        for(ASI_TnE_ClaimHeader__c obj : triggerNew){
            if(mapUser.get(obj.ASI_TnE_KR_Payee__c)!=null&&mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c!=null){
                if(mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c)!=null
                   &&mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Sub_Brand__c!=null
                   &&mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Branch_Code__c!=null)
                {
                    String comCode = mapSubBrand.get(mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Sub_Brand__c).ASI_KOR_Manufacturer__c;
                    if(comCode.equals('222'))
                    {
                        obj.ASI_TnE_KR_Department__c = mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Branch_Code__c;
                        obj.ASI_TnE_KR_Company__c = comCode+'-PRK';
                    }//end if
                    else if(comCode.equals('286'))
                    {
                        obj.ASI_TnE_KR_Department__c = mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Branch_Code__c;
                        obj.ASI_TnE_KR_Company__c = comCode+'-PRKI';
                    }//end ele if
                }//end if
                else if(mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c)!=null
                   &&mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Branch_Code__c!=null
                   &&mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Code__c!=null){
                       obj.ASI_TnE_KR_Department__c = mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Branch_Code__c;
                       obj.ASI_TnE_KR_Company__c = mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Code__c +'-'+ mapMDM.get(mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Name_MDM__c;
                }//end else if
                else
                {
                    obj.addError('User : ' + mapUser.get(obj.ASI_TnE_KR_Payee__c).Name + '(' + mapUser.get(obj.ASI_TnE_KR_Payee__c).ASI_KOR_Commission_Code__c + ') don\'t have a MDM record or missing branch code/company code.');
                }//end else
            }//end if
        }//end for
    }//end method:beforeInsertMethod
    
    public static void sharingWithApprover(List<ASI_TnE_ClaimHeader__c> triggerNew, Map<Id, ASI_TnE_ClaimHeader__c> triggerOldMap){
        
        List<ASI_TnE_ClaimHeader__Share> sharingObj = new List<ASI_TnE_ClaimHeader__Share>();
        
        for(ASI_TnE_ClaimHeader__c obj  : triggerNew){
            
            if(triggerOldMap.get(obj.Id).ASI_TnE_Status__c == statusDraft 
               && obj.ASI_TnE_Status__c==statusSubmitted)
            {
            
            ASI_TnE_ClaimHeader__Share shareRecord1 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord2 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord3 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord4 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord5 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord6 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord7 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord8 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord9 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord10 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord11 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord12 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord13 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord14 = new ASI_TnE_ClaimHeader__Share();
            ASI_TnE_ClaimHeader__Share shareRecord15 = new ASI_TnE_ClaimHeader__Share();
            
            shareRecord1.ParentId = obj.id;
            shareRecord2.ParentId = obj.id;
            shareRecord3.ParentId = obj.id;
            shareRecord4.ParentId = obj.id;
            shareRecord5.ParentId = obj.id;
            shareRecord6.ParentId = obj.id;
            shareRecord7.ParentId = obj.id;
            shareRecord8.ParentId = obj.id;
            shareRecord9.ParentId = obj.id;
            shareRecord10.ParentId = obj.id;
            shareRecord11.ParentId = obj.id;
            shareRecord12.ParentId = obj.id;
            shareRecord13.ParentId = obj.id;
            shareRecord14.ParentId = obj.id;
            shareRecord15.ParentId = obj.id;
            
            if(obj.ASI_TnE_KR_Additional_Approver_1__c!=null)
                shareRecord1.UserOrGroupId = obj.ASI_TnE_KR_Additional_Approver_1__c;
            if(obj.ASI_TnE_KR_Additional_Approver_2__c!=null)
                shareRecord2.UserOrGroupId = obj.ASI_TnE_KR_Additional_Approver_2__c;
            if(obj.ASI_TnE_KR_Additional_Approver_3__c!=null)
                shareRecord3.UserOrGroupId = obj.ASI_TnE_KR_Additional_Approver_3__c;
            if(obj.ASI_TnE_KR_Additional_Approver_4__c!=null)
                shareRecord4.UserOrGroupId = obj.ASI_TnE_KR_Additional_Approver_4__c;
            if(obj.ASI_TnE_KR_Additional_Approver_5__c!=null)
                shareRecord5.UserOrGroupId = obj.ASI_TnE_KR_Additional_Approver_5__c;
            if(obj.ASI_TnE_KR_Budget_Owner_1__c!=null)
                shareRecord6.UserOrGroupId = obj.ASI_TnE_KR_Budget_Owner_1__c;
            if(obj.ASI_TnE_KR_Budget_Owner_2__c!=null)
                shareRecord7.UserOrGroupId = obj.ASI_TnE_KR_Budget_Owner_2__c;
            if(obj.ASI_TnE_KR_Budget_Owner_3__c!=null)
                shareRecord8.UserOrGroupId = obj.ASI_TnE_KR_Budget_Owner_3__c;
            if(obj.ASI_TnE_KR_Budget_Owner_4__c!=null)
                shareRecord9.UserOrGroupId = obj.ASI_TnE_KR_Budget_Owner_4__c;
            if(obj.ASI_TnE_KR_Budget_Owner_5__c!=null)
                shareRecord10.UserOrGroupId = obj.ASI_TnE_KR_Budget_Owner_5__c;
            if(obj.ASI_TnE_KR_CoApprover_1__c!=null)
                shareRecord11.UserOrGroupId = obj.ASI_TnE_KR_CoApprover_1__c;
            if(obj.ASI_TnE_KR_CoApprover_2__c!=null)
                shareRecord12.UserOrGroupId = obj.ASI_TnE_KR_CoApprover_2__c;
            if(obj.ASI_TnE_KR_CoApprover_3__c!=null)
                shareRecord13.UserOrGroupId = obj.ASI_TnE_KR_CoApprover_3__c;
            if(obj.ASI_TnE_KR_CoApprover_4__c!=null)
                shareRecord14.UserOrGroupId = obj.ASI_TnE_KR_CoApprover_4__c;
            if(obj.ASI_TnE_KR_CoApprover_5__c!=null)
                shareRecord15.UserOrGroupId = obj.ASI_TnE_KR_CoApprover_5__c;
            
            shareRecord1.AccessLevel = 'edit';
            shareRecord2.AccessLevel = 'edit';
            shareRecord3.AccessLevel = 'edit';
            shareRecord4.AccessLevel = 'edit';
            shareRecord5.AccessLevel = 'edit';
            shareRecord6.AccessLevel = 'edit';
            shareRecord7.AccessLevel = 'edit';
            shareRecord8.AccessLevel = 'edit';
            shareRecord9.AccessLevel = 'edit';
            shareRecord10.AccessLevel = 'edit';
            shareRecord11.AccessLevel = 'edit';
            shareRecord12.AccessLevel = 'edit';
            shareRecord13.AccessLevel = 'edit';
            shareRecord14.AccessLevel = 'edit';
            shareRecord15.AccessLevel = 'edit';
            
            shareRecord1.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord2.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord3.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord4.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord5.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord6.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord7.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord8.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord9.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord10.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord11.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord12.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord13.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord14.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            shareRecord15.RowCause = Schema.ASI_TnE_ClaimHeader__Share.RowCause.ASI_TnE_KR_ShareWithApprover__c;
            
            if(shareRecord1.UserOrGroupId!=null)
                sharingObj.add(shareRecord1);
            if(shareRecord2.UserOrGroupId!=null)
                sharingObj.add(shareRecord2);
            if(shareRecord3.UserOrGroupId!=null)
                sharingObj.add(shareRecord3);
            if(shareRecord4.UserOrGroupId!=null)
                sharingObj.add(shareRecord4);
            if(shareRecord5.UserOrGroupId!=null)
                sharingObj.add(shareRecord5);
            if(shareRecord6.UserOrGroupId!=null)
                sharingObj.add(shareRecord6);
            if(shareRecord7.UserOrGroupId!=null)
                sharingObj.add(shareRecord7);
            if(shareRecord8.UserOrGroupId!=null)
                sharingObj.add(shareRecord8);
            if(shareRecord9.UserOrGroupId!=null)
                sharingObj.add(shareRecord9);
            if(shareRecord10.UserOrGroupId!=null)
                sharingObj.add(shareRecord10);
            if(shareRecord11.UserOrGroupId!=null)
                sharingObj.add(shareRecord11);
            if(shareRecord12.UserOrGroupId!=null)
                sharingObj.add(shareRecord12);
            if(shareRecord13.UserOrGroupId!=null)
                sharingObj.add(shareRecord13);
            if(shareRecord14.UserOrGroupId!=null)
                sharingObj.add(shareRecord14);
            if(shareRecord15.UserOrGroupId!=null)
                sharingObj.add(shareRecord15);            
        }
        }
        if(sharingObj.size()>0)
            Database.SaveResult[] jobShareInsertResult = Database.insert(sharingObj,false);
    }//end method:sharingWithApprover
    
    public static void beforeSubmitChecking(List<ASI_TnE_ClaimHeader__c> triggerNew, Map<Id, ASI_TnE_ClaimHeader__c> triggerOldMap)
    {
        string rtTnE = 'ASI_TnE_KR_TnE';
        string rtAnP = 'ASI_TnE_KR_AnP';
        String rtCash = 'ASI_TnE_KR_Cash';
        String rtDetail = 'ASI_TnE_KR_Claim_Detail';
        Set<ID> headerId = new Set<ID>();
        List<ASI_TnE_ClaimDetail__c> allKRDraftDetail = new List<ASI_TnE_ClaimDetail__c>();
        Map<Id,String> checkMissing = new Map<Id,String>();
        
        for(ASI_TnE_ClaimHeader__c header : triggerNew)
        {
            //check if the header is 'Submitted' and storage the header id
            if(triggerOldMap.get(header.Id).ASI_TnE_Status__c == statusDraft 
               && header.ASI_TnE_Status__c == statusSubmitted)
                headerId.add(header.id);
        }
        //if there is any header
        if(headerId.size()>0)
        {
            //get all the detail with header
            allKRDraftDetail = [SELECT id,Name,
                                ASI_TnE_Receipt_Date__c,
                                ASI_TnE_Expense_Category__c,
                                ASI_TnE_Expense_Classification__c,
                                ASI_TnE_Currency__c,
                                ASI_TnE_Receipt_Amount__c,
                                ASI_TnE_Total_Number_Pax__c,
                                ASI_TnE_Dept_in_Charge__c,
                                ASI_TnE_Sales_Year__c,
                                ASI_TnE_Sales_Month__c,
                                ASI_TnE_KR_Sub_Brand__c,
                                ASI_TnE_Supported_Item__c,
                                ASI_TnE_Branch_code_Channel__c,
                                ASI_TnE_Promotion_Code__c,
                                ASI_TnE_KR_Promotion_Code__c,
                                ASI_TnE_KR_Customer__c,
                                ASI_TnE_ClaimHeader__r.RecordType.DeveloperName
                                FROM ASI_TnE_ClaimDetail__c
                                WHERE ASI_TnE_ClaimHeader__c IN: headerId
                                AND RecordType.DeveloperName =: rtDetail
                               ];
            //loop the detail list
            for(ASI_TnE_ClaimDetail__c obj : allKRDraftDetail)
            {
                //check is TnE and those fields are null or not
                if(obj.ASI_TnE_ClaimHeader__r.RecordType.DeveloperName == rtTnE
                   && (obj.ASI_TnE_Expense_Category__c == null
                       || obj.ASI_TnE_Expense_Classification__c == null
                       || obj.ASI_TnE_Total_Number_Pax__c == null))
                    if(!Test.isRunningTest())
                        checkMissing.put(obj.ASI_TnE_ClaimHeader__c,'Pls check if you entered all mandatory Fields:\nExpense Category, Expense Classification, Pax');
                
                //check is AnP and those fields are null or not
                if(obj.ASI_TnE_ClaimHeader__r.RecordType.DeveloperName == rtAnP
                   && ((obj.ASI_TnE_Dept_in_Charge__c == null || obj.ASI_TnE_Dept_in_Charge__c == '')
                       || (obj.ASI_TnE_Sales_Year__c == null || obj.ASI_TnE_Sales_Year__c == '')
                       || (obj.ASI_TnE_Sales_Month__c == null || obj.ASI_TnE_Sales_Month__c == '')
                       || (obj.ASI_TnE_KR_Sub_Brand__c == null)
                       || (obj.ASI_TnE_Supported_Item__c == null || obj.ASI_TnE_Supported_Item__c == '')
                       || (obj.ASI_TnE_Branch_code_Channel__c == null)
                       || (obj.ASI_TnE_KR_Promotion_Code__c == null) //added on 20160113, Leo
                       //|| (obj.ASI_TnE_Promotion_Code__c == null || obj.ASI_TnE_Promotion_Code__c == '')
                       || (obj.ASI_TnE_KR_Customer__c == null)))
                    if(!Test.isRunningTest())
                        checkMissing.put(obj.ASI_TnE_ClaimHeader__c,'Pls check if you entered all mandatory Fields:\nCustomer, Dept in Charge, Sub brand, Branch Code+Channel, Promotion Code, Sales Year, Sales Month, Supported Item');
                
                //check is Cash and those fields are null or not
                if(obj.ASI_TnE_ClaimHeader__r.RecordType.DeveloperName == rtCash
                   && (obj.ASI_TnE_Receipt_Date__c == null
                       || obj.ASI_TnE_Expense_Category__c == null
                       || obj.ASI_TnE_Expense_Classification__c == null
                       || (obj.ASI_TnE_Currency__c == null || obj.ASI_TnE_Currency__c == '')
                       || obj.ASI_TnE_Receipt_Amount__c == null
                       || obj.ASI_TnE_Total_Number_Pax__c == null))
                    if(!Test.isRunningTest())
                        checkMissing.put(obj.ASI_TnE_ClaimHeader__c,'Pls check if you entered all mandatory Fields:\nReceipt Date, Expense Category, Expense Classification, Currency, Receipt Amount, Pax');
            }//end for : detail loop
            
            //loop header, and check there are any null fields
            for(ASI_TnE_ClaimHeader__c header : triggerNew)
            {
                if(checkMissing.containsKey(header.id))
                    header.addError(checkMissing.get(header.id));
            }//end for : header loop
        }//end if : check if there is any submitted header
    }//end method:beforeSubmitChecking
    
    public static void wrongSpent(List<ASI_TnE_ClaimHeader__c> triggerNew, Map<Id,ASI_TnE_ClaimHeader__c> oldMap)
    {
        Set<ID> headerId = new Set<ID>();
        Set<ID> reactionHeader = new Set<ID>();
        List<ASI_TnE_ClaimHeader__c> wrongSpentHeader = new List<ASI_TnE_ClaimHeader__c>();
        List<ASI_TnE_ClaimHeader__c> newHeaderList = new List<ASI_TnE_ClaimHeader__c>();
        List<ASI_TnE_ClaimHeader__c> tneHeaderList = new List<ASI_TnE_ClaimHeader__c>();
        List<ASI_TnE_ClaimHeader__c> updateHeaderList = new List<ASI_TnE_ClaimHeader__c>();
        List<ASI_TnE_ClaimDetail__c> wrongSpentDetail = new List<ASI_TnE_ClaimDetail__c>();
        List<ASI_TnE_ClaimDetail__c> newDetailList = new List<ASI_TnE_ClaimDetail__c>();
        Map<Id,Id> newHeaderMap = new Map<Id,Id>();
        Id ClaimHeaderRecordTypeAnP = rtIdAnP;
        Id claimDetailRecordType = rtIdDetail;
        
        for(ASI_TnE_ClaimHeader__c header : triggerNew)
        {
            //Obsolete: check if the header is 'Pending for A&P Submitted' and store the header id
            //if (oldMap.get(header.Id).ASI_TnE_Status__c != header.ASI_TnE_Status__c && header.ASI_TnE_Status__c == statusPending)
            
            //T&E will be submitted before A&P filled, the A&P will be generated when it is submitted
            if (oldMap.get(header.Id).ASI_TnE_Status__c != header.ASI_TnE_Status__c && header.ASI_TnE_Status__c == statusSubmitted)
                headerId.add(header.id);
            //check if the header is AnP, status 'Submitted', is created by T&E wrong use
            if(oldMap.get(header.Id).ASI_TnE_Status__c != header.ASI_TnE_Status__c
               && header.RecordTypeId == rtIdAnP
               && header.ASI_TnE_KR_LookupTnE__c != null
               && header.ASI_TnE_Status__c == 'Submitted')
                reactionHeader.add(header.ASI_TnE_KR_LookupTnE__c);
        }       
        
        if(headerId.size()>0)
        {
            //get wrong header
            wrongSpentHeader = [SELECT Id,OwnerId,
                                ASI_TnE_KR_Payee__c,
                                ASI_TnE_KR_Credit_Card_No__c,
                                ASI_TnE_Date__c,
                                ASI_TnE_KR_Year__c,
                                ASI_TnE_KR_Month__c,
                                ASI_TnE_KR_GL_Date__c
                                FROM ASI_TnE_ClaimHeader__c 
                                WHERE Id IN: headerId];
            
            //get all the wrong detail with header
            wrongSpentDetail = [SELECT id,
                                ASI_TnE_Receipt_Date__c,
                                ASI_TnE_KR_Receipt_Time__c,
                                ASI_TnE_KR_Business_Name__c,
                                ASI_TnE_KR_Business_Type__c,                  // Added by 2018-05-25 Linus@introv
                                ASI_TnE_KR_Business_Address__c,
                                ASI_TnE_Receipt_Amount__c,
                                ASI_TnE_ClaimHeader__c,
                                ASI_TnE_ClaimHeader__r.ASI_TnE_KR_Payee__c,   // Added by 2018-07-25 Linus@introv
                                ASI_TnE_Details_of_Expense__c,                // Added by 2018-07-25 Linus@introv
                                ASI_TnE_Total_Number_Pax__c,                  // Added by 2018-07-25 Linus@introv
                                ASI_TnE_KR_Where__c,                          // Added by 2018-07-25 Linus@introv
                                ASI_TnE_KR_Customer__c                        // Added by 2018-07-25 Linus@introv
                                FROM ASI_TnE_ClaimDetail__c
                                WHERE ASI_TnE_ClaimHeader__c IN: headerId
                                AND ASI_TnE_Expense_Category__r.ASI_TnE_KR_A_P_Transfer__c = true             // Added by 2017-10-31  Linus@introv
                                AND ASI_TnE_Expense_Classification__r.ASI_TnE_KR_A_P_Transfer__c = true        // Added by 2017-10-31  Linus@introv
                                //AND ASI_TnE_Expense_Category__r.Name_en_US__c like 'Wrong use'
                                //AND ASI_TnE_Expense_Classification__r.Name_en_US__c like 'If A&P is used by T&E card'
                               ];
            
            system.debug('wrongSpentDetail:'+wrongSpentDetail);

            //Update by Hector 2019-05-16: LS-57: Change the logic so that system would only create the header when one or more “wrong spending line” exist.
            //Loop WrongSpentDetail first and get suitable ASI_TnE_ClaimHeader__c first and only create newHeader for those
            Set<Id> claimHeaderIdSet = new Set<Id>();
            for (ASI_TnE_ClaimDetail__c obj : wrongSpentDetail){
                claimHeaderIdSet.add(obj.ASI_TnE_ClaimHeader__c);
            }


            //create new anp header
            for(ASI_TnE_ClaimHeader__c obj : wrongSpentHeader)
            {
                ASI_TnE_ClaimHeader__c tempHeader
                    = new ASI_TnE_ClaimHeader__c
                    (OwnerId = obj.OwnerId,
                     ASI_TnE_KR_Payee__c = obj.ASI_TnE_KR_Payee__c,
                     ASI_TnE_Status__c = 'Draft',
                     ASI_TnE_KR_Credit_Card_No__c = obj.ASI_TnE_KR_Credit_Card_No__c,
                     ASI_TnE_Date__c = obj.ASI_TnE_Date__c,
                     RecordTypeId = ClaimHeaderRecordTypeAnP,
                     ASI_TnE_KR_Year__c = obj.ASI_TnE_KR_Year__c,
                     ASI_TnE_KR_Month__c = obj.ASI_TnE_KR_Month__c,
                     //ASI_TnE_KR_GL_Date__c = obj.ASI_TnE_KR_GL_Date__c,
                     ASI_TnE_KR_LookupTnE__c = obj.Id);
                if (claimHeaderIdSet.contains(obj.Id)){
                    newHeaderList.add(tempHeader);
                }
            }//end for

            //insert new anp header first
            if(newHeaderList.size() >0)
            {
                try
                {
                    insert newHeaderList;
                    for(ASI_TnE_ClaimHeader__c obj: newHeaderList)
                        newHeaderMap.put(obj.ASI_TnE_KR_LookupTnE__c, obj.Id);
                }//end try
                catch(Exception err){}//end catch
            }//end if

            //create wrong use detail for anp header
            for(ASI_TnE_ClaimDetail__c obj : wrongSpentDetail)
            {
                ASI_TnE_ClaimDetail__c tempDetail
                    = new ASI_TnE_ClaimDetail__c
                    (ASI_TnE_ClaimHeader__c = newHeaderMap.get(obj.ASI_TnE_ClaimHeader__c),
                     recordTypeId = claimDetailRecordType,
                     ASI_TnE_Receipt_Date__c = obj.ASI_TnE_Receipt_Date__c,
                     ASI_TnE_KR_Receipt_Time__c = obj.ASI_TnE_KR_Receipt_Time__c,
                     ASI_TnE_KR_Business_Name__c = obj.ASI_TnE_KR_Business_Name__c,
                     ASI_TnE_KR_Business_Type__c = obj.ASI_TnE_KR_Business_Type__c,      // Added by 2018-05-25 Linus@introv
                     ASI_TnE_Currency__c = 'KRW',
                     ASI_TnE_Receipt_Amount__c = obj.ASI_TnE_Receipt_Amount__c,
                     ASI_TnE_FX_Rate__c = 1,
                     ASI_TnE_Approved_Amount__c = 1,
                     ASI_TnE_KR_Business_Address__c = obj.ASI_TnE_KR_Business_Address__c,
                     ASI_TnE_KR_Salesman__c = obj.ASI_TnE_ClaimHeader__r.ASI_TnE_KR_Payee__c,   // Added by 2018-07-25 Linus@introv
                     ASI_TnE_Details_of_Expense__c = obj.ASI_TnE_Details_of_Expense__c,         // Added by 2018-07-25 Linus@introv
                     ASI_TnE_KR_Customer__c = obj.ASI_TnE_KR_Customer__c,                       // Added by 2018-07-25 Linus@introv
                     ASI_TnE_KR_Where__c = obj.ASI_TnE_KR_Where__c,                             // Added by 2018-07-25 Linus@introv
                     ASI_TnE_Total_Number_Pax__c = obj.ASI_TnE_Total_Number_Pax__c              // Added by 2018-07-25 Linus@introv
                    );
                newDetailList.add(tempDetail);
            }//end for

            //insert wrong use detail for anp header
            if(newDetailList.size() >0)
            {
                try
                {
                    insert newDetailList;
                }//end try
                catch(Exception err){}//end catch
            }//end if
        }//end if : check if there is any anp pending for approval header
        
        if(reactionHeader.size() > 0)
        {
            tneHeaderList = [SELECT Name, ASI_TnE_Status__c FROM ASI_TnE_ClaimHeader__c WHERE Id IN: reactionHeader];
            for(ASI_TnE_ClaimHeader__c obj : tneHeaderList)
            {
                if(obj.ASI_TnE_Status__c == statusPending)
                {
                    obj.ASI_TnE_Status__c = 'Draft';
                    updateHeaderList.add(obj);
                }//end if: the T&E is not in pending A&P approve
            }//end for
            if(updateHeaderList.size() >0)
            {
                try
                {
                    update updateHeaderList;
                    for(ASI_TnE_ClaimHeader__c obj : updateHeaderList)
                    {
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setObjectId(obj.id);
                        Approval.ProcessResult result = Approval.process(req);
                    }
                }//end try
                catch(Exception err){}//end catch
            }
        }
    }//end method:wrongSpent
    
    public static void beforeDeleteMethod(List<ASI_TnE_ClaimHeader__c> triggerOld, String field)
    {
        if(trigger.isDelete)
        {
            for(ASI_TnE_ClaimHeader__c obj : triggerOld) // Modified by 2017-09-22  Linus@introv
            {
                if((obj.RecordTypeId == rtIdAnP
                    || obj.RecordTypeId == rtIdTnE
                    || obj.RecordTypeId == rtIdAnPFV
                    || obj.RecordTypeId == rtIdTnEFV)
                   //&& !profileName.contains(admin)
                   )
                {
                    /*if(!Test.isRunningTest())
                        obj.addError('Delete not allowed for TnE or AnP card Claim Requests');*/
                }//end if  
                else if(obj.get(field) == statusApproved || obj.get(field) == statusCompleted 
                         || obj.get(field) == statusFinal || obj.get(field) == statusSubmitted
                         //&& !profileName.contains(admin)
                       )                         
                {
                    if(!Test.isRunningTest())
                        obj.addError('Delete not allowed for Submitted, Approved, Final or Complete Claim Requests');
                }//end else if
            }//end for
        }//end if
    }//end method:beforeDeleteMethod
    
    public static void beforeUpdateMethod(List<ASI_TnE_ClaimHeader__c> triggerNew, Map<Id,ASI_TnE_ClaimHeader__c> oldMap,String field)
    {
        Set<String> headerID = new Set<String>();
        Set<String> AnPheaderID = new Set<String>();
        List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
        for(ASI_TnE_ClaimHeader__c obj : triggerNew)
        {
            if(obj.RecordTypeId == rtIdCash)
               headerID.add(obj.id);
            //added by Leo, 20160112
            else if(obj.RecordTypeId == rtIdAnPFV
                    &&oldMap.get(obj.Id).ASI_TnE_Status__c == statusFinal
                    &&obj.ASI_TnE_Status__c == statusCompleted)
            {
                AnPheaderID.add(obj.id);
            }//end else if
            //added by Leo, 20160112
        }//end for
        if(headerID.size()>0)
        {
            list<Attachment> a =new list<Attachment>([Select name,parentID,Id from Attachment where parentid IN: headerID]); 
            map<id,Attachment> mapAttachment = new Map<id,Attachment>();
            for(Attachment obj : a)
            {
                mapAttachment.put(obj.parentID,obj);
            }//end for: loop attachment list
            
            for(ASI_TnE_ClaimHeader__c Parent : triggerNew){
                if((mapAttachment.get(Parent.id))==null&&Parent.get('ASI_TnE_Status__c')==statusSubmitted){
                        if(!Test.isRunningTest())
                            Parent.addError('Attachment required for approval.');
                }//end if
            }//end for: loop header
        }//end if: there is any cash header
        
        //added by Leo, 20160112
        Map<Id,Decimal> promoMap = new Map<Id,Decimal>();
        if(AnPheaderID.size()>0)
        {
            List<ASI_TnE_ClaimDetail__c> rollUpDetail 
                = new List<ASI_TnE_ClaimDetail__c>([SELECT id, name, 
                                                    ASI_TnE_Receipt_Amount__c,
                                                    ASI_TnE_KR_Promotion_Code__c
                                                    FROM ASI_TnE_ClaimDetail__c
                                                    WHERE (ASI_TnE_ClaimHeader__r.Id IN: AnPheaderID
                                                    OR (ASI_TnE_ClaimHeader__r.recordType.developerName = 'ASI_TnE_KR_AnP_Finance_View'
                                                    AND recordType.developerName = 'ASI_TnE_KR_Claim_Detail'
                                                    AND ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c =: statusCompleted))
                                                    AND ASI_TnE_KR_Promotion_Code__c != null]); //20161102, edited by Leo
            for(ASI_TnE_ClaimDetail__c detail: rollUpDetail)
            {
                if(!promoMap.containsKey(detail.ASI_TnE_KR_Promotion_Code__c))
                {
                    promoMap.put(detail.ASI_TnE_KR_Promotion_Code__c, detail.ASI_TnE_Receipt_Amount__c);
                }//end if
                else
                {
                    Decimal amt = promoMap.get(detail.ASI_TnE_KR_Promotion_Code__c);
                    amt += detail.ASI_TnE_Receipt_Amount__c;
                    promoMap.put(detail.ASI_TnE_KR_Promotion_Code__c, amt);
                }//end else
            }//end for
            
            if(promoMap.size() > 0)
            {
                for(Id planId: promoMap.keySet())
                {
                    ASI_MFM_Plan__c tempP = new ASI_MFM_Plan__c();
                    tempP.Id = planId;
                    tempP.ASI_MFM_KR_AnP_RollupAmount__c = promoMap.get(planId);
                    planList.add(tempP);
                }//end for
            }//end if
            
            if(planList.size() > 0)
            {
                update planList;
            }//end if
        }//end if: there is any anp header
        //added by Leo, 20160112
        
        //getting role name
        String accounting = 'ASI_KR_Accounting_Team';
        String accountingLeader = 'ASI_KR_Accounting_Team_Leader';
        String roleName = [Select Id,UserRole.DeveloperName from User where Id=:userinfo.getUserId()].UserRole.DeveloperName;
        Map<Id,String> oldStatus = new Map<Id,String>();
        ID curUserId = userInfo.getUserId();
        
        if(trigger.isUpdate)
        {
            for(ASI_TnE_ClaimHeader__c obj : triggerNew)
            {       //for field 'Status' update
                if(((oldMap.get(obj.Id).ASI_TnE_Status__c != obj.ASI_TnE_Status__c
                    ||(oldMap.get(obj.Id).ASI_TnE_Status__c == statusSubmitted && obj.ASI_TnE_Status__c == statusSubmitted)))
                   //status that allowed to edit
                   ||obj.ASI_TnE_Status__c ==  statusDraft
                   ||obj.ASI_TnE_Status__c ==  statusReject
                   //only A&P approver can edit in status submitted in A&P card claim
                   ||(obj.RecordTypeId == rtIdAnP
                      && obj.ASI_TnE_Status__c ==  statusSubmitted
                      &&(curUserId == obj.ASI_TnE_KR_Additional_Approver_1__c
                         ||curUserId == obj.ASI_TnE_KR_Additional_Approver_2__c
                         ||curUserId == obj.ASI_TnE_KR_Additional_Approver_3__c
                         ||curUserId == obj.ASI_TnE_KR_Additional_Approver_4__c
                         ||curUserId == obj.ASI_TnE_KR_Additional_Approver_5__c
                         ||curUserId == obj.ASI_TnE_KR_Payee_Approver__c))
                   //accounting can edit in status approved
                   ||((roleName == accounting || roleName == accountingLeader) && obj.ASI_TnE_Status__c ==  statusApproved)
                   //admin can edit in all times
                   || profileName.contains(admin))
                {System.Debug('Hello World!!');}
                else
                {
                    if(!Test.isRunningTest())
                        obj.addError('Edit not allowed');
                        //obj.addError('Edit not allowed for Final or Completed Claim Requests');
                }//end if:checking status and is admin or not
            }//end for:loop list of header
        }//end if:checking is updating or not
    }//end method:beforeUpdateMethod
    
    public static void AfterUpdateMethod(List<ASI_TnE_ClaimHeader__c> triggerNew, Map<Id,ASI_TnE_ClaimHeader__c> oldMap){
    	//Added Hector 2018-12-10 
    	//If T&E request is rejected or recalled, delete the existing A&P claim under the T&E
    	List<ASI_TnE_ClaimHeader__c> AnPClaimToBeDeleted = new List<ASI_TnE_ClaimHeader__c>();
    	Set<Id> TnEClaimIdRecalled = new Set<Id>();  
    	for(ASI_TnE_ClaimHeader__c claimHeader : triggerNew){   
    		//Status update AND Submitted -> Rejected OR Submitted -> Draft AND TnE Record
            if(oldMap.get(claimHeader.Id).ASI_TnE_Status__c == statusSubmitted 
            	&& (claimHeader.ASI_TnE_Status__c == statusReject || claimHeader.ASI_TnE_Status__c == statusDraft)
            	&& (claimHeader.RecordTypeId == rtIdTnE || claimHeader.RecordTypeId == rtIdCash )){
            	TnEClaimIdRecalled.add(claimHeader.Id);
            }
        }
        delete [SELECT Id 
        		FROM ASI_TnE_ClaimHeader__c 
        		WHERE ASI_TnE_KR_LookupTnE__c in :TnEClaimIdRecalled
        		AND ASI_TnE_Status__c != :statusApproved 
        		AND ASI_TnE_Status__c != :statusCompleted
        		AND ASI_TnE_Status__c != :statusFinal 
        		AND ASI_TnE_Status__c != :statusSubmitted];
    }
    
}