public with sharing class ASI_CRM_CN_AccountsCRMCodeAutoNumber extends ASI_HK_CRM_TriggerAbstract {
    
    public ASI_CRM_CN_AccountsCRMCodeAutoNumber() {
        super('ASI_CRM_CN_AccountsCRMCodeAutoNumber');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT)
            //            && !isBypassByCurrentUser()) {
            && !ASI_CRM_CN_Function.IsBypassTrigger('ASI_CRM_CN_AccountsCRMCodeAutoNumber')) {
                
                List<ASI_CRM_AccountsAdditionalField__c> soList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;            
                
                Set<Id> cityIds = new Set<Id>();
                Set<Id> subChannelIds = new Set<Id>();
                
                Map<id, ASI_CRM_City__c> cityMap = new Map<id, ASI_CRM_City__c>();
                Map<id, ASI_MFM_Sub_Channel__c> subChannelMap = new Map<id, ASI_MFM_Sub_Channel__c>();
                //20160701 Ben @ Elufa
                
                Map<Id, ASI_CRM_CN_Channel__c> channelMap = new Map<Id, ASI_CRM_CN_Channel__c>([SELECT Id, ASI_CRM_CN_On_Off__c FROM ASI_CRM_CN_Channel__c 
                                                                                                WHERE RecordType.DeveloperName Like 'ASI_CRM_CN_New_Channel'
                                                                                               ]);
                //20160701
                
                System.debug('1');
                for (ASI_CRM_AccountsAdditionalField__c accountAdditionalField : soList) {
                    cityIds.add(accountAdditionalField.ASI_CRM_CN_CCity__c);
                    if (accountAdditionalField.ASI_CRM_CN_Sub_Channel__c != null)
                        subChannelIds.add(accountAdditionalField.ASI_CRM_CN_Sub_Channel__c);
                }
                
                for (ASI_CRM_City__c city : [Select id, ASI_CRM_CN_City_Code__c From ASI_CRM_City__c WHERE id in :cityIds]){
                    cityMap.put(city.id, city);
                }
                
                for (ASI_MFM_Sub_Channel__c subChannel : [Select id, ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c From ASI_MFM_Sub_Channel__c WHERE id in :subChannelIds]){
                    subChannelMap.put(subChannel.id, subChannel);
                }
                
                Map<String, ASI_CRM_CN_AutoNumberAssignment> autoNumberAssignmentMap = new Map<String, ASI_CRM_CN_AutoNumberAssignment>();
                for (ASI_CRM_AccountsAdditionalField__c accountAdditionalField : soList) {   
                    String cityCode = cityMap.get(accountAdditionalField.ASI_CRM_CN_CCity__c).ASI_CRM_CN_City_Code__c;
                    
                    if (Global_RecordTypeCache.getRt(accountAdditionalField.recordTypeid).developerName.contains('ASI_CRM_Outlet_CN')){
                        
                        // Updated by Michael Yip (Introv) 21Aug2014 for handling null exception
                        String onoff;
                        //system.debug(subChannelMap.get(accountAdditionalField.ASI_CRM_CN_Sub_Channel__c).ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c);
                        //system.debug(subChannelMap.get(accountAdditionalField.ASI_CRM_CN_Sub_Channel__c));
                        
                        //20160701 Ben @ ELufa
                        if(channelMap.containsKey(accountAdditionalField.ASI_CRM_CN_NewChannel__c)){
                            
                            onoff = channelMap.get(accountAdditionalField.ASI_CRM_CN_NewChannel__c).ASI_CRM_CN_On_Off__c;
                            
                        }else if(subChannelMap.get(accountAdditionalField.ASI_CRM_CN_Sub_Channel__c) != null){//20160701 Ben @ Elufa added Else
                            System.debug(onoff);
                            ASI_MFM_Sub_Channel__c sc = subChannelMap.get(accountAdditionalField.ASI_CRM_CN_Sub_Channel__c);
                            system.debug(sc);
                            system.debug(sc.ASI_CRM_CN_Channel__c );
                            if(sc.ASI_CRM_CN_Channel__c != null){
                                onoff = sc.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c;
                                System.debug(onoff);
                            }
                        }
                        System.debug(onoff);
                        //String onoff = subChannelMap.get(accountAdditionalField.ASI_CRM_CN_Sub_Channel__c).ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c; 
                        System.debug('Generate ASI_CRM_Outlet_CN:');
                        System.debug('cityCode:' + cityCode);
                        System.debug('onoff:' + onoff);
                        if (cityCode != null && onoff != null){
                            //onoff.substring(2);                     
                            String key = onoff.substring(0,2).toUpperCase() + cityCode.toUpperCase();
                            System.debug(key);
                            ASI_CRM_CN_AutoNumberAssignment autoNumAssign;                      
                            if (autoNumberAssignmentMap.get(key) == null) autoNumAssign = new ASI_CRM_CN_AutoNumberAssignment(key);
                            else autoNumAssign = autoNumberAssignmentMap.get(key);
                            
                            accountAdditionalField.ASI_CRM_CN_CRM_Code__c = autoNumAssign.nextAutoNumStr();
                            accountAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c = accountAdditionalField.ASI_CRM_CN_CRM_Code__c;
                            System.debug(accountAdditionalField.ASI_CRM_CN_CRM_Code__c);                      
                            autoNumberAssignmentMap.put(key, autoNumAssign);
                        }
                    }else if (Global_RecordTypeCache.getRt(accountAdditionalField.recordTypeid).developerName.contains('ASI_CRM_CN_WS')){
                        System.debug('Generate ASI_CRM_CN_WS:');
                        if (cityCode != null){                                              
                            String key = 'WS' + cityCode.toUpperCase();
                            
                            ASI_CRM_CN_AutoNumberAssignment autoNumAssign;                      
                            if (autoNumberAssignmentMap.get(key) == null) autoNumAssign = new ASI_CRM_CN_AutoNumberAssignment(key);
                            else autoNumAssign = autoNumberAssignmentMap.get(key);
                            
                            accountAdditionalField.ASI_CRM_CN_CRM_Code__c = autoNumAssign.nextAutoNumStr();  
                            accountAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c = accountAdditionalField.ASI_CRM_CN_CRM_Code__c;
                            autoNumberAssignmentMap.put(key, autoNumAssign);
                            
                        }
                    }
                }
                
                for (ASI_CRM_CN_AutoNumberAssignment autoNumAssign : autoNumberAssignmentMap.Values())
                    autoNumAssign.writeToDB();
            }
    }
}