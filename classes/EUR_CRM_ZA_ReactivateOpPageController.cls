/*
*    Description : Apex controller class for ZA Objective Promo Reactivation page
*
*    Version         Author            Date                Description
*    1.0             Sid               12/22/2015          
*/

public with sharing class EUR_CRM_ZA_ReactivateOpPageController {

    private static final String STR_ZA_OP_STATUS_ENDED = 'Ended';    //Sid 3.0
    
    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    public Boolean blnAllowReactivate {get; set;}

    //Constructor
    public EUR_CRM_ZA_ReactivateOpPageController(ApexPages.StandardController oStandardController){
    
        objPromo = (EUR_CRM_ObjPromo__c)oStandardController.getRecord();
        this.init();
    }
    
    //Initial Data population
    public void init(){
        
        blnAllowReactivate = false;
        List<EUR_CRM_ObjPromo__c> objPromoList = [select Id,
                                                         EUR_CRM_Status__c,
                                                         EUR_CRM_Active_Start_Date__c,
                                                         EUR_CRM_Active_End_Date__c,
                                                         EUR_CRM_Evaluation_Period_End_Date__c 
                                                  from EUR_CRM_ObjPromo__c 
                                                  where Id =: objPromo.Id];
        
        if(!objPromoList.isEmpty()){
            
            this.objPromo = objPromoList[0]; 
        }
    }
    
    //Cancel
    public pageReference cancel(){
    
        PageReference pr = new PageReference('/' + objPromo.id);
        pr.setRedirect(true);
        return pr;        
    }
    
    //reactivate
    public pagereference reactivate(){
    
        blnAllowReactivate = false;
        Boolean blnTemp = true;
        
        if(objPromo.EUR_CRM_Active_Start_Date__c < date.today()){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_StartDate_Validation));
            blnAllowReactivate = false;
            blnTemp = false;
        }
        
        if(objPromo.EUR_CRM_Active_End_Date__c < objPromo.EUR_CRM_Active_Start_Date__c){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_EndDate_Validation));
            blnAllowReactivate = false;
            blnTemp = false;
        }
        
        if(objPromo.EUR_CRM_Evaluation_Period_End_Date__c < objPromo.EUR_CRM_Active_End_Date__c){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_EvalEndDate_Validation));
            blnAllowReactivate = false;
            blnTemp = false;
        }
        blnAllowReactivate = blnTemp;
        
        if(!blnAllowReactivate){
            return null;
        }
        
        if(blnAllowReactivate){
            //Logic to set all ZA OP Account Mappings to true
            
            //Retrieve all the related OP Account Mapping records
            List<EUR_CRM_ObjPromo_Account_Mapping__c> zaOpAccMappingList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            zaOpAccMappingList = [select EUR_CRM_Is_Active__c 
                                  from EUR_CRM_ObjPromo_Account_Mapping__c 
                                  where EUR_CRM_ObjPromo__c =: objPromo.Id and 
                                  EUR_CRM_Do_Not_Reactivate__c = false];
            
            List<sObject> sObjectList = new List<sObject>();
            if(!zaOpAccMappingList.isEmpty()){
                
                for(EUR_CRM_ObjPromo_Account_Mapping__c objOpAccMapping : zaOpAccMappingList){
                
                    objOpAccMapping.EUR_CRM_Is_Active__c = true;
                    sObjectList.add(objOpAccMapping);
                }
                objPromo.EUR_CRM_Status__c = 'Active';
            }
            
            sObjectList.add(objPromo);
            
            try{
                update sObjectList;
            }
            catch(Exception ex){
                System.debug('========== ex ' + ex.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
            
            PageReference pr = new PageReference('/' + objPromo.id);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
}