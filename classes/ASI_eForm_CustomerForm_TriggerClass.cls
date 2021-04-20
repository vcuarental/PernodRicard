/***************************************************************************************************************************
* Name: ASI_eForm_CustomerForm_TriggerClass
* Description: 
* Test Class: ASI_eForm_CustomerForm_TriggerClassTest
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-09-24       Hector Tsang	        Created
* 2018-09-27       Fanny Yeung	        	handle trigger for updating SysApprovers, createVendorAccount, updateOriginalCustomerFormField 
* 											while revise form status changed to master revision
* 2019-05-09       Wilken Lee	        	[WL 1.0] INC0082214 Avoid validation error when creating Vendor Form from Customer Form
* 2019-07-02       Wilken Lee	        	[WL 2.0] Add Dummy Customer approval for ATR Customer
* 2020-11-05       PRA CoE                  [CoE 1.0] bypass Cheque in bank information creation.
****************************************************************************************************************************/
public without sharing class ASI_eForm_CustomerForm_TriggerClass {
    //private static constant for trigger class
    private final static String CUSTOMERFORM_RECORD_TYPE_READ_ONLY = 'Read_Only';
    private final static String CUSTOMERFORM_RECORD_TYPE_REVISE = 'Revise';
    private final static String ATTACHMENT_TYPE_BR = 'BR';
    private final static String ATTACHMENT_TYPE_BANK_PROOF = 'Bank Proof';
    private final static String PAYMENT_METHOD = 'Cheque';
    private final static String EFORM_TYPE ='Customer Form';
    private final static String PRHKM = 'PRHKM';
    private final static String PRATR = 'PRATR';
    private final static String PRAFF = 'Affiliate';
    
    private final static String PARENT = 'Parent';
    private final static String MASTER_REVISE = 'Completed_Master_Revision';
    
    private final static Integer NUMBER_OF_SYS_APPROVER = 8;
    
    public static void routineBeforeInsert(list<ASI_eForm_Customer_Form__c> trigger_new) {
        if(trigger_new.size()>0){
            changeSysApprovers(trigger_new);
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_eForm_Customer_Form__c> trigger_new,Map<id, ASI_eForm_Customer_Form__c> trigger_oldMap) {
        
        List<ASI_eForm_Customer_Form__c> approvedCustomerFormList = new List<ASI_eForm_Customer_Form__c>();
        
        for (ASI_eForm_Customer_Form__c newCustForm : trigger_new){//new map
            ASI_eForm_Customer_Form__c oldCustForm =  trigger_oldMap.get(newCustForm.Id); //get old approval status
            //owner changed or defined fields changed
            if(newCustForm.OwnerId != oldCustForm.OwnerId || newCustForm.ASI_eForm_CC14_KAM__c != oldCustForm.ASI_eForm_CC14_KAM__c || 
               newCustForm.ASI_eForm_CC17_TR_Asia_Business_Unit__c != oldCustForm.ASI_eForm_CC17_TR_Asia_Business_Unit__c ||
               newCustForm.ASI_eForm_Is_Exceed_Default_Credit_Terms__c != oldCustForm.ASI_eForm_Is_Exceed_Default_Credit_Terms__c ||
               newCustForm.ASI_eForm_Create_Vendor_Account__c != oldCustForm.ASI_eForm_Create_Vendor_Account__c	||
               newCustForm.ASI_eForm_Is_Dummy_Customer__c != oldCustForm.ASI_eForm_Is_Dummy_Customer__c //WL 2.0
              ){
                  approvedCustomerFormList.add(newCustForm);
              }
        }
        
        if(approvedCustomerFormList.size()>0){
            changeSysApprovers(approvedCustomerFormList);
        }
        
    }
    @TestVisible
    private static void changeSysApprovers(List<ASI_eForm_Customer_Form__c> approvedCustomerFormList){
        Id ownerIdList;
        String userCompList = '';
        String cc14 = '';
        String cc17 = '';
        Boolean createVendorAccount ;
        Boolean isExceedLimitList ;
        String recordType = '';
        String lineManager = '';
        Boolean isDummyCustomer; //WL 2.0
        
        for (ASI_eForm_Customer_Form__c newCustForm : approvedCustomerFormList){//new map
            ownerIdList = newCustForm.OwnerId;
            cc14 = newCustForm.ASI_eForm_CC14_KAM__c;
            cc17 = newCustForm.ASI_eForm_CC17_TR_Asia_Business_Unit__c;
            isExceedLimitList= newCustForm.ASI_eForm_Is_Exceed_Default_Credit_Terms__c;
            createVendorAccount= newCustForm.ASI_eForm_Create_Vendor_Account__c;
            isDummyCustomer = newCustForm.ASI_eForm_Is_Dummy_Customer__c; //WL 2.0
            
            if (Global_RecordTypeCache.getRt(newCustForm.recordTypeid).developerName.contains(PRHKM)  ){
                recordType = PRHKM;
            }else if (Global_RecordTypeCache.getRt(newCustForm.recordTypeid).developerName.contains(PRATR)){
                recordType = PRATR;
            }else if(Global_RecordTypeCache.getRt(newCustForm.recordTypeid).developerName.contains(PRAFF)){
                recordType = PRAFF;
            }
        }
        
        List<User> cnUserL=[select id,CompanyName,ASI_Department__c,ManagerId from user where id =:ownerIdList];
        
        for(User u : cnUserL){
            userCompList = u.CompanyName;
            lineManager = u.ManagerId;
        }
        List<ASI_eForm_Route_Type__c> routeTypes = new List<ASI_eForm_Route_Type__c>();
        if(recordType == PRHKM){
            routeTypes = [SELECT ID, Name,ASI_eForm_Company__c, ASI_eForm_Department__c,
                          ASI_eForm_Form_Type__c,ASI_eForm_Sys_Approver_Count__c, 
                          (SELECT ASI_eForm_Approver__c, ASI_eForm_Note__c 
                           FROM ASI_eForm_Route_Rule_Details__r)
                          FROM ASI_eForm_Route_Type__c
                          WHERE ASI_eForm_Company__c =: userCompList
                          AND ASI_eForm_Form_Type__c =: EFORM_TYPE
                          AND ASI_eForm_Is_Exceed_Default_Credit_Terms__c =: isExceedLimitList
                          AND ASI_eForm_Create_Vendor_Account__c =: createVendorAccount];
        }
        else if(recordType == PRATR){
            /*[WL 2.0] BEGIN*/
            if (isDummyCustomer){
                routeTypes = [SELECT ID, Name,ASI_eForm_Company__c, ASI_eForm_Department__c, ASI_eForm_Form_Type__c,ASI_eForm_Sys_Approver_Count__c, (SELECT ASI_eForm_Approver__c FROM ASI_eForm_Route_Rule_Details__r) FROM ASI_eForm_Route_Type__c WHERE ASI_eForm_Company__c =: userCompList AND ASI_eForm_Form_Type__c =: EFORM_TYPE AND ASI_eForm_Is_Dummy_Customer__c = true And ASI_eForm_CC17_TR_Business_Unit_del__c =: cc17];
            }else {
                /*WL 2.0] END*/
                routeTypes = [SELECT ID, Name,ASI_eForm_Company__c, ASI_eForm_Department__c, ASI_eForm_Form_Type__c,ASI_eForm_Sys_Approver_Count__c, (SELECT ASI_eForm_Approver__c FROM ASI_eForm_Route_Rule_Details__r) FROM ASI_eForm_Route_Type__c WHERE ASI_eForm_Company__c =: userCompList AND ASI_eForm_Form_Type__c =: EFORM_TYPE AND ASI_eForm_CC14_KAM__c =: cc14 And ASI_eForm_CC17_TR_Business_Unit_del__c =: cc17];
            }
        }
        
        List<ASI_eForm_Route_Rule_Details__c> approvalList = new List<ASI_eForm_Route_Rule_Details__c>();
        for (ASI_eForm_Route_Type__c routeType : routeTypes){
            for(ASI_eForm_Route_Rule_Details__c detail: routeType.ASI_eForm_Route_Rule_Details__r){
                approvalList.add(detail);
            }
        }
        
        for (ASI_eForm_Customer_Form__c newCustForm : approvedCustomerFormList){
            
            if(recordType == PRATR){
                //clean sys approver
                cleanSysApprovers(newCustForm);
                //insert new sys approver            
                //sys approver 1-8 follow route
                
                integer looping = math.min(approvalList.size(),8);
                for(integer i=0; i< looping; i++){
                    String fieldName = 'ASI_eForm_Sys_Approver_'+ (i+1)+'__c';
                    newCustForm.put(fieldName,approvalList[i].ASI_eForm_Approver__c);//put the sys approvers as many as in the list from route type
                }
            }else if(recordType == PRHKM || recordType == PRAFF){
                //clean sys approver
                cleanSysApprovers(newCustForm);
                
                //insert new sys approver
                //line manager as sys approver 1
                if(String.isNotBlank(lineManager)){
                    newCustForm.put('ASI_eForm_Sys_Approver_1__c',lineManager);
                }
                
                //sys approver 2-8 follow route		
                integer looping = math.min(approvalList.size(),7);
                //TODO: Limit the number of loop to be <= 6 for (i+2) < 9
                for(integer i=0; i< looping; i++){
                    String fieldName = 'ASI_eForm_Sys_Approver_'+ (i+2)+'__c';
                    newCustForm.put(fieldName,approvalList[i].ASI_eForm_Approver__c);//put the sys approvers as many as in the list from route type
                }
            }            
        }
    }
    
    private static void cleanSysApprovers(ASI_eForm_Customer_Form__c newCustForm){
        for(integer i=0; i< NUMBER_OF_SYS_APPROVER; i++){
            String fieldName = 'ASI_eForm_Sys_Approver_'+ (i+1)+'__c';
            newCustForm.put(fieldName,null);
        }
    }
    
    public static void routineAfterUpdate(list<ASI_eForm_Customer_Form__c> trigger_new, Map<id, ASI_eForm_Customer_Form__c> trigger_oldMap) {
        //Identify form only newly approved and approved = Final
        Map<id, ASI_eForm_Customer_Form__c> approvedCustomerFormMap = new Map<id, ASI_eForm_Customer_Form__c>();
        List<ASI_eForm_Customer_Form__c> revisedFinalCustomerFormMap = new List<ASI_eForm_Customer_Form__c>();
        Map<id, ASI_eForm_Customer_Form__c> separateAPCustomerFormMap = new Map<id, ASI_eForm_Customer_Form__c>();
        
        //TODO: Replace meaningless variable c to a more meaningful name like customerForm or newCustomerForm
        //      Also, for List/Map, try to use plural variable name like forms/formList etc.
        for (ASI_eForm_Customer_Form__c newCustForm : trigger_new){//new map
            ASI_eForm_Customer_Form__c oldCustForm =  trigger_oldMap.get(newCustForm.Id); //get old approval status
            //check if record type change to read-only 
            if(Global_RecordTypeCache.getRt(newCustForm.recordTypeid).developerName.contains(CUSTOMERFORM_RECORD_TYPE_READ_ONLY)  && !Global_RecordTypeCache.getRt(oldCustForm.recordTypeid).developerName.contains(CUSTOMERFORM_RECORD_TYPE_READ_ONLY) 
               && newCustForm.ASI_eForm_Parent_Customer_Form__c == null && newCustForm.ASI_eForm_Original_Customer_Form__c == null ) 
            {
                if(newCustForm.ASI_eForm_Create_Vendor_Account__c){
                    //add customer form to approvedCustomerForm
                    approvedCustomerFormMap.put(newCustForm.id,newCustForm);
                }
                //ATR parent and separate acc regional AP is checked
                if( Global_RecordTypeCache.getRt(newCustForm.recordTypeid).developerName.contains(PRATR) &&  newCustForm.ASI_eForm_Separate_Acc_Regional_AP__c){
                    //add customer form to separate regional AP CustomerForm
                    separateAPCustomerFormMap.put(newCustForm.id,newCustForm);
                }
            }
            //is Revise form and status changes to Master
            if(Global_RecordTypeCache.getRt(newCustForm.recordTypeid).developerName.contains(CUSTOMERFORM_RECORD_TYPE_REVISE) && (newCustForm.ASI_eForm_Status__c).contains(MASTER_REVISE) && !(oldCustForm.ASI_eForm_Status__c).contains(MASTER_REVISE)){
                revisedFinalCustomerFormMap.add(newCustForm);
            }
        }	
        
        //Pass to another function to create Vendor Account
        if(approvedCustomerFormMap.size() >0){
            createVendorAccount(approvedCustomerFormMap);
        }
        //Pass to another function to move file attachment
        if(revisedFinalCustomerFormMap.size() >0){
            String orignalCF = revisedFinalCustomerFormMap[0].ASI_eForm_Original_Customer_Form__c;
            List<ASI_eForm_Customer_Form__c> tmp = new List<ASI_eForm_Customer_Form__c>();
            tmp = queryOriginalCustomerForm(' where Id = \'' + orignalCF + '\'');
            if(tmp.size()>0){
                updateOriginalCustomerFormField(revisedFinalCustomerFormMap[0],tmp[0]);
            }
        }
        
        //Pass to another function to clone a customer form
        if(separateAPCustomerFormMap.size() >0){        
            cloneCustomerForm(separateAPCustomerFormMap);
        }
        
    }
    @TestVisible
    private static void createVendorAccount(Map<id, ASI_eForm_Customer_Form__c> approvedCustomerFormList){
        Map<id, ASI_eForm_Vendor_Form__c> vendorFormListMap = new  Map<id, ASI_eForm_Vendor_Form__c>();
        
        for(ASI_eForm_Customer_Form__c form: approvedCustomerFormList.values()){
            // 1. Create and insert Vendor Account
            // TODO: Clean up unwanted code
            ASI_eForm_Vendor_Form__c vendorForm = new ASI_eForm_Vendor_Form__c(
                ASI_eForm_Vendor_Name__c			= form.ASI_eForm_Customer_Name__c,
                ASI_eForm_Address_Line_1__c			= form.ASI_eForm_Address_Line_1__c,
                ASI_eForm_Address_Line_2__c			= form.ASI_eForm_Address_Line_2__c,
                ASI_eForm_Address_Line_3__c			= form.ASI_eForm_Address_Line_3__c,
                ASI_eForm_Contact_Person__c			= form.ASI_eForm_Contact_Person_1__c,
                ASI_eForm_Phone_Fax_1__c   			= 'Phone',
                ASI_eForm_Phone_Fax_2__c			= 'Phone',
                ASI_eForm_Phone_Fax_3__c			= 'Fax',
                ASI_eForm_Prefix_1__c	  			= form.ASI_eForm_Country_Code_1__c,
                ASI_eForm_Prefix_2__c	   			= form.ASI_eForm_Country_Code_2__c,
                ASI_eForm_Prefix_3__c	   			= form.ASI_eForm_Country_Code_fax__c,
                ASI_eForm_Payment_Term__c			= form.ASI_eForm_Vendor_Payment_Terms__c,
                ASI_eForm_Alternate_Payee__c		= 'NO',
                ASI_eForm_MFM_Access__c				= 'YES',
                OwnerId 							= form.OwnerId,
                ASI_eForm_Status__c					= 'Draft',
                ASI_eForm_Search_Type__c			= form.ASI_eForm_Vendor_Search_Type__c,
                ASI_eForm_Country__c				= form.ASI_eForm_Address_Country__c,
                ASI_eForm_Postal_Code__c			= form.ASI_eForm_Address_Postal_Code__c,
                ASI_eForm_Email__c					= form.ASI_eForm_Email_1__c,
                ASI_eForm_Phone_Fax_Number_1__c		= form.ASI_eForm_Phone_Contact_1__c,
                ASI_eForm_Phone_Fax_Number_2__c		= form.ASI_eForm_Phone_Contact_2__c,
                ASI_eForm_Phone_Fax_Number_3__c		= form.ASI_eForm_Fax_Contact__c,
                ASI_eForm_Payment_Method__c 		= form.ASI_eForm_Vendor_Payment_Method__c,
                ASI_eForm_Default_Currency__c		= form.ASI_eForm_Vendor_Currency__c,
                ASI_eForm_Bank_Charges__c			= 'S',
                ASI_eForm_Class_Code__c 			= form.ASI_eForm_Vendor_Payment_Class_Code__c,
                ASI_eForm_Freight_Handling_Code__c	= form.ASI_eForm_Vendor_Freight_Handling_Code__c,
                ASI_eForm_CAT_Code_15__c 			= form.ASI_eForm_Vendor_MFM_Access_CC15__c,
                ASI_eForm_Customer_Form__c			= form.Id,
                RecordTypeId =  Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__c'+'ASI_eForm_HK_Vendor_Form_New')
            );
            
            
            vendorFormListMap.put(form.Id, vendorForm);
        }
        
        if(vendorFormListMap.size() >0){
            insert vendorFormListMap.values();
        }
        // 2. Create Vendor Bank Information and relate to the Vendor Account in 1)
        List<ASI_eForm_Vendor_Form_Line_Item__c> vendorFormLineItemList = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
        for (Id id : vendorFormListMap.keySet()){
            ASI_eForm_Vendor_Form__c vendorForm = vendorFormListMap.get(id);
            ASI_eForm_Customer_Form__c custForm = approvedCustomerFormList.get(id);
            
            /*[WL 1.0] BEGIN*/
            String strBank;//[CoE 1.0]  bypass Cheque 
            if (custForm.ASI_eForm_Vendor_Payment_Method__c != 'Cheque'){
                strBank = custForm.ASI_eForm_Bank__c;
                /*[WL 1.0] END*/
                ASI_eForm_Vendor_Form_Line_Item__c vendorFormLineItem = new ASI_eForm_Vendor_Form_Line_Item__c(
                    ASI_eForm_Vendor_Form__c				=vendorForm.Id,
                    ASI_eForm_Beneficiary_Name__c			=custForm.ASI_eForm_Beneficiary_Name__c,
                    ASI_eForm_Contact_Person__c			=custForm.ASI_eForm_Contact_Person_1__c,
                    ASI_eForm_Contact_Person_Tel_No__c	=custForm.ASI_eForm_Phone_Contact_1__c,
                    ASI_eForm_Email_Address_1__c			=custForm.ASI_eForm_Email_1__c,
                    ASI_eForm_Email_Address_2__c			=custForm.ASI_eForm_Email_2__c,
                    ASI_eForm_Email_Address_3__c			=custForm.ASI_eForm_Email_3__c,
                    ASI_eForm_Bank_A_C_Number__c			=custForm.ASI_eForm_Bank_Account_No__c,
                    ASI_eForm_Bank__c						=strBank,	//WL 1.0
                    ASI_eForm_Bank_Name__c				=custForm.ASI_eForm_Banks_Name__c,
                    ASI_eForm_Bank_Address__c				=custForm.ASI_eForm_Bank_Address__c,
                    ASI_eForm_Contact_Person_Fax_No__c	=custForm.ASI_eForm_Fax_Contact__c,
                    ASI_eForm_Currency__c					=custForm.ASI_eForm_Bank_Currency__c,
                    ASI_eForm_Bank_Country_Code__c		=custForm.ASI_eForm_Bank_Country__c,
                    ASI_eForm_SWIFT_Code__c				=custForm.ASI_eForm_Swift_Code__c,
                    ASI_eForm_IBAN_Code__c				=custForm.ASI_eForm_IBAN_Code__c,
                    ASI_eForm_Bank_Code__c				=custForm.ASI_eForm_Bank_Code__c,
                    RecordTypeId =  Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__c'+'ASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank')
                );
                vendorFormLineItemList.add(vendorFormLineItem);
            }
            
            
            
        }
        
        
        // 3. Create Vendor Attachment and relate to the Vendor Account in 1)
        Map<Id,ASI_eForm_Vendor_Form_Attachment__c> vendorFormAttachmentMap = new Map<Id,ASI_eForm_Vendor_Form_Attachment__c>();      
        
        for (ASI_eForm_Customer_Form_Attachment__c attachment : [SELECT Id,Name, ASI_eForm_Category__c, ASI_eForm_FeedItemId__c,ASI_eForm_File_Ext__c,ASI_eForm_FileId__c,
                                                                 ASI_eForm_File_Name__c,ASI_eForm_File_Size__c,ASI_eForm_Remark__c,ASI_eForm_Customer_Form__c 
                                                                 FROM ASI_eForm_Customer_Form_Attachment__c 
                                                                 WHERE ASI_eForm_Customer_Form__c IN :approvedCustomerFormList.keySet()]) 
        {
            //is BR or Bank Proof(has checked if creating vendor account in the start of trigger)
            ASI_eForm_Customer_Form__c custForm = approvedCustomerFormList.get(attachment.ASI_eForm_Customer_Form__c);
            
            if(attachment.ASI_eForm_Category__c == ATTACHMENT_TYPE_BR || (attachment.ASI_eForm_Category__c == ATTACHMENT_TYPE_BANK_PROOF && custForm.ASI_eForm_Payment_Method__c != PAYMENT_METHOD)){
                ASI_eForm_Vendor_Form__c vendorForm = vendorFormListMap.get(attachment.ASI_eForm_Customer_Form__c);
                ASI_eForm_Vendor_Form_Attachment__c vendorFormAttachment = new ASI_eForm_Vendor_Form_Attachment__c(
                    ASI_eForm_Category__c				=attachment.ASI_eForm_Category__c,
                    ASI_eForm_FeedItemId__c			=attachment.ASI_eForm_FeedItemId__c,
                    ASI_eForm_File_Ext__c				=attachment.ASI_eForm_File_Ext__c,
                    ASI_eForm_FileId__c				=attachment.ASI_eForm_FileId__c,
                    ASI_eForm_File_Name__c			=attachment.ASI_eForm_File_Name__c,
                    ASI_eForm_File_Size__c			=attachment.ASI_eForm_File_Size__c,
                    ASI_eForm_Remark__c				=attachment.ASI_eForm_Remark__c,
                    ASI_eForm_Vendor_Form__c			=vendorForm.Id,
                    RecordTypeId 						=Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Attachment__c'+'ASI_eForm_HK_Vendor_Form_Attachment')
                );
                vendorFormAttachmentMap.put(attachment.Id, vendorFormAttachment);
                
            }
        }
        
        
        // 4. Insert both Vendor Bank Information and Vendor Attachment
        
        if(vendorFormLineItemList.size()>0){
            insert vendorFormLineItemList;
        }
        if(vendorFormAttachmentMap.size()>0){
            insert vendorFormAttachmentMap.values();
            
            //5. Create ContentDocumentLink for file sharing setting and relate to the Vendor Form Attachment in 3)
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            Set<Id> cfAttachmentId = vendorFormAttachmentMap.keySet();
            
            for (ContentDocumentLink documentLink : [ SELECT ContentDocumentID, LinkedEntity.type, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: cfAttachmentId]){
                ASI_eForm_Vendor_Form_Attachment__c vendorAttachmentValue = vendorFormAttachmentMap.get(documentLink.LinkedEntityId);
                ContentDocumentLink cdl = New ContentDocumentLink( LinkedEntityId = vendorAttachmentValue.Id, ContentDocumentId = documentLink.ContentDocumentID, ShareType = 'V');
                cdlList.add(cdl);
            }
            
            if(cdlList.size()>0){
                insert cdlList;
            }
        }
        //6.Change vendor form status to final
        for(ASI_eForm_Vendor_Form__c form: vendorFormListMap.values()){
            form.ASI_eForm_Status__c = 'Final';
        }
        update vendorFormListMap.values();
        
    }    
    @TestVisible
    private static void updateOriginalCustomerFormField(ASI_eForm_Customer_Form__c revisedFinalCustomerForm, ASI_eForm_Customer_Form__c originalCustomerForm){
        List<String> fieldsList = getFieldsForRecodeType(Global_RecordTypeCache.getRt(revisedFinalCustomerForm.recordTypeid).developerName);
        for(String field : fieldsList){
            if(revisedFinalCustomerForm.get(field) != originalCustomerForm.get(field)){
                originalCustomerForm.put(field,revisedFinalCustomerForm.get(field));
            }
        }
        upsert originalCustomerForm;
    }
    @TestVisible
    Private static List<ASI_eForm_Customer_Form__c> queryOriginalCustomerForm(String whereClause){
        Map<String, Schema.SObjectField> vendorForm_FIELD_MAP = Schema.SObjectType.ASI_eForm_Customer_Form__c.fields.getMap();
        String queryStr = 'SELECT ';
        queryStr += String.join(new List<String>(vendorForm_FIELD_MAP.keySet()), ', ');
        queryStr += ' FROM ASI_eForm_Customer_Form__c ';
        queryStr +=  whereClause;
        system.debug('queryStr::'+ queryStr);
        Return database.query(queryStr);
    }
    
    @TestVisible
    Private static List<String> getFieldsForRecodeType(String recordType){
        List<String> fieldsList = new List<String>();
        //common field
        fieldsList.add('ASI_eForm_Search_Type__c');
        fieldsList.add('ASI_eForm_Customer_Number__c');
        fieldsList.add('ASI_eForm_Customer_Name__c');
        fieldsList.add('ASI_eForm_Address_Country__c');
        fieldsList.add('ASI_eForm_Address_City__c');
        fieldsList.add('ASI_eForm_Address_Postal_Code__c');
        fieldsList.add('ASI_eForm_CC03_Sales_Territory_Region__c');
        fieldsList.add('ASI_eForm_Billing_Name__c');
        fieldsList.add('ASI_eForm_Address_Line_1__c');
        fieldsList.add('ASI_eForm_Address_Line_2__c');
        fieldsList.add('ASI_eForm_Address_Line_3__c');
        fieldsList.add('ASI_eForm_Contact_Person_1__c');
        fieldsList.add('ASI_eForm_Title_1__c');
        fieldsList.add('ASI_eForm_Contact_Person_2__c');
        fieldsList.add('ASI_eForm_Title_2__c');
        fieldsList.add('ASI_eForm_Contact_Person_3__c');
        fieldsList.add('ASI_eForm_Title_3__c');
        fieldsList.add('ASI_eForm_Phone_Contact_1__c');
        fieldsList.add('ASI_eForm_Country_Code_fax__c');
        fieldsList.add('ASI_eForm_Phone_Contact_2__c');
        fieldsList.add('ASI_eForm_Country_Code_2__c');
        fieldsList.add('ASI_eForm_Phone_Contact_3__c');
        fieldsList.add('ASI_eForm_Country_Code_3__c');
        fieldsList.add('ASI_eForm_Fax_Contact__c');
        fieldsList.add('ASI_eForm_Country_Code_1__c');
        fieldsList.add('ASI_eForm_Default_Email__c');
        fieldsList.add('ASI_eForm_No_BR__c');
        fieldsList.add('ASI_eForm_BR_Certificate_no__c');
        
        
        if(recordType.contains(PRHKM) || recordType.contains(PRAFF) ){
            fieldsList.add('ASI_eForm_Account_Type_Requested__c');
            fieldsList.add('ASI_eForm_Customer_Type_Channel__c');
            fieldsList.add('ASI_eForm_CC10_Customer_Type__c');
            fieldsList.add('ASI_eForm_Default_Credit_Limits__c');
            fieldsList.add('ASI_eForm_Default_Credit_Period__c');
            fieldsList.add('ASI_eForm_Payment_Method__c');
            fieldsList.add('ASI_eForm_Credit_Hold_Option__c');
            fieldsList.add('ASI_eForm_Credit_Currency__c');
            fieldsList.add('ASI_eForm_Estimate_Avg_Monthly_Sales__c');
            fieldsList.add('ASI_eForm_Exceed_Credit_Limit__c');
            fieldsList.add('ASI_eForm_Exceed_Credit_Period__c');
            fieldsList.add('ASI_eForm_Exceed_Default_Credit_Hold__c');
            fieldsList.add('ASI_eForm_CC07_Outlet_Type__c');
            fieldsList.add('ASI_eForm_CC08_Channel_of_Distribution__c');
            fieldsList.add('ASI_eForm_CC08_Channel_of_Distribution__c');
            fieldsList.add('ASI_eForm_CC25_Channel__c');
            fieldsList.add('ASI_eForm_CC01_AR_Branch__c');
            fieldsList.add('ASI_eForm_CC12_Country_Offtake__c');
            fieldsList.add('ASI_eForm_CC13_Market_SCA__c');
            fieldsList.add('ASI_eForm_CC15_MFM_Access__c');
            fieldsList.add('ASI_eForm_CC06_MKT_Resp__c');
            fieldsList.add('ASI_eForm_CC09_AR_Co__c');
            fieldsList.add('ASI_eForm_CC26_Regional_Key_Account__c');
            fieldsList.add('ASI_eForm_CC27_CCC_Location__c');
            fieldsList.add('ASI_eForm_CC28_License_Type__c');
            fieldsList.add('ASI_eForm_CC28_License_Type__c');
        }else if(recordType.contains(PRATR)){
            fieldsList.add('ASI_eForm_Separate_Acc_Regional_AP__c');
            fieldsList.add('ASI_eForm_Separate_A_P_Account_for_Child__c');
            fieldsList.add('ASI_eForm_Paying_Customer_Different__c');
            fieldsList.add('ASI_eForm_Paying_Customer__c');
            fieldsList.add('ASI_eForm_Handled_by_Agent__c');
            fieldsList.add('ASI_eForm_Agent__c');
            fieldsList.add('ASI_eForm_Credit_Limit__c');
            fieldsList.add('ASI_eForm_Payment_Terms__c');
            fieldsList.add('ASI_eForm_Incro_Terms__c');
            fieldsList.add('ASI_eForm_Payment_Method__c');
            fieldsList.add('ASI_eForm_Credit_Currency__c');
            fieldsList.add('ASI_eForm_Credit_Hold_Option__c');
            fieldsList.add('ASI_eForm_Account_Type_Requested__c');
            fieldsList.add('ASI_eForm_CC10_Category_of_Customer__c');
            fieldsList.add('ASI_eForm_CC15_MFM_Access__c');
            fieldsList.add('ASI_eForm_CC17_TR_Asia_Business_Unit__c');
            fieldsList.add('ASI_eForm_CC19_Old_PL_Market__c');
            fieldsList.add('ASI_eForm_CC21_Channel_Group__c');
            fieldsList.add('ASI_eForm_CC29_Market__c');
            fieldsList.add('ASI_eForm_Salesman_Commission_Code__c');
            fieldsList.add('ASI_eForm_Salesman_Commission_Name__c');
            fieldsList.add('ASI_eForm_CC01_AR_Branch__c');
            fieldsList.add('ASI_eForm_CC02_AR_Salesman__c');
            fieldsList.add('ASI_eForm_CC04_DFDP__c');
            fieldsList.add('ASI_eForm_CC06_MKT_Resp__c');
            fieldsList.add('ASI_eForm_CC07_Outlet_Type__c');
            fieldsList.add('ASI_eForm_CC09_AR_Co__c');
            fieldsList.add('ASI_eForm_CC11_GDF_Customer__c');
            fieldsList.add('ASI_eForm_CC12_Country_Offtake__c');
            fieldsList.add('ASI_eForm_CC13_Market_SCA__c');
            fieldsList.add('ASI_eForm_CC14_KAM__c');
            fieldsList.add('ASI_eForm_CC16_Offtake__c');	
            fieldsList.add('ASI_eForm_Email_2__c');
            fieldsList.add('ASI_eForm_e_Statement_for_Email_2__c');
        }
        if(recordType.contains(PARENT)){
            fieldsList.add('ASI_eForm_Email_1__c');
            fieldsList.add('ASI_eForm_e_Statement_for_Email_1__c');
            fieldsList.add('ASI_eForm_Email_3__c');
            fieldsList.add('ASI_eForm_e_Statement_for_Email_3__c');
            fieldsList.add('ASI_eForm_Email_4__c');
            fieldsList.add('ASI_eForm_e_Statement_for_Email_4__c');
            fieldsList.add('ASI_eForm_Email_5__c');
            fieldsList.add('ASI_eForm_e_Statement_for_Email_5__c');
        }
        return fieldsList;
    }
    @TestVisible
    private static void cloneCustomerForm(Map<id, ASI_eForm_Customer_Form__c> originalCustomerFormList){
        List<ASI_eForm_Customer_Form__c> newSeparateCustomerFormList = new List<ASI_eForm_Customer_Form__c>();
        for(ASI_eForm_Customer_Form__c originalForm : originalCustomerFormList.values()){
            //Cloning the original Customer Form
            ASI_eForm_Customer_Form__c newSeparateCustomerForm = originalForm.clone(false, false, false, false);
            newSeparateCustomerForm.ASI_eForm_Status__c = 'Final';
            newSeparateCustomerForm.ASI_eForm_Is_Regional_AP_Account__c = True;
            newSeparateCustomerForm.ASI_eForm_Separate_Acc_Regional_AP__c = False;
            newSeparateCustomerForm.ASI_eForm_CC15_MFM_Access__c = '203';
            newSeparateCustomerFormList.add(newSeparateCustomerForm);
        }
        if(newSeparateCustomerFormList.size() >0){
            insert newSeparateCustomerFormList;
        }
    }
    
}