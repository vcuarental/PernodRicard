/*********************************************************************************
 * Name: ASI_CRM_TH_ReUpdate_Image_Level
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_ReUpdate_Image_Level
*********************************************************************************/

public with sharing class ASI_CRM_TH_ReUpdate_Image_Level{
    
    public static void updateCustomerImageLevel(List<ASI_CRM_AccountsAdditionalField__c> updatedCustomer, List<ASI_CRM_AccountsAdditionalField__c> oldData){
        
        List<ASI_CRM_AccountsAdditionalField__c> custToUpdate = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        for(Integer x = 0; x < updatedCustomer.size(); x++){
            if(updatedCustomer[x].ASI_CRM_SG_SYS_Pending_Approval__c && updatedCustomer[x].ASI_CRM_SG_SYS_Pending_Approval__c != oldData[x].ASI_CRM_SG_SYS_Pending_Approval__c){
                custToUpdate.add(updatedCustomer[x]);
            }
        }
        
        if(custToUpdate.size() > 0){
           Map<Id, ASI_CRM_Pros_Segmentation__c> cpMap = prosToUpdate(custToUpdate);
           updatePros(custToUpdate, cpMap);
        }    
    }
    
    public static Map<Id, ASI_CRM_Pros_Segmentation__c> prosToUpdate(List<ASI_CRM_AccountsAdditionalField__c> custList){       
        Map<Id, ASI_CRM_Pros_Segmentation__c> custProsMap = new Map<Id, ASI_CRM_Pros_Segmentation__c>();
        
        Set<Id> custIds = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c c : custList){
            custIds.add(c.Id);
        }
        
        for(ASI_CRM_Pros_Segmentation__c pros : [SELECT Id, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Image_Level_Threshold__c, ASI_CRM_SG_Image_Level__c FROM ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Customer__c in: custIds]){
            custProsMap.put(pros.ASI_CRM_SG_Customer__c, pros);
        }        
        return custProsMap;
    }
    
    public static void updatePros(List<ASI_CRM_AccountsAdditionalField__c> custList, Map<Id, ASI_CRM_Pros_Segmentation__c> custProsMap){
        
        List<ASI_CRM_Pros_Segmentation__c> prosListToUpdate = new List<ASI_CRM_Pros_Segmentation__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c  cus : custList){
            ASI_CRM_Pros_Segmentation__c ps = custProsMap.get(cus.Id);
            if(cus.ASI_CRM_SG_SYS_New_Image_Level_Threshold__c != null)
            {
                system.debug('**New ILT '+ Id.valueOf(cus.ASI_CRM_SG_SYS_New_Image_Level_Threshold__c.substringBeforeLast('&')));
            	ps.ASI_CRM_SG_Image_Level_Threshold__c = Id.valueOf(cus.ASI_CRM_SG_SYS_New_Image_Level_Threshold__c.substringBeforeLast('&'));
            
            	prosListToUpdate.add(ps); 
            }
                       
        }        
        update prosListToUpdate;        
    }
}