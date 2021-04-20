/*********************************************************************************
 * Name:ASI_CRM_SG_Customer_Test
 * Description: Test all related code to the object Customer
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/02/2015         Laputa: Conrad        Created
 * 19/10/2015         Wilken Lee            Add testUpdateCustomerRelatedRecordOwner method to test customer owner change
 * 28/06/2017         Wilken Lee            [WL 1.0] Add coverage for ASI_CRM_SG_ReUpdate_Image_Level class
 * 18/07/2017         Wilken Lee            [WL 2.0] Add Biz Registration Number to Customer test data
*********************************************************************************/
@isTest
public class ASI_CRM_SG_Customer_Test {

    public static testmethod void testUpdateCustomerRelatedRecordOwner () {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
		/*[WL 2.0 Begin]*/
        //ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
		ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(false);
		customerC.customer.ASI_CRM_Business_Registration_Number__c = '123456789';
		insert customerC.customer;
		/*[WL 2.0 End]*/
		
        //Create Dummy Contract for update
        ASI_CRM_SG_TestClassHelper.contractData contract = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Contract Approved');
        
        //Create Dummy Payment for update 
        ASI_CRM_SG_TestClassHelper.paymentData payment = new ASI_CRM_SG_TestClassHelper.paymentData(true, contract);
        
        //Create Dummy FOC for update
        ASI_CRM_SG_TestClassHelper.freeGoodsData foc = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true, 'ASI_CRM_SG_FOC', 'Draft');
        
        User newOwner = ASI_CRM_SG_TestClassHelper.createUser('newOwner');
        
		/*[WL 1.0 Begin]*/
		ASI_CRM_Pros_Segmentation__c pros = new ASI_CRM_Pros_Segmentation__c(ASI_CRM_SG_Customer__c=customerC.customer.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Segmentation__cASI_CRM_SG_PROS_Segmentation'));
		insert pros;
		
		ASI_CRM_Group_Outlet_Type__c grpOutletType = new ASI_CRM_Group_Outlet_Type__c();
		insert grpOutletType;
		
		ASI_CRM_Image_Level__c imgLvl = new ASI_CRM_Image_Level__c();
		insert imgLvl;
		
		ASI_CRM_Image_Level_Threshold__c imgLvlThreshold = new ASI_CRM_Image_Level_Threshold__c(
																ASI_CRM_SG_Name__c='Test', 
																ASI_CRM_SG_Group_Outlet_Type__c=grpOutletType.Id, 
																ASI_CRM_SG_Image_Level__c=imgLvl.Id);
		insert imgLvlThreshold;
		
		customerC.customer.ASI_CRM_SG_SYS_New_Image_Level_Threshold__c = String.valueOf(imgLvlThreshold.Id);
		customerC.customer.ASI_CRM_SG_SYS_Pending_Approval__c = true;
		
		
		/*[WL 1.0 End]*/
        customerC.customer.ownerID = newOwner.ID;
        
        Update customerC.customer;
    }

    public static testmethod void testFinanceCustomer_Controller () {
		ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(customerC.customer);
        
        ASI_CRM_SG_FinanceCustomer_Controller finController = new ASI_CRM_SG_FinanceCustomer_Controller(sc);
        finController.save();
    
    }
    
    public static testmethod void testtrigger () {
    
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        ASI_CRM_SG_TestClassHelper.customerData outletData = new ASI_CRM_SG_TestClassHelper.customerData(false);
        ASI_CRM_SG_TestClassHelper.customerData outletData2 = new ASI_CRM_SG_TestClassHelper.customerData(false);
        ASI_CRM_SG_TestClassHelper.customerData outletData3 = new ASI_CRM_SG_TestClassHelper.customerData(false);
        
        List<ASI_CRM_AccountsAdditionalField__c> customerInsert = new List<ASI_CRM_AccountsAdditionalField__c>();
        customerInsert.add(outletData.customer);
        customerInsert.add(outletData2.customer);
        customerInsert.add(outletData3.customer);
        
        insert customerInsert;
        
        ASI_CRM_AccountsAdditionalField__c customertemp = outletData.customer;
        delete customertemp;
    
    }

}