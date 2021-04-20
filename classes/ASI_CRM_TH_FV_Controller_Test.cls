/*Created by Kevani Chow @introv 23/05/2016
*
* Testclass for ASI_CRM_TH_FV_Controller
*/

@isTest
public class ASI_CRM_TH_FV_Controller_Test{

public static testMethod void ASI_CRM_TH_FV_Controller_Test() {

    user u = [SELECT id FROM user WHERE profile.Name = 'System Administrator' and isactive = true LIMIT 1];

    //Create Contract
    ASI_HK_CRM_Running_Number__c customerCodeRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Customer_Code', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = 'TH_A{000000}' );        
        try{
        insert customerCodeRunningNumber;
        } catch (System.DmlException e) {
        }
    
        ASI_HK_CRM_Running_Number__c contractRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Contract__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '{YY/YY}{0000}' );        
        try{
        insert contractRunningNumber;    
        } catch (System.DmlException e) {
        }
        
        ASI_HK_CRM_Running_Number__c paymentRequestRunningNumber= new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_PaymentRequest__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '60{YY}{0000}' );        
        try{
        insert paymentRequestRunningNumber;                    
        } catch (System.DmlException e) {
        }

            Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Potential_Outlet'), ownerid = u.id  );
            insert potentialOutlet ;                            
            
            ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
            ASI_TH_CRM_End_Date__c = date.today().addMonths(12), ASI_TH_CRM_Total_Fund_Advance__c = 10000,
            RecordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract'));
            insert contract;         
        
    
    ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(RecordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand'), Name='subbrand', ASI_MFM_Sub_brand_Code__c ='123', ownerid=u.id, ASI_TH_CRM_Active__c=true);
    insert subBrand;
    
    Account vendor = new Account(RecordTypeId=Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Supplier'), Name='vendor',ASI_TH_CRM_Region__c='31-BKK', ASI_KOR_Venue_Business_License_Number__c='123', ownerid=u.id);
    insert vendor;
    
    ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(RecordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_A_C_Code__cASI_CRM_TH_A_C_Code'),Name ='5558.202',ownerid=u.id, ASI_MFM_A_C_Code__c='5558.202',ASI_MFM_A_C_Description__c='Fund - Cash AC Code');
    insert acCode;
    
    ASI_MFM_Tax_Code__c taxCode = new ASI_MFM_Tax_Code__c(RecordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_Tax_Code__cASI_CRM_TH_Tax_Code'), Name='505',ownerid=u.id);
    insert taxCode;

    
     id rtIDPR = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request');
     id rtIDPRitm = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_TH_CRM_Payment_Request_Detail');
     
     ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c = contract.id, RecordTypeID = rtIDPR, ASI_TH_CRM_Status__c='Approved');
     insert paymentRequest;        
            
     List<ASI_TH_CRM_PaymentRequestLineItem__c> listpaymentRequestLineitem = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
     listpaymentRequestLineitem.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
     ASI_TH_CRM_Payment_Request__c = paymentRequest.id, ASI_TH_CRM_Quantity__c = 1, ASI_TH_CRM_UnitCost__c = 200, 
     ASI_TH_CRM_Amount__c = 300, ASI_TH_CRM_COA__c = 'Fund - Cash AC Code', ASI_CRM_Invoice_Due_Date__c =Date.today()
     ));
            
     listpaymentRequestLineitem.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
     ASI_TH_CRM_Payment_Request__c = paymentRequest.id, ASI_TH_CRM_Quantity__c = 1, ASI_TH_CRM_UnitCost__c = 200, 
     ASI_TH_CRM_Invoice_No__c = '123', ASI_TH_CRM_Amount__c = 300, ASI_TH_CRM_COA__c = 'Fund - Cash AC Code', RecordTypeID = rtIDPRitm
     ));
     
     insert listpaymentRequestLineitem;


    System.runAs(u) {
    Test.startTest();
    ApexPages.StandardController stdController = new ApexPages.StandardController(paymentRequest);
    ASI_CRM_TH_FV_Controller controller = new ASI_CRM_TH_FV_Controller(stdController);
    
                
        controller.seacrhConNo=contract.name;
        controller.searchPayReqNo=paymentRequest.name;
        controller.searchVendor='vendor';
        controller.searchTaxId='123';
        controller.searchACCode='5558.202';
        controller.searchStatus='Approved';
        controller.searchDueDateFrom.ASI_CRM_Invoice_Due_Date__c = Date.Today();
        controller.searchDueDateTo.ASI_CRM_Invoice_Due_Date__c = Date.Today();
        
        controller.save();
        controller.firstPage();
        controller.lastPage();
        controller.prevPage();
        controller.nextPage();
        controller.runSearch();
        controller.save();
        controller.toggleSort();
        controller.gotopage();
        test.stopTest(); 
    

    }
}
}