public class ASI_TnE_KR_ClaimManageAllCtrl{
    /*******************************************************************************
 * Name: ASI_TnE_KR_ClaimManageAllCtrl
 * Description: Controller class for T&E KR Manage Claim
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------
 * ????Created 
 * 22-05-2017		[Laputa] Kevin 			Updated getClaimDetails() , 
 * 											added getOtherClaimDetails() 
 * 13-12-2018		[Laputa] Hector			Updated lookupFieldToSelectedOptions to Disable Budget Owner field when expense category = Transfer to A&P is selected in ManageTnEClaimPage
*************************************************************************************/ 

    private final static String roleName = [Select Id,UserRole.Name from User where Id=:userinfo.getUserId()].UserRole.Name;
    private final static String accounting = 'KR Accounting Team';
    private final static Id profileId = userinfo.getProfileId();
    private final static String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    private final static String admin = 'System Administrator';
    private final static String ThresholdTolerance = 'ASI_GnH_TnE_Threshold_Tolerance';
    private final static String AnPSupportItem = 'ASI_GnH_AnP_Supported_Item';
    private final static String koreaClaimRetailRt = 'ASI_TnE_KR_Claim_Detail';
    private final static String ThresholdObject = 'ASI_TnE_ClaimDetail__c';
    private final static String mfmPlanRt = 'ASI_MFM_KR_Plan_Read_Only';
    private final static String koreaRecipientRt = 'ASI_GnH_KR_Request_Recipient';
    private final static String koreaRecipientMasterRt = 'ASI_GnH_KR_Recipient_Master';
    private final static String koreaStaffMasterRt = 'ASI_GnH_KR_PR_Staffs_Master';
    private final static List<String> claimHeaderStatus = new List<String>{'Draft','Rejected'};
    private final static List<String> gnhRequestStatus = new List<String>{'Approved'};

    private  static Set<String> GnHRecordType = new Set<String>{'ASI_GnH_KR_Offer_Request_Read_Only','ASI_GnH_KR_Receive_Request_Read_Only'};

    private Id payee,ap1,ap2,ap3,ap4,ap5;
    private List<ASI_TnE_ClaimHeader__c> listHeader;
    public Integer isEditable {get; set;}
    public Boolean isFAUser {get; set;}
    public Boolean isFAVerifyStep {get; set;}
    public Boolean isSalesUser   {get; set;}
    public String branchCode  {get; set;}
    public Id detailRecordType {get; set;}//cash claim
    public ASI_TnE_ClaimHeader__c claimHeader {get; set;}
    public List<Decimal> TnEThreshold {get; set;}

    public Map<String,List<String>> gnhRequestMap {get; set;}
    public Map<String,List<ASI_GnH_Actual_Recipient__c>> currentRecipientMap {get;set;}
    public Map<String,Set<ASI_GnH_Request_Recipient__c>> recipientbyRequestMap {get; set;}
    public Map<String, ASI_JP_TnE_Expense_Classification__c> checkedClassificationMap {get; set;}
    public Map<String, String> promotionCodeMap {get; set;}
    public String supportItemForBrand {get; set;}

    public String gnhRequestMapJson  {get {return toJsonString(gnhRequestMap);}}//parse to VF page with Json encoded   
    public String TnEThresholdJson  {get {return toJsonString(TnEThreshold);}}//parse to VF page with Json encoded  
    public String currentRecipientMapJson  {get {return toJsonString(currentRecipientMap);}}//parse to VF page with Json encoded 
    public String recipientbyRequestMapJson  {get {return toJsonString(recipientbyRequestMap);}}//parse to VF page with Json encoded
    public String checkedClassificationMapJson  {get {return toJsonString(checkedClassificationMap);}}//parse to VF page with Json encoded
    public String promotionCodeMapJson  {get {return toJsonString(promotionCodeMap);}}//parse to VF page with Json encoded
    public String supportItemForBrandJson  {get {return toJsonString(supportItemForBrand);}}//parse to VF page with Json encoded
	public String idTransferAnP {get;set;}

    public ASI_TnE_KR_ClaimManageAllCtrl(ApexPages.StandardController stdController) {
        try {            
            this.claimHeader = (ASI_TnE_ClaimHeader__c)stdController.getRecord();                
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage())); 
            return;
        }
        gnhRequestMap = getOtherClaimDetails(this.claimHeader.Id);
        TnEThreshold  = getTnEThresholdTolerance();
        currentRecipientMap = getCurrentRecipient(this.claimHeader.Id);
        recipientbyRequestMap = getRecipientByRequest();
        checkedClassificationMap = getGnHRelatedClassification();
        promotionCodeMap = getPromotionCodeMapping();
        supportItemForBrand = getAnPSupportItem();
        
        ASI_JP_TnE_Expense_Category__c transferAnP;
        try{
            transferAnP = [SELECT Id 
                               FROM ASI_JP_TnE_Expense_Category__c
                               WHERE recordType.developerName like 'ASI_TnE_KR%' 
                               AND Name = 'Transfer to A&P'];
        } catch (Exception e) {}
        
        if (transferAnp != null)
        	idTransferAnP = transferAnP.Id;
    }

    public void init(){

        if(this.claimHeader!=null){

            detailRecordType = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_KR_Claim_Detail');//cash claim

            branchCode = '';
            ASI_TnE_ClaimHeader__c currentHeader = [SELECT Id,ASI_TnE_Status__c, ASI_TnE_KR_Payee__c,ASI_TnE_KR_Payee_Approver__c, ASI_TnE_KR_Additional_Approver_1__c, 
                                                    ASI_TnE_KR_Additional_Approver_2__c,ASI_TnE_KR_Additional_Approver_3__c,
                                                    ASI_TnE_KR_Additional_Approver_4__c,ASI_TnE_KR_Additional_Approver_5__c 
                                                    FROM ASI_TnE_ClaimHeader__c WHERE id =: this.claimHeader.Id limit 1];
            
            System.debug('currentHeader status: ' +currentHeader.ASI_TnE_Status__c +' AND profileName:'+profileName);    


            payee = currentHeader.ASI_TnE_KR_Payee__c;

            if(payee!=null){
                // used to control the auto-complete for customer and venue
                Set<String> validateTitle = new Set<String>{'Channel Sales Director', 'Deputy Sales Director'};
                User payeeUser = [SELECT ASI_KOR_User_Branch_Code__c,ASI_KOR_Commission_Code__c FROM User WHERE Id =: payee limit 1];
                String payeeBC = payeeUser.ASI_KOR_User_Branch_Code__c;
                String payeeEmId = payeeUser.ASI_KOR_Commission_Code__c; 

                ASI_eForm_HR_MDM__c mdmForm = [SELECT ASI_eForm_Employee_Is_Salesman__c,ASI_eForm_Employee_Job_Title__c FROM ASI_eForm_HR_MDM__c WHERE Name =: payeeEmId limit 1];
                Boolean isSales = mdmForm.ASI_eForm_Employee_Is_Salesman__c;
                String jobtitle = mdmForm.ASI_eForm_Employee_Job_Title__c;

                if(isSales && !validateTitle.contains(jobtitle)){
                    isSalesUser = true;
                    branchCode = payeeBC;
                }else isSalesUser = false;

            }

            payee = currentHeader.ASI_TnE_KR_Payee_Approver__c;

            ap1 = currentHeader.ASI_TnE_KR_Additional_Approver_1__c;
            ap2 = currentHeader.ASI_TnE_KR_Additional_Approver_2__c;
            ap3 = currentHeader.ASI_TnE_KR_Additional_Approver_3__c;
            ap4 = currentHeader.ASI_TnE_KR_Additional_Approver_4__c;
            ap5 = currentHeader.ASI_TnE_KR_Additional_Approver_5__c;
            //Check if current user is in FA public user group to display JDE interface fields and VAT fields
            // isFAUser = checkIsInFAUserGroup(UserInfo.getUserId());

            //Check if current step is FA Verification, to allow FA edit
            isFAVerifyStep = (this.claimHeader.ASI_TnE_Status__c == 'Approved');

            //Check if current step is Open to allow everyone to edit
            //isEditable = (claim.ASI_TnE_Status__c == 'Draft' || claim.ASI_TnE_Status__c == 'Rejected');
            if((this.claimHeader.ASI_TnE_Status__c == 'Draft'
                || this.claimHeader.ASI_TnE_Status__c == 'Rejected'
                || profileName == admin)
               &&!Test.isRunningTest())
                isEditable = 1;
            //for TnE card&cash
            else if((this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash_Finance_View')
                     ||this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE_Finance_View'))
                    && this.claimHeader.ASI_TnE_Status__c == 'Approved'
                    && roleName == accounting)
                isEditable = 2;
            //for Tne card&cash
            else if((this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE')
                     ||this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash')
                     ||this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash_Finance_View')
                     ||this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE_Finance_View'))
                    &&(this.claimHeader.ASI_TnE_Status__c == 'Submitted'
                       ||this.claimHeader.ASI_TnE_Status__c == 'Final'
                       ||this.claimHeader.ASI_TnE_Status__c == 'Complete'
                       ||this.claimHeader.ASI_TnE_Status__c == 'Approved'
                       ||this.claimHeader.ASI_TnE_Status__c == 'Pending for A&P Approved'))
                isEditable = 3;
            //for AnP
            else if(this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP')
                    &&this.claimHeader.ASI_TnE_Status__c == 'Submitted'
                    &&(userInfo.getUserId() == payee
                       ||userInfo.getUserId() == ap1
                       ||userInfo.getUserId() == ap2
                       ||userInfo.getUserId() == ap3
                       ||userInfo.getUserId() == ap4
                       ||userInfo.getUserId() == ap5))
                isEditable = 4;
            //for AnP
            else if((this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP_Finance_View')
                     ||this.claimHeader.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP'))
                    &&(this.claimHeader.ASI_TnE_Status__c == 'Approved'
                       ||this.claimHeader.ASI_TnE_Status__c == 'Final'
                       ||this.claimHeader.ASI_TnE_Status__c == 'Complete'
                       ||this.claimHeader.ASI_TnE_Status__c == 'Submitted'))
                isEditable = 5;

            System.debug('isEditable: ' + isEditable + ' isFA: ' + isFAUser + ' isFAVerifyStep: ' + isFAVerifyStep);   

        }  

    }

    public static Map<String, ASI_JP_TnE_Expense_Classification__c> getGnHRelatedClassification(){

        List<ASI_JP_TnE_Expense_Classification__c> classificationList= [SELECT Id, Name,ASI_TnE_KR_Expense_Category__c,ASI_TnE_KR_Expense_Category__r.Name,ASI_TnE_GnH__c 
                                                                        FROM ASI_JP_TnE_Expense_Classification__c 
                                                                        WHERE recordType.developerName like 'ASI_TnE_KR%' AND ASI_TnE_GnH__c = true
                                                                        Order by ASI_TnE_KR_Expense_Category__r.Name, Name ];

        Map<String, ASI_JP_TnE_Expense_Classification__c> classificationMap = new Map<String, ASI_JP_TnE_Expense_Classification__c>();
        for (ASI_JP_TnE_Expense_Classification__c classification : classificationList){
            classificationMap.put(classification.Id, classification);        
        }

        return classificationMap;
    }

    /***************************************************************
    Updated Kevin 22-05-2017
    Get Promotion Code Mapping (Id, Name)
    ***************************************************************/

    public static Map<String, String> getPromotionCodeMapping(){
        List<ASI_MFM_Plan__c> promotionCodeList= [select Id, Name 
                                                  from ASI_MFM_Plan__c 
                                                  where RecordType.DeveloperName = :mfmPlanRt AND ASI_MFM_Status__c ='Approved'];

        Map<String, String> promotionCodeMap = new Map<String, String>();

        for (ASI_MFM_Plan__c promo : promotionCodeList){
            promotionCodeMap.put(promo.Id,promo.Name);
        }

        return promotionCodeMap;
    }
    /***************************************************************
    Updated Kevin 22-05-2017
    Get all Claim details that dont belongs to current claim header,
    Used to check if duplicated GnH request is used 
    ***************************************************************/
    public static Map<String,List<String>> getOtherClaimDetails(Id claimHeaderId){
        List<ASI_TnE_ClaimDetail__c> OtherClaimDetailList =  [SELECT Id,ASI_TnE_ClaimHeader__c,ASI_TnE_GnH_Request__c // Kevin 16-05-2017
                                                              FROM ASI_TnE_ClaimDetail__c 
                                                              WHERE ASI_TnE_ClaimHeader__c  != :claimHeaderId 
                                                              AND ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c  =:claimHeaderStatus
                                                              AND ASI_TnE_GnH_Request__r.ASI_GnH_Status__c =: gnhRequestStatus 
                                                              AND recordType.developerName =: koreaClaimRetailRt 
                                                              ORDER BY ID ];
        Map<String,List<String>> gnhRequestMap = new Map<String,List<String>>();

        for (ASI_TnE_ClaimDetail__c claimDetail : OtherClaimDetailList){
            if (claimDetail.ASI_TnE_GnH_Request__c != null ){
                if (gnhRequestMap.get(claimDetail.ASI_TnE_GnH_Request__c) == null){
                    List<String> claimDetailList = new List<String>();
                    claimDetailList.add(claimDetail.id);
                    gnhRequestMap.put(claimDetail.ASI_TnE_GnH_Request__c,claimDetailList);
                }else{
                    gnhRequestMap.get(claimDetail.ASI_TnE_GnH_Request__c).add(claimDetail.id);
                }
            }
        }
        //system.debug('GnH Request Map: ' + gnhRequestMap);
        return gnhRequestMap;
    }
    /*********************************************
    Updated Kevin 22-05-2017
    Get all request recipient and sort by request
    *********************************************/
    Public static Map<String,Set<ASI_GnH_Request_Recipient__c>> getRecipientByRequest(){
        List<ASI_GnH_Request_Recipient__c> gnhRecipient = [SELECT Id,ASI_GnH_Request__c
                                                           ,ASI_GnH_Recipient__c
                                                           ,ASI_GnH_Recipient__r.Name
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Title__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Organization__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Company_Address__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Mobile__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Email__c
                                                           FROM ASI_GnH_Request_Recipient__c
                                                           WHERE RecordType.DeveloperName = :koreaRecipientRt];
        Map<String,Set<ASI_GnH_Request_Recipient__c>> gnhRecipientMap = new Map<String,Set<ASI_GnH_Request_Recipient__c>>();

        for (ASI_GnH_Request_Recipient__c recipient : gnhRecipient){

            if (recipient.ASI_GnH_Request__c != null){

                if (gnhRecipientMap.get(recipient.ASI_GnH_Request__c)==null){
                    Set<ASI_GnH_Request_Recipient__c> tempRecipient = new Set<ASI_GnH_Request_Recipient__c>();
                    tempRecipient.add(recipient);
                    gnhRecipientMap.put(recipient.ASI_GnH_Request__c,tempRecipient);
                }else{
                    gnhRecipientMap.get(recipient.ASI_GnH_Request__c).add(recipient);
                }
            }
        }
        return gnhRecipientMap;
    }
    /***************************************************************
    Updated Kevin 20-06-2017
    Get all actual recipient related to all claim details under claim header
    ***************************************************************/

    public static Map<String,List<ASI_GnH_Actual_Recipient__c>> getCurrentRecipient(Id claimHeaderId){
        List<ASI_GnH_Actual_Recipient__c> acutalRecipientList = [select Id, ASI_GnH_Recipient__c,
                                                                 ASI_GnH_Recipient__r.Name,
                                                                 ASI_GnH_Recipient__r.ASI_GnH_Title__c, 
                                                                 ASI_GnH_Recipient__r.ASI_GnH_Organization__c,
                                                                 ASI_GnH_Recipient__r.ASI_GnH_Company_Address__c,
                                                                 ASI_GnH_Recipient__r.ASI_GnH_Mobile__c,
                                                                 ASI_GnH_Recipient__r.ASI_GnH_Email__c,
                                                                 ASI_TnE_Details__c 
                                                                 from ASI_GnH_Actual_Recipient__c where ASI_TnE_Details__r.ASI_TnE_ClaimHeader__c = :claimHeaderId];

        Map<String,List<ASI_GnH_Actual_Recipient__c>> actualRecipientMap = new Map<String,List<ASI_GnH_Actual_Recipient__c>>();
        for (ASI_GnH_Actual_Recipient__c autualRecipient : acutalRecipientList){
            if (actualRecipientMap.get(autualRecipient.ASI_TnE_Details__c) == null){
                List<ASI_GnH_Actual_Recipient__c> newRecipientList = new List<ASI_GnH_Actual_Recipient__c>();
                newRecipientList.add(autualRecipient);
                actualRecipientMap.put(autualRecipient.ASI_TnE_Details__c,newRecipientList);
            }else{
                actualRecipientMap.get(autualRecipient.ASI_TnE_Details__c).add(autualRecipient);
            }       
        }
        system.debug(actualRecipientMap);
        return actualRecipientMap;
    }
    /***************************************************************
    Updated Kevin 15-06-2017
    Get all threshold value that belongs to  ASI_TnE_KR_Claim_Detail 
    ASI_GnH_TnE_Threshold_Tolerance is used to calculate the request amount 
    ***************************************************************/
    public static List<Decimal> getTnEThresholdTolerance(){
        List<ASI_GnH_KR_Default_Setting__c> allThreshold = [select id, Name, ASI_GnH_Percent__c,ASI_GnH_Record_Type__c ,ASI_GnH_Object__c from ASI_GnH_KR_Default_Setting__c
                                                            where Name =: ThresholdTolerance AND ASI_GnH_Record_Type__c =: koreaClaimRetailRt AND ASI_GnH_Object__c =:ThresholdObject];
        List<Decimal> thresholdList = new List<Decimal>();
        for (ASI_GnH_KR_Default_Setting__c threshold : allThreshold){
            Decimal tolerancePercentage = threshold.ASI_GnH_Percent__c;
            tolerancePercentage = tolerancePercentage / 100;
            tolerancePercentage = tolerancePercentage +1;
            thresholdList.add(tolerancePercentage);
        }        
        return thresholdList;
    }
    /***************************************************************
    Updated Kevin 15-06-2017
    Get support item list for custom setting for AnP claim
    Dept in charge: Brand MKT
    ***************************************************************/
    public static String getAnPSupportItem(){
        ASI_GnH_KR_Default_Setting__c supportItemBrand = [select id, Name, ASI_GnH_Text__c,ASI_GnH_Record_Type__c ,ASI_GnH_Object__c from ASI_GnH_KR_Default_Setting__c
                                                            where Name =: AnPSupportItem AND ASI_GnH_Record_Type__c =: koreaClaimRetailRt AND ASI_GnH_Object__c =:ThresholdObject limit 1];
        
        //for (ASI_GnH_KR_Default_Setting__c item : supportItemBrand){
            //String tolerancePercentage = threshold.ASI_GnH_Percent__c; 
            //thresholdList.add(tolerancePercentage);
        //}        
        return supportItemBrand.ASI_GnH_Text__c;
    }
    /***************************************************************
    Updated Kevin 15-06-2017
    get all picklist value from the field 
    ***************************************************************/
    @RemoteAction
    public static Map<String, String> getSelectedOptions (String FieldName) {
        Map<String, String> optionMap = new Map<String, String>();
        if(FieldName!=null)
        {
            Schema.sObjectType objType = ASI_TnE_ClaimDetail__c.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            List<Schema.PicklistEntry> values = fieldMap.get(FieldName).getDescribe().getPickListValues();
            optionMap.put('', '--None--');
            for(Schema.PicklistEntry pick: values){
                optionMap.put(String.valueOf(pick.getValue()), String.valueOf(pick.getLabel()));
            }
        }

        return optionMap;         
    }
    /*****************************************************
    Updated Kevin 15-06-2017
    Function to generate picklist value for Recipient Type
    ******************************************************/
    @RemoteAction
    public static Map<String, String> getRecipientOptions (String FieldName) {
        Map<String, String> optionMap = new Map<String, String>();
        if(FieldName!=null){
            optionMap.put('', '--None--');
            optionMap.put('Public Official & Media', 'Public Official & Media');
            optionMap.put('Others', 'Others');           
        }        
        return optionMap;         
    }

    @RemoteAction
    public static List<dependentPicklist> lookupFieldToSelectedOptions (String sObjInputTypeStr, String sObjInputFieldStr) {
        //System.debug('sObjInputTypeStr: ' + sObjInputTypeStr);
        //System.debug('sObjInputFieldStr: ' + sObjInputFieldStr);
        List<dependentPicklist> optionList = new List<dependentPicklist>();
        Map<String,dependentPicklist> parentMap = new Map<String,dependentPicklist>();


        if(sObjInputFieldStr=='ASI_TnE_Expense_Category__c'){ 
            List<ASI_JP_TnE_Expense_Classification__c> exClaList 
                = new List<ASI_JP_TnE_Expense_Classification__c>([SELECT Id, Name,
                                                                  ASI_TnE_KR_Expense_Category__c,
                                                                  ASI_TnE_KR_Expense_Category__r.Name,
                                                                  ASI_TnE_GnH__c
                                                                  FROM ASI_JP_TnE_Expense_Classification__c 
                                                                  WHERE recordType.developerName like 'ASI_TnE_KR%'
                                                                  Order by ASI_TnE_KR_Expense_Category__r.Name, Name]);

            for(ASI_JP_TnE_Expense_Classification__c cla :exClaList){
                if(parentMap.containsKey(cla.ASI_TnE_KR_Expense_Category__c)){
                    dependentPicklist tempPicklist = parentMap.get(cla.ASI_TnE_KR_Expense_Category__c);
                    tempPicklist.childPicklist.put(cla.Id,cla.Name);
                    parentMap.put(cla.ASI_TnE_KR_Expense_Category__c,tempPicklist );
                }else{
                    dependentPicklist tempPicklist = new dependentPicklist();
                    tempPicklist.label = cla.ASI_TnE_KR_Expense_Category__r.Name;
                    tempPicklist.recordId = cla.ASI_TnE_KR_Expense_Category__c;
                    tempPicklist.gnhRelated = cla.ASI_TnE_GnH__c;
                    tempPicklist.childPicklist.put(cla.Id,cla.Name);
                    parentMap.put(cla.ASI_TnE_KR_Expense_Category__c,tempPicklist);
                }
            }            
			
        }else{
            /*
            Schema.sObjectType sobjType = Schema.getGlobalDescribe().get(sObjInputTypeStr);
            Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
            Schema.DescribeFieldResult F = sObjFieldMap.get(sObjInputFieldStr).getDescribe();   

            if(!F.isNamePointing()){
                    List<Schema.sobjectType> sobjTypeList = F.getReferenceTo();
                    String retObject = sobjTypeList[0].getDescribe().getName();

                    String queryStr = 'SELECT id, Name FROM ' + retObject + ' order by Name';   
                    System.debug('retObject: ' + retObject);
                    List<sObject> existingSObjList = Database.query(queryStr);

                    for(sObject sobj: existingSObjList ){   
                        dependentPicklist tempPicklist = new dependentPicklist();
                        Object nameValue= sobj.get('Name');
                        Object idValue = sobj.get('Id');                                        
                        tempPicklist.label = String.valueOf(nameValue);
                        tempPicklist.recordId = String.valueof(idValue);     
                        parentMap.put(String.valueof(idValue),tempPicklist );
                    }
            }
            */
        } 

        if(!parentMap.isEmpty()){    
            optionList.add(new dependentPicklist ());
            optionList.addAll(parentMap.values());
        }else{
            dependentPicklist tempPicklist = new dependentPicklist();
            optionList.add(tempPicklist);
        }

        return optionList;        
    }

    @RemoteAction
    public static String getClaimDetails (String claimHeaderId) { //List<ASI_TnE_ClaimDetail__c>
        List<ASI_TnE_ClaimDetail__c> claimDetailList =  [SELECT Id,Name,ASI_TnE_ClaimHeader__c,ASI_TnE_Receipt_Date__c,
                                                         ASI_TnE_KR_Salesman__c,ASI_TnE_KR_Salesman__r.Name,
                                                         ASI_TnE_KR_Customer__c,ASI_TnE_KR_Customer__r.Name,
                                                         ASI_TnE_Dept_in_Charge__c,ASI_TnE_Details_of_Expense__c,
                                                         ASI_TnE_KR_Receipt_Time__c,ASI_TnE_KR_Business_Name__c,
                                                         ASI_TnE_KR_Business_Address__c,ASI_TnE_Receipt_Amount_Displaying__c,
                                                         ASI_TnE_KR_Sub_Brand__r.Name,
                                                         ASI_TnE_KR_Sub_Brand__c, ASI_TnE_Branch_code_Channel__c,
                                                         ASI_TnE_Branch_code_Channel__r.Name,
                                                         ASI_TnE_KR_Promotion_Code__c,ASI_TnE_KR_Promotion_Code__r.Name,
                                                         ASI_TnE_KR_Where__c,ASI_TnE_KR_Where__r.Name,
                                                         ASI_TnE_Sales_Month__c,ASI_TnE_Sales_Year__c,
                                                         ASI_TnE_Supported_Item__c
                                                         ,ASI_TnE_Expense_Category__c //new add for test
                                                         ,ASI_TnE_Expense_Classification__c //new add for test
                                                         ,ASI_TnE_Currency__c //new add for test
                                                         ,ASI_TnE_FX_Rate__c //new add for test
                                                         ,ASI_TnE_Total_Number_Pax__c //new add for test
                                                         ,ASI_TnE_KR_Owner__c //new add for test
                                                         ,ASI_TnE_KR_Owner__r.Name  //new add for test
                                                         ,ASI_TnE_Receipt_Amount__c
                                                         ,ASI_TnE_Recipient_Type__c
                                                         ,ASI_GnH_Type__c
                                                         ,ASI_TnE_GnH_Request__c // Kevin 16-05-2017
                                                         ,ASI_TnE_GnH_Request__r.Name
                                                         ,ASI_TnE_GnH_Request__r.ASI_GnH_Applicant__c // Kevin 16-05-2017
                                                         ,ASI_TnE_GnH_Request__r.ASI_GnH_Applicant__r.Name// Kevin 16-05-2017
                                                         FROM ASI_TnE_ClaimDetail__c 
                                                         WHERE ASI_TnE_ClaimHeader__c  =: claimHeaderId
                                                         ORDER BY ID ];
        String JSONclaimDetailList = JSON.serialize(claimDetailList);        
        return JSONclaimDetailList;        

    }
    /*********************************
    Updated Kevin 15-06-2017
    Function to get GnH recipient Data
    **********************************/

    @RemoteAction
    Public static String getGnhRecipient(){
        List<ASI_GnH_Request_Recipient__c> gnhRecipient = [SELECT Id,ASI_GnH_Request__c
                                                           ,ASI_GnH_Recipient__c
                                                           ,ASI_GnH_Recipient__r.Name
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Title__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Organization__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Company_Address__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Mobile__c
                                                           ,ASI_GnH_Recipient__r.ASI_GnH_Email__c
                                                           FROM ASI_GnH_Request_Recipient__c
                                                           WHERE RecordType.DeveloperName = :koreaRecipientRt];
        Map<String,Set<ASI_GnH_Request_Recipient__c>> gnhRecipientMap = new Map<String,Set<ASI_GnH_Request_Recipient__c>>();

        for (ASI_GnH_Request_Recipient__c recipient : gnhRecipient){

            if (recipient.ASI_GnH_Request__c != null){

                if (gnhRecipientMap.get(recipient.ASI_GnH_Request__c)==null){
                    Set<ASI_GnH_Request_Recipient__c> tempRecipient = new Set<ASI_GnH_Request_Recipient__c>();
                    tempRecipient.add(recipient);
                    gnhRecipientMap.put(recipient.ASI_GnH_Request__c,tempRecipient);
                }else{
                    gnhRecipientMap.get(recipient.ASI_GnH_Request__c).add(recipient);
                }
            }
        }

        String gnhRecipientJsonList = JSON.serialize(gnhRecipientMap);
        return gnhRecipientJsonList;
    }
    /****************************************
    Updated Kevin 15-06-2017
    Function to get GnH recipient Master Data
    *****************************************/
    @RemoteAction
    Public static String getRecipientMaster(){
        List<ASI_GnH_Recipient_Master__c> recipientMasterList = [SELECT Id, Name
                                                                 ,ASI_GnH_Email__c
                                                                 ,ASI_GnH_Mobile__c
                                                                 ,ASI_GnH_Organization__c
                                                                 ,ASI_GnH_Company_Address__c
                                                                 ,ASI_GnH_Title__c 
                                                                 FROM ASI_GnH_Recipient_Master__c
                                                                 WHERE recordType.developerName =: koreaRecipientMasterRt OR recordType.developerName =:koreaStaffMasterRt ];

        Map<String,ASI_GnH_Recipient_Master__c> recipientMasterMap= new Map<String,ASI_GnH_Recipient_Master__c>();
        for (ASI_GnH_Recipient_Master__c recipientMaster : recipientMasterList){
            if(recipientMaster.Name !=null){
                recipientMasterMap.put(recipientMaster.Id,recipientMaster);
            }
        }
        String recipientMasterJsonList = JSON.serialize(recipientMasterMap);
        return recipientMasterJsonList;
    }

    /**************************************************
    Updated Kevin 15-06-2017
    Function to get GnH Request for checking the Amount
    ***************************************************/
    @RemoteAction
    public static String getGnHRequest(){
        List<ASI_GnH_Request__c> gnhRequestList = [SELECT Id, Name, ASI_GnH_Recipient_Type__c, ASI_GnH_Type__c, ASI_GnH_Amount_per_Recipient__c, ASI_GnH_PAX__c, ASI_GnH_Total_Request_Amount__c
                                                   FROM ASI_GnH_Request__c WHERE ASI_GnH_Status__c = 'Approved' AND recordType.DeveloperName IN : GnHRecordType];
        Map<String, ASI_GnH_Request__c> gnhRequestMap = new Map<String, ASI_GnH_Request__c>();
        for (ASI_GnH_Request__c gnhRequest : gnhRequestList){
            gnhRequestMap.put(gnhRequest.Name,gnhRequest);
        }
        String gnhRequestJsonList = JSON.serialize(gnhRequestMap);
        return gnhRequestJsonList;
    }

    /***************************************************************
    Updated Kevin 15-06-2017
    Function to get ASI_MFM_Plan__c and decide the required field
    (Recipient Type and G&H Type) base on the plan name
    ***************************************************************/
    @RemoteAction
    public static String getGnHCheckedPlan(){
        List<ASI_MFM_Plan__c>checkedPlanList = [SELECT Id, Name, ASI_MFM_Project_Code__c,ASI_MFM_Project_Code__r.ASI_GnH_GnH__c,ASI_MFM_Project_Code__r.ASI_GnH_Supported_Item__c FROM ASI_MFM_Plan__c 
                                                WHERE RecordType.DeveloperName = :mfmPlanRt AND ASI_MFM_Project_Code__r.ASI_GnH_GnH__c = true];

        Map<String, ASI_MFM_Plan__c> mfmPlanMap = new Map<String, ASI_MFM_Plan__c>();
        for (ASI_MFM_Plan__c plan : checkedPlanList){
            if (String.isNotEmpty(plan.Name)){
                mfmPlanMap.put(plan.Name,plan);
            }
        }
        String mfmPlanJsonList = JSON.serialize(mfmPlanMap);
        return mfmPlanJsonList;
    }

    @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if

        // create the filter text
        String filter = qry;

        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null){
            if(obj != 'ASI_GnH_Threshold__c'){
                soql = 'select '+statement+' from ' + obj + filter +' order by Name';
            }
            else{
                soql = 'select '+statement+' from ' + obj + filter +' order by ASI_GnH_Threshold_Amount__c ASC';
            }
        }else{
            soql = 'select '+statement+' from ' + obj +' order by Name';
        }

        List<sObject> sobjs = new List<sObject>();

        List<String> results = new List<String>();

        System.debug('soql:' + soql);

        try
        {
            //SYSTEM.debug('TEST SQL AND COMPLETE: '+soql);
            sobjs = Database.query(soql);
            //System.debug('Results Found: ' + sobjs);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }


    public class dependentPicklist{
        public String label {set;get;}
        public String recordId {set;get;}
        public Boolean gnhRelated {set;get;}
        public Map<String, String> childPicklist {set;get;}

        public dependentPicklist(){
            this.label ='';
            this.recordId = '';
            this.gnhRelated = false;
            this.childPicklist = new Map<String, String>();
        }
    }

    public class remoteActionResult{
        public Boolean SuccessFlag {set;get;} 
        public List<String> errorMessages {set;get;}

        public remoteActionResult(){
            this.SuccessFlag = true;
            this.errorMessages = new List<String>();
        }
    }

    public class AngularApexClaimDetail{
        public ASI_TnE_ClaimDetail__c  claimDetail {get;set;}
        public Boolean IsChanged {set;get;}
        public Integer rdYear {get;set;}
        public Integer rdMonth {get;set;}
        public Integer rdDay {get;set;}
        public Integer rowNo {get;set;}

        public AngularApexClaimDetail(){
            this.claimDetail = new ASI_TnE_ClaimDetail__c();
            this.Ischanged = true;
        }

    }

    public class AngularApexActualRecipient{
        public ASI_GnH_Actual_Recipient__c actualRecipient {get;set;}
        public Integer rowNo {get;set;}

        public AngularApexActualRecipient(){
            this.actualRecipient = new ASI_GnH_Actual_Recipient__c();
        }
    }
    /***********************************************
    Updated Kevin 19-06-2017
    Tool Function for Saving AnP Claim and TnE Claim
    ************************************************/

    public static Map<Integer,ASI_TnE_ClaimDetail__c> getClaimDetailsByApexMap(Map<Integer, AngularApexClaimDetail> apexClaimDetailMap){
        List<ASI_TnE_ClaimDetail__c> claimDetails = new List<ASI_TnE_ClaimDetail__c>();
        Map<Integer,ASI_TnE_ClaimDetail__c> claimDetailMap = new Map<Integer,ASI_TnE_ClaimDetail__c>();

        for(Integer key : apexClaimDetailMap.keyset()){
            ASI_TnE_ClaimDetail__c claimDetail = apexClaimDetailMap.get(key).claimDetail;
            Integer rowNumber = apexClaimDetailMap.get(key).rowNo;
            system.debug('Claim Detail: '+ claimDetail+' row:'+rowNumber);

            Boolean isChanged = false;
            if (apexClaimDetailMap.get(key).isChanged != null) {
                isChanged = apexClaimDetailMap.get(key).IsChanged;
            }
            //if (isChanged) {
            //claimDetails.add(claimDetail);
            claimDetailMap.put(rowNumber,claimDetail);
            //}                 
        }
        return claimDetailMap;
    }

    public static List<ASI_GnH_Actual_Recipient__c> deleteOldRecipient(Map<Integer, ASI_GnH_Actual_Recipient__c> gnhActualRecipientJsonMap,Map<Integer,ASI_TnE_ClaimDetail__c> claimDetailsMap){
        //system.debug('GnH Actual Recipient to be converted: ' + gnhActualRecipientJsonMap);
        List<ASI_GnH_Actual_Recipient__c> gnhActualRecipientApexList = new List<ASI_GnH_Actual_Recipient__c>();
        Set<Id> tnEDetails = new Set<Id>();  
        for(Integer key : gnhActualRecipientJsonMap.keyset()){
            ASI_GnH_Actual_Recipient__c recipient = gnhActualRecipientJsonMap.get(key);
            gnhActualRecipientApexList.add(recipient);
            tnEDetails.add(recipient.ASI_TnE_Details__c);
        }

        for (ASI_TnE_ClaimDetail__c claimdetail : claimDetailsMap.values()){
            tnEDetails.add(claimdetail.Id);
        }
        system.debug('Set of Id involved: '+tnEDetails);
        List<ASI_GnH_Actual_Recipient__c> existingRecipientWillDelete = [SELECT id,ASI_TnE_Details__c FROM ASI_GnH_Actual_Recipient__c WHERE ASI_TnE_Details__c IN :tnEDetails];
        //system.debug('Existing Actual Recipient: '+existingRecipientWillDelete);
        if(existingRecipientWillDelete!=null){
            //system.debug('Start deleting List: '+existingRecipientWillDelete);
            delete existingRecipientWillDelete;
        }
        system.debug(gnhActualRecipientApexList);
        return gnhActualRecipientApexList;
    } 
    /*****************************************
    Updated Kevin 19-06-2017
    Save Function for AnP Claim and TnE Claim
    ******************************************/
    @RemoteAction
    public static remoteActionResult doSave(Map<Integer, AngularApexClaimDetail> apexClaimDetailMap,Map<Integer, ASI_GnH_Actual_Recipient__c> gnhActualRecipient){
        Savepoint sp = Database.setSavepoint();
        ASI_TnE_KR_ClaimManageAllCtrl.remoteActionResult result = new ASI_TnE_KR_ClaimManageAllCtrl.remoteActionResult(); 
        Map<Integer,ASI_TnE_ClaimDetail__c> claimDetailsMap = new Map<Integer,ASI_TnE_ClaimDetail__c>();
        try{
            if(!apexClaimDetailMap.keySet().isEmpty()){
                system.debug(apexClaimDetailMap);
                claimDetailsMap = ASI_TnE_KR_ClaimManageAllCtrl.getClaimDetailsByApexMap(apexClaimDetailMap);
                system.debug(claimDetailsMap);
                upsert claimDetailsMap.values();
            }
            //system.debug('GnH Actual Recipient to be insert: ' + gnhActualRecipient.keySet());
            List<ASI_GnH_Actual_Recipient__c> actualRecipientList = ASI_TnE_KR_ClaimManageAllCtrl.deleteOldRecipient(gnhActualRecipient,claimDetailsMap);
            upsert actualRecipientList;
            //system.debug('Insert Actual Recipient Successful');


        } catch(DmlException e) {
            Database.rollback(sp);
            result.SuccessFlag = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                integer index = Integer.valueOf(e.getDmlIndex(i)) + 1; 
                result.errorMessages.add('#' + index +': ' + e.getDmlMessage(i));
            }
            return result;
        }catch(Exception e) {
            Database.rollback(sp);
            result.SuccessFlag = false;
            result.errorMessages.add(e.getMessage());
            return result;
        }

        return result;
    }

    /**********************************
    Updated Kevin 19-06-2017
    Tool Function for Saving Cash Claim
    ***********************************/

    public static Set<Id> getDelClaimIdsByJson(List<Object> jsonDelClaimIdList) {
        Set<Id> delClaimIds = new Set<Id>();
        for (Object item : jsonDelClaimIdList) {
            delClaimIds.add((String)item);
        }

        return delClaimIds;
    }

    public static List<ASI_TnE_ClaimDetail__c> getDeleteClaimDetails(Set<Id> delClaimIds) {
        return [SELECT Id FROM ASI_TnE_ClaimDetail__c WHERE Id IN: delClaimIds];
    }    


    //cash claim
    public static Map<Integer,ASI_TnE_ClaimDetail__c> getCashClaimDetailsByApexMap(Map<Integer, AngularApexClaimDetail> apexClaimDetailMap){
        List<ASI_TnE_ClaimDetail__c> claimDetails = new List<ASI_TnE_ClaimDetail__c>();
        Map<Integer,ASI_TnE_ClaimDetail__c> claimDetailMap = new Map<Integer,ASI_TnE_ClaimDetail__c>();

        for(Integer key : apexClaimDetailMap.keyset()){
            ASI_TnE_ClaimDetail__c claimDetail = apexClaimDetailMap.get(key).claimDetail;
            Integer rowNumber = apexClaimDetailMap.get(key).rowNo;
            //system.debug('Record '+key+':'+claimDetail);
            claimDetail.ASI_TnE_Receipt_Date__c = Date.newInstance(apexClaimDetailMap.get(key).rdYear, apexClaimDetailMap.get(key).rdMonth, apexClaimDetailMap.get(key).rdDay);//cash claim
            Boolean isChanged = false;
            if (apexClaimDetailMap.get(key).isChanged != null) {
                isChanged = apexClaimDetailMap.get(key).IsChanged;
            }
            //if (isChanged) {
            //claimDetails.add(claimDetail);
            claimDetailMap.put(rowNumber,claimDetail);
            //}                 
        }
        return claimDetailMap;
    }

    public static List<ASI_GnH_Actual_Recipient__c> deleteOldRecipientByDetailId(Map<Integer, AngularApexActualRecipient> gnhActualRecipientJsonMap, Map<Integer,ASI_TnE_ClaimDetail__c> claimDetailsMap){
        //system.debug('GnH Actual Recipient to be converted: ' + gnhActualRecipientJsonMap);
        List<ASI_GnH_Actual_Recipient__c> gnhActualRecipientApexList = new List<ASI_GnH_Actual_Recipient__c>();
        Set<Id> tnEDetails = new Set<Id>();  
        for(Integer key : gnhActualRecipientJsonMap.keyset()){
            ASI_GnH_Actual_Recipient__c recipient = gnhActualRecipientJsonMap.get(key).actualRecipient;
            if (String.isEmpty(recipient.ASI_TnE_Details__c)){
                system.debug('Has No Id');
                Integer rowNumber = gnhActualRecipientJsonMap.get(key).rowNo;
                recipient.ASI_TnE_Details__c = claimDetailsMap.get(rowNumber).Id;
            }
            gnhActualRecipientApexList.add(recipient);
            tnEDetails.add(recipient.ASI_TnE_Details__c);
        }
        for (ASI_TnE_ClaimDetail__c claimdetail : claimDetailsMap.values()){
            tnEDetails.add(claimdetail.Id);
        }
        system.debug('Set of Id involved: '+tnEDetails);
        List<ASI_GnH_Actual_Recipient__c> existingRecipientWillDelete = [SELECT id,ASI_TnE_Details__c FROM ASI_GnH_Actual_Recipient__c WHERE ASI_TnE_Details__c IN :tnEDetails];
        //system.debug('Set of Id involved: '+tnEDetails);
        //system.debug('Existing Actual Recipient: '+existingRecipientWillDelete);
        if(existingRecipientWillDelete!=null){
            system.debug('Start deleting List: '+existingRecipientWillDelete);
            delete existingRecipientWillDelete;
        }
        system.debug(gnhActualRecipientApexList);
        return gnhActualRecipientApexList;
    } 
    /***************************
    Updated Kevin 19-06-2017
    Save Function for Cash Claim
    *****************************/

    @RemoteAction
    public static remoteActionResult doCashSave(Map<Integer, AngularApexClaimDetail> apexClaimDetailMap, String delClaimListJSON, Map<Integer, AngularApexActualRecipient> gnhActualRecipient){
        Savepoint sp = Database.setSavepoint();
        ASI_TnE_KR_ClaimManageAllCtrl.remoteActionResult result = new ASI_TnE_KR_ClaimManageAllCtrl.remoteActionResult();
        Map<Integer,ASI_TnE_ClaimDetail__c> claimDetailsMap = new Map<Integer,ASI_TnE_ClaimDetail__c>();
        try{
            if (String.isNotEmpty(delClaimListJSON)) {
                //system.debug('delClaimListJSON: ' + delClaimListJSON);
                List<Object> jsonDelClaimIdList = (List<Object>) JSON.deserializeUntyped(delClaimListJSON);
                Set<Id> delClaimIds = ASI_TnE_KR_ClaimManageAllCtrl.getDelClaimIdsByJson(jsonDelClaimIdList);
                List<ASI_TnE_ClaimDetail__c> delList =  ASI_TnE_KR_ClaimManageAllCtrl.getDeleteClaimDetails(delClaimIds);
                delete delList;
                //system.debug('Delete Successful');
            }

            if(!apexClaimDetailMap.keySet().isEmpty()){
                //system.debug('apexClaimDetailMap: ' + apexClaimDetailMap.keySet());
                claimDetailsMap = ASI_TnE_KR_ClaimManageAllCtrl.getCashClaimDetailsByApexMap(apexClaimDetailMap);
                upsert claimDetailsMap.values();
                //change update->upsert,cash claim
                //system.debug('Save Successful');
            }
            //system.debug('GnH Actual Recipient to be insert: ' + gnhActualRecipient.keySet());
            system.debug('Insert claim details Map: ' + claimDetailsMap);
            List<ASI_GnH_Actual_Recipient__c> actualRecipientList = ASI_TnE_KR_ClaimManageAllCtrl.deleteOldRecipientByDetailId(gnhActualRecipient,claimDetailsMap);
            //system.debug('ActualRecipient' + actualRecipientList);
            insert actualRecipientList;
            //system.debug('Insert Actual Recipient Successful');


        } catch(DmlException e) {
            Database.rollback(sp);
            result.SuccessFlag = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                integer index = Integer.valueOf(e.getDmlIndex(i)) + 1; 
                result.errorMessages.add('#' + index +': ' + e.getDmlMessage(i));
            }
            return result;
        }catch(Exception e) {
            Database.rollback(sp);
            result.SuccessFlag = false;
            result.errorMessages.add(e.getMessage());
            return result;
        }

        return result;
    }
    //cash claim

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

}