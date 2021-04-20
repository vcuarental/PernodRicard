/*********************************************************************************
 * Name:ASI_CRM_JP_ListingList_Test
 * Description: Test Class for Listing List Object
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/4/2015       Laputa: Conrad            Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_ListingList_Test {

    static testMethod void ASI_CRM_ListingList_Validate(){
    
        ASI_CRM_JP_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_JP_TestClassHelper.createCustomer();
        
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
        insert itemGroup;
        
        ASI_MFM_Item_Group__c itemGroup1 = new ASI_MFM_Item_Group__c(Name = 'Test1', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
        insert itemGroup1;
        
        ASI_CRM_Listing_List__c listingList = new ASI_CRM_Listing_List__c(
                                                                            ASI_CRM_Customer__c=customer.id, 
                                                                            ASI_CRM_Item_Group__c=itemGroup.id, 
                                                                            ASI_CRM_Reg_Volume_Monthly__c=10, 
                                                                            recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Listing_List__cASI_CRM_JP_Listing_List')
                                                                         );
        insert listingList;
        
        listingList.ASI_CRM_Item_Group__c= itemGroup1.id;
        update listingList;
        
    }

}