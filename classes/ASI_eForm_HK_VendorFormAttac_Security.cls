public without sharing class ASI_eForm_HK_VendorFormAttac_Security {
    
    Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form__c.fields.getMap();
    
    Public Static void updateContentVersionSecurity(Set<Id> contentVersionId, ASI_eForm_Vendor_Form__c parent/*, Set<Id> userIDSet*/, Id soaAdmin){
        
        if(contentVersionId != Null){
            
            Set<Id> contentDoc = new Set<Id>();
            Set<Id> userId = new Set<Id>();
            Set<Id> disableNotificationUserSet = new Set<Id>();
            
            List<ContentVersion> cv = new List<ContentVersion>([SELECT Id, ContentDocumentId, SharingPrivacy FROM ContentVersion WHERE Id IN : contentVersionId]);
            List<ContentDocumentLink > cdl = new List<ContentDocumentLink>();
            
            List<ContentDocumentLink> deleteList = new List<ContentDocumentLink>();
            List<ContentDocumentLink> insertList = new List<ContentDocumentLink>();
            Set<Id> docIdSet = new Set<Id>();
            
            if(cv.size() > 0){
                for(ContentVersion obj : cv){
                    
                    contentDoc.add(obj.ContentDocumentId);
                }
                
                if(contentDoc.size() > 0){
                    
                    List<ContentDocument> cd = new List<ContentDocument>([SELECT Id, OwnerId FROM ContentDocument WHERE Id IN : contentDoc]);
                    
                    if(cd.size() > 0 && soaAdmin != Null){
                        for(ContentDocument obj : cd){
                            obj.OwnerId = soaAdmin;
                        }
                        
                        Try{
                            
                            Update cd;
                            
                        }catch(dmlException dmle){
                            
                        }
                    }
                    
                    cdl = new List<ContentDocumentLink>([SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE ContentDocumentId IN : contentDoc]);
                    
                    if(cdl.size() > 0){
                        
                        List<GroupMember> vendorFormAdmins = new List<GroupMember>([SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN : [SELECT id FROM Group WHERE DeveloperName LIKE 'ASI_eForm_HK_Vendor_Form_Admin']]);
                        Set<Id> gm = new Set<Id>();
                        
                        if(vendorFormAdmins.size() > 0){
                            
                            for(GroupMember obj : vendorFormAdmins)
                                gm.add(obj.UserOrGroupId);
                            
                            gm.add(userInfo.getUserId());
                            if(parent != Null)
                                gm.add(parent.OwnerId);
                        }
                        
                        Integer i = 1;
                        String fieldName = 'ASI_eForm_Sys_Approver_' + i + '__c';
                        
                        While(VENDOR_FORM_FIELD_MAP.containsKey(fieldName)){
                            
                            if(parent.get(fieldName) != Null)
                                gm.add((Id)parent.get(fieldName));
                            
                            i++;
                            fieldName = 'ASI_eForm_Sys_Approver_' + i + '__c';
                        }
                        
                        List<User> disableNotificationUserList = new List<User>();
                        
                        for(User u : [SELECT Id, UserPreferencesDisableAllFeedsEmail FROM USER WHERE Id IN : gm AND UserPreferencesDisableAllFeedsEmail = False]){
                            
                            u.UserPreferencesDisableAllFeedsEmail = True;
                            disableNotificationUserList.add(u);
                            disableNotificationUserSet.add(u.id);
                        }
                        
                        if(disableNotificationUserList.size() > 0){
                            try{
                                
                                Update disableNotificationUserList;
                                
                            }catch(dmlException dmle){
                                
                            }
                        }
                        
                        for(ContentDocumentLink obj : cdl){
                            if(obj.LinkedEntityId.getSObjectType().getDescribe().getName().toLowerCase() != 'user'){
                                
                                deleteList.add(obj);
                            }else if(obj.LinkedEntityId.getSObjectType().getDescribe().getName().toLowerCase() == 'user'){
                                
                                userId.add(obj.LinkedEntityId);
                                docIdSet.add(obj.ContentDocumentId);
                            }
                        }
                        
                        for(Id obj : docIdSet){
                            for(Id user : gm){
                                if(!userId.contains(user) && user != soaAdmin){
                                    insertList.add(new ContentDocumentLink(ContentDocumentId = obj
                                                                           , LinkedEntityId = user
                                                                           , ShareType = 'V'
                                                                           , Visibility = 'AllUsers'
                                                                          ));
                                }
                            }
                        }
                        
                        Try{
                            
                            if(insertList.size() > 0)
                                Insert insertList;
                            if(deleteList.size() > 0)
                                Delete deleteList;
                            if(disableNotificationUserSet.size() > 0 && !system.isBatch() && !system.isFuture() && !system.isQueueable() && !system.isScheduled())
                                enableUserNotfication(disableNotificationUserSet);
                            
                        }catch(dmlException dmle){
                            
                        }
                    }
                }
            }
        }
    }
    
    @future
    Public Static void enableUserNotfication(Set<Id> userIdSet){
        
        List<User> updateList = new List<User>();
        for(User u : [SELECT Id, UserPreferencesDisableAllFeedsEmail FROM USER WHERE Id IN : userIdSet]){
            u.UserPreferencesDisableAllFeedsEmail = False;
            updateList.add(u);
        }
        
        try{
            update updateList;
        }catch(dmlException dmle){
            
        }
    }
}