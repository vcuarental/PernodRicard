public class ASI_eForm_HK_CustomerForm_PDF_PageCtrler {
    
   // Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank');
  //  Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RO_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank_RO');
  //  Private Static Final Id NEW_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_HK_Vendor_Form_New');
  //  Private Static Final Id NEW_VENDOR_FORM_READONLY_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_HK_Vendor_Form_New_RO');
  //  Private Static Final Id REVISE_VENDOR_FORM_STEP_ONE_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_HK_Vendor_Form_Revise_Step_1');
  //  Private Static Final Id REVISE_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_HK_Vendor_Form_Revise');
    private final static String PRHKM = 'PRHKM';
    private final static String PRATR = 'PRATR';
    private final static String PARENT = 'Parent';
    private final static String REVISE = 'Revise';
    Private Static Final Id PRHKM_PARENT_REVISE_CUSTOMER_FORM = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRHKM_Parent_Revise');
    
    Private Static Final Map<String, Schema.SObjectField> CUSTOMER_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Customer_Form__c.fields.getMap();
  //  Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_LINE_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form_Line_Item__c.fields.getMap();
    
    Private Static Final Set<String> SET_OF_PICKLIST_TO_DISPLAY_LABEL = new Set<String>{'ASI_eForm_Search_Type__c'};
    
    public id formID {set;get;}
    public ASI_eForm_Customer_Form__c customerformCurrent{get;set;}
    
    public ASI_eForm_Customer_Form__c customerForm {get;set;}
  //  public list<ASI_eForm_Vendor_Form_Line_Item__c> vendorFormLineList{get;set;}
    
    public ASI_eForm_Customer_Form__c archivedCustomerForm {get;set;}
  //  public list<ASI_eForm_Vendor_Form_Line_Item__c> archivedVendorFormLineList{get;set;}
    
    Public Map<String, Boolean> mapChanges {Get; Set;}
    Public Map<String, String> picklistLabelMap {Get; Set;}
    
    Public String logoURL {Get; Private Set;}
   // Public String keyBankRT{Get; Private Set;}
   // Public String keyBankRORT{Get; Private Set;}
    Public String reviseHKMParent{Get; Private Set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public Boolean isHKM { get ; set; }

    public Boolean isChild { get ; set; }
    
    public Boolean isRevise { get ; set; }
    
    /*//Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
        public dateTime approvalDateTime{get;set;}
    }//end class
    */
    
    public ASI_eForm_HK_CustomerForm_PDF_PageCtrler(){}
    
    public ASI_eForm_HK_CustomerForm_PDF_PageCtrler(ApexPages.StandardController controller) {
		this.customerformCurrent = (ASI_eForm_Customer_Form__c)controller.getRecord();
    }  
    
    public boolean init(){
        
        List<Document> logo = new List<Document>([SELECT id, Name FROM Document WHERE DeveloperName LIKE 'ASI_Pernod_Ricard_Logo' LIMIT 1]);
        Id strOrgId = UserInfo.getOrganizationId();
        
        logoURL = logo.size() > 0 ? 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/servlet/servlet.ImageServer?id=' + logo[0].id + '&oid=' + strOrgId : '';
        
        picklistLabelMap = new Map<String, String>();
        
        for(Schema.SObjectField p : CUSTOMER_FORM_FIELD_MAP.values()){
            
            if(p.getDescribe().getType() == Schema.DisplayType.Picklist && SET_OF_PICKLIST_TO_DISPLAY_LABEL.contains(p.getDescribe().getName())){
                
                for(Schema.PicklistEntry pv : p.getDescribe().getPicklistValues()){
                    picklistLabelMap.put(pv.getValue().toUpperCase(), pv.getLabel().toUpperCase());
                }
            }
        }
        
     //   keyBankRT = VENDOR_FORM_LINE_KEY_BANK_RT;
      //  keyBankRORT = VENDOR_FORM_LINE_KEY_BANK_RO_RT;
        reviseHKMParent = PRHKM_PARENT_REVISE_CUSTOMER_FORM;
        
        String addonFields = ', Owner.Name';
        
        List<ASI_eForm_Customer_Form__c> tmpvendorList = new List<ASI_eForm_Customer_Form__c>();
        tmpvendorList = queryOriginalCustomerForm(null, null, null, ' where Id = \'\'' + formId + '\'\'', addonFields);
        
        if(tmpvendorList.size() > 0){
            
            customerForm = tmpvendorList[0];            
            
        
        List<ASI_eForm_Customer_Form__c> tmp = new List<ASI_eForm_Customer_Form__c>();
        
        if(Global_RecordTypeCache.getRt(customerForm.recordTypeid).developerName.contains(REVISE))
        tmp = queryOriginalCustomerForm(null, null, null, ' WHERE Id = \'\'' + customerForm.ASI_eForm_Original_Customer_Form__c + '\'\' LIMIT 1', addonFields);
        
       if(tmp.size() > 0){
            
            archivedCustomerForm = tmp[0];
           // archivedVendorFormLineList = tmp[0].Vendor_Form_Line_Items__r;
        }else{
            archivedCustomerForm = Null;
          // archivedVendorFormLineList = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
        }
        
       
            
            checkFieldModification(customerForm, archivedCustomerForm);
            
          /*  if(!String.isBlank(archivedCustomerForm.ASI_eForm_Search_Type__c) && !picklistLabelMap.containsKey(archivedCustomerForm.ASI_eForm_Search_Type__c.toUpperCase())){
                
                picklistLabelMap.put(archivedCustomerForm.ASI_eForm_Search_Type__c.toUpperCase(), archivedCustomerForm.ASI_eForm_Search_Type__c.toUpperCase());
            }*/
        }
        
        isHKM = (Global_RecordTypeCache.getRt(customerForm.recordTypeid).developerName.contains('PRHKM'))? true:false;
        
        isChild = (!String.isBlank(customerForm.ASI_eForm_Parent_Customer_Form__c))? true:false;
        
        isRevise = (!String.isBlank(customerForm.ASI_eForm_Original_Customer_Form__c))? true:false;
        
        system.debug('isHKM::'+ isHKM);
        
        if(!String.isBlank(customerForm.ASI_eForm_Search_Type__c) && !picklistLabelMap.containsKey(customerForm.ASI_eForm_Search_Type__c.toUpperCase())){
            
            picklistLabelMap.put(customerForm.ASI_eForm_Search_Type__c.toUpperCase(), customerForm.ASI_eForm_Search_Type__c.toUpperCase());
        }
        
      //  getapprovalDetails();
        
      system.debug('picklistLabelMap: '+ picklistLabelMap);
		return true; 
    }
    
    /*public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && formID != null)
        {
            List<ProcessInstance> pList = [SELECT Id, 
                                           (SELECT Id,
                                            CreatedDate,
                                            StepStatus,
                                            Comments,
                                            ActorId,
                                            Actor.Name,
                                            OriginalActorId,
                                            OriginalActor.Name
                                            FROM StepsAndWorkitems
                                            ORDER BY CreatedDate DESC,
                                            StepStatus DESC)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :formID
                                           ORDER BY CreatedDate DESC
                                           Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList){
                for (ProcessInstanceHistory his:p.StepsAndWorkitems){
                    actoerIdSet.add(his.ActorId);
                }//end for
            }//end for
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList)
            {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 &&(p.StepsAndWorkitems[0].StepStatus == 'Approved' || p.StepsAndWorkitems[0].StepStatus == 'Rejected')){
                    byPassPending = true;
                }//end if
                for (ProcessInstanceHistory his:p.StepsAndWorkitems){
                    if(his.StepStatus != 'Reassigned' && his.StepStatus != 'NoResponse' && !(byPassPending && his.StepStatus == 'Pending')){
                        approvalDetail detail = new approvalDetail();
                        if(his.StepStatus == 'Removed')
                            detail.status = 'Recalled';
                        else if(his.StepStatus == 'Started')
                            detail.status = 'Submitted';
                        else
                            detail.status = his.StepStatus;
                            
                        detail.title = userMap.get(his.ActorId).title;
                        detail.history = his;
                        detail.approvalDateTime = his.CreatedDate.addSeconds(integer.valueOf(UserInfo.getTimeZone().getOffset(his.CreatedDate)/1000));
                        details.add(detail);
                    }//end if
                }//end for
            }//end for
        }//end if
        return details;
    }//end method: getapprovalDetails
    */
    
    Private List<ASI_eForm_Customer_Form__c> queryOriginalCustomerForm(Set<String> setOne, Set<String> setTwo, List<ASI_eForm_Customer_Form__c> triggerNew, String whereClause, String additionalFields){
        
        Map<String, Schema.SObjectField> customerForm_FIELD_MAP = Schema.SObjectType.ASI_eForm_Customer_Form__c.fields.getMap();
     //   Map<String, Schema.SObjectField> vendorFormLine_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form_Line_Item__c.fields.getMap();
        List<String> paraList = new List<String>{'setOne', 'setTwo', 'triggerNew'};
	        
        String queryStr = 'SELECT ';
        
        queryStr += String.join(new List<String>(customerForm_FIELD_MAP.keySet()), ' , ');
        
        queryStr += additionalFields;
        
   //     queryStr += ', (SELECT ';
        
    //    queryStr += String.join(new List<String>(vendorFormLine_FIELD_MAP.keySet()), ', ');
        
        queryStr += ' FROM ASI_eForm_Customer_Form__c ' + String.format(whereClause, paraList);
        System.debug('queryStr: '+ queryStr);
        Return database.query(queryStr);
    }
    
    Private Void checkFieldModification(ASI_eForm_Customer_Form__c customerForm, ASI_eForm_Customer_Form__c snapshotVersion){
        List<String> fieldsList = getFieldsForRecodeType();
      List<AggregateResult> fieldHistroyResult = [SELECT Field FROM ASI_eForm_Customer_Form__history where Parent.Name =: customerForm.Name group by Field];
      Map<String,String> fieldChanged = new Map<String,String>();
        mapChanges = new Map<String, Boolean>();
        
        for (AggregateResult ar : fieldHistroyResult)  {
            fieldChanged.put(ar.get('Field').toString(),ar.get('Field').toString());
        }

        
        for(String field : fieldsList){
        
          /*  if(snapshotVersion != null){
                if(customerForm.get(field) != snapshotVersion.get(field)){
                    mapChanges.put(field.toUpperCase(), True);
                }else{
                    mapChanges.put(field.toUpperCase(), False);
                }
            }*/
			
            if(fieldChanged.get(field) != null){
                 mapChanges.put(field.toUpperCase(), True);
            }else{
                 mapChanges.put(field.toUpperCase(), False);
            }
        }
        
       
        
        system.debug('mapChanges: '+ mapChanges);
    }
    
    Private List<String> getFieldsForRecodeType(){
        List<String> fieldsList = new List<String>();
        fieldsList.add('ASI_eForm_Account_Type_Requested__c');
        fieldsList.add('ASI_eForm_Address_City__c');
        fieldsList.add('ASI_eForm_Address_Country__c');
        fieldsList.add('ASI_eForm_Address_Line_1__c');
        fieldsList.add('ASI_eForm_Address_Line_2__c');
        fieldsList.add('ASI_eForm_Address_Line_3__c');
        fieldsList.add('ASI_eForm_Address_Postal_Code__c');
        fieldsList.add('ASI_eForm_Bank__c');
        fieldsList.add('ASI_eForm_Bank_Account_No__c');
        fieldsList.add('ASI_eForm_Bank_Address__c');
        fieldsList.add('ASI_eForm_Bank_Code__c');
        fieldsList.add('ASI_eForm_Bank_Country__c');
        fieldsList.add('ASI_eForm_Bank_Currency__c');
        fieldsList.add('ASI_eForm_Banks_Name__c');
        fieldsList.add('ASI_eForm_Beneficiary_Name__c');
        fieldsList.add('ASI_eForm_BR_Certificate_no__c');
        fieldsList.add('ASI_eForm_Create_Vendor_Account__c');
        fieldsList.add('ASI_eForm_Credit_Currency__c');
        fieldsList.add('ASI_eForm_Credit_Hold_Option__c');
        fieldsList.add('ASI_eForm_Credit_Limit__c');
        fieldsList.add('ASI_eForm_Customer_Name__c');
        fieldsList.add('ASI_eForm_Customer_Type_Channel__c');
        fieldsList.add('ASI_eForm_Contact_Person_1__c');
        fieldsList.add('ASI_eForm_Default_Credit_Limits__c');
        fieldsList.add('ASI_eForm_Default_Credit_Period__c');
        fieldsList.add('ASI_eForm_Default_Email__c');
        fieldsList.add('ASI_eForm_Exceed_Credit_Limit__c');
        fieldsList.add('ASI_eForm_Exceed_Credit_Period__c');
        fieldsList.add('ASI_eForm_Exceed_Default_Credit_Hold__c');
        fieldsList.add('ASI_eForm_Incro_Terms__c');
        fieldsList.add('ASI_eForm_No_BR__c');
        fieldsList.add('Owner');
        fieldsList.add('ASI_eForm_Payment_Method__c');
        fieldsList.add('ASI_eForm_Payment_Terms__c');
        fieldsList.add('ASI_eForm_Vendor_Freight_Handling_Code__c');
        fieldsList.add('ASI_eForm_Vendor_MFM_Access_CC15__c');
        fieldsList.add('ASI_eForm_Vendor_Payment_Class_Code__c');
        fieldsList.add('ASI_eForm_Vendor_Payment_Method__c');
        fieldsList.add('ASI_eForm_Vendor_Payment_Terms__c');
        fieldsList.add('ASI_eForm_Vendor_Search_Type__c');

       // system.debug('fieldsList::'+ fieldsList);
        return fieldsList;
    }
}