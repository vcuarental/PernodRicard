//Modified by William Yang on 20150602
//1.Change value of 'ASI_CRM_Field__c' from API Name to field label
//2.copy OldValue/NewValue to OldValueName/NewValueName for movements on non-lookup fields as well. For report purpose.

public with sharing class ASI_CRM_TW_AccountMovement_TgrHdlr extends ASI_HK_CRM_TriggerAbstract {
    
    public ASI_CRM_TW_AccountMovement_TgrHdlr() {
        super('ASI_CRM_TW_AccountMovement_TgrHdlr');
    }
    
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_AccountMovement__c> accountMovements = new List<ASI_CRM_AccountMovement__c>();
        ASI_CRM_AccountMovement__c accountMovement = null;
        DateTime updateDatetime = System.now();

        if(isBypassByCurrentUser())return;
        
        Map<Id,String> newOwnerIdMap = new Map<Id,String>();
        Map<Id,String> oldOwnerIdMap = new Map<Id,String>();
        Map<Id,String> accountIdMap = new Map<Id,String>();
        List<Id> newOutletTypeId = new List<Id>();
        List<Id> oldOutletTypeId = new List<Id>();
        
        //Added by William Yang(Introv) 20150527
        List<Id> newOutletImageId = new List<Id>();
        List<Id> oldOutletImageId = new List<Id>();
        
        Map<Id,ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
        Map<Id,User> newOwnerMap = new Map<Id,User>();
        Map<Id,User> oldOwnerMap = new Map<Id,User>();
        
        Map<Id,ASI_TH_CRM_OutletType__c> newOutletTypes = new Map<Id,ASI_TH_CRM_OutletType__c> (); 
        Map<Id,ASI_TH_CRM_OutletType__c> oldOutletTypes = new Map<Id,ASI_TH_CRM_OutletType__c> ();
        
        Map<Id,ASI_TH_CRM_OutletImage__c> newOutletImages = new Map<Id,ASI_TH_CRM_OutletImage__c> (); 
        Map<Id,ASI_TH_CRM_OutletImage__c> oldOutletImages = new Map<Id,ASI_TH_CRM_OutletImage__c> (); 
        //End

        for(sObject obj: sObjList){
            if (obj.getSObjectType() == Schema.getGlobalDescribe().get('Account')){
                Account newAccount = (Account)obj;
                newOwnerIdMap.put(newAccount.OwnerId,newAccount.OwnerId);
                
                if (oldMap != null && oldMap.get(newAccount.id) != null){
                    Account oldAccount = (Account)oldMap.get(newAccount.id);
                    oldOwnerIdMap.put(oldAccount.OwnerId,oldAccount.OwnerId);
                }
                if(newAccount.Id != NULL)
                    accountIdMap.put(newAccount.Id,newAccount.Id);                
            }
            else {
                ASI_CRM_AccountsAdditionalField__c newCustomer = (ASI_CRM_AccountsAdditionalField__c) obj;
                newOutletTypeId.add(newCustomer.ASI_TH_CRM_OutletType__c);
        
                //Added by William Yang(Introv) 20150527                
                if(newCustomer.ASI_TH_CRM_OutletImage__c != null)
                    newOutletImageId.add(newCustomer.ASI_TH_CRM_OutletImage__c);
                //End
                
                if (oldMap != null && oldMap.get(newCustomer.id) != null) {
                    ASI_CRM_AccountsAdditionalField__c oldCustomer = (ASI_CRM_AccountsAdditionalField__c)oldMap.get(newCustomer.id);
                    oldOutletTypeId.add(oldCustomer.ASI_TH_CRM_OutletType__c);
                    
                    //Added by William Yang(Introv) 20150527
                    //if(oldCustomer.ASI_TH_CRM_OutletImage__c != null)
                        oldOutletImageId.add(oldCustomer.ASI_TH_CRM_OutletImage__c);
                    //End
                }
            }
        }
        system.debug(accountIdMap.keySet());
        
        if(newOwnerIdMap != null)
            newOwnerMap = new Map<Id,User>([SELECT Id,Name,ASI_KOR_User_Region_Code__c FROM User WHERE Id IN :newOwnerIdMap.keySet()]);
        if(oldOwnerIdMap != null)
            oldOwnerMap = new Map<Id,User>([SELECT Id,Name,ASI_KOR_User_Region_Code__c FROM User WHERE Id IN :oldOwnerIdMap.keySet()]);
        
        if(newOutletTypeId != null && newOutletTypeId.size() > 0)
            newOutletTypes = new Map<Id,ASI_TH_CRM_OutletType__c> ([SELECT Id,Name FROM ASI_TH_CRM_OutletType__c WHERE Id = :newOutletTypeId]); 
        if(oldOutletTypeId != null && oldOutletTypeId.size() > 0)    
            oldOutletTypes = new Map<Id,ASI_TH_CRM_OutletType__c> ([SELECT Id,Name FROM ASI_TH_CRM_OutletType__c WHERE Id IN :oldOutletTypeId]); 
        
        //Added by William Yang(Introv) 20150527
        if(newOutletImageId != null && newOutletImageId.size() > 0)
            newOutletImages = new Map<Id,ASI_TH_CRM_OutletImage__c>([SELECT Id,Name FROM ASI_TH_CRM_OutletImage__c WHERE Id IN :newOutletImageId]); 
        if(oldOutletImageId != null && oldOutletImageId.size() > 0)
            oldOutletImages = new Map<Id,ASI_TH_CRM_OutletImage__c>([SELECT Id,Name FROM ASI_TH_CRM_OutletImage__c WHERE Id IN :oldOutletImageId]);         
        //End
        
        List<ASI_CRM_AccountsAdditionalField__c> listCustomerToUpdate = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c customer = null;
        
        if(accountIdMap != null && accountIdMap.size() > 0)
            customerMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>([SELECT Id, Name, ASI_CRM_TW_canUpdate__c, ASI_CRM_Account__c, ASI_CRM_TW_ChangeAccountOwner__c, ASI_CRM_Approval_Status__c FROM ASI_CRM_AccountsAdditionalField__c WHERE recordtype.developerName LIKE 'ASI_CRM_TW%' AND ASI_CRM_Account__c IN :accountIdMap.keySet()]);
        system.debug(customerMap);
        system.debug(customerMap.size());
        
        Map<Id,ASI_CRM_AccountsAdditionalField__c> accCustomerMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
        if(customerMap != null && customerMap.size() > 0)
            for(ASI_CRM_AccountsAdditionalField__c c:customerMap.values())
                accCustomerMap.put(c.ASI_CRM_Account__c,c);
        
        for(sObject obj: sObjList){
            if (obj.getSObjectType() == Schema.getGlobalDescribe().get('Account')){
                Account newAccount = (Account)obj;
                 
                if(!Global_RecordTypeCache.getRt(newAccount.recordTypeid).developerName.contains('ASI_CRM_TW_Outlet'))
                    continue;
                 
                if(newAccount.ASI_KOR_Venue_Diageo_Managed__c){
                    newAccount.ASI_KOR_Venue_Diageo_Managed__c = false;
                    continue;
                }
                
                //Added by William Yang (Introv) 20150828
                if(newAccount.ASI_KOR_SYS_NeedRefreshGeolocation__c){
                    newAccount.ASI_KOR_SYS_NeedRefreshGeolocation__c = false;
                    continue;
                }
                
                Account oldAccount = null;
                if (oldMap != null && oldMap.get(newAccount.id) != null)
                    oldAccount = (Account)oldMap.get(newAccount.id);
                
                //Record Owner
                if(oldAccount == null || newAccount.OwnerId != oldAccount.OwnerId){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.Id;
                    accountMovement.ASI_CRM_Field__c = 'Owner';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Owner';
                    accountMovement.ASI_CRM_NewValue__c = String.valueOf(newAccount.OwnerId);
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime; 
                            
                    User newOwner = newOwnerMap.get(newAccount.OwnerId);                
                    accountMovement.ASI_CRM_NewValueName__c = String.valueOf(newOwner.Name);
                                 
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        User oldOwner = oldOwnerMap.get(oldAccount.OwnerId);   
                        
                        if(newOwner.ASI_KOR_User_Region_Code__c != oldOwner.ASI_KOR_User_Region_Code__c){
                            newAccount.addError('Change to different region Owner is not allowed.');
                        }
                        
                        accountMovement.ASI_CRM_OldValue__c = String.valueOf(oldAccount.OwnerId);
                        accountMovement.ASI_CRM_OldValueName__c = String.valueOf(oldOwner.Name);
                        newAccount.OwnerId = oldAccount.OwnerId;
                    }
                    
                    if(oldAccount != null){
                        customer = accCustomerMap.get(oldAccount.Id);
                        
                        if(customer != null){
                            customer.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                            customer.ASI_CRM_TW_ChangeAccountOwner__c = True;
                            listCustomerToUpdate.add(customer);
                        }
                    }            
                    accountMovements.add(accountMovement);
                }     

             
                //Added by William Yang (Introv) to block direct edit Account Name
                if(tAction == TriggerAction.BEFORE_UPDATE && newAccount.Name != oldAccount.Name && accCustomerMap.get(oldAccount.Id) != NULL && !accCustomerMap.get(oldAccount.Id).ASI_CRM_TW_canUpdate__c)
                {
                    if(newAccount.ASI_KOR_SYS_NeedRefreshGeolocation__c == false)
                        newAccount.addError('Directly editing Account Name is not allowed. Please use the Edit button.');
                }
            }
            
            if (obj.getSObjectType() == Schema.getGlobalDescribe().get('ASI_CRM_AccountsAdditionalField__c')){
                System.debug('-----------------Update Customer------------' );
                 ASI_CRM_AccountsAdditionalField__c newAccount = (ASI_CRM_AccountsAdditionalField__c)obj;
                    System.debug('Can Update: ' + newAccount.ASI_CRM_TW_canUpdate__c);
                 if(newAccount.ASI_CRM_TW_canUpdate__c){
                    newAccount.ASI_CRM_TW_canUpdate__c = false;
                    System.debug('Can Update: ' + newAccount.ASI_CRM_TW_canUpdate__c);
                    continue;
                }
           
                ASI_CRM_AccountsAdditionalField__c oldAccount = null;
                if (oldMap != null && oldMap.get(newAccount.id) != null){
                    oldAccount = (ASI_CRM_AccountsAdditionalField__c)oldMap.get(newAccount.id);
                }             

                //Record Account Name
                if(oldAccount == null || newAccount.Name != oldAccount.Name){
                    accountMovement = new ASI_CRM_AccountMovement__c();
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'Name';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Name';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.Name;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.Name;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.Name;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.Name;
                        newAccount.Name = oldAccount.Name;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                } 
             
                //Record Account Legal Name
                if(oldAccount == null || newAccount.ASI_CRM_CN_Legal_Name__c != oldAccount.ASI_CRM_CN_Legal_Name__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();               
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_CN_Legal_Name__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Legal Name';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_CN_Legal_Name__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_CN_Legal_Name__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;                
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_CN_Legal_Name__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_CN_Legal_Name__c;
                        newAccount.ASI_CRM_CN_Legal_Name__c = oldAccount.ASI_CRM_CN_Legal_Name__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                newAccount.ASI_CRM_CN_Address__c = generateAddress(newAccount);
                //Record Address
                if(oldAccount == null || newAccount.ASI_CRM_CN_Address__c != oldAccount.ASI_CRM_CN_Address__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_CN_Address__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Address';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_CN_Address__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_CN_Address__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_CN_Address__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_CN_Address__c;
                        newAccount.ASI_CRM_CN_Address__c = oldAccount.ASI_CRM_CN_Address__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                if(oldAccount == null || newAccount.ASI_CRM_City__c != oldAccount.ASI_CRM_City__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_City__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'City';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_City__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_City__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_City__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_City__c;
                        newAccount.ASI_CRM_City__c = oldAccount.ASI_CRM_City__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }                                
                
                if(oldAccount == null || newAccount.ASI_CRM_Town__c != oldAccount.ASI_CRM_Town__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_Town__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Town';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_Town__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_Town__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_Town__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_Town__c;
                        newAccount.ASI_CRM_Town__c = oldAccount.ASI_CRM_Town__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                } 
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Street__c != oldAccount.ASI_CRM_TW_Street__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Street__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Street';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Street__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Street__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Street__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Street__c;
                        newAccount.ASI_CRM_TW_Street__c = oldAccount.ASI_CRM_TW_Street__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }                                
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Section__c != oldAccount.ASI_CRM_TW_Section__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Section__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Section';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Section__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Section__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Section__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Section__c;
                        newAccount.ASI_CRM_TW_Section__c = oldAccount.ASI_CRM_TW_Section__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Lane__c != oldAccount.ASI_CRM_TW_Lane__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Lane__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Lane';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Lane__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Lane__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Lane__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Lane__c;
                        newAccount.ASI_CRM_TW_Lane__c = oldAccount.ASI_CRM_TW_Lane__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }                                
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Alley__c != oldAccount.ASI_CRM_TW_Alley__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Alley__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Alley';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Alley__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Alley__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Alley__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Alley__c;
                        newAccount.ASI_CRM_TW_Alley__c = oldAccount.ASI_CRM_TW_Alley__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Number__c != oldAccount.ASI_CRM_TW_Number__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Number__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Number';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Number__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Number__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Number__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Number__c;
                        newAccount.ASI_CRM_TW_Number__c = oldAccount.ASI_CRM_TW_Number__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }                                
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Number_Hyphen__c != oldAccount.ASI_CRM_TW_Number_Hyphen__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Number_Hyphen__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Number Hyphen';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Number_Hyphen__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Number_Hyphen__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Number_Hyphen__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Number_Hyphen__c;
                        newAccount.ASI_CRM_TW_Number_Hyphen__c = oldAccount.ASI_CRM_TW_Number_Hyphen__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Floor__c != oldAccount.ASI_CRM_TW_Floor__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Floor__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Floor';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Floor__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Floor__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Floor__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Floor__c;
                        newAccount.ASI_CRM_TW_Floor__c = oldAccount.ASI_CRM_TW_Floor__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }                                
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Hyphen__c != oldAccount.ASI_CRM_TW_Hyphen__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Hyphen__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Hyphen';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Hyphen__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Hyphen__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Hyphen__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Hyphen__c;
                        newAccount.ASI_CRM_TW_Hyphen__c = oldAccount.ASI_CRM_TW_Hyphen__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                if(oldAccount == null || newAccount.ASI_CRM_TW_Suite__c != oldAccount.ASI_CRM_TW_Suite__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Suite__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Suite';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Suite__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Suite__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Suite__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Suite__c;
                        newAccount.ASI_CRM_TW_Suite__c = oldAccount.ASI_CRM_TW_Suite__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                //Michael Edit 2019/08/22 TW Invoice, Warehouse address
                //Invoice Address start
                newAccount.ASI_CRM_TW_Invoice_Address__c = generateInvoiceAddress(newAccount);
                //Record Address
                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Address__c != oldAccount.ASI_CRM_TW_Invoice_Address__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Address__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Address';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Address__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Address__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Address__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Address__c;
                        newAccount.ASI_CRM_TW_Invoice_Address__c = oldAccount.ASI_CRM_TW_Invoice_Address__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Alley__c != oldAccount.ASI_CRM_TW_Invoice_Alley__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Alley__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Alley';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Alley__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Alley__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Alley__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Alley__c;
                        newAccount.ASI_CRM_TW_Invoice_Alley__c = oldAccount.ASI_CRM_TW_Invoice_Alley__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_City__c != oldAccount.ASI_CRM_TW_Invoice_City__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_City__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice City';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_City__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_City__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_City__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_City__c;
                        newAccount.ASI_CRM_TW_Invoice_City__c = oldAccount.ASI_CRM_TW_Invoice_City__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Floor__c != oldAccount.ASI_CRM_TW_Invoice_Floor__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Floor__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'InvoicevFloor';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Floor__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Floor__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Floor__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Floor__c;
                        newAccount.ASI_CRM_TW_Invoice_Floor__c = oldAccount.ASI_CRM_TW_Invoice_Floor__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Hyphen__c != oldAccount.ASI_CRM_TW_Invoice_Hyphen__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Hyphen__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Hyphen';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Hyphen__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Hyphen__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Hyphen__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Hyphen__c;
                        newAccount.ASI_CRM_TW_Invoice_Hyphen__c = oldAccount.ASI_CRM_TW_Invoice_Hyphen__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Lane__c != oldAccount.ASI_CRM_TW_Invoice_Lane__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Lane__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Lane';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Lane__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Lane__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Lane__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Lane__c;
                        newAccount.ASI_CRM_TW_Invoice_Lane__c = oldAccount.ASI_CRM_TW_Invoice_Lane__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Number__c != oldAccount.ASI_CRM_TW_Invoice_Number__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Number__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Number';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Number__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Number__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Number__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Number__c;
                        newAccount.ASI_CRM_TW_Invoice_Number__c = oldAccount.ASI_CRM_TW_Invoice_Number__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c != oldAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Number_Hyphen__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Number Hyphen';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c;
                        newAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c = oldAccount.ASI_CRM_TW_Invoice_Number_Hyphen__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Section__c != oldAccount.ASI_CRM_TW_Invoice_Section__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Section__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Section';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Section__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Section__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Section__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Section__c;
                        newAccount.ASI_CRM_TW_Invoice_Section__c = oldAccount.ASI_CRM_TW_Invoice_Section__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Street__c != oldAccount.ASI_CRM_TW_Invoice_Street__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Street__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Street';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Street__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Street__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Street__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Street__c;
                        newAccount.ASI_CRM_TW_Invoice_Street__c = oldAccount.ASI_CRM_TW_Invoice_Street__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Suite__c != oldAccount.ASI_CRM_TW_Invoice_Suite__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Suite__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Suite';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Suite__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Suite__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Suite__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Suite__c;
                        newAccount.ASI_CRM_TW_Invoice_Suite__c = oldAccount.ASI_CRM_TW_Invoice_Suite__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Invoice_Town__c != oldAccount.ASI_CRM_TW_Invoice_Town__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Invoice_Town__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Invoice Town';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Invoice_Town__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Invoice_Town__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Invoice_Town__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Invoice_Town__c;
                        newAccount.ASI_CRM_TW_Invoice_Town__c = oldAccount.ASI_CRM_TW_Invoice_Town__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                //Invoice Address End

                //Warehpuese Address Start
                newAccount.ASI_CRM_TW_Warehouse_Address__c = generateWarehouseAddress(newAccount);
                //Record Address
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Address__c != oldAccount.ASI_CRM_TW_Warehouse_Address__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Address__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Address';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Address__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Address__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Address__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Address__c;
                        newAccount.ASI_CRM_TW_Warehouse_Address__c = oldAccount.ASI_CRM_TW_Warehouse_Address__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }

                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Alley__c != oldAccount.ASI_CRM_TW_Warehouse_Alley__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Alley__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Alley';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Alley__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Alley__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Alley__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Alley__c;
                        newAccount.ASI_CRM_TW_Warehouse_Alley__c = oldAccount.ASI_CRM_TW_Warehouse_Alley__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_City__c != oldAccount.ASI_CRM_TW_Warehouse_City__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_City__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse City';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_City__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_City__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_City__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_City__c;
                        newAccount.ASI_CRM_TW_Warehouse_City__c = oldAccount.ASI_CRM_TW_Warehouse_City__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Floor__c != oldAccount.ASI_CRM_TW_Warehouse_Floor__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Floor__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Floor';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Floor__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Floor__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Floor__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Floor__c;
                        newAccount.ASI_CRM_TW_Warehouse_Floor__c = oldAccount.ASI_CRM_TW_Warehouse_Floor__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Hyphen__c != oldAccount.ASI_CRM_TW_Warehouse_Hyphen__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Hyphen__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Hyphen';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Hyphen__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Hyphen__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Hyphen__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Hyphen__c;
                        newAccount.ASI_CRM_TW_Warehouse_Hyphen__c = oldAccount.ASI_CRM_TW_Warehouse_Hyphen__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Lane__c != oldAccount.ASI_CRM_TW_Warehouse_Lane__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Lane__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Lane';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Lane__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Lane__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Lane__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Lane__c;
                        newAccount.ASI_CRM_TW_Warehouse_Lane__c = oldAccount.ASI_CRM_TW_Warehouse_Lane__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Number__c != oldAccount.ASI_CRM_TW_Warehouse_Number__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Number__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Number';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Number__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Number__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Number__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Number__c;
                        newAccount.ASI_CRM_TW_Warehouse_Number__c = oldAccount.ASI_CRM_TW_Warehouse_Number__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c != oldAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Number_Hyphen__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Number Hyphen';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c;
                        newAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c = oldAccount.ASI_CRM_TW_Warehouse_Number_Hyphen__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Section__c != oldAccount.ASI_CRM_TW_Warehouse_Section__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Section__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Section';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Section__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Section__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Section__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Section__c;
                        newAccount.ASI_CRM_TW_Warehouse_Section__c = oldAccount.ASI_CRM_TW_Warehouse_Section__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Street__c != oldAccount.ASI_CRM_TW_Warehouse_Street__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Street__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Street';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Street__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Street__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Street__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Street__c;
                        newAccount.ASI_CRM_TW_Warehouse_Street__c = oldAccount.ASI_CRM_TW_Warehouse_Street__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Suite__c != oldAccount.ASI_CRM_TW_Warehouse_Suite__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Suite__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Suite';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Suite__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Suite__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Suite__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Suite__c;
                        newAccount.ASI_CRM_TW_Warehouse_Suite__c = oldAccount.ASI_CRM_TW_Warehouse_Suite__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                if(oldAccount == null || newAccount.ASI_CRM_TW_Warehouse_Town__c != oldAccount.ASI_CRM_TW_Warehouse_Town__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_TW_Warehouse_Town__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Warehouse Town';
                    accountMovement.ASI_CRM_NewValue__c = newAccount.ASI_CRM_TW_Warehouse_Town__c;
                    accountMovement.ASI_CRM_NewValueName__c = newAccount.ASI_CRM_TW_Warehouse_Town__c;
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;              
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = oldAccount.ASI_CRM_TW_Warehouse_Town__c;
                        accountMovement.ASI_CRM_OldValueName__c = oldAccount.ASI_CRM_TW_Warehouse_Town__c;
                        newAccount.ASI_CRM_TW_Warehouse_Town__c = oldAccount.ASI_CRM_TW_Warehouse_Town__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                //Warehpuese Address End

                //Record Inactive
                if(oldAccount == null || newAccount.ASI_CRM_CN_Inactive_Flag__c != oldAccount.ASI_CRM_CN_Inactive_Flag__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_CN_Inactive_Flag__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Inactive';
                    accountMovement.ASI_CRM_NewValue__c = String.valueOf(newAccount.ASI_CRM_CN_Inactive_Flag__c);
                    accountMovement.ASI_CRM_NewValueName__c = String.valueOf(newAccount.ASI_CRM_CN_Inactive_Flag__c);
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;               
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = String.valueOf(oldAccount.ASI_CRM_CN_Inactive_Flag__c);
                        accountMovement.ASI_CRM_OldValueName__c = String.valueOf(oldAccount.ASI_CRM_CN_Inactive_Flag__c);
                        newAccount.ASI_CRM_CN_Inactive_Flag__c = oldAccount.ASI_CRM_CN_Inactive_Flag__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                //Record Inactive
                if(oldAccount == null || newAccount.ASI_CRM_IsParentAccount__c != oldAccount.ASI_CRM_IsParentAccount__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_IsParentAccount__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Is Parent Account';
                    accountMovement.ASI_CRM_NewValue__c = String.valueOf(newAccount.ASI_CRM_IsParentAccount__c);
                    accountMovement.ASI_CRM_NewValueName__c = String.valueOf(newAccount.ASI_CRM_IsParentAccount__c);
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;               
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = String.valueOf(oldAccount.ASI_CRM_IsParentAccount__c);
                        accountMovement.ASI_CRM_OldValueName__c = String.valueOf(oldAccount.ASI_CRM_IsParentAccount__c);
                        newAccount.ASI_CRM_IsParentAccount__c = oldAccount.ASI_CRM_IsParentAccount__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }                                                                 
                
                //Record Outlet Type
                if(oldAccount == null || newAccount.ASI_TH_CRM_OutletType__c != oldAccount.ASI_TH_CRM_OutletType__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();               
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_TH_CRM_OutletType__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Outlet Type';
                    accountMovement.ASI_CRM_NewValue__c = String.valueOf(newAccount.ASI_TH_CRM_OutletType__c);
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;
                    
                    
                    if(newOutletTypes.get(newAccount.ASI_TH_CRM_OutletType__c) != null)
                        accountMovement.ASI_CRM_NewValueName__c = String.valueOf(newOutletTypes.get(newAccount.ASI_TH_CRM_OutletType__c).Name);  
                    
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = String.valueOf(oldAccount.ASI_TH_CRM_OutletType__c);
                        
                        if(oldOutletTypes.get(oldAccount.ASI_TH_CRM_OutletType__c) != null) 
                            accountMovement.ASI_CRM_OldValueName__c = String.valueOf(oldOutletTypes.get(oldAccount.ASI_TH_CRM_OutletType__c).Name); 
                            
                        newAccount.ASI_TH_CRM_OutletType__c = oldAccount.ASI_TH_CRM_OutletType__c;
                    }            
                    
                    accountMovements.add(accountMovement);
                    
                    newAccount.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                }
                
                //Record Grade
                if(oldAccount == null || newAccount.ASI_CRM_CN_Grade__c != oldAccount.ASI_CRM_CN_Grade__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_CN_Grade__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Grade';
                    accountMovement.ASI_CRM_NewValue__c = String.valueOf(newAccount.ASI_CRM_CN_Grade__c);
                    accountMovement.ASI_CRM_NewValueName__c = String.valueOf(newAccount.ASI_CRM_CN_Grade__c);
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;
                    accountMovement.ASI_CRM_Approved__c = True;               
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = String.valueOf(oldAccount.ASI_CRM_CN_Grade__c);
                        accountMovement.ASI_CRM_OldValueName__c = String.valueOf(oldAccount.ASI_CRM_CN_Grade__c);
                    }            
                    
                    accountMovements.add(accountMovement); 
                } 
                
                //Record Sales Potential
                if(oldAccount == null || newAccount.ASI_CRM_Sales_Potential__c != oldAccount.ASI_CRM_Sales_Potential__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_CRM_Sales_Potential__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Sales Potential';
                    accountMovement.ASI_CRM_NewValue__c = String.valueOf(newAccount.ASI_CRM_Sales_Potential__c);
                    accountMovement.ASI_CRM_NewValueName__c = String.valueOf(newAccount.ASI_CRM_Sales_Potential__c);
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;
                    accountMovement.ASI_CRM_Approved__c = True;               
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = String.valueOf(oldAccount.ASI_CRM_Sales_Potential__c);
                        accountMovement.ASI_CRM_OldValueName__c = String.valueOf(oldAccount.ASI_CRM_Sales_Potential__c);
                    }            
                    
                    accountMovements.add(accountMovement);
                } 
                
                //Record Outlet Image
                if(oldAccount == null || newAccount.ASI_TH_CRM_OutletImage__c != oldAccount.ASI_TH_CRM_OutletImage__c){
                    accountMovement = new ASI_CRM_AccountMovement__c();                
                    accountMovement.ASI_CRM_Account__c = newAccount.ASI_CRM_Account__c;
                    accountMovement.ASI_CRM_Field__c = 'ASI_TH_CRM_OutletImage__c';
                    accountMovement.ASI_CRM_FieldLabel__c = 'Outlet Image';
                    accountMovement.ASI_CRM_NewValue__c = String.valueOf(newAccount.ASI_TH_CRM_OutletImage__c);
                    accountMovement.ASI_CRM_UpdateDateTime__c = updateDatetime;
                    accountMovement.ASI_CRM_Approved__c = True; 
                    
                    //Modified by William Yang(Introv) 20150527
                    if(newOutletImages.get(newAccount.ASI_TH_CRM_OutletImage__c) != null)
                        accountMovement.ASI_CRM_NewValueName__c = String.valueOf(newOutletImages.get(newAccount.ASI_TH_CRM_OutletImage__c).Name);
      
                    if (tAction == TriggerAction.BEFORE_UPDATE){
                        accountMovement.ASI_CRM_OldValue__c = String.valueOf(oldAccount.ASI_TH_CRM_OutletImage__c);
                        
                        if(oldOutletImages.get(oldAccount.ASI_TH_CRM_OutletImage__c) != null)
                            accountMovement.ASI_CRM_OldValueName__c = String.valueOf(oldOutletImages.get(oldAccount.ASI_TH_CRM_OutletImage__c).Name);
                    }         
                    //End   
                    
                    accountMovements.add(accountMovement);
                }
            }                                                                                                                           
        }

        if(accountMovements != null && accountMovements.size() > 0)
            insert accountMovements;
            
        if(listCustomerToUpdate != null && listCustomerToUpdate.size() > 0)
            update listCustomerToUpdate;
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

    private String generateInvoiceAddress(ASI_CRM_AccountsAdditionalField__c accountAdditionalField){
            String  address = '';
            
            if (accountAdditionalField!= null){   
                // Update the address from Additional Field to Account            
                if (accountAdditionalField.ASI_CRM_TW_Invoice_City__c != null) address += accountAdditionalField.ASI_CRM_TW_Invoice_City__c;
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Town__c != null) address += accountAdditionalField.ASI_CRM_TW_Invoice_Town__c;
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Street__c != null) address += accountAdditionalField.ASI_CRM_TW_Invoice_Street__c;
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Section__c != null) address += accountAdditionalField.ASI_CRM_TW_Invoice_Section__c;
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Lane__c != null) address += accountAdditionalField.ASI_CRM_TW_Invoice_Lane__c + '巷';
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Alley__c != null) address += accountAdditionalField.ASI_CRM_TW_Invoice_Alley__c + '弄';
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Number__c != null) 
                {
                    address += accountAdditionalField.ASI_CRM_TW_Invoice_Number__c;
                    if (accountAdditionalField.ASI_CRM_TW_Invoice_Number_Hyphen__c != null) 
                        address += '之' + accountAdditionalField.ASI_CRM_TW_Invoice_Number_Hyphen__c;
                    address += '號';
                }
                
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Floor__c != null) 
                {
                    address += accountAdditionalField.ASI_CRM_TW_Invoice_Floor__c;
                    if (accountAdditionalField.ASI_CRM_TW_Invoice_Hyphen__c != null) 
                        address += '之' + accountAdditionalField.ASI_CRM_TW_Invoice_Hyphen__c;
                    address += '樓';
                }
                
                if (accountAdditionalField.ASI_CRM_TW_Invoice_Suite__c != null) address += accountAdditionalField.ASI_CRM_TW_Invoice_Suite__c + '室';
            }
        return address;    
    }

    private String generateWarehouseAddress(ASI_CRM_AccountsAdditionalField__c accountAdditionalField){
            String  address = '';
            
            if (accountAdditionalField!= null){   
                // Update the address from Additional Field to Account            
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_City__c != null) address += accountAdditionalField.ASI_CRM_TW_Warehouse_City__c;
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Town__c != null) address += accountAdditionalField.ASI_CRM_TW_Warehouse_Town__c;
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Street__c != null) address += accountAdditionalField.ASI_CRM_TW_Warehouse_Street__c;
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Section__c != null) address += accountAdditionalField.ASI_CRM_TW_Warehouse_Section__c;
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Lane__c != null) address += accountAdditionalField.ASI_CRM_TW_Warehouse_Lane__c + '巷';
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Alley__c != null) address += accountAdditionalField.ASI_CRM_TW_Warehouse_Alley__c + '弄';
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Number__c != null) 
                {
                    address += accountAdditionalField.ASI_CRM_TW_Warehouse_Number__c;
                    if (accountAdditionalField.ASI_CRM_TW_Warehouse_Number_Hyphen__c != null) 
                        address += '之' + accountAdditionalField.ASI_CRM_TW_Warehouse_Number_Hyphen__c;
                    address += '號';
                }
                
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Floor__c != null) 
                {
                    address += accountAdditionalField.ASI_CRM_TW_Warehouse_Floor__c;
                    if (accountAdditionalField.ASI_CRM_TW_Warehouse_Hyphen__c != null) 
                        address += '之' + accountAdditionalField.ASI_CRM_TW_Warehouse_Hyphen__c;
                    address += '樓';
                }
                
                if (accountAdditionalField.ASI_CRM_TW_Warehouse_Suite__c != null) address += accountAdditionalField.ASI_CRM_TW_Warehouse_Suite__c + '室';
            }
        return address;    
    }
}