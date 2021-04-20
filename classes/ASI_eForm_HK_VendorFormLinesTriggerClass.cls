Public without sharing class ASI_eForm_HK_VendorFormLinesTriggerClass {
    
    Private Static Map<Id, ASI_eForm_Vendor_Form__c> mapVendorForm = new Map<Id, ASI_eForm_Vendor_Form__c>();
    
    Private Static List<ASI_eForm_HK_MetaData__mdt> bankCodeList = new List<ASI_eForm_HK_MetaData__mdt>([SELECT Id, ASI_eForm_Bank_Code__c, ASI_eForm_Bank_Name__c, ASI_eForm_SWIFT_Code__c FROM ASI_eForm_HK_MetaData__mdt WHERE ASI_eForm_Type__c LIKE 'Vendor Form Bank Code Mapping']);
    
    Private Static Final String BLOCK_DELETE = 'You are NOT allowed to delete existing Bank account';
    Private Static Final String BLOCK_CHANGE_CURRENCY = 'You are NOT allowed to change currency for existing bank account.';
    Private Static Final String DUPLICATED_CURRENCY_ERROR_MSG = 'Bank account in {0} already exist, please select other currency';
    Private Static Final String BLOCK_ARCHIVED_FORM_LINE_CREATION = 'You are not allowed to create bank information line for archived form';
    Private Static Final String SWIFT_CODE_MANDATORY = 'Please {1} SWIFT Code for {0}';
    Private Static Final String BANK_NAME_MANDATORY = 'Please {0} Bank Name';
    Private Static Final String BANK_CODE_MANDATORY = 'Please {1} Bank Code for {0}';
    Private Static Final String BANK_ACCOUNT_MANDATORY = 'Please {1} Account Code for Bank({0})';
    Private Static Final String BANK_CODE_MUST_BE_3_DIGIT = 'Bank Code must be 3 digit';
    Private Static Final String BANK_CODE_OR_ACCOUNT_CODE_MANDATORY = 'Please input Bank Code or Account Code';
    
    Private Static Final String KEY_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank');
    Private Static Final String OTHER_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Other_Bank ');
    Private Static Final String ARCHIVED_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Archived');
    Private Static Final Id REVISE_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Revise');
    
    Private Static Final String DRAFT_STATUS = 'Draft';
    Private Static Final String OTHER_BANK = 'Other Bank';
    Private Static Final String COUNTRY_CODE_HK = 'HK-HONG KONG';
    Private Static Final String CURRENCY_CODE_HK = 'HKD-Hong Kong - Hong Kong Dollar';
    
    Private Static User currentUser = [SELECT Id, Name, BypassTriggers__c FROM User WHERE Id = : userInfo.getUserId()];
    
    Public Static void beforeDeleteFunction(List<ASI_eForm_Vendor_Form_Line_Item__c> triggerOld){
        
        if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorFormLinesTriggerClass')){
            for(ASI_eForm_Vendor_Form_Line_Item__c obj : triggerOld){
                if(obj.ASI_eForm_Clone_From_Original__c){
                    obj.addError(BLOCK_DELETE);
                }
            }
        }
    }
    
    Public Static void beforeInsertFunction(List<ASI_eForm_Vendor_Form_Line_Item__c> triggerNew){
        
        if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorFormLinesTriggerClass')){
            Set<Id> vendorFormIdSet = new Set<Id>();
            Set<String> duplicatedSet = new Set<String>();
            
            Map<String, ASI_eForm_HK_MetaData__mdt> mapBankCode = createBankCodeMap();
            
            for(ASI_eForm_Vendor_Form_Line_Item__c obj : triggerNew){
                
                vendorFormIdSet.add(obj.ASI_eForm_Vendor_Form__c);
            }
            
            duplicatedSet = checkDuplicatedCurrency(triggerNew, vendorFormIdSet);
            
            for(ASI_eForm_Vendor_Form_Line_Item__c obj : triggerNew){
                
                if(mapVendorForm.containsKey(obj.ASI_eForm_Vendor_Form__c) && mapVendorForm.get(obj.ASI_eForm_Vendor_Form__c).recordTypeId == ARCHIVED_VENDOR_FORM_RT && !obj.ASI_eForm_Archived_Version__c){
                    
                    obj.addError(BLOCK_ARCHIVED_FORM_LINE_CREATION);
                    
                }else{
                    
                    if(obj.ASI_eForm_Bank__c == OTHER_BANK && obj.ASI_eForm_Bank_Country_Code__c == COUNTRY_CODE_HK && obj.ASI_eForm_Currency__c == CURRENCY_CODE_HK){
                        
                        if(String.isBlank(obj.ASI_eForm_Bank_Name__c))
                            obj.ASI_eForm_Bank_Name__c.addError(String.format(BANK_NAME_MANDATORY, new List<String>{'input'}));
                        
                        if(String.isBlank(obj.ASI_eForm_SWIFT_Code__c))
                            obj.ASI_eForm_SWIFT_Code__c.addError(String.format(SWIFT_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                        
                        if(String.isBlank(obj.ASI_eForm_Bank_Code__c))
                            obj.ASI_eForm_Bank_Code__c.addError(String.format(BANK_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                        else if(obj.ASI_eForm_Bank_Code__c.length() != 3)//20180807 Introv
                        	obj.ASI_eForm_Bank_Code__c.addError(BANK_CODE_MUST_BE_3_DIGIT);
                        
                        //20180807 Introv
                        if(String.isBlank(obj.ASI_eForm_Bank_A_C_Number__c ))
                            obj.ASI_eForm_Bank_A_C_Number__c.addError(String.format(BANK_ACCOUNT_MANDATORY, new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                        
                    }else if(obj.ASI_eForm_Bank__c == OTHER_BANK && String.isBlank(obj.ASI_eForm_IBAN_Code__c) && (obj.ASI_eForm_Bank_Country_Code__c != COUNTRY_CODE_HK || obj.ASI_eForm_Currency__c != CURRENCY_CODE_HK)){
                        
                        if(String.isBlank(obj.ASI_eForm_Bank_Name__c))
                            obj.ASI_eForm_Bank_Name__c.addError(String.format(BANK_NAME_MANDATORY, new List<String>{'input'}));
                        
                        if(String.isBlank(obj.ASI_eForm_SWIFT_Code__c) || String.isBlank(obj.ASI_eForm_Bank_A_C_Number__c)){
                            
                            obj.ASI_eForm_SWIFT_Code__c.addError(String.format(SWIFT_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                            obj.ASI_eForm_Bank_A_C_Number__c.addError(String.format(BANK_ACCOUNT_MANDATORY, new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                        }
                    }else if(mapBankCode.containsKey(obj.ASI_eForm_Bank__c)){
                        
                        if(String.isBlank(obj.ASI_eForm_Bank_Code__c))
                            obj.ASI_eForm_Bank_Code__c = mapBankCode.get(obj.ASI_eForm_Bank__c).ASI_eForm_Bank_Code__c;
                        
                        if(String.isBlank(obj.ASI_eForm_SWIFT_Code__c))
                            obj.ASI_eForm_SWIFT_Code__c = mapBankCode.get(obj.ASI_eForm_Bank__c).ASI_eForm_SWIFT_Code__c;
                        
                        obj.ASI_eForm_Bank_Name__c = obj.ASI_eForm_Bank__c;
                    }
                }
                
                /*if(mapVendorFormDefaultCurrency.containsKey(obj.ASI_eForm_Vendor_Form__c) && obj.RecordTypeId == KEY_BANK_RT){
obj.ASI_eForm_Currency__c = mapVendorFormDefaultCurrency.get(obj.ASI_eForm_Vendor_Form__c).ASI_eForm_Default_Currency__c;
}*/
                
                if(mapVendorForm.containsKey(obj.ASI_eForm_Vendor_Form__c) && (obj.RecordTypeId == KEY_BANK_RT || obj.RecordTypeId == OTHER_BANK_RT) && obj.ASI_eForm_Email_Address_1__c == Null){
                    
                    obj.ASI_eForm_Email_Address_1__c = mapVendorForm.get(obj.ASI_eForm_Vendor_Form__c).ASI_eForm_Email__c;
                }
                
                if(duplicatedSet.contains('' + obj.ASI_eForm_Vendor_Form__c + (!String.isBlank(obj.ASI_eForm_Currency__c) ? obj.ASI_eForm_Currency__c.toLowerCase() : ''))){
                    obj.ASI_eForm_Currency__c.addError(String.format(DUPLICATED_CURRENCY_ERROR_MSG, new List<String>{obj.ASI_eForm_Currency__c}));
                }
                
                duplicatedSet.add('' + obj.ASI_eForm_Vendor_Form__c + (!String.isBlank(obj.ASI_eForm_Currency__c) ? obj.ASI_eForm_Currency__c.toLowerCase() : ''));
            }
        }
    }
    
    Public Static void beforeUpdateFunction(List<ASI_eForm_Vendor_Form_Line_Item__c> triggerNew, Map<Id, ASI_eForm_Vendor_Form_Line_Item__c> triggerOldMap){
        
        if(String.isBlank(currentUser.BypassTriggers__c) || !currentUser.BypassTriggers__c.containsIgnoreCase('ASI_eForm_HK_VendorFormLinesTriggerClass')){
            Set<Id> vendorFormIdSet = new Set<Id>();
            Set<Id> vendorFormLineIdSet = new Set<Id>();
            Set<String> duplicatedSet = new Set<String>();
            
            Map<String, ASI_eForm_HK_MetaData__mdt> mapBankCode = createBankCodeMap();
            
            for(ASI_eForm_Vendor_Form_Line_Item__c obj : triggerNew){
                
                vendorFormIdSet.add(obj.ASI_eForm_Vendor_Form__c);
                
                if(obj.ASI_eForm_Bank__c == OTHER_BANK && obj.ASI_eForm_Bank_Country_Code__c == COUNTRY_CODE_HK && obj.ASI_eForm_Currency__c == CURRENCY_CODE_HK){
                    
                    Boolean isChange = False;
                    
                    if(obj.ASI_eForm_Bank__c != triggerOldMap.get(obj.id).ASI_eForm_Bank__c)
                        isChange = True;
                    
                    if(triggerOldMap.get(obj.id).ASI_eForm_Bank_Name__c == obj.ASI_eForm_Bank_Name__c && isChange)
                        obj.ASI_eForm_Bank_Name__c.addError(String.format(BANK_NAME_MANDATORY, new List<String>{'change'}));
                    
                    if(String.isBlank(obj.ASI_eForm_Bank_Name__c))
                        obj.ASI_eForm_Bank_Name__c.addError(String.format(BANK_NAME_MANDATORY, new List<String>{'input'}));
                    
                    if(triggerOldMap.get(obj.id).ASI_eForm_SWIFT_Code__c == obj.ASI_eForm_SWIFT_Code__c && isChange)
                        obj.ASI_eForm_SWIFT_Code__c.addError(String.format(SWIFT_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'change'}));
                    
                    if(String.isBlank(obj.ASI_eForm_SWIFT_Code__c))
                        obj.ASI_eForm_SWIFT_Code__c.addError(String.format(SWIFT_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                    
                    if(triggerOldMap.get(obj.id).ASI_eForm_Bank_Code__c == obj.ASI_eForm_Bank_Code__c && isChange)
                        obj.ASI_eForm_Bank_Code__c.addError(String.format(BANK_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'change'}));
                    
                    if(String.isBlank(obj.ASI_eForm_Bank_Code__c))
                        obj.ASI_eForm_Bank_Code__c.addError(String.format(BANK_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                    else if(String.isNotBlank(obj.ASI_eForm_Bank_Code__c) && obj.ASI_eForm_Bank_Code__c.length() != 3)//20180807 Introv
                        obj.ASI_eForm_Bank_Code__c.addError(BANK_CODE_MUST_BE_3_DIGIT);
                    
                    //20180830 Introv
                    if(String.isBlank(obj.ASI_eForm_Bank_A_C_Number__c))
                        obj.ASI_eForm_Bank_A_C_Number__c.addError(String.format(BANK_ACCOUNT_MANDATORY, new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                    
                //20180807 Introv
                }else if(obj.ASI_eForm_Bank__c == OTHER_BANK && String.isBlank(obj.ASI_eForm_IBAN_Code__c) && (obj.ASI_eForm_Bank_Country_Code__c != COUNTRY_CODE_HK || obj.ASI_eForm_Currency__c != CURRENCY_CODE_HK)){
                    
                    if(String.isBlank(obj.ASI_eForm_Bank_Name__c))
                        obj.ASI_eForm_Bank_Name__c.addError(String.format(BANK_NAME_MANDATORY, new List<String>{'input'}));
                    
                    if(String.isBlank(obj.ASI_eForm_SWIFT_Code__c) || String.isBlank(obj.ASI_eForm_Bank_A_C_Number__c)){
                        
                        obj.addError(BANK_CODE_OR_ACCOUNT_CODE_MANDATORY);
                        obj.ASI_eForm_SWIFT_Code__c.addError(String.format(SWIFT_CODE_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                        obj.ASI_eForm_Bank_A_C_Number__c.addError(String.format(BANK_ACCOUNT_MANDATORY,new List<String>{obj.ASI_eForm_Bank_Name__c, 'input'}));
                    }
                }else if((obj.ASI_eForm_Bank__c != triggerOldMap.get(obj.id).ASI_eForm_Bank__c
                          || String.isBlank(obj.ASI_eForm_Bank_Code__c)
                          || String.isBlank(obj.ASI_eForm_SWIFT_Code__c)
                          || String.isBlank(obj.ASI_eForm_Bank_Country_Code__c)
                          || String.isBlank(obj.ASI_eForm_Bank_Name__c)
                         )
                         && mapBankCode.containsKey(obj.ASI_eForm_Bank__c)){
                    
                    obj.ASI_eForm_Bank_Code__c = mapBankCode.get(obj.ASI_eForm_Bank__c).ASI_eForm_Bank_Code__c;
                    obj.ASI_eForm_SWIFT_Code__c = mapBankCode.get(obj.ASI_eForm_Bank__c).ASI_eForm_SWIFT_Code__c;
                    obj.ASI_eForm_Bank_Name__c = obj.ASI_eForm_Bank__c;
                    obj.ASI_eForm_Bank_Country_Code__c = COUNTRY_CODE_HK;
                }
            }
            
            for(ASI_eForm_Vendor_Form_Line_Item__c obj : [SELECT Id, ASI_eForm_Related_Vendor_From_Line__c 
                                                          FROM ASI_eForm_Vendor_Form_Line_Item__c
                                                          WHERE ASI_eForm_Related_Vendor_From_Line__c != Null 
                                                          AND ASI_eForm_Related_Vendor_From_Line__c IN : triggerNew]){
                                                              
                                                              vendorFormLineIdSet.add(obj.ASI_eForm_Related_Vendor_From_Line__c);
                                                          }
            
            duplicatedSet = checkDuplicatedCurrency(triggerNew, vendorFormIdSet);
            
            for(ASI_eForm_Vendor_Form_Line_Item__c obj : triggerNew){
                
                /*if(mapVendorFormDefaultCurrency.containsKey(obj.ASI_eForm_Vendor_Form__c) && mapVendorFormDefaultCurrency.get(obj.ASI_eForm_Vendor_Form__c).ASI_eForm_Status__c == DRAFT_STATUS && obj.RecordTypeId == KEY_BANK_RT){
obj.ASI_eForm_Currency__c = mapVendorFormDefaultCurrency.get(obj.ASI_eForm_Vendor_Form__c).ASI_eForm_Default_Currency__c;
}*/
                
                if(mapVendorForm.containsKey(obj.ASI_eForm_Vendor_Form__c) && (obj.RecordTypeId == KEY_BANK_RT || obj.RecordTypeId == OTHER_BANK_RT) && obj.ASI_eForm_Email_Address_1__c == Null){
                    
                    obj.ASI_eForm_Email_Address_1__c = mapVendorForm.get(obj.ASI_eForm_Vendor_Form__c).ASI_eForm_Email__c;
                }
                
                if(duplicatedSet.contains('' + obj.ASI_eForm_Vendor_Form__c + (!String.isBlank(obj.ASI_eForm_Currency__c) ? obj.ASI_eForm_Currency__c.toLowerCase() : ''))){
                    
                    if(mapVendorForm.containsKey(obj.ASI_eForm_Vendor_Form__c) && mapVendorForm.get(obj.ASI_eForm_Vendor_Form__c).recordTypeId != ARCHIVED_VENDOR_FORM_RT)
                        obj.ASI_eForm_Currency__c.addError(String.format(DUPLICATED_CURRENCY_ERROR_MSG, new List<String>{obj.ASI_eForm_Currency__c}));
                }
                
                if(vendorFormLineIdSet.contains(obj.id) && obj.ASI_eForm_Currency__c != triggerOldMap.get(obj.id).ASI_eForm_Currency__c 
                   && mapVendorForm.containsKey(obj.ASI_eForm_Vendor_Form__c) && mapVendorForm.get(obj.ASI_eForm_Vendor_Form__c).RecordTypeId == REVISE_VENDOR_FORM_RT){
                       
                       obj.ASI_eForm_Currency__c.addError(BLOCK_CHANGE_CURRENCY);
                   }
                
                duplicatedSet.add('' + obj.ASI_eForm_Vendor_Form__c + (!String.isBlank(obj.ASI_eForm_Currency__c) ? obj.ASI_eForm_Currency__c.toLowerCase() : ''));
            }
        }
    }
    
    @TestVisible
    Private Static Set<String> checkDuplicatedCurrency(List<ASI_eForm_Vendor_Form_Line_Item__c> triggerNew, Set<Id> vendorFormIdSet){
        
        Set<String> duplicatedSet = new Set<String>();
        
        for(ASI_eForm_Vendor_Form__c vendorForm : [SELECT Id
                                                   , recordTypeId
                                                   , ASI_eForm_Status__c
                                                   , ASI_eForm_Default_Currency__c
                                                   , ASI_eForm_Email__c 
                                                   , (SELECT Id
                                                      , ASI_eForm_Currency__c
                                                      , ASI_eForm_Vendor_Form__c
                                                      FROM Vendor_Form_Line_Items__r
                                                      WHERE Id NOT IN : triggerNew
                                                     )
                                                   FROM ASI_eForm_Vendor_Form__c
                                                   WHERE Id IN : vendorFormIdSet
                                                  ]){
                                                      
                                                      for(ASI_eForm_Vendor_Form_Line_Item__c obj : vendorForm.Vendor_Form_Line_Items__r){
                                                          
                                                          duplicatedSet.add('' + vendorForm.Id + (!String.isBlank(obj.ASI_eForm_Currency__c) ? obj.ASI_eForm_Currency__c.toLowerCase() : ''));
                                                      }
                                                      
                                                      mapVendorForm.put(vendorForm.Id, vendorForm);
                                                  }
        
        Return duplicatedSet;
    }
    
    @TestVisible
    Private Static Map<String, ASI_eForm_HK_MetaData__mdt> createBankCodeMap(){
        
        Map<String, ASI_eForm_HK_MetaData__mdt> tmpMap = new Map<String, ASI_eForm_HK_MetaData__mdt>();
        
        for(ASI_eForm_HK_MetaData__mdt obj : bankCodeList){
            
            tmpMap.put(obj.ASI_eForm_Bank_Name__c, obj);
        }
        
        Return tmpMap;
    }
}