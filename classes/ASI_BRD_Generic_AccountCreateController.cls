/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountCreateController
 * Description: Controller for Page ASI_BRD_Generic_AccountCreatePage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/9/2015         Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_BRD_Generic_AccountCreateController{
    private ASI_BRD_Generic_CRM_Mapping__c mapping = null;
    public ASI_BRD_Generic_AccountCreateController(ApexPages.StandardController controller) {
        User u = [Select ASI_BRD_CRM_Market__c From User Where Id = :UserInfo.getUserId()];
        if(u.ASI_BRD_CRM_Market__c != null && u.ASI_BRD_CRM_Market__c != ''){
            mapping = ASI_BRD_Generic_CRM_Mapping__c.getInstance(u.ASI_BRD_CRM_Market__c);
        }
    }
    
    public pageReference redirect(){
        if(mapping != null && mapping.ASI_BRD_Record_Type__c != null && mapping.ASI_BRD_Primary_Market_HTML_Id__c != null){
            return new pageReference('/001/e?RecordType=' + Global_RecordTypeCache.getRtId('Account' + mapping.ASI_BRD_Record_Type__c) + '&' + mapping.ASI_BRD_Primary_Market_HTML_Id__c + '=' + mapping.Name + '&nooverride=1');
        }else{
            return new pageReference('/001/o');
        }
    }
}