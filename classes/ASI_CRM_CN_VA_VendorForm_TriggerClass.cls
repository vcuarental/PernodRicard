/*****************************************************************************************************************
 * Name:        ASI_CRM_CN_VA_VendorForm_TriggerClass       
 * Test Class:  ASI_CRM_CN_VA_VendorForm_TriggerTest
 * Description: CN Vendor Form Trigger Class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-02-26       Sera Liao               Create
 *****************************************************************************************************************/
public without sharing class ASI_CRM_CN_VA_VendorForm_TriggerClass {
    
    Private Static Final Map<String, Schema.SObjectField> FIX_APPROVAL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form__c.fields.getMap();
    Private Static Map<String, ASI_CRM_Fix_Approval_Route__c> fixApprovalRouteMap = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
    Private Static Map<String, ASI_CRM_Dynamic_Approval_Route__c> dynamicApprovalRouteMap = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
    Private Static Final Id FIX_APPROVAL_RT = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route');
    Private Static Final String FIX_APPROVAL_TYPE_NEW = 'Vendor Form - New';
    Private Static Final String FIX_APPROVAL_TYPE_REVISE = 'Vendor Form - Revise';
        
    Private Static Final Id NEW_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_CRM_CN_VA_Vendor_Form_New');
    Private Static Final Id NEW_VENDOR_FORM_RO_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_CRM_CN_VA_Vendor_Form_New_Read_Only');
    Private Static Final Id REVISE_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_CRM_CN_VA_Vendor_Form_Revise');
    Private Static Final Id REVISE_VENDOR_FORM_RO_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_CRM_CN_VA_Vendor_Form_Revise_Read_Only');
    Private Static Final Id BP_KEY_DATA_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_CRM_CN_VA_Vendor_Form_BP_Key_Data');
    Private Static Final Id ANNEX_1_VENDOR_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_CRM_CN_VA_Vendor_Form_Annex_1_Vendor');
        
    Private Static Final String STATUS_DRAFT = 'Draft';
    Private Static Final String STATUS_APPROVED = 'Approved';
    Private Static Final String ANNUAL_BUSINESS_TRANSACTION_VALUE_2M = '>= RMB 2 million';
    Private Static Final String INTERFACE_WITH_PUBLIC_OFFICIALS = 'Yes';
    Private Static Final String TYPE_VENDOR_FORM = 'Vendor Form';

    Private Static User currentUser = [SELECT Id, Name, BypassTriggers__c FROM User WHERE Id = :userInfo.getUserId()];
    Private Static Map<Id, User> mapUser = new Map<Id, User>([SELECT ID, ManagerId FROM User WHERE CompanyName = 'Pernod Ricard China']); 
    
    public Static void beforeInsertFunction(List<ASI_eForm_Vendor_Form__c> triggerNew){
        if(String.isBlank(currentUser.BypassTriggers__c) || 
            !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_CRM_CN_VA_VendorForm_TriggerClass')){
            getFixApprovalRouteMap();
            getDynamicApprovalRouteMap();
            for(ASI_eForm_Vendor_Form__c vendorForm : triggerNew){
                if(vendorForm.RecordTypeId == NEW_VENDOR_FORM_RT 
                    || vendorForm.RecordTypeId == REVISE_VENDOR_FORM_RT){
                    vendorForm.ASI_eForm_Status__c = STATUS_DRAFT;
                    if(vendorForm.RecordTypeId == NEW_VENDOR_FORM_RT){
                        if(String.isNotBlank(vendorForm.ASI_CRM_CN_VA_Vendor_Code__c) 
                            && vendorForm.ASI_CRM_CN_VA_Effective__c){
                            vendorForm.ASI_eForm_Status__c = STATUS_APPROVED;
                        }
                    }
                    if((vendorForm.RecordTypeId == NEW_VENDOR_FORM_RT || vendorForm.RecordTypeId == NEW_VENDOR_FORM_RO_RT)
                      && String.isNotBlank(vendorForm.ASI_CRM_CN_VA_Company_Name__c)){
                        vendorForm.ASI_CRM_CN_VA_External_ID__c = 'New-' + vendorForm.ASI_CRM_CN_VA_Company_Name__c;
                    }
                    if(fixApprovalRouteMap.containsKey('' + (vendorForm.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE))){
                        setApproverToNull(vendorForm);
                        setApprover(vendorForm, fixApprovalRouteMap.get('' + (vendorForm.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE))); 
                    }
                }
            }
        }
    }

    public Static void beforeUpdateFunction(List<ASI_eForm_Vendor_Form__c> newList,Map<Id,ASI_eForm_Vendor_Form__c> oldMap){
        if(String.isBlank(currentUser.BypassTriggers__c) || 
            !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_CRM_CN_VA_VendorForm_TriggerClass')){
            getFixApprovalRouteMap();
            getDynamicApprovalRouteMap();
            for(ASI_eForm_Vendor_Form__c newVF : newList){
                ASI_eForm_Vendor_Form__c oldVF = oldMap.get(newVF.Id);
                if(newVF.RecordTypeId == NEW_VENDOR_FORM_RT
                    || newVF.RecordTypeId == NEW_VENDOR_FORM_RO_RT 
                    || newVF.RecordTypeId == REVISE_VENDOR_FORM_RT
                    || newVF.RecordTypeId == REVISE_VENDOR_FORM_RO_RT){
                    if(newVF.OwnerId != oldVF.OwnerId 
                        || newVF.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c != oldVF.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c){
                        if(fixApprovalRouteMap.containsKey('' + (newVF.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE))){
                            setApproverToNull(newVF);
                            setApprover(newVF, fixApprovalRouteMap.get('' + (newVF.RecordTypeId == NEW_VENDOR_FORM_RT ? FIX_APPROVAL_TYPE_NEW : FIX_APPROVAL_TYPE_REVISE))); 
                        }
                    }
                    if((newVF.RecordTypeId == NEW_VENDOR_FORM_RT || newVF.RecordTypeId == NEW_VENDOR_FORM_RO_RT)){
                      if(newVF.ASI_eForm_Status__c == 'Approved' 
                        && newVF.ASI_CRM_CN_VA_Effective__c == false){
                        newVF.ASI_CRM_CN_VA_Effective__c = true;
                      }
                      if(newVF.ASI_CRM_CN_VA_Company_Name__c != oldVF.ASI_CRM_CN_VA_Company_Name__c
                        && String.isNotBlank(newVF.ASI_CRM_CN_VA_Company_Name__c)){
                        newVF.ASI_CRM_CN_VA_External_ID__c = 'New-' + newVF.ASI_CRM_CN_VA_Company_Name__c;
                      }
                    }
                }
            }
        }
    }

    public Static void afterInsertFunction(List<ASI_eForm_Vendor_Form__c> triggerNew){
        if(String.isBlank(currentUser.BypassTriggers__c) || 
            !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_CRM_CN_VA_VendorForm_TriggerClass')){
            
            Set<String> bpKeyDataAddedRelatedVFIds = new Set<String>();
            Set<String> bpKeyDataRequiredRelatedVFIds = new Set<String>();
            Set<String> annex1VendorAddedRelatedVFIds = new Set<String>();

            for(ASI_eForm_Vendor_Form__c vendorForm : triggerNew){
                if(vendorForm.RecordTypeId == BP_KEY_DATA_RT&&vendorForm.ASI_CRM_CN_VA_Related_Vendor_Form__c!=null){
                    bpKeyDataAddedRelatedVFIds.add(vendorForm.ASI_CRM_CN_VA_Related_Vendor_Form__c);
                    if(vendorForm.ASI_CRM_CN_VA_BP_A3__c == ANNUAL_BUSINESS_TRANSACTION_VALUE_2M
                        || vendorForm.ASI_CRM_CN_VA_BP_A4__c == INTERFACE_WITH_PUBLIC_OFFICIALS){
                        bpKeyDataRequiredRelatedVFIds.add(vendorForm.ASI_CRM_CN_VA_Related_Vendor_Form__c);
                    }
                }

                if(vendorForm.RecordTypeId == ANNEX_1_VENDOR_RT&&vendorForm.ASI_CRM_CN_VA_Related_Vendor_Form__c!=null){
                    annex1VendorAddedRelatedVFIds.add(vendorForm.ASI_CRM_CN_VA_Related_Vendor_Form__c);
                }
            }
            List<ASI_eForm_Vendor_Form__c> updateVFList = new List<ASI_eForm_Vendor_Form__c>();
            if(bpKeyDataAddedRelatedVFIds.size() > 0){
                for(String relatedVFId : bpKeyDataAddedRelatedVFIds){
                    ASI_eForm_Vendor_Form__c updateVF = new ASI_eForm_Vendor_Form__c();
                    updateVF.Id = relatedVFId;
                    updateVF.ASI_CRM_CN_VA_BP_Key_Data_Is_Added__c = true;
                    
                    if (bpKeyDataRequiredRelatedVFIds.size() > 0 
                        && bpKeyDataRequiredRelatedVFIds.contains(relatedVFId)){
                        updateVF.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c = true;
                    }
            
                    updateVFList.add(updateVF);
                }
            }
            if(annex1VendorAddedRelatedVFIds.size() > 0){
                for(String relatedVFId : annex1VendorAddedRelatedVFIds){
                    ASI_eForm_Vendor_Form__c updateVF = new ASI_eForm_Vendor_Form__c(
                        Id = relatedVFId,
                        ASI_CRM_CN_VA_Annex_1_Vendor_Is_Added__c = true);
                    updateVFList.add(updateVF);
                }
            }
            if(updateVFList.size() > 0){
                update updateVFList;
            }
        }
    }

    /*
     *Lg_One:Find the corresponding Account through Vendor Code 
            and update the ASI_TH_CRM_Supplier__c、Name、ASI_LUX_Email_Business__c
     *L_Two:The value of ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c field 
            in the ASI_CRM_CN_VA_Related_Vendor_Form__c record should be 
            updated according to the ASI_CRM_CN_VA_BP_A3__c and ASI_CRM_CN_VA_BP_A4__c fields
     * 
    */
    public static void afterUpdateFunction(List<ASI_eForm_Vendor_Form__c> newList,Map<Id,ASI_eForm_Vendor_Form__c> oldMap){
      if(String.isBlank(currentUser.BypassTriggers__c) || 
            !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_CRM_CN_VA_VendorForm_TriggerClass')){
        Map<String,ASI_eForm_Vendor_Form__c> mapVendorCodeVF = new Map<String,ASI_eForm_Vendor_Form__c>();
        List<Account> updateAccList = new List<Account>();
        Set<String> vendorCodeSet = new Set<String>();
        Set<String> bpKeyDataAddedRelatedVFIds = new Set<String>();
        Set<String> bpKeyDataRequiredRelatedVFIds = new Set<String>();
        for(ASI_eForm_Vendor_Form__c vForm:newList){
          ASI_eForm_Vendor_Form__c vForm_Old = oldMap.get(vForm.id);
          RecordType vForm_Recordtype =Global_RecordTypeCache.getRt(vForm.recordtypeid);
          if((vForm.ASI_CRM_CN_VA_Vendor_Code__c != vForm_Old.ASI_CRM_CN_VA_Vendor_Code__c ||
              vForm.ASI_eForm_Status__c != vForm_Old.ASI_eForm_Status__c)
              &&vForm.ASI_CRM_CN_VA_Vendor_Code__c != null
              &&vForm.ASI_eForm_Status__c == 'Approved'
            &&(vForm_Recordtype.DeveloperName=='ASI_CRM_CN_VA_Vendor_Form_New'
                ||vForm_Recordtype.DeveloperName=='ASI_CRM_CN_VA_Vendor_Form_New_Read_Only'
                ||vForm_Recordtype.DeveloperName=='ASI_CRM_CN_VA_Vendor_Form_Revise'
                ||vForm_Recordtype.DeveloperName=='ASI_CRM_CN_VA_Vendor_Form_Revise_Read_Only'
              )
            ){
              vendorCodeSet.add(vForm.ASI_CRM_CN_VA_Vendor_Code__c);
              mapVendorCodeVF.put(vForm.ASI_CRM_CN_VA_Vendor_Code__c,vForm);
          }
          if(vForm.RecordTypeId == BP_KEY_DATA_RT
             &&(vForm.ASI_CRM_CN_VA_BP_A3__c!=vForm_Old.ASI_CRM_CN_VA_BP_A3__c
                ||vForm.ASI_CRM_CN_VA_BP_A4__c!=vForm_Old.ASI_CRM_CN_VA_BP_A4__c
               )
            ){
              bpKeyDataAddedRelatedVFIds.add(vForm.ASI_CRM_CN_VA_Related_Vendor_Form__c);
              if(vForm.ASI_CRM_CN_VA_BP_A3__c==ANNUAL_BUSINESS_TRANSACTION_VALUE_2M
                 ||vForm.ASI_CRM_CN_VA_BP_A4__c==INTERFACE_WITH_PUBLIC_OFFICIALS
              ){
                bpKeyDataRequiredRelatedVFIds.add(vForm.ASI_CRM_CN_VA_Related_Vendor_Form__c);
              }
          }
        }
        if(vendorCodeSet.size()>0){
          List<Account> accList = [SELECT id,Name,
                                        ASI_TH_CRM_Supplier__c,
                                        ASI_LUX_Email_Business__c,
                                        ASI_MFM_Customer_Supplier_Number__c
                                FROM Account 
                                WHERE ASI_MFM_Customer_Supplier_Number__c in:vendorCodeSet
                                AND RecordType.DeveloperName in ('ASI_MFM_CN_Supplier',
                                                                  'ASI_CRM_CN_Supplier',
                                                                  'ASI_MFM_CN_Structure_Cost_Supplier'
                                                                )
                                ];
          for(Account acc:accList){
            if(mapVendorCodeVF.containskey(acc.ASI_MFM_Customer_Supplier_Number__c)){
              ASI_eForm_Vendor_Form__c vF= mapVendorCodeVF.get(acc.ASI_MFM_Customer_Supplier_Number__c);
              if(acc.Name!=vF.ASI_CRM_CN_VA_Company_Name__c
                ||acc.ASI_TH_CRM_Supplier__c!=vF.ASI_CRM_CN_VA_Vendor_Form_A2__c
                ||acc.ASI_LUX_Email_Business__c!=vF.ASI_CRM_CN_VA_Vendor_Form_A1__c){
                  Account accInstance = new Account();
                  accInstance.id = acc.id;
                  if(acc.Name!=vF.ASI_CRM_CN_VA_Company_Name__c
                    &&vF.ASI_CRM_CN_VA_Company_Name__c!=null){
                    accInstance.Name = vF.ASI_CRM_CN_VA_Company_Name__c;
                  }
                  if(acc.ASI_TH_CRM_Supplier__c!=vF.ASI_CRM_CN_VA_Vendor_Form_A2__c
                    &&vF.ASI_CRM_CN_VA_Vendor_Form_A2__c!=null){
                    accInstance.ASI_TH_CRM_Supplier__c = vF.ASI_CRM_CN_VA_Vendor_Form_A2__c;
                  }
                  if(acc.ASI_LUX_Email_Business__c!=vF.ASI_CRM_CN_VA_Vendor_Form_A1__c
                    &&vF.ASI_CRM_CN_VA_Vendor_Form_A1__c!=null){
                    accInstance.ASI_LUX_Email_Business__c = vF.ASI_CRM_CN_VA_Vendor_Form_A1__c;
                  }
                  updateAccList.add(accInstance);
              }
            }
          }
          if(updateAccList.size()>0)update updateAccList;
        }
        if(bpKeyDataAddedRelatedVFIds.size()>0){
          List<ASI_eForm_Vendor_Form__c> updateVFList = new List<ASI_eForm_Vendor_Form__c>();
          for(String relatedVFId : bpKeyDataAddedRelatedVFIds){
            ASI_eForm_Vendor_Form__c updateVF = new ASI_eForm_Vendor_Form__c();
            updateVF.Id = relatedVFId;
            updateVF.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c = false;
            
            if (bpKeyDataRequiredRelatedVFIds.size() > 0 
                && bpKeyDataRequiredRelatedVFIds.contains(relatedVFId)){
                updateVF.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c = true;
            }
    
            updateVFList.add(updateVF);
          }
          if(updateVFList.size()>0)update updateVFList;
        }
      }
    }
    /*
     *Lg_One:When the recordType is ASI_CRM_CN_VA_Vendor_Form_BP_Key_Data 
             and ASI_CRM_CN_VA_Vendor_Form_Annex_1_Vendor, the ASI_CRM_CN_VA_BP_Key_Data_Is_Added__c 
             and ASI_CRM_CN_VA_Annex_1_Vendor_Is_Added__c fields of ASI_CRM_CN_VA_Related_Vendor_Form__c 
             record need to be updated when deleted
     * 
     * 
    */
    public static void beforeDeleteFunction(List<ASI_eForm_Vendor_Form__c> oldList){
      if(String.isBlank(currentUser.BypassTriggers__c) || 
         !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_CRM_CN_VA_VendorForm_TriggerClass')){
        Map<Id,ASI_eForm_Vendor_Form__c> bpKeyOrAnnex1RelatedVFIdsMap = new Map<Id,ASI_eForm_Vendor_Form__c>();
        for(ASI_eForm_Vendor_Form__c oldVForm:oldList){
          if(oldVForm.ASI_CRM_CN_VA_Related_Vendor_Form__c!=null
             &&(
                oldVForm.RecordTypeId == BP_KEY_DATA_RT||oldVForm.RecordTypeId == ANNEX_1_VENDOR_RT
               )
            ){
            if(bpKeyOrAnnex1RelatedVFIdsMap.containskey(oldVForm.ASI_CRM_CN_VA_Related_Vendor_Form__c)){
              ASI_eForm_Vendor_Form__c vendorForm = bpKeyOrAnnex1RelatedVFIdsMap.get(oldVForm.ASI_CRM_CN_VA_Related_Vendor_Form__c);
              if(oldVForm.RecordTypeId == BP_KEY_DATA_RT){
                vendorForm.ASI_CRM_CN_VA_BP_Key_Data_Is_Added__c = false;
                vendorForm.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c = false;
              }
              if(oldVForm.RecordTypeId == ANNEX_1_VENDOR_RT)vendorForm.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Added__c = false;
            }else{
              ASI_eForm_Vendor_Form__c vendorForm = new ASI_eForm_Vendor_Form__c();
              vendorForm.id = oldVForm.ASI_CRM_CN_VA_Related_Vendor_Form__c;
              if(oldVForm.RecordTypeId == BP_KEY_DATA_RT){
                vendorForm.ASI_CRM_CN_VA_BP_Key_Data_Is_Added__c = false;
                vendorForm.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c = false;
              }
              if(oldVForm.RecordTypeId == ANNEX_1_VENDOR_RT)vendorForm.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Added__c = false;
              bpKeyOrAnnex1RelatedVFIdsMap.put(oldVForm.ASI_CRM_CN_VA_Related_Vendor_Form__c,vendorForm);
            }
          }
        }
        if(bpKeyOrAnnex1RelatedVFIdsMap.size()>0)update bpKeyOrAnnex1RelatedVFIdsMap.values();
      }
    }

    Private static void getDynamicApprovalRouteMap(){
        List<ASI_CRM_Dynamic_Approval_Route__c> dynamicApprovalList =
                                                            [SELECT Id,
                                                             ASI_CRM_End_of_Dynamic_Route__c,
                                                             ASI_CRM_User__c,
                                                             ASI_CRM_Type__c,
                                                             ASI_CRM_Approval_Limit__c,
                                                             ASI_CRM_Manager_ID__c 
                                                            FROM ASI_CRM_Dynamic_Approval_Route__c
                                                            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')
                                                            AND ASI_CRM_Type__c = :TYPE_VENDOR_FORM];
        for(ASI_CRM_Dynamic_Approval_Route__c dynamicApprova : dynamicApprovalList){
            dynamicApprovalRouteMap.put(dynamicApprova.ASI_CRM_User__c, dynamicApprova);
        }
    }

    Private static void getFixApprovalRouteMap(){
            
        if(fixApprovalRouteMap.size() == 0){
            
            fixApprovalRouteMap = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
            for(ASI_CRM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FIX_APPROVAL_FIELD_MAP, 'WHERE ASI_CRM_CN_Type__c LIKE \'' + TYPE_VENDOR_FORM + '%\'' + ' AND RecordTypeId = \'' + FIX_APPROVAL_RT + '\'')){
               
                fixApprovalRouteMap.put('' + obj.ASI_CRM_CN_Type__c, obj);
            }
        }
    }

    Private Static void setApproverToNull(ASI_eForm_Vendor_Form__c vendorForm){
            
        setApproverToNullDetail(vendorForm, 'asi_eform_sys_approver_');
        setApproverToNullDetail(vendorForm, 'asi_crm_cn_va_sys_approver_');
    }

    Private Static void setApproverToNullDetail(ASI_eForm_Vendor_Form__c vendorForm, String sysApproverField){
            
        Integer i = 1;
        String sysApprover = sysApproverField + i + '__c';
        
        While(VENDOR_FORM_FIELD_MAP.containsKey(sysApprover)){
            
            vendorForm.put(sysApprover, null);
            
            i++;
            sysApprover = sysApproverField + i + '__c';
        }
    }

    Private Static void setApprover(ASI_eForm_Vendor_Form__c vendorForm, ASI_CRM_Fix_Approval_Route__c fixApproval){
        
        Set<String> approverSet = new Set<String>();
        if(mapUser.containsKey(vendorForm.OwnerId) 
            && mapUser.get(vendorForm.OwnerId).ManagerId != null){
            approverSet.add(mapUser.get(vendorForm.OwnerId).ManagerId);
        }

        setDynamicApprover(vendorForm, approverSet);
        
        setFixedApprover(vendorForm, fixApproval, 'asi_crm_cn_approver_', approverSet);

        Integer approverCount = 1;
        for(String approver : approverSet){
            if(approverCount == approverSet.size()){
                String sysApprover = 'asi_crm_cn_va_sys_approver_12__c';
                vendorForm.put(sysApprover, approver);
            }else if(approverCount == approverSet.size() - 1){
                String sysApprover = 'asi_crm_cn_va_sys_approver_11__c';
                vendorForm.put(sysApprover, approver);
            }else{
                if(approverCount <= 8){
                    String sysApprover = 'asi_eform_sys_approver_' + approverCount + '__c';
                    vendorForm.put(sysApprover, approver);
                }else{
                    String sysApprover = 'asi_crm_cn_va_sys_approver_' + approverCount + '__c';
                    if(VENDOR_FORM_FIELD_MAP.containsKey(sysApprover)){
                        vendorForm.put(sysApprover, approver);
                    }
                }
            }
            approverCount ++;
        }
    }

    Private static void setFixedApprover(ASI_eForm_Vendor_Form__c vendorForm, ASI_CRM_Fix_Approval_Route__c fixApproval, String fixApprovalField, Set<String> approverSet){
        Integer fixApprovalCount = 1;
        
        String fixApprover = fixApprovalField + fixApprovalCount + '__c';

        While(FIX_APPROVAL_FIELD_MAP.containsKey(fixApprover)){
            
            if(fixApproval.get(fixApprover) == Null 
                || (fixApproval.get(fixApprover) != Null 
                    && approverSet.contains((String)fixApproval.get(fixApprover)))){
                
                fixApprovalCount ++;
                fixApprover = fixApprovalField + fixApprovalCount + '__c';
                continue;
            }
            if(fixApprovalCount == 1){
                vendorForm.ASI_CRM_CN_VA_Legal_Person__c = (Id)fixApproval.get(fixApprover);
                if(vendorForm.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Required__c){
                    approverSet.add((String)fixApproval.get(fixApprover));
                }
            }else{
                approverSet.add((String)fixApproval.get(fixApprover));
            }
             
            fixApprovalCount ++;
            fixApprover = fixApprovalField + fixApprovalCount + '__c';
        }
    }

    Private static void setDynamicApprover(ASI_eForm_Vendor_Form__c vendorForm, Set<String> approverSet){
        Id approverId;
    
        if(mapUser.containsKey(vendorForm.OwnerId) 
            && mapUser.get(vendorForm.OwnerId).ManagerId != null){
            approverId = mapUser.get(vendorForm.OwnerId).ManagerId;
        }
        if(dynamicApprovalRouteMap.size() > 0){
            if(vendorForm.RecordTypeId == NEW_VENDOR_FORM_RT){
                for(Integer i = 1; i <= 50; i++){
                    if(dynamicApprovalRouteMap.containsKey(approverId)){
                        // While(dynamicApprovalRouteMap.containsKey(approverId)){
                            if(!dynamicApprovalRouteMap.get(approverId).ASI_CRM_End_of_Dynamic_Route__c){
                                if(!approverSet.contains(approverId)){
                                    approverSet.add(approverId);
                                }
                                if(approverId != NULL 
                                    && mapUser.containsKey(approverId) 
                                    && mapUser.containsKey(mapUser.get(approverId).ManagerId)){
                                    approverId = mapUser.get(approverId).ManagerId;
                                }else{
                                    break;
                                }
                            }else{
                                if(!approverSet.contains(approverId)){
                                    approverSet.add(approverId);
                                }
                                break;
                            }
                        // }
                    }else if(approverId != NULL 
                            && mapUser.containsKey(approverId) 
                            && mapUser.containsKey(mapUser.get(approverId).ManagerId)){
                        approverId = mapUser.get(approverId).ManagerId;
                    }else{
                        break;
                    }
                }
            }else if(vendorForm.RecordTypeId == REVISE_VENDOR_FORM_RT){
                if(!approverSet.contains(approverId) 
                  && String.isNotBlank(approverId)){
                    approverSet.add(approverId);
                }
            }
        }
    }

    Private Static List<ASI_CRM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
        
        String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_CRM_Fix_Approval_Route__c ' + whereClause;
        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_CRM_Fix_Approval_Route__c>) Database.query(query);
        return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_CRM_Fix_Approval_Route__c>();
    }
    
    Private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}