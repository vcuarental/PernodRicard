/*********************************************************************************
 * Name: ASI_CRM_SG_Submit_for_ApprovalCtrl
 * Description: 
 * Test Class: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/03/2020       Ceterna                 Created
 * 08/04/2020       Wilken Lee              [WL 1.0] Requirement from SG user to make PROS checking optional
*/
public class ASI_CRM_SG_Submit_for_ApprovalCtrl {
    @AuraEnabled
    public Static String validateRecord(Id recordId){
        system.debug('@#debug'+recordId);
        try{
        ASI_CRM_AccountsAdditionalField__c customer = [Select id,ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_Business_Registration_Number__c, ASI_CRM_Legal_Outlet_Name__c, ASI_CRM_SG_Category_Code_13__c, ASI_CRM_JP_City_Ward__c, 
         ASI_CRM_PostalCode__c, ASI_CRM_CN_Phone_Number__c from ASI_CRM_AccountsAdditionalField__c where Id = :recordId limit 1]; 
        
        /*[WL 1.0] BEGIN*/
        /*List<ASI_CRM_Pros_Segmentation__c> detailRecords  = [Select Id, ASI_CRM_SG_DAMD_Threshold__c from ASI_CRM_Pros_Segmentation__c where 
                                                               ASI_CRM_SG_Customer__c = :recordId AND ASI_CRM_SG_DAMD_Threshold__c <> NULL ];*/
        /*[WL 1.0] END*/
        
        List<Contact> relatedContacts = [Select Id from Contact where ASI_CRM_AccountAdditionalField__c = : recordId];
        String groupOutletTypeName = '';
        if(customer.ASI_CRM_SG_Group_Outlet_Type__c != null) {
             List<ASI_CRM_Group_Outlet_Type__c> detailRecords2 =[SELECT ID, name, ASI_CRM_SG_Group_Outlet_Name__c FROM ASI_CRM_Group_Outlet_Type__c WHERE ID = : customer.ASI_CRM_SG_Group_Outlet_Type__c];
            if(detailRecords2!= null && detailRecords2.size()>0){
                groupOutletTypeName = detailRecords2[0].ASI_CRM_SG_Group_Outlet_Name__c;
            }
        }
        
        /*[WL 1.0] BEGIN*/
        /*if ((detailRecords == null || detailRecords.size() <= 0) && groupOutletTypeName != 'Offtrade'){
            return 'No valid Pros Segmentation found to submit for approval';
        }
        else */
        /*[WL 1.0] END*/
        if (relatedContacts == null || relatedContacts.size() <= 0){
            return 'Please enter at least one Contact for the Outlet';
        }
        // For SG CRM P2, check other required fields
        else if((customer.ASI_CRM_Business_Registration_Number__c== null || customer.ASI_CRM_Business_Registration_Number__c=='' )
                || (customer.ASI_CRM_Legal_Outlet_Name__c== null || customer.ASI_CRM_Legal_Outlet_Name__c=='' ) || (customer.ASI_CRM_SG_Category_Code_13__c== null || customer.ASI_CRM_SG_Category_Code_13__c=='' )
                || (customer.ASI_CRM_JP_City_Ward__c== null || customer.ASI_CRM_JP_City_Ward__c=='' )|| (customer.ASI_CRM_PostalCode__c== null || customer.ASI_CRM_PostalCode__c=='' )
                || (customer.ASI_CRM_CN_Phone_Number__c== null || customer.ASI_CRM_CN_Phone_Number__c=='' )){
                    return 'Please enter all required information: Legal Outlet Name, Business Registration Number, Address Line 1, Postal Code, Phone Number and Sector Code.';
        }else{
            return 'Success';               
        }
        }catch(exception e){
            return e.getMessage();
        }
    }
}