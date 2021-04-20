/***************************************************************************************************************************
 * Name: ASI_eForm_HK_VendorForm_TriggerClass
 * Description: 
 * Test Class: ASI_eForm_HK_VendorForm_TriggerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-28    Wilken Lee        [WL 1.0] INC0075088 Update Address Book Master checkbox for ETL 
 * 2019-06-11    Wilken Lee        [WL 2.0] INC0087486 Query last sync vendor form for cloning during revision
 * 2019-08-26    Wilken Lee        [WL 3.0] INC0097419 Bug fix to ensure only 1 revise vendor form can be created at any time
 * 2019-08-27    Wilken Lee        [WL 4.0] INC0097606 Enhancement to cater different approvers for China Duty Free and China Finance SSC users
 ****************************************************************************************************************************/
public without sharing class ASI_eForm_HK_VendorForm_TriggerClass {
        
        Private Static Final Map<String, Schema.SObjectField> FIX_APPROVAL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
        Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form__c.fields.getMap();
        Private Static Final Map<String, Schema.SObjectField> VENDORFORMLINE_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form_Line_Item__c.fields.getMap();
        
        Private Static Final String JDECODE_CANNOT_FOUND = 'Vendor number ({0}) not exist, please submit HK Vendor Form-New';
        Private Static Final String HAS_ONGOING_VENDORFORM = 'Vendor number ({0}) already exist and is in the process of creation';
        Private Static Final String NO_JDE_AND_VENDOR_FORM = 'Please input either Vendor Number or Vendor Form Number';
        Private Static Final String CONNECTED_WITH_OTHER_VENDOR = 'Alternate payee ({0}[{1}]) already exist in other vendor master.';
        Private Static Final String IS_PAYEE = 'Vendor ({0}[{1}]) already exist in other vendor master';
        Private Static Final String HAS_PAYEE = 'Alternate payee ({0}[{1}]) already exist in other vendor master.';
        Private Static Final String BLOCK_DELETE = 'You are NOT allowed to delete vendor form.';
        Private Static Final String VENDOR_NUMBER_ERROR_MSG = 'Vendor number for "{0}" is {1}.';
        Private Static Final String DUPLICATED_VENDOR_NUMBER_FOUND = 'Vendor number already exist, please submit HK Vendor Form-Revise for any changes.';
        Private Static Final String VENDOR_NUMBER_NO_SAME = 'Please input either vendor number or vendor form number.'; //ISSUE-20181112
        Private Static Final String EXISTING_OUTSTANDING_FORM = 'Existing Vendor Revision Form {0} of {1} status created by {2} is outstanding. Please complete this revision first'; //WL 3.0
        Private Static boolean INPUT_ORG_VENDOR_FORM = false; //ISSUE-20181112
        
        
        Private Static Final String STATUS_BU_APPROVED_PENDING_MASTER_CREATION = 'BU Approved, Pending Master Creation';
        Private Static Final String STATUS_COMPLETED_MASTER_CREATION = 'Completed Master Creation';
        Private Static Final String STATUS_ARCHIVED = 'Archived';
        Private Static Final String STATUS_DRAFT = 'Draft';
        Private Static Final String SEARCH_TYPE_A = 'A';
        Private Static Final String FIX_APPROVAL_TYPE_NEW = 'Vendor Form - New';
        Private Static Final String FIX_APPROVAL_TYPE_REVISE = 'Vendor Form - Revise';
        
        Private Static Final Id NEW_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_New');
        Private Static Final Id NEW_VENDOR_FORM_READONLY_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_New_RO');
        Private Static Final Id REVISE_VENDOR_FORM_STEP_ONE_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Revise_Step_1');
        Private Static Final Id REVISE_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Revise');
        Private Static Final Id ARCHIVED_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Archived');
        Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank');
        Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RT_RO = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank_RO');
        Private Static Final Id VENDOR_FORM_LINE_OTHER_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Other_Bank');
        Private Static Final Id VENDOR_FORM_LINE_OTHER_BANK_RT_RO = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Other_Bank_RO');
        Private Static Final Id FIX_APPROVAL_RT = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_eForm_HK_Fix_Approval');
        
        Private Static Map<String, String> mapClassCode = new Map<String, String>();
        Private Static Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixApprovalRoute = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
        
        Private Static Set<Id> isConvertingSet = new Set<Id>();
        
        Private Static User currentUser = [SELECT Id, Name, BypassTriggers__c FROM User WHERE Id = : userInfo.getUserId()];
        
        Private Static List<ASI_eForm_Vendor_Form__c> existingVendorFormList = new List<ASI_eForm_Vendor_Form__c>();
        Private Static List<ASI_eForm_HK_MetaData__mdt> eFromMetaData = new List<ASI_eForm_HK_MetaData__mdt>([SELECT Id
                                                                                                              , ASI_eForm_Search_Type__c
                                                                                                              , ASI_eForm_Class_Code__c
                                                                                                              , ASI_eForm_User_Department__c 
                                                                                                              FROM ASI_eForm_HK_MetaData__mdt 
                                                                                                              WHERE ASI_eForm_Type__c LIKE 'Vendor Form']);
        
        //--------------// Before Insert Function //--------------//
        
        Public Static void beforeInsertFunction(List<ASI_eForm_Vendor_Form__c> triggerNew){
            
            if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorForm_TriggerClass')){
                
                Set<String> JDECodeSet = new Set<String>();
                Set<String> existingVendorFormId = new Set<String>();
                Set<Id> ownerSetId = new Set<Id>();
                
                Map<Id, String> mapJDECodeByVendorFormId = new Map<Id, String>();
                
                String whereClause = '';
                
                for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                    
                    ownerSetId.add(obj.OwnerId);
                    
                    if(obj.recordTypeId == REVISE_VENDOR_FORM_STEP_ONE_RT){
                        if(String.isBlank(obj.ASI_eForm_JDE_AB_Code__c) && obj.ASI_eForm_Original_Vendor_Form__c == Null){                            
                            obj.addError(NO_JDE_AND_VENDOR_FORM);                            
                        }
                        //ISSUE-20181112
                        String orgVendorNumber = '';
                        if(obj.ASI_eForm_Original_Vendor_Form__c != Null){                            
                            existingVendorFormId.add(obj.ASI_eForm_Original_Vendor_Form__c);
                            
                             //user input wrong vendor number
                            List<ASI_eForm_Vendor_Form__c> srcVendor = new List<ASI_eForm_Vendor_Form__c>([SELECT ASI_eForm_JDE_AB_Code__c FROM ASI_eForm_Vendor_Form__c WHERE ID=:obj.ASI_eForm_Original_Vendor_Form__c]);
                            
                            if(srcVendor.size() > 0 && !String.isBlank(srcVendor.get(0).ASI_eForm_JDE_AB_Code__c)) {
                                JDECodeSet.add(srcVendor.get(0).ASI_eForm_JDE_AB_Code__c.toLowerCase());
                                orgVendorNumber = srcVendor.get(0).ASI_eForm_JDE_AB_Code__c.toLowerCase();
                            }
                        }
                        //ISSUE-20181112
                         if(!String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){     
                            /*[WL 3.0] BEGIN*/
                            List<ASI_eForm_Vendor_Form__c> existingPendingVF = [SELECT ID, Name, ASI_eForm_Status__c, Owner.FirstName, Owner.LastName FROM ASI_eForm_Vendor_Form__c WHERE ASI_eForm_JDE_AB_Code__c = :obj.ASI_eForm_JDE_AB_Code__c.toLowerCase() 
                                                                                AND ASI_eForm_Status__c IN ('Draft', 'Submitted','BU Approved, Pending Master Creation') AND recordType.DeveloperName LIKE 'ASI_eForm_HK_Vendor_Form_Revise%'];
                            if (existingPendingVF.size() > 0){
                                String ownerName = existingPendingVF.get(0).Owner.FirstName + ' ' + existingPendingVF.get(0).Owner.LastName;
                                obj.addError(String.format(EXISTING_OUTSTANDING_FORM, new List<String>{existingPendingVF.get(0).Name, existingPendingVF.get(0).ASI_eForm_Status__c, ownerName}));
                            }
                            /*[WL 3.0] END*/
                            
                            JDECodeSet.add(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase());
                             
                            if(!String.isBlank(orgVendorNumber) && obj.ASI_eForm_JDE_AB_Code__c.toLowerCase()!= orgVendorNumber)  {
                                  obj.addError(VENDOR_NUMBER_NO_SAME);
                            }                             
                         } 
                         else {
                            INPUT_ORG_VENDOR_FORM = true;
                         }
                        
                    }else if(obj.recordTypeId == NEW_VENDOR_FORM_RT){
                        
                        if(obj.ASI_eForm_Search_Type__c == SEARCH_TYPE_A && String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){
                            
                            obj.ASI_eForm_JDE_AB_Code__c.addError(String.format(VENDOR_NUMBER_ERROR_MSG, new List<String>{obj.ASI_eForm_Search_Type__c, 'required'}));
                            
                        }else if(obj.ASI_eForm_Search_Type__c != SEARCH_TYPE_A && !String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){
                            
                            obj.ASI_eForm_JDE_AB_Code__c.addError(String.format(VENDOR_NUMBER_ERROR_MSG, new List<String>{obj.ASI_eForm_Search_Type__c, 'not required'}));
                            
                        }else if(!String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){
                            
                            JDECodeSet.add(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase());
                        }
                    }
                }
                
                if(JDECodeSet.size() > 0 || existingVendorFormId.size() > 0){
                    //WL 2.0 Added Limit 1 so that when Revise, it will only use the latest Sync Date form to clone
                    whereClause = ' WHERE (ASI_eForm_JDE_AB_Code__c IN : {0} OR Id IN : {1}) AND RecordType.DeveloperName Like \'\'ASI_eForm_HK_Vendor_Form%\'\' AND RecordTypeId != \'\'' + ARCHIVED_VENDOR_FORM_RT + '\'\' Order By ASI_eForm_Last_Sync_Date__c DESC NULLS LAST LIMIT 1';
                    
                    existingVendorFormList = queryLastVendorForm(JDECodeSet, existingVendorFormId, new Set<String>(), triggerNew, whereClause);
                    
                    Set<String> duplicatedJDECode = new Set<String>();
                    
                    for(ASI_eForm_Vendor_Form__c obj : existingVendorFormList){
                        
                        mapJDECodeByVendorFormId.put(obj.id, obj.ASI_eForm_JDE_AB_Code__c);
                        duplicatedJDECode.add(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase());
                    }
                    
                    for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                        
                        if(obj.recordTypeId == REVISE_VENDOR_FORM_STEP_ONE_RT){
                            
                            if(obj.ASI_eForm_Original_Vendor_Form__c != Null && mapJDECodeByVendorFormId.containsKey(obj.ASI_eForm_Original_Vendor_Form__c)){
                                
                                obj.ASI_eForm_JDE_AB_Code__c = mapJDECodeByVendorFormId.get(obj.ASI_eForm_Original_Vendor_Form__c);
                            }
                        }else if(obj.recordTypeId == NEW_VENDOR_FORM_RT){
                            
                            if(!String.isBlank(obj.ASI_eForm_JDE_AB_Code__c) && duplicatedJDECode.contains(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase()) && obj.ASI_eForm_Search_Type__c == SEARCH_TYPE_A){
                                
                                obj.ASI_eForm_JDE_AB_Code__c.addError(DUPLICATED_VENDOR_NUMBER_FOUND);
                            }
                        }
                    }
                }
                
                Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Department, ManagerId, CompanyName, ASI_Company_Name__c FROM User WHERE Id IN : ownerSetId]);
                createFixApprovalMap();
                
                for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                    if(userMap.containsKey(obj.ownerId) 
                       && !String.isBlank(userMap.get(obj.ownerId).CompanyName)
                       && mapFixApprovalRoute.containsKey('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase()) 
                      ){
                        setApproverToNull(obj);
                          
                        /*[WL 4.0] BEGIN*/
                        //If User's Department has specific route type
                        if (mapFixApprovalRoute.get('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase() + userMap.get(obj.ownerId).Department.toLowerCase()) != null){
                            setApprover(obj, mapFixApprovalRoute.get('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase() + userMap.get(obj.ownerId).Department.toLowerCase()), userMap.get(obj.ownerId)); 
                        }
                        else{   //Company level approval
                            setApprover(obj, mapFixApprovalRoute.get('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase()), userMap.get(obj.ownerId)); 
                        }
                        /*[WL 4.0] END*/
                      }
                }
            }
        }
        
        //--------------// Before Delete Function //--------------//
        
        Public Static void beforeDeleteFunction(List<ASI_eForm_Vendor_Form__c> triggerOld){
            
            if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorForm_TriggerClass')){
                Set<Id> deleteSet = new Set<Id>();
                
                for(ASI_eForm_Vendor_Form__c obj : triggerOld){
                    
                    if(!String.isBlank(obj.ASI_eForm_Status__c) && !obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_DRAFT)){
                        
                        obj.addError(BLOCK_DELETE);
                        
                    }else{
                        
                        deleteSet.add(obj.Id);
                    }
                }
                
                if(deleteSet.size() > 0){
                    List<ASI_eForm_Vendor_Form__c> archivedFormList = new List<ASI_eForm_Vendor_Form__c>([SELECT id, ASI_eForm_Status__c FROM ASI_eForm_Vendor_Form__c WHERE ASI_eForm_Related_Vendor_From__c IN : deleteSet AND RecordTypeId = : ARCHIVED_VENDOR_FORM_RT]);
                    
                    for(ASI_eForm_Vendor_Form__c obj : archivedFormList){
                        obj.ASI_eForm_Status__c = STATUS_DRAFT;
                    }
                    
                    Update archivedFormList;
                    Delete archivedFormList;
                }
            }
        }
        
        //--------------// Before Update Function //--------------//
        
        Public Static void beforeUpdateFunction(List<ASI_eForm_Vendor_Form__c> triggerNew, Map<Id, ASI_eForm_Vendor_Form__c> triggerNewMap, Map<Id, ASI_eForm_Vendor_Form__c> triggerOldMap){
  System.debug('mark debug 232');                 
            if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorForm_TriggerClass')){
                Map<Id, User> userMap = new Map<Id, User>();
                Map<Id, ASI_eForm_Vendor_Form__c> mapClonedVendorForm = new Map<Id, ASI_eForm_Vendor_Form__c>();
                Map<Id, ASI_eForm_Vendor_Form_Line_Item__c> mapClonedVendorFormLine = new Map<Id, ASI_eForm_Vendor_Form_Line_Item__c>();
                Map<Id, ASI_eForm_Vendor_Form__c> mapVendorForm = new Map<Id, ASI_eForm_Vendor_Form__c>();
                Map<Id, ASI_eForm_Vendor_Form__c> mapAlternatePayee = new Map<Id, ASI_eForm_Vendor_Form__c>();
                
                Set<Id> ownerSetId = new Set<Id>();
                Set<String> alternatePayeeSet = new Set<String>();
                Set<String> vendorFormIdSet = new Set<String>();
                Set<String> allId = new Set<String>();
                Set<String> allJDECodeSet = new Set<String>();
                Set<String> duplicatedJDECodeSet = new Set<String>();
                
                createMetaDataMap();
                createFixApprovalMap();
System.debug('mark debug 249');                 
                for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                    
                    if(obj.recordTypeId == NEW_VENDOR_FORM_RT){
                        
                        if(!String.isBlank(obj.ASI_eForm_Status__c) && obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_DRAFT)){
                            if(obj.ASI_eForm_Search_Type__c == SEARCH_TYPE_A && String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){
                                
                                obj.ASI_eForm_JDE_AB_Code__c.addError(String.format(VENDOR_NUMBER_ERROR_MSG, new List<String>{obj.ASI_eForm_Search_Type__c, 'input'}));
                                
                            }else if(obj.ASI_eForm_Search_Type__c != SEARCH_TYPE_A && !String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){
                                
                                obj.ASI_eForm_JDE_AB_Code__c.addError(String.format(VENDOR_NUMBER_ERROR_MSG, new List<String>{obj.ASI_eForm_Search_Type__c, 'remove'}));
                                
                            }else if(!String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){
                                
                                allJDECodeSet.add(obj.ASI_eForm_JDE_AB_Code__c);
                            }
                        }
                    }
                    
                    if(obj.ASI_eForm_Original_Vendor_Form__c != Null)
                        obj.ASI_eForm_Original_Vendor_Form__c = Null;
                    
                    if(obj.ASI_eForm_Alternate_Payee_Lookup__c != Null && obj.ASI_eForm_Alternate_Payee_Lookup__c != triggerOldMap.get(obj.id).ASI_eForm_Alternate_Payee_Lookup__c){
                        alternatePayeeSet.add(obj.ASI_eForm_Alternate_Payee_Lookup__c);
                        vendorFormIdSet.add(obj.id);
                        
                        allId.add(obj.ASI_eForm_Alternate_Payee_Lookup__c);
                        allId.add(obj.id);
                    }
                    
                    if(obj.ASI_eForm_Alternate_Payee_Lookup__c != Null){
                        if(mapAlternatePayee.containsKey(obj.ASI_eForm_Alternate_Payee_Lookup__c) && mapAlternatePayee.get(obj.ASI_eForm_Alternate_Payee_Lookup__c).ASI_eForm_JDE_AB_Code__c != obj.ASI_eForm_JDE_AB_Code__c){
                            obj.addError(String.format(CONNECTED_WITH_OTHER_VENDOR, new List<String>{mapAlternatePayee.get(obj.ASI_eForm_Alternate_Payee_Lookup__c).ASI_eForm_Vendor_Name__c, mapAlternatePayee.get(obj.ASI_eForm_Alternate_Payee_Lookup__c).ASI_eForm_JDE_AB_Code__c}));
                        }
                        
                        mapAlternatePayee.put(obj.ASI_eForm_Alternate_Payee_Lookup__c, obj);
                    }
                    
                    ownerSetId.add(obj.ownerId);
                }
                
                for(ASI_eForm_Vendor_Form__c vf : queryLastVendorForm(allId, alternatePayeeSet, allJDECodeSet, triggerNew, ' WHERE ((recordTypeId = \'\'' + NEW_VENDOR_FORM_RT + '\'\' OR recordTypeId = \'\'' + NEW_VENDOR_FORM_READONLY_RT + '\'\') AND ASI_eForm_JDE_AB_Code__c IN : {2} AND (NOT Id IN : {3})) OR (recordTypeId != \'\'' + ARCHIVED_VENDOR_FORM_RT + '\'\' AND (( ASI_eForm_Alternate_Payee_Lookup__c IN : {0} ) OR (Id IN : {1}))) OR (Id IN : {3} AND recordTypeId = \'\'' + REVISE_VENDOR_FORM_RT + '\'\') OR (ASI_eForm_Clone_From_Orginal__c = True AND ASI_eForm_Related_Vendor_From__c IN : {3} AND recordTypeId = \'\'' + ARCHIVED_VENDOR_FORM_RT + '\'\')')){
                    
                    if(!triggerOldMap.containsKey(vf.id) && !String.isBlank(vf.ASI_eForm_JDE_AB_Code__c) && (vf.recordTypeId == NEW_VENDOR_FORM_RT || vf.recordTypeId == NEW_VENDOR_FORM_READONLY_RT)){
                        
                        duplicatedJDECodeSet.add(vf.ASI_eForm_JDE_AB_Code__c.toLowerCase());
                    }
                    
                    if(vendorFormIdSet.contains(vf.ASI_eForm_Alternate_Payee_Lookup__c) || alternatePayeeSet.contains(vf.ASI_eForm_Alternate_Payee_Lookup__c)){
                        
                        if(triggerNewMap.containsKey(vf.ASI_eForm_Alternate_Payee_Lookup__c)){
                            
                            triggerNewMap.get(vf.ASI_eForm_Alternate_Payee_Lookup__c).addError(String.format(IS_PAYEE, new List<String>{vf.ASI_eForm_Vendor_Name__c, vf.ASI_eForm_JDE_AB_Code__c}));
                            
                        }else if(mapAlternatePayee.containsKey(vf.ASI_eForm_Alternate_Payee_Lookup__c) && mapAlternatePayee.get(vf.ASI_eForm_Alternate_Payee_Lookup__c).ASI_eForm_JDE_AB_Code__c != vf.ASI_eForm_JDE_AB_Code__c){
                            
                            mapAlternatePayee.get(vf.ASI_eForm_Alternate_Payee_Lookup__c).ASI_eForm_Alternate_Payee_Lookup__c.addError(String.format(CONNECTED_WITH_OTHER_VENDOR, new List<String>{vf.ASI_eForm_Vendor_Name__c, vf.ASI_eForm_JDE_AB_Code__c}));
                        }
                    }
                    
                    if(alternatePayeeSet.contains(vf.id) && vf.ASI_eForm_Alternate_Payee_Lookup__c != Null){
                        
                        if(mapAlternatePayee.containsKey(vf.id))
                            mapAlternatePayee.get(vf.id).addError(String.format(HAS_PAYEE, new List<String>{vf.ASI_eForm_Vendor_Name__c, vf.ASI_eForm_JDE_AB_Code__c}));
                    }
                    
                    if(vf.ASI_eForm_Clone_From_Orginal__c && vf.recordTypeId == ARCHIVED_VENDOR_FORM_RT){
                        
                        mapClonedVendorForm.put(vf.ASI_eForm_Related_Vendor_From__c, vf);
                        
                        for(ASI_eForm_Vendor_Form_Line_Item__c vfl : vf.Vendor_Form_Line_Items__r){
                            
                            mapClonedVendorFormLine.put(vfl.ASI_eForm_Related_Vendor_From_Line__c, vfl);
                        }
                    }else{
                        mapVendorForm.put(vf.Id, vf);
                    }
                }
                
                userMap = new Map<Id, User>([SELECT Id, Department, ManagerId, CompanyName, ASI_Company_Name__c FROM User WHERE Id IN : ownerSetId]);
                
                for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                    
                    if(!String.isBlank(obj.ASI_eForm_Status__c) && obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_DRAFT)){
                        
                        if(obj.recordTypeId == NEW_VENDOR_FORM_RT || obj.recordTypeId == NEW_VENDOR_FORM_READONLY_RT){
                            
                            if(!String.isBlank(obj.ASI_eForm_JDE_AB_Code__c) && duplicatedJDECodeSet.contains(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase()) && obj.ASI_eForm_Search_Type__c == SEARCH_TYPE_A)
                                obj.ASI_eForm_JDE_AB_Code__c.addError(DUPLICATED_VENDOR_NUMBER_FOUND);
                        }
                        
                        if(obj.ASI_eForm_Alternate_Payee_Lookup__c == Null && triggerOldMap.get(obj.id).ASI_eForm_Alternate_Payee_Lookup__c != Null)
                            obj.ASI_eForm_Alternate_Payee__c = 'NO';
                        else if(obj.ASI_eForm_Alternate_Payee_Lookup__c != Null && triggerOldMap.get(obj.id).ASI_eForm_Alternate_Payee_Lookup__c == Null){
                            obj.ASI_eForm_Alternate_Payee__c = 'YES';
                        }
                        
                        if(mapClonedVendorForm.containsKey(obj.id) && obj.RecordTypeId == REVISE_VENDOR_FORM_RT && !isConvertingSet.contains(obj.id))
                            checkFieldModification(obj, mapVendorForm, mapClonedVendorForm.get(obj.id), mapClonedVendorFormLine);
System.debug('mark debug 350');                         
                        if(userMap.containsKey(obj.ownerId) 
                            && !String.isBlank(userMap.get(obj.ownerId).CompanyName)  
                            && mapFixApprovalRoute.containsKey('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase())){
                              
                              setApproverToNull(obj);
System.debug('mark debug 356');                          
                            /*[WL 4.0] BEGIN*/
                            //If User's Department has specific route type
                            if (mapFixApprovalRoute.get('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase() + userMap.get(obj.ownerId).Department.toLowerCase()) != null){
  System.debug('mark debug 360');   
                                setApprover(obj, mapFixApprovalRoute.get('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase() + userMap.get(obj.ownerId).Department.toLowerCase()), userMap.get(obj.ownerId)); 
                            }
                            else{   //Company level approval
  System.debug('mark debug 364');   
                                setApprover(obj, mapFixApprovalRoute.get('' + (obj.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE) + userMap.get(obj.ownerId).CompanyName.toLowerCase()), userMap.get(obj.ownerId)); 
                            }
                            /*[WL 4.0] END*/
                        }
                        
                        if(obj.recordTypeId == NEW_VENDOR_FORM_RT && String.isBlank(obj.ASI_eForm_Class_Code__c)){
                            if(!String.isBlank(obj.ASI_eForm_Search_Type__c)
                               && mapClassCode.containsKey(obj.ASI_eForm_Search_Type__c.toLowerCase())){
                                   
                                   obj.ASI_eForm_Class_Code__c = mapClassCode.get(obj.ASI_eForm_Search_Type__c.toLowerCase());
                                   
                               }else if(userMap.containsKey(obj.ownerId) && !String.isBlank(userMap.get(obj.ownerId).Department) && mapClassCode.containsKey(userMap.get(obj.ownerId).Department.toLowerCase())){
                                   
                                   obj.ASI_eForm_Class_Code__c = mapClassCode.get(userMap.get(obj.ownerId).Department.toLowerCase());
                               }
                        }
                    }
                }
            }
        }
        
        //--------------// After Insert Function //--------------//
        
        Public Static void afterInsertFunction(List<ASI_eForm_Vendor_Form__c> triggerNew){
            
            if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorForm_TriggerClass')){
                Set<String> JDECodeSet = new Set<String>();
                Set<String> draftJDECodeSet = new Set<String>();
                Set<String> existingVendorFormId = new Set<String>();
                Set<Id> ownerSetId = new Set<Id>();
                
                Map<String, ASI_eForm_Vendor_Form__c> mapVendorFormByJDECode = new Map<String, ASI_eForm_Vendor_Form__c>();
                Map<Id, String> mapJDECodeByVendorFormId = new Map<Id, String>();
                Map<Integer, List<ASI_eForm_Vendor_Form_Line_Item__c>> mapCloneFormLine = new Map<Integer, List<ASI_eForm_Vendor_Form_Line_Item__c>>();
                Map<Integer, List<ASI_eForm_Vendor_Form_Line_Item__c>> mapCurrentFormLine = new Map<Integer, List<ASI_eForm_Vendor_Form_Line_Item__c>>();
                
                List<ASI_eForm_Vendor_Form__c> formToUpdate = new List<ASI_eForm_Vendor_Form__c>();
                List<ASI_eForm_Vendor_Form_Line_Item__c> lineToInsert = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
                
                String whereClause = '';
                
                if(existingVendorFormList.size() > 0){
                    
                    for(ASI_eForm_Vendor_Form__c obj : existingVendorFormList){
                        
                        if(!String.isBlank(obj.ASI_eForm_JDE_AB_Code__c) && !String.isBlank(obj.ASI_eForm_Status__c)){
                            
                            if( 
                                //(obj.recordTypeId == NEW_VENDOR_FORM_RT || obj.recordTypeId == NEW_VENDOR_FORM_READONLY_RT) &&  //[WL 2.0] No need to check for new Vendor Form RT because if there is Revise Form, there must be New Form
                                obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_COMPLETED_MASTER_CREATION)
                                        && !mapVendorFormByJDECode.containsKey(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase())
                              )
                            {
                                mapVendorFormByJDECode.put(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase(), obj);
                            }
                            
                            if(!obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_COMPLETED_MASTER_CREATION)){
                                
                                draftJDECodeSet.add(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase());
                            }
                        }
                    }
                    
                    Integer count = 0;
                    
                    for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                        
                        ownerSetId.add(obj.OwnerId);
                        
                        if(obj.recordTypeId == REVISE_VENDOR_FORM_STEP_ONE_RT){
                            
                            if(!String.isBlank(obj.ASI_eForm_JDE_AB_Code__c)){
                                
                                if(draftJDECodeSet.contains(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase())){
                                    
                                    if(INPUT_ORG_VENDOR_FORM) {//ISSUE-20181112
                                        obj.ASI_eForm_Original_Vendor_Form__c.addError(String.format(HAS_ONGOING_VENDORFORM, new List<String>{obj.ASI_eForm_JDE_AB_Code__c}));
                                    } else {
                                        obj.ASI_eForm_JDE_AB_Code__c.addError(String.format(HAS_ONGOING_VENDORFORM, new List<String>{obj.ASI_eForm_JDE_AB_Code__c}));
                                    }
                                }else if(!mapVendorFormByJDECode.containsKey(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase())){
                                    
                                    obj.ASI_eForm_JDE_AB_Code__c.addError(String.format(JDECODE_CANNOT_FOUND, new List<String>{obj.ASI_eForm_JDE_AB_Code__c}));
                                    
                                }else if(mapVendorFormByJDECode.containsKey(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase())){
                                    
                                    ASI_eForm_Vendor_Form__c originalForm = mapVendorFormByJDECode.get(obj.ASI_eForm_JDE_AB_Code__c.toLowerCase());
                                    
                                    ASI_eForm_Vendor_Form__c tmp = originalForm.clone(false, true, false, false);
                                    ASI_eForm_Vendor_Form__c archiveVersion = originalForm.clone(false, true, false, false);
                                    
                                    tmp.id = obj.id;
                                    tmp.ASI_eForm_Status__c = STATUS_DRAFT;
                                    tmp.RecordTypeId = REVISE_VENDOR_FORM_RT;
                                    tmp.OwnerId = userInfo.getUserId();
                                    tmp.ASI_eForm_Need_Approval__c = False;
                                    tmp.ASI_eForm_Address_Book_Master__c = False;
                                    tmp.ASI_eForm_Bank_Master__c = False;
                                    tmp.ASI_eForm_Email_Master__c = False;
                                    tmp.ASI_eForm_Vendor_Master__c = False;
                                    tmp.ASI_eForm_Last_Sync_Date__c = Null;
                                    tmp.ASI_eForm_Synced_to_JDE__c = False;
                                    
                                    archiveVersion.ASI_eForm_Status__c = STATUS_ARCHIVED;
                                    archiveVersion.RecordTypeId = ARCHIVED_VENDOR_FORM_RT;
                                    archiveVersion.ASI_eForm_Related_Vendor_From__c = tmp.id;
                                    archiveVersion.ASI_eForm_Archived_Time__c = dateTime.now();
                                    archiveVersion.OwnerId = userInfo.getUserId();
                                    archiveVersion.ASI_eForm_Need_Approval__c = False;
                                    archiveVersion.ASI_eForm_Clone_From_Orginal__c = True;
                                    archiveVersion.ASI_eForm_Address_Book_Master__c = False;
                                    archiveVersion.ASI_eForm_Bank_Master__c = False;
                                    archiveVersion.ASI_eForm_Email_Master__c = False;
                                    archiveVersion.ASI_eForm_Vendor_Master__c = False;
                                    archiveVersion.ASI_eForm_Last_Sync_Date__c = Null;
                                    archiveVersion.ASI_eForm_Synced_to_JDE__c = False;
                                    
                                    JDECodeSet.add(originalForm.ASI_eForm_JDE_AB_Code__c.toLowerCase());
                                    
                                    isConvertingSet.add(tmp.id);
                                    formToUpdate.add(tmp);
                                    formToUpdate.add(archiveVersion);
                                    
                                    for(ASI_eForm_Vendor_Form_Line_Item__c line : originalForm.Vendor_Form_Line_Items__r){
                                        
                                        ASI_eForm_Vendor_Form_Line_Item__c tmpLine = line.clone(false, true, false, false);
                                        ASI_eForm_Vendor_Form_Line_Item__c archiveVersionLine = line.clone(false, true, false, false);
                                        
                                        tmpLine.ASI_eForm_Vendor_Form__c = tmp.id;
                                        
                                        if(tmpLine.recordTypeId == VENDOR_FORM_LINE_KEY_BANK_RT_RO)
                                            tmpLine.recordTypeId = VENDOR_FORM_LINE_KEY_BANK_RT;
                                        else if(tmpLine.recordTypeId == VENDOR_FORM_LINE_OTHER_BANK_RT_RO)
                                            tmpLine.recordTypeId = VENDOR_FORM_LINE_OTHER_BANK_RT;
                                        
                                        tmpLine.ASI_eForm_Clone_From_Original__c = True; //This Flag is to indicate which archive version is clone from original form
                                        archiveVersionLine.ASI_eForm_Archived_Version__c = True;
                                        
                                        List<ASI_eForm_Vendor_Form_Line_Item__c> tmpList = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
                                        List<ASI_eForm_Vendor_Form_Line_Item__c> tmpList_CurrentFormLine = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
                                        
                                        if(mapCurrentFormLine.containsKey(count))
                                            tmpList_CurrentFormLine = mapCurrentFormLine.get(count);
                                        
                                        if(mapCloneFormLine.containsKey(count))
                                            tmpList = mapCloneFormLine.get(count);
                                        
                                        tmpList.add(archiveVersionLine);
                                        tmpList_CurrentFormLine.add(tmpLine);
                                        
                                        mapCloneFormLine.put(count, tmpList);
                                        mapCurrentFormLine.put(count, tmpList_CurrentFormLine);
                                        
                                        lineToInsert.add(tmpLine);
                                    }
                                    
                                    count++;
                                }
                            }else{
                                
                                obj.ASI_eForm_JDE_AB_Code__c.addError(String.format(JDECODE_CANNOT_FOUND, new List<String>{obj.ASI_eForm_JDE_AB_Code__c}));
                            }
                        }
                    }
                    
                    try{
                        
                        if(formToUpdate.size() > 0){
                            List<Database.UpsertResult> srList = DataBase.Upsert(formToUpdate);
                            List<Id> creationList = new List<Id>();
                            
                            if(lineToInsert.size() > 0){
                                
                                Insert lineToInsert;
                            }
                            
                            for(Database.UpsertResult sr : srList){
                                if(sr.isCreated() && sr.isSuccess()){
                                    creationList.add(sr.getId());
                                }
                            }
                            
                            List<ASI_eForm_Vendor_Form_Line_Item__c> lineToInsert2 = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
                            
                            if(mapCloneFormLine.keySet().size() > 0){
                                for(Integer num : mapCloneFormLine.keySet()){
                                    
                                    Integer i = 0;
                                    
                                    for(ASI_eForm_Vendor_Form_Line_Item__c line : mapCloneFormLine.get(num)){
                                        
                                        line.ASI_eForm_Vendor_Form__c = creationList[num];
                                        line.ASI_eForm_Related_Vendor_From_Line__c = mapCurrentFormLine.get(num)[i].id;
                                        
                                        lineToInsert2.add(line);
                                        
                                        i++;
                                    }
                                }
                            }
                            
                            if(lineToInsert2.size() > 0){
                                
                                Insert lineToInsert2;
                            }
                        }
                        
                    }catch(dmlException dmle){
                        triggerNew[0].addError(dmle.getMessage());
                    }
                }else{
                    
                    for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                        if(obj.RecordTypeId == REVISE_VENDOR_FORM_STEP_ONE_RT)
                            obj.addError(String.format(JDECODE_CANNOT_FOUND, new List<String>{obj.ASI_eForm_JDE_AB_Code__c}));
                    }
                }
            }
        }
        
        //--------------// After Update Function //--------------//
        
        Public Static void afterUpdateFunction(List<ASI_eForm_Vendor_Form__c> triggerNew, Map<Id, ASI_eForm_Vendor_Form__c> triggerOldMap, Map<Id, ASI_eForm_Vendor_Form__c> triggerNewMap){
            
            if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorForm_TriggerClass')){
                Set<Id> vendorIdSet = new Set<Id>();
                Set<String> allVendorFormIdSet = new Set<String>();
                Set<Id> changedCurrencyForm = new Set<Id>();
                Set<Id> submittedForm = new Set<Id>();
                Set<Id> rejectedForm = new Set<Id>();
                Set<Id> duplicationSet = new Set<Id>();
                
                for(ASI_eForm_Vendor_Form__c obj : triggerNew){
                    
                    if(!String.isBlank(obj.ASI_eForm_Status__c)){
                        
                        if(triggerOldMap.get(obj.id).ASI_eForm_Status__c != obj.ASI_eForm_Status__c && !obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_DRAFT)){
                            submittedForm.add(obj.id);
                            allVendorFormIdSet.add(obj.id);
                        }
                        
                        if(triggerOldMap.get(obj.id).ASI_eForm_Status__c != obj.ASI_eForm_Status__c && obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_DRAFT)){
                            rejectedForm.add(obj.id);
                            allVendorFormIdSet.add(obj.id);
                        }
                        
                        if(((triggerOldMap.get(obj.id).ASI_eForm_Status__c != obj.ASI_eForm_Status__c)
                            || ((obj.RecordTypeId == NEW_VENDOR_FORM_READONLY_RT || obj.RecordTypeId == NEW_VENDOR_FORM_RT) 
                                && obj.ASI_eForm_Last_Sync_Date__c != triggerOldMap.get(obj.id).ASI_eForm_Last_Sync_Date__c))
                           && (obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_BU_APPROVED_PENDING_MASTER_CREATION)
                               || obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_COMPLETED_MASTER_CREATION)))
                        {
                            vendorIdSet.add(obj.id);
                            allVendorFormIdSet.add(obj.id);
                        }
                    }
                    
                    /*if(obj.ASI_eForm_Default_Currency__c != triggerOldMap.get(obj.id).ASI_eForm_Default_Currency__c 
    && obj.ASI_eForm_Status__c.containsIgnoreCase(STATUS_DRAFT)
    && obj.RecordTypeId == NEW_VENDOR_FORM_RT)
    {
    
    changedCurrencyForm.add(obj.id);
    allVendorFormIdSet.add(obj.id);
    }*/
                }
                
                if(allVendorFormIdSet.size() > 0){
                    
                    String whereClause = ' WHERE Id IN : {1}';
                    List<ASI_eForm_Vendor_Form__c> insertVendorFormList = new List<ASI_eForm_Vendor_Form__c>();
                    List<ASI_eForm_Vendor_Form_Line_Item__c> upsertVendorFormLineList = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
                    
                    Map<Integer, List<ASI_eForm_Vendor_Form_Line_Item__c>> mapCloneFormLine = new Map<Integer, List<ASI_eForm_Vendor_Form_Line_Item__c>>();
                    
                    Integer count = 0;
                    
                    for(ASI_eForm_Vendor_Form__c obj : queryLastVendorForm(new Set<String>(), allVendorFormIdSet, new Set<String>(), new List<ASI_eForm_Vendor_Form__c>(), whereClause)){
                        
                        if(vendorIdSet.contains(obj.id)){
                            
                            ASI_eForm_Vendor_Form__c archiveVersion = triggerNewMap.get(obj.id).clone(false, true, false, false);
                            
                            archiveVersion.ASI_eForm_Status__c = STATUS_ARCHIVED;
                            archiveVersion.RecordTypeId = ARCHIVED_VENDOR_FORM_RT;
                            archiveVersion.ASI_eForm_Related_Vendor_From__c = obj.id;
                            archiveVersion.ASI_eForm_Archived_Time__c = dateTime.now();
                            
                            insertVendorFormList.add(archiveVersion);
                        }
                        
                        for(ASI_eForm_Vendor_Form_Line_Item__c line : obj.Vendor_Form_Line_Items__r){
                            
                            if(rejectedForm.contains(obj.id)){
                                
                                if(line.RecordTypeId == VENDOR_FORM_LINE_KEY_BANK_RT_RO){
                                    
                                    line.RecordTypeId = VENDOR_FORM_LINE_KEY_BANK_RT;
                                    upsertVendorFormLineList.add(line);
                                    duplicationSet.add(line.id);
                                }else if(line.RecordTypeId == VENDOR_FORM_LINE_OTHER_BANK_RT_RO){
                                    
                                    line.RecordTypeId = VENDOR_FORM_LINE_OTHER_BANK_RT;
                                    upsertVendorFormLineList.add(line);
                                    duplicationSet.add(line.id);
                                }
                            }else if(submittedForm.contains(obj.id)){
                                
                                if(line.RecordTypeId == VENDOR_FORM_LINE_KEY_BANK_RT){
                                    
                                    line.RecordTypeId = VENDOR_FORM_LINE_KEY_BANK_RT_RO;
                                    upsertVendorFormLineList.add(line);
                                    duplicationSet.add(line.id);
                                }else if(line.RecordTypeId == VENDOR_FORM_LINE_OTHER_BANK_RT){
                                    
                                    line.RecordTypeId = VENDOR_FORM_LINE_OTHER_BANK_RT_RO;
                                    upsertVendorFormLineList.add(line);
                                    duplicationSet.add(line.id);
                                }
                            }
                            
                            /*if(changedCurrencyForm.contains(obj.id) && line.recordTypeId == VENDOR_FORM_LINE_KEY_BANK_RT && !duplicationSet.contains(line.id)){
    
    upsertVendorFormLineList.add(line);
    duplicationSet.add(line.id);
    }*/
                            
                            if(vendorIdSet.contains(obj.id)){
                                
                                ASI_eForm_Vendor_Form_Line_Item__c archiveVersionLine = line.clone(false, true, false, false);
                                archiveVersionLine.ASI_eForm_Related_Vendor_From_Line__c = line.id;
                                archiveVersionLine.ASI_eForm_Archived_Version__c = True;
                                
                                List<ASI_eForm_Vendor_Form_Line_Item__c> tmpList = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
                                
                                if(mapCloneFormLine.containsKey(count))
                                    tmpList = mapCloneFormLine.get(count);
                                
                                tmpList.add(archiveVersionLine);
                                mapCloneFormLine.put(count, tmpList);
                            }
                        }
                    }
                    
                    try{
                        
                        if(insertVendorFormList.size() > 0){
                            List<Database.SaveResult> srList = DataBase.Insert(insertVendorFormList);
                            List<Id> creationList = new List<Id>();
                            
                            for(Database.SaveResult sr : srList){
                                if(sr.isSuccess()){
                                    creationList.add(sr.getId());
                                }
                            }
                            
                            if(mapCloneFormLine.keySet().size() > 0){
                                for(Integer num : mapCloneFormLine.keySet()){
                                    for(ASI_eForm_Vendor_Form_Line_Item__c line : mapCloneFormLine.get(num)){
                                        line.ASI_eForm_Vendor_Form__c = creationList[num];
                                        upsertVendorFormLineList.add(line);
                                    }
                                }
                            }
                        }
                        
                        if(upsertVendorFormLineList.size() > 0){
                            
                            Upsert upsertVendorFormLineList;
                        }
                        
                    }catch(dmlException dmle){
                        triggerNew[0].addError(dmle.getMessage());
                    }
                }
            }
        }
        
        //--------------// Helper Function //--------------//
        
        @TestVisible
        Private Static Void createFixApprovalMap(){
            
            if(mapFixApprovalRoute.size() == 0){
                
                mapFixApprovalRoute = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
                
                for(ASI_CRM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FIX_APPROVAL_FIELD_MAP, 'WHERE ASI_CRM_CN_Type__c LIKE \'Vendor Form%\' AND RecordTypeId = \'' + FIX_APPROVAL_RT + '\'')){
                    /*[WL 4.0] BEGIN*/ //Unique key for Approval Path: "Form Type + Company" or "Form Type + Company + Department"
                    if(!String.isBlank(obj.ASI_MFM_Department__c)){
                        //mapFixApprovalRoute.put('' + obj.ASI_CRM_CN_Type__c + obj.ASI_MFM_Department__c.toLowerCase(), obj);
                        mapFixApprovalRoute.put('' + obj.ASI_CRM_CN_Type__c + obj.ASI_CRM_Company__c.toLowerCase() + obj.ASI_MFM_Department__c.toLowerCase(), obj);
                    }
                    else {
                        mapFixApprovalRoute.put('' + obj.ASI_CRM_CN_Type__c + obj.ASI_CRM_Company__c.toLowerCase(), obj);
                    }
                    /*[WL 4.0] END*/
                }
            }
        }
        
        @TestVisible
        Private Static Void createMetaDataMap(){
            
            mapClassCode = new Map<String, String>();
            
            for(ASI_eForm_HK_MetaData__mdt md : eFromMetaData){
                
                if(!String.isBlank(md.ASI_eForm_Search_Type__c) && md.ASI_eForm_Search_Type__c != 'All')
                    mapClassCode.put(md.ASI_eForm_Search_Type__c.toLowerCase(), md.ASI_eForm_Class_Code__c);
                else if(!String.isBlank(md.ASI_eForm_User_Department__c))
                    mapClassCode.put(md.ASI_eForm_User_Department__c.toLowerCase(), md.ASI_eForm_Class_Code__c);
            }
        }
        
        @TestVisible
        Private Static Void checkFieldModification(ASI_eForm_Vendor_Form__c vendorForm, Map<Id, ASI_eForm_Vendor_Form__c> vendorFormMap, ASI_eForm_Vendor_Form__c snapshotVersion, Map<Id, ASI_eForm_Vendor_Form_Line_Item__c> snapshotVersionLineMap){
            
            vendorForm.ASI_eForm_Need_Approval__c = False;
            vendorForm.ASI_eForm_Bank_Master__c = False;
            vendorForm.ASI_eForm_Vendor_Master__c = False;
            vendorForm.ASI_eForm_Address_Book_Master__c = False;
            vendorForm.ASI_eForm_Email_Master__c = False;
            
            vendorForm.ASI_eForm_CR_Master__c = False;  //CR20180922
    
            if(vendorForm.ASI_eForm_Address_Line_1__c != snapshotVersion.ASI_eForm_Address_Line_1__c
               || vendorForm.ASI_eForm_Address_Line_2__c != snapshotVersion.ASI_eForm_Address_Line_2__c
               || vendorForm.ASI_eForm_Address_Line_3__c != snapshotVersion.ASI_eForm_Address_Line_3__c
               || vendorForm.ASI_eForm_Alternate_Payee_Lookup__c != snapshotVersion.ASI_eForm_Alternate_Payee_Lookup__c
              ){
                  vendorForm.ASI_eForm_Need_Approval__c = True;
                  vendorForm.ASI_eForm_Address_Book_Master__c = True;
              }
            
            if(vendorForm.ASI_eForm_Vendor_Name__c != snapshotVersion.ASI_eForm_Vendor_Name__c
               || vendorForm.ASI_eForm_Payee_Name__c != snapshotVersion.ASI_eForm_Payee_Name__c
              ){
                  vendorForm.ASI_eForm_Need_Approval__c = True;
                  vendorForm.ASI_eForm_CR_Master__c = True;
          vendorForm.ASI_eForm_Address_Book_Master__c = True;  //[WL 1.0]
            }
    
            if(vendorForm.ASI_eForm_Payment_Term__c != snapshotVersion.ASI_eForm_Payment_Term__c
                || vendorForm.ASI_eForm_Email__c != snapshotVersion.ASI_eForm_Email__c
            ){
                
                vendorForm.ASI_eForm_Vendor_Master__c = True;
                vendorForm.ASI_eForm_Need_Approval__c = True;
            }
            
            if(vendorFormMap.containsKey(vendorForm.id)){
    
                if(vendorFormMap.get(vendorForm.id).Vendor_Form_Line_Items__r.size() != snapshotVersion.Vendor_Form_Line_Items__r.size()
                //    || vendorForm.ASI_eForm_Bank_Account_Number_1__c != snapshotVersion.ASI_eForm_Bank_Account_Number_1__c
                ){
                    
                    vendorForm.ASI_eForm_Need_Approval__c = True;
                    vendorForm.ASI_eForm_Bank_Master__c  = True;
                }
                
                for(ASI_eForm_Vendor_Form_Line_Item__c vfl : vendorFormMap.get(vendorForm.id).Vendor_Form_Line_Items__r){
                    
                    if(snapshotVersionLineMap.containsKey(vfl.id)){
                        ASI_eForm_Vendor_Form_Line_Item__c snapshotLine = snapshotVersionLineMap.get(vfl.id);
                        
                        if(vfl.RecordTypeId == VENDOR_FORM_LINE_KEY_BANK_RT){
                            if(vfl.ASI_eForm_Beneficiary_Name_2__c != snapshotLine.ASI_eForm_Beneficiary_Name_2__c
                               || vfl.ASI_eForm_Beneficiary_Name__c != snapshotLine.ASI_eForm_Beneficiary_Name__c
                              ){
                                  vendorForm.ASI_eForm_Need_Approval__c = True;
                                  vendorForm.ASI_eForm_Address_Book_Master__c = True;
                              }
                            
                            if(vfl.ASI_eForm_Email_Address_1__c != snapshotLine.ASI_eForm_Email_Address_1__c
                               || vfl.ASI_eForm_Email_Address_2__c != snapshotLine.ASI_eForm_Email_Address_2__c
                               || vfl.ASI_eForm_Email_Address_3__c != snapshotLine.ASI_eForm_Email_Address_3__c
                              ){
                                  vendorForm.ASI_eForm_Need_Approval__c = True;
                                  vendorForm.ASI_eForm_Email_Master__c = True;
                              }
                        }

                        if(vfl.ASI_eForm_Bank_Code__c != snapshotLine.ASI_eForm_Bank_Code__c
                           //|| vfl.ASI_eForm_Branch__c != snapshotLine.ASI_eForm_Branch__c
                           || vfl.ASI_eForm_Bank_Name__c != snapshotLine.ASI_eForm_Bank_Name__c
                           || vfl.ASI_eForm_Bank_A_C_Number__c != snapshotLine.ASI_eForm_Bank_A_C_Number__c
                           || vfl.ASI_eForm_SWIFT_Code__c != snapshotLine.ASI_eForm_SWIFT_Code__c 
                           || vfl.ASI_eForm_IBAN_Code__c != snapshotLine.ASI_eForm_IBAN_Code__c){
                               
                               vendorForm.ASI_eForm_Need_Approval__c = True;
                               vendorForm.ASI_eForm_Bank_Master__c = True;
                           }
                    }
                }
            }
        }
        
        @TestVisible
        Private Static void setApprover(ASI_eForm_Vendor_Form__c vendorForm, ASI_CRM_Fix_Approval_Route__c fixApproval, User owner){
            
            Integer i = 1;
            Integer j = 1;
            String sysApprover = 'asi_eform_sys_approver_' + i + '__c';
            String fixApprover = 'asi_crm_cn_approver_' + j + '__c';
            
            Set<String> duplicatedApproverSet = new Set<String>();
            
            if(VENDOR_FORM_FIELD_MAP.containsKey(sysApprover)){
                
                if(owner != Null && owner.ManagerId != Null){
                    
                    vendorForm.put(sysApprover, owner.ManagerId);
                    duplicatedApproverSet.add(owner.ManagerId);
                }
                
                i++;
                sysApprover = 'asi_eform_sys_approver_' + i + '__c';
            }
    
            While(VENDOR_FORM_FIELD_MAP.containsKey(sysApprover) && FIX_APPROVAL_FIELD_MAP.containsKey(fixApprover)){
                
                if(vendorForm.get(sysApprover) != Null){
                    
                    i++;
                    sysApprover = 'asi_eform_sys_approver_' + i + '__c';
                    continue;
                }
                
                if(fixApproval.get(fixApprover) == Null || (fixApproval.get(fixApprover) != Null && duplicatedApproverSet.contains(fixApprover))){
                    
                    j++;
                    fixApprover = 'asi_crm_cn_approver_' + j + '__c';
                    continue;
                }
                
                vendorForm.put(sysApprover, fixApproval.get(fixApprover));
                duplicatedApproverSet.add((String)fixApproval.get(fixApprover));
                
                i++;
                sysApprover = 'asi_eform_sys_approver_' + i + '__c';
                
                j++;
                fixApprover = 'asi_crm_cn_approver_' + j + '__c';
            }
        }
        
        @TestVisible
        Private Static void setApproverToNull(ASI_eForm_Vendor_Form__c vendorForm){
            
            Integer i = 1;
            String sysApprover = 'asi_eform_sys_approver_' + i + '__c';
            
            While(VENDOR_FORM_FIELD_MAP.containsKey(sysApprover)){
                
                vendorForm.put(sysApprover, null);
                
                i++;
                sysApprover = 'asi_eform_sys_approver_' + i + '__c';
            }
        }
        
        @TestVisible
        Private Static List<ASI_eForm_Vendor_Form__c> queryLastVendorForm(Set<String> setOne, Set<String> setTwo, Set<String> setThree, List<ASI_eForm_Vendor_Form__c> triggerNew, String whereClause){
            
            List<String> paraList = new List<String>{'setOne', 'setTwo', 'setThree', 'triggerNew'};
                
            String queryStr = 'SELECT ';
            
            queryStr += String.join(new List<String>(VENDOR_FORM_FIELD_MAP.keySet()), ', ');
            
            queryStr += ', (SELECT ';
            
            queryStr += String.join(new List<String>(VENDORFORMLINE_FIELD_MAP.keySet()), ', ');
            
            queryStr += ' FROM Vendor_Form_Line_Items__r ) FROM ASI_eForm_Vendor_Form__c ' + String.format(whereClause, paraList);
            
            System.debug(LoggingLevel.INFO, queryStr);
            Return database.query(queryStr);
            
        }
        
        @TestVisible
        Private Static List<ASI_CRM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
            
            String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_CRM_Fix_Approval_Route__c ' + whereClause;
            
            List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_CRM_Fix_Approval_Route__c>) Database.query(query);
            return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_CRM_Fix_Approval_Route__c>();
        }
        
        @TestVisible
        Private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
            String queryField = '';
            for(String fields : fieldMap.keySet()) {
                queryField += fields + ',';
            }
            return queryField.subString(0, queryField.length() - 1);
        }
    }