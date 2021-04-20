public with sharing class ASI_CRM_CN_AddCallPlanController {

    //Original design, using custom object ASI_CRM_Call_Plan__c
    /*
    public ASI_CRM_Call_Plan__c Template {get;set;}
    
    public string Message {get;set;}
    
    private list<Account> selectedAccounts;
    private list<ASI_CRM_AccountsAdditionalField__c> selectedAccountAdditions;
    private string retURL = '';
    
    public ASI_CRM_CN_AddCallPlanController(ApexPages.StandardSetController controller) {
        
        Template = new ASI_CRM_Call_Plan__c();
        
        if(controller.getRecord().getSObjectType()==Account.SObjectType) {
            selectedAccounts = controller.getSelected();
        }
        else if(controller.getRecord().getSObjectType()==ASI_CRM_AccountsAdditionalField__c.SObjectType) {
            selectedAccountAdditions = controller.getSelected();
        }
        
        if((selectedAccounts==null || selectedAccounts.size()<=0) &&
           (selectedAccountAdditions==null || selectedAccountAdditions.size()<=0))
            Message = 'No Accounts selected to create call plan.';
        else
            Message = null;
            
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL==null) retURL = '/';
    }
    
    public PageReference createCallPlans() {
        
        set<Id> aIds = new set<Id>();
        set<Id> aaIds = new set<Id>();
        
        if(selectedAccounts!=null) {
            for(Account a :selectedAccounts) {
                aIds.add(a.Id);
            }        
            
            if(aIds.size()>0) {
                for(ASI_CRM_AccountsAdditionalField__c aa :[SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c in :aIds]) {
                    aaIds.add(aa.Id);
                }
            }
        }

        if(selectedAccountAdditions!=null) {
            for(ASI_CRM_AccountsAdditionalField__c aa :selectedAccountAdditions) {
                aaIds.add(aa.Id);
            }
        }
        
        if(aaIds.size()>0) {
        
            RecordType rt = Global_RecordTypeCache.getRtRec('ASI_CRM_Call_Plan__c'+'ASI_CRM_CallPlan_CN_Plan');
        
            list<ASI_CRM_Call_Plan__c> callPlans = new list<ASI_CRM_Call_Plan__c>();
            for(Id aaid :aaIds)
                callPlans.add(new ASI_CRM_Call_Plan__c(
                    RecordTypeId = rt.Id,
                    ASI_CRM_AccountsAdditionalField__c = aaid, 
                    ASI_CRM_Visit_Date__c = Template.ASI_CRM_Visit_Date__c));
            
            if(callPlans.size()>0)
                insert callPlans;
        }
        
        return new PageReference(retURL);
    }
    */
    
    public Contact DummyContact {get;set;} //for Date Field control
    
    public string Message {get;set;}
    
    private list<Account> selectedAccounts;
    private list<ASI_CRM_AccountsAdditionalField__c> selectedAccountAdditions;
    private string retURL = '';
    
    public ASI_CRM_CN_AddCallPlanController(ApexPages.StandardSetController controller) {
        
        DummyContact = new Contact();
        
        if(controller.getRecord().getSObjectType()==Account.SObjectType) {
            selectedAccounts = controller.getSelected();
        }
        else if(controller.getRecord().getSObjectType()==ASI_CRM_AccountsAdditionalField__c.SObjectType) {
            selectedAccountAdditions = controller.getSelected();
        }
        
        if((selectedAccounts==null || selectedAccounts.size()<=0) &&
           (selectedAccountAdditions==null || selectedAccountAdditions.size()<=0))
            Message = 'No Accounts selected to create call plan.';
        else
            Message = null;
            
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL==null) retURL = '/';
    }
    
    public PageReference createCallPlans() {
        
        set<Id> aIds = new set<Id>();
        set<ASI_CRM_AccountsAdditionalField__c> aas = new set<ASI_CRM_AccountsAdditionalField__c>();
        
        if(selectedAccounts!=null) {
            for(Account a :selectedAccounts) {
                aIds.add(a.Id);
            }        
            
            if(aIds.size()>0) {
                for(ASI_CRM_AccountsAdditionalField__c aa :[SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c in :aIds]) {
                    aas.add(aa);
                }
            }
        }

        if(selectedAccountAdditions!=null) {
            for(ASI_CRM_AccountsAdditionalField__c aa :selectedAccountAdditions) {
                aas.add(aa);
            }
        }
        
        if(aas.size()>0) {
        
            RecordType rt = Global_RecordTypeCache.getRtRec('Event'+'ASI_CRM_CN_Call_Plan');
        
            list<Event> events = new list<Event>();
            for(ASI_CRM_AccountsAdditionalField__c aa :aas)
                events.add(new Event(
                    RecordTypeId = rt.Id,
                    WhatId = aa.Id,
                    IsAllDayEvent = TRUE,
                    StartDateTime = DummyContact.Birthdate,
                    EndDateTime = DummyContact.Birthdate,
                    Subject = 'Call Plan: ' + aa.Name));
            
            if(events.size()>0){
                try{
                    insert events;
                }
                catch(exception e){
                    //Added by Michael Yip (Introv) 26Aug2014 to show error message
                    return null;
                }
            }
        }
        
        return new PageReference(retURL);
    }
    
}