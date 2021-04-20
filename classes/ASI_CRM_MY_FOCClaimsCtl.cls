/*********************************************************************************
 * Name: ASI_CRM_MY_FOCClaimsCtl
 * Description: Controller class for ASI_CRM_MY_FOCClaimsPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-01-26       Daniel WONG             Created 
 */


public with sharing class ASI_CRM_MY_FOCClaimsCtl{
        
    private ApexPages.StandardController standardController {get;set;}
    private Id FOCId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
    
    public list<ASI_FOC_Request_Item__c> getFOCItem(){    
        List<ASI_FOC_Request_Item__c> lstFOCItem = [
            SELECT id, ASI_FOC_SKU__c, ASI_FOC_SKU__r.ASI_MFM_SKU_Description__c,
                   ASI_FOC_Issued_Qty__c, ASI_CRM_SetupCode__c, ASI_CRM_GLReasonCode__c, ASI_FOC_Remark__c,
                   LastModifiedDate
            FROM ASI_FOC_Request_Item__c
            WHERE ASI_FOC_Request_Order__c = :FOCId 
            //ORDER BY ASI_CRM_SKU__r.name ASC
        ];
        
             
        return lstFOCItem;
    }
        
    public ASI_CRM_MY_FOCClaimsCtl(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if(FOCId != NULL){
        }
    }
}