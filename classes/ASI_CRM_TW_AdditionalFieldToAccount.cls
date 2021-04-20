public without sharing class ASI_CRM_TW_AdditionalFieldToAccount extends ASI_HK_CRM_TriggerAbstract {

    public ASI_CRM_TW_AdditionalFieldToAccount() {
        super('ASI_CRM_TW_AdditionalFieldToAccount');
    }
    
    private String generateAddress(ASI_CRM_AccountsAdditionalField__c accountAdditionalField){
            String address = '';
            
            if (accountAdditionalField!= null){   
                // Update the address from Additional Field to Account            
                if (accountAdditionalField.ASI_CRM_City__c != null) address += accountAdditionalField.ASI_CRM_City__c;
                if (accountAdditionalField.ASI_CRM_Town__c != null) address += accountAdditionalField.ASI_CRM_Town__c;
                if (accountAdditionalField.ASI_CRM_TW_Street__c != null) address += accountAdditionalField.ASI_CRM_TW_Street__c;
                if (accountAdditionalField.ASI_CRM_TW_Section__c != null) address += accountAdditionalField.ASI_CRM_TW_Section__c;
                if (accountAdditionalField.ASI_CRM_TW_Lane__c != null) address += accountAdditionalField.ASI_CRM_TW_Lane__c + '巷';
                if (accountAdditionalField.ASI_CRM_TW_Alley__c != null) address += accountAdditionalField.ASI_CRM_TW_Alley__c + '弄';
                if (accountAdditionalField.ASI_CRM_TW_Number__c != null) 
                {
                    address += accountAdditionalField.ASI_CRM_TW_Number__c;
                    if (accountAdditionalField.ASI_CRM_TW_Number_Hyphen__c != null) 
                        address += '之' + accountAdditionalField.ASI_CRM_TW_Number_Hyphen__c;
                    address += '號';
                }
                
                if (accountAdditionalField.ASI_CRM_TW_Floor__c != null) 
                {
                    address += accountAdditionalField.ASI_CRM_TW_Floor__c;
                    if (accountAdditionalField.ASI_CRM_TW_Hyphen__c != null) 
                        address += '之' + accountAdditionalField.ASI_CRM_TW_Hyphen__c;
                    address += '樓';
                }
                
                if (accountAdditionalField.ASI_CRM_TW_Suite__c != null) address += accountAdditionalField.ASI_CRM_TW_Suite__c + '室';
            }
        return address;    
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
            ) { // Removed by William Yang '&& !isBypassByCurrentUser()'
            List<ASI_CRM_AccountsAdditionalField__c> soList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;

            Set<Id> accountIds = new Set<Id>();
            Set<Id> outletTypeIds = new Set<Id>();  
            List<String> servicePackIds = new List<String>();
            List<String> segmentationCriteriaIds = new List<String>();
            
            if(Trigger.isUpdate){
				for (ASI_CRM_AccountsAdditionalField__c accountAdditionalField : soList) {
                    Id recordId = accountAdditionalField.Id;
                    ASI_CRM_AccountsAdditionalField__c old_accountAdditionalField = (ASI_CRM_AccountsAdditionalField__c)oldMap.get(recordId);
                    
                    if(accountAdditionalField.ASI_CRM_CN_Address__c != old_accountAdditionalField.ASI_CRM_CN_Address__c && !String.isBlank(accountAdditionalField.ASI_CRM_CN_Address__c ) ){
                        accountAdditionalField.ASI_CRM_MY_GeoConverStatus__c = 'Pending';
                    }
                }                
            }    
            
                
            for (ASI_CRM_AccountsAdditionalField__c accountAdditionalField : soList) {
                accountIds.add(accountAdditionalField.ASI_CRM_Account__c);
                outletTypeIds.add(accountAdditionalField.ASI_TH_CRM_OutletType__c);
            }
            System.debug('****accountIds: ' + accountIds);
            System.debug('---------------------------------------Query----------------------------------------');
            Map<id, Account> accountMap = new Map<id, Account>(
                [SELECT Id,
                        ASI_HK_CRM_JDE_Account_Number__c, 
                        ASI_KOR_Customer_Code__c, 
                        ASI_KOR_Grade__c, 
                        ASI_TH_CRM_Region__c, 
                        ASI_HK_CRM_Channel__c, 
                        ASI_KOR_Addr_Street__c, 
                        ASI_MFM_City__c, 
                        ASI_MFM_Site_Code__c, 
                        ASI_KOR_Legal_Name__c, 
                        ASI_HK_CRM_Inactive__c, 
                        Sub_Channel__c, 
                        ASI_HK_CRM_Address__c, 
                        Phone, 
                        Fax, 
                        ParentId, 
                        ASI_HK_CRM_IsDeliveryAccount__c     
                FROM Account 
                WHERE Id IN :accountIds]);
            System.debug('****accountMap: ' + accountMap);
            System.debug('---------------------------------------Query----------------------------------------');
            Map<id, ASI_TH_CRM_OutletType__c> outletTypeMap = new Map<id, ASI_TH_CRM_OutletType__c>([SELECT id, Name, ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Channel__c, ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Channel__r.Name, ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_CRM_Sub_Channel__c, ASI_CRM_Sub_Channel__r.Name FROM ASI_TH_CRM_OutletType__c WHERE id in :outletTypeIds]);
            
            // Added by William Yang on 20140603
            for (ASI_CRM_AccountsAdditionalField__c accountAdditionalField : soList) {
                if (accountAdditionalField.ASI_TH_CRM_OutletType__c != null){
                    ASI_TH_CRM_OutletType__c outletType = (ASI_TH_CRM_OutletType__c)outletTypeMap.get(accountAdditionalField.ASI_TH_CRM_OutletType__c);
                    
                    accountAdditionalField.ASI_CRM_Channel__c = outletType.ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Channel__c;
                    accountAdditionalField.ASI_CRM_CN_Sub_Channel__c = outletType.ASI_CRM_Sub_Channel__c;
                }
                
                if (accountAdditionalField.ASI_CRM_CN_Sub_Channel__c != null/* && accountAdditionalField.ASI_TH_CRM_OutletImage__c != null*/){
                    if(accountAdditionalField.ASI_TH_CRM_OutletImage__c != null)
                        servicePackIds.add((''+accountAdditionalField.ASI_CRM_CN_Sub_Channel__c).substring(0,15) + (''+accountAdditionalField.ASI_TH_CRM_OutletImage__c).substring(0,15));
                    else
                        servicePackIds.add((''+accountAdditionalField.ASI_CRM_CN_Sub_Channel__c).substring(0,15));
                }    
                if (accountAdditionalField.ASI_CRM_Channel__c != null && accountAdditionalField.ASI_CRM_CN_Grade__c != null && accountAdditionalField.ASI_CRM_Sales_Potential__c != null)
                    segmentationCriteriaIds.add((''+accountAdditionalField.ASI_CRM_Channel__c).substring(0,15) + 
                        accountAdditionalField.ASI_CRM_CN_Grade__c +
                        accountAdditionalField.ASI_CRM_Sales_Potential__c);
                        
            }
            //-- End --
            
            Map<String, ASI_CRM_ServicePack__c> servicePackMap = new Map<String, ASI_CRM_ServicePack__c>();
            System.debug('---------------------------------------Query----------------------------------------');
            for (ASI_CRM_ServicePack__c servicePack:[SELECT ASI_CRM_Key_For_Account__c  FROM ASI_CRM_ServicePack__c WHERE ASI_CRM_Key_For_Account__c in :servicePackIds]){
                servicePackMap.put(servicePack.ASI_CRM_Key_For_Account__c , servicePack); 
            }
            
            Map<String, ASI_CRM_SegmentationCriteria__c> segmentationCriteriaMap = new Map<String, ASI_CRM_SegmentationCriteria__c>();
            System.debug('---------------------------------------Query----------------------------------------');
            for (ASI_CRM_SegmentationCriteria__c segmentationCriteria:[SELECT ASI_CRM_Key_For_Account__c FROM ASI_CRM_SegmentationCriteria__c WHERE ASI_CRM_Key_For_Account__c in :segmentationCriteriaIds]){
                segmentationCriteriaMap.put(segmentationCriteria.ASI_CRM_Key_For_Account__c , segmentationCriteria); 
            }  
            
            Map<String, ASI_CRM_TW_AutoNumberAssignment> autoNumberAssignmentMap = new Map<String, ASI_CRM_TW_AutoNumberAssignment>();
            
            for (ASI_CRM_AccountsAdditionalField__c accountAdditionalField : soList) {
                if(accountAdditionalField.ASI_CRM_Account__c != null){
                    
                    Account a = (Account)accountMap.get(accountAdditionalField.ASI_CRM_Account__c);  
                    String regionCode = '';
                    
                    System.debug('****a: ' + a);
                                    
                    //Remarked Before_Insert condition due to change request
                    //if (tAction == TriggerAction.BEFORE_INSERT){
                    if( a != null && accountAdditionalField.ASI_CRM_Region__c != null && accountAdditionalField.ASI_CRM_Region__c != '')
                        a.ASI_TH_CRM_Region__c= accountAdditionalField.ASI_CRM_Region__c;
                        regionCode = accountAdditionalField.ASI_CRM_Region__c;
                    //}
    
                    //Generate Customer Code 
                    if(Global_RecordTypeCache.getRt(accountAdditionalField.recordTypeId).developerName.contains('ASI_CRM_TW_Outlet')){
                          if(a!=null){          
                        if ( (a.ASI_KOR_Customer_Code__c == null || a.ASI_KOR_Customer_Code__c == '') && 
                        (a.ASI_HK_CRM_JDE_Account_Number__c == null || a.ASI_HK_CRM_JDE_Account_Number__c == '')){
                            String key = '';
                            
                            
                            ASI_TH_CRM_OutletType__c outletType = outletTypeMap.get(accountAdditionalField.ASI_TH_CRM_OutletType__c);
                            if (outletType.Name == 'Sub-Wholesaler'){
                                if (regionCode == 'North') key += '3001';
                                else if (regionCode == 'North 2') key += '3004';
                                else if (regionCode == 'Central') key += '3002';
                                else if (regionCode == 'South') key += '3003';
                                else if (regionCode == 'CVS') key += '3005';
                            }else{
                                if (regionCode == 'North') key += '31';
                                else if (regionCode == 'North 2') key += '34';
                                else if (regionCode == 'Central') key += '32';
                                else if (regionCode == 'South') key += '33';
                                else if (regionCode == 'CVS') key += '35';
                                
                                //Added by Introv (Twinkle) @20161222 for new outlet modules
                                else if (regionCode == 'HYPER') key += '36';
                                else if (regionCode == 'SUPER') key += '37';
                            }
                        
                            ASI_CRM_TW_AutoNumberAssignment autoNumAssign;                      
                            if (autoNumberAssignmentMap.get(key) == null) autoNumAssign = new ASI_CRM_TW_AutoNumberAssignment(key);
                            else autoNumAssign = autoNumberAssignmentMap.get(key);
                            
                            if (outletType.Name == 'Sub-Wholesaler')
                                a.ASI_HK_CRM_JDE_Account_Number__c = autoNumAssign.nextAutoNumStr(4);
                            else
                                a.ASI_HK_CRM_JDE_Account_Number__c = autoNumAssign.nextAutoNumStr(6);
                                
                            a.ASI_KOR_Customer_Code__c = 'TW_'+a.ASI_HK_CRM_JDE_Account_Number__c;
                            if(accountAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c == null || accountAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c == '')
                                accountAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c = a.ASI_KOR_Customer_Code__c;
                            autoNumberAssignmentMap.put(key, autoNumAssign); 
                        }
                      } 
                    }
                    /*
                    if (tAction == TriggerAction.BEFORE_INSERT){
                        System.debug('****a: ' + a);
                        System.debug('****a.ASI_HK_CRM_Address__c: ' + a.ASI_HK_CRM_Address__c);
                        a.ASI_HK_CRM_Address__c = generateaddress(accountAdditionalField);
                    }
                    else
                        a.ASI_HK_CRM_Address__c = accountAdditionalField.ASI_CRM_CN_Address__c;
                    //accountAdditionalField.ASI_CRM_CN_Address__c = address;
                    */
                    
                    //Update Address
                    accountAdditionalField.ASI_CRM_CN_Address__c = generateaddress(accountAdditionalField);
                    system.debug('@@@accountAdditionalField: '+accountAdditionalField);
                    system.debug('@@@ASI_CRM_CN_Address__c: '+generateaddress(accountAdditionalField));
                    //if( !String.isBlank(accountAdditionalField.ASI_CRM_CN_Address__c) ){
                        a.ASI_HK_CRM_Address__c = accountAdditionalField.ASI_CRM_CN_Address__c;    
                    //}
                    
                    
                    //Copy the Account Name
                    a.Name = accountAdditionalField.Name;
                    a.ASI_KOR_Legal_Name__c = accountAdditionalField.ASI_CRM_CN_Legal_Name__c;
                    
                    //Copy Inactive Flag
                    a.ASI_HK_CRM_Inactive__c = accountAdditionalField.ASI_CRM_CN_Inactive_Flag__c;
                    
                    //Copy Is Parent Account
                    a.ASI_HK_CRM_IsDeliveryAccount__c = accountAdditionalField.ASI_CRM_IsParentAccount__c;
                    
                    //Copy City/Town
                    a.ASI_MFM_City__c = accountAdditionalField.ASI_CRM_City__c;
                    a.ASI_KOR_Addr_Street__c = accountAdditionalField.ASI_CRM_Town__c;
                    
                    //Copy the lookup value to Account object --> Parent Account 
                    //if (accountAdditionalField.ASI_CRM_TW_Parent_Account__c != null) 
                    a.ParentId = accountAdditionalField.ASI_CRM_TW_Parent_Account__c;
                    
                    //Update Phone Fax input format
                    a.Phone = ((accountAdditionalField.ASI_CRM_TW_Phone_Area_Code__c != null) ? '('+accountAdditionalField.ASI_CRM_TW_Phone_Area_Code__c+')': '') + 
                    ((accountAdditionalField.ASI_CRM_TW_Phone_Number__c != null) ? accountAdditionalField.ASI_CRM_TW_Phone_Number__c: '') + 
                    ((accountAdditionalField.ASI_CRM_TW_Phone_Ext__c != null) ? ' #'+accountAdditionalField.ASI_CRM_TW_Phone_Ext__c: '') ;
                    
                    a.Fax = ((accountAdditionalField.ASI_CRM_TW_Fax_Area_Code__c != null) ? '('+accountAdditionalField.ASI_CRM_TW_Fax_Area_Code__c+')': '') + 
                    ((accountAdditionalField.ASI_CRM_TW_Fax_Number__c != null) ? accountAdditionalField.ASI_CRM_TW_Fax_Number__c: '');
                    
                    //Add by Kendy.Tam at 2014-07-04 for fixing update account owner trigger dead loop issue
                    if(accountAdditionalField.ASI_CRM_TW_ChangeAccountOwner__c == true){
                        accountMap.remove(accountAdditionalField.ASI_CRM_Account__c);
                        accountAdditionalField.ASI_CRM_TW_ChangeAccountOwner__c = false;
                    }                                
                    
                    //Auto-populate Channel & Sub-Channel 
                    if (accountAdditionalField.ASI_TH_CRM_OutletType__c != null){
                        ASI_TH_CRM_OutletType__c outletType = (ASI_TH_CRM_OutletType__c)outletTypeMap.get(accountAdditionalField.ASI_TH_CRM_OutletType__c);
                        
                        //Copy Channel/Sub-channel
                        a.ASI_HK_CRM_Channel__c =  outletType.ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Channel__r.Name;
                        a.ASI_HK_CRM_Channel_Detail__c  = outletType.ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_Channel_Code__c;
                        a.Sub_Channel__c = outletType.ASI_CRM_Sub_Channel__r.Name;
                        a.ASI_MFM_Site_Code__c = outletType.ASI_CRM_Sub_Channel__r.Name;
                        
                        //Copy Grade
                        a.ASI_KOR_Grade__c = accountAdditionalField.ASI_CRM_CN_Grade__c;
                    }
                    
                    //Update Service Pack - According to Channel & Outlet Image changes
                    if (accountAdditionalField.ASI_CRM_CN_Sub_Channel__c != null/* && accountAdditionalField.ASI_TH_CRM_OutletImage__c != null*/){
                        ASI_CRM_ServicePack__c servicePack = new ASI_CRM_ServicePack__c();
                        if(accountAdditionalField.ASI_TH_CRM_OutletImage__c != null){
                            servicePack = (ASI_CRM_ServicePack__c)servicePackMap.get((''+accountAdditionalField.ASI_CRM_CN_Sub_Channel__c).substring(0,15) + (''+accountAdditionalField.ASI_TH_CRM_OutletImage__c).substring(0,15));
                        }
                        else{
                            servicePack = (ASI_CRM_ServicePack__c)servicePackMap.get((''+accountAdditionalField.ASI_CRM_CN_Sub_Channel__c).substring(0,15));
                        }
                        accountAdditionalField.ASI_CRM_Service_Pack__c = (servicePack == null) ? null : servicePack.id;
                    }
                    
                    //Update Segmentation Criteria - According to Grade & Sales Potential changes
                    if (accountAdditionalField.ASI_CRM_Channel__c != null && accountAdditionalField.ASI_CRM_CN_Grade__c != null && accountAdditionalField.ASI_CRM_Sales_Potential__c != null){
                        ASI_CRM_SegmentationCriteria__c segmentationCriteria = (ASI_CRM_SegmentationCriteria__c)segmentationCriteriaMap.get(
                            (''+accountAdditionalField.ASI_CRM_Channel__c).substring(0,15) + 
                            accountAdditionalField.ASI_CRM_CN_Grade__c +
                            accountAdditionalField.ASI_CRM_Sales_Potential__c);
                        accountAdditionalField.ASI_CRM_Segmentation_Criteria__c = (segmentationCriteria == null) ? null : segmentationCriteria.id;
                    }                
                }
            }
            if(accountMap != null && accountMap.size()>0)
            {
                for(Account acc:accountMap.values()){
                    acc.ASI_KOR_SYS_NeedRefreshGeolocation__c = true;
                    System.debug('============ acc.Name ' + acc.Name);
                }
                
                update accountMap.values();
            }
                
            for (ASI_CRM_TW_AutoNumberAssignment autoNumAssign : autoNumberAssignmentMap.Values())
                autoNumAssign.writeToDB(); 
        }
    }
}