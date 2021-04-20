/*Filename:    ASI_CRM_TW_VPDTodayMassCancel_Ctrl.cls
* Author:      Twinkle LI (Introv Limited)
* Date:        2016/10/19
* Purpose:     Controller Class for Mass cancel of VPD Today Home Component
*
* History
* -----------------------------------------------------------------------------
*/
public with sharing class ASI_CRM_TW_VPDTodayMassCancel_Ctrl {
    public List<ASI_HK_CRM_Visitation_Plan_Detail__c> VPDToday {set; get;}
    public ASI_HK_CRM_Visitation_Plan_Detail__c vpdCancelReason {set; get;}
    public boolean showMerDaily {set;get;}
    
    public ASI_CRM_TW_VPDTodayMassCancel_Ctrl(ApexPages.StandardController controller) {
        init();
    }
    
    public void init(){
        showMerDaily = false; //default Sales Call Report
        
        VPDToday =  [SELECT Id,Name,ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName,ASI_HK_CRM_Visitation_Plan__c, 
                     ASI_HK_CRM_Account__c, ASI_HK_CRM_Account__r.Name, ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c,
                     ASI_HK_CRM_Visit_Date__c, ASI_CRM_Cancel_Reason__c, ASI_CRM_To_be_Cancelled__c
                     FROM ASI_HK_CRM_Visitation_Plan_Detail__c  
                     WHERE ASI_CRM_Cancel_Reason__c = null AND
                     ASI_HK_CRM_Visit_Date__c = TODAY AND 
                     ASI_HK_CRM_Visitation_Plan__r.OwnerId = :UserInfo.getUserID() AND 
                     (ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName = 'ASI_CRM_TW_Visitation_Plan' OR ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName = 'ASI_CRM_TW_Merchandiser_Visitation_Plan') ];
        
        if(VPDToday != NULL && VPDToday.size() > 0 &&
           VPDToday[0].ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName == 'ASI_CRM_TW_Merchandiser_Visitation_Plan'){
            showMerDaily=true;
        }
        
        vpdCancelReason = new ASI_HK_CRM_Visitation_Plan_Detail__c();
    }   
    
    public PageReference save(){
        system.debug('Enter Save');
        Boolean boolToBeCancelled = FALSE;
        
        if(String.isEmpty(vpdCancelReason.ASI_CRM_Cancel_Reason__c)){
            system.debug('Enter');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Cancel Reason.'));
            return null;
        }
        else{
            for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : VPDToday){
                if(vpd.ASI_CRM_To_be_Cancelled__c){
                    boolToBeCancelled = TRUE;
                    vpd.ASI_CRM_Cancel_Reason__c = vpdCancelReason.ASI_CRM_Cancel_Reason__c;
                    vpd.ASI_CRM_To_be_Cancelled__c = FALSE;
                }
            }
            
            if(!boolToBeCancelled){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least 1 Visitation Plan Detail to cancel.'));
                return null;
            }
            else{
                update VPDToday;       
                return new PageReference('/apex/ASI_CRM_TW_VPDToday');  
            }
        }  
    }    
}