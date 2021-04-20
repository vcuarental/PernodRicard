/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneController
 * Created : DC @02/02/2016 12:58 PM
 * Revision History:
 * 1. 02/02/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_TnE_TW_ClaimHeaderTriggerClass_Test {
 
    //----------------------------------------------------------Fiscal Year---------------------------------------------------------------------------------------
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
    private static TestMethod void testDeletionWithoutDetails() {

        ASI_MFM_PO__c testPo = ASI_TnE_TW_TestClassHelper.createPO();
        System.Test.startTest();
        ASI_TnE_ClaimHeader__c testHeader =
            ASI_TnE_TW_TestClassHelper.createClaimHeader('Inv-0001', 'ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header');

        insert testHeader;
        delete testHeader;
        System.Test.stopTest();

    }
    
    private static TestMethod void testDeletionWithDetails() {
        
        ASI_MFM_PO__c testPo = ASI_TnE_TW_TestClassHelper.createPO();
        System.Test.startTest();
        ASI_TnE_ClaimHeader__c testHeader =
            ASI_TnE_TW_TestClassHelper.createClaimHeader('Inv-0001', 'ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header');
        
        insert testHeader;
        ASI_TnE_ClaimDetail__c testDetail =
            ASI_TnE_TW_TestClassHelper.createClaimDetail(
                testHeader.Id,
                'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
                testPo.Id
            );
        
        insert testDetail;
        delete testHeader;
        System.Test.stopTest();
        
    }
    
    private static TestMethod void testUpdatewithePlan() {
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(Name = 'test', 
                                                     ASI_MFM_Module__c = 'Plan', 
                                                     Plan_Type__c = 'test', 
                                                     ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px; 
        User u = [select userRole.developerName from user where id =: userInfo.getUserId()];  
        
        ASI_MFM_Role_Prefix_Relationship__c pr = 
            new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = px.id, 
                                                    ASI_MFM_Role_Name__c = u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = 
                    new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
                                        Name= 'test', ASI_MFM_End_Date__c = Date.today().addMonths(1), 
                                        ASI_MFM_Plan_Description__c = 'testDescription', 
                                        ASI_MFM_Plan_Name__c = 'test', 
                                        ASI_MFM_Start_Date__c = Date.today().addMonths(1),  
                                        ASI_MFM_Prefix__c = px.id, ASI_MFM_Status__c = 'Final');
       insert p;
        System.Test.startTest();
        ASI_TnE_ClaimHeader__c testHeader = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = 'Inv-0001', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header')
        );
        insert testHeader;        
        
        List<ASI_TnE_ClaimDetail__c> detailList = new List<ASI_TnE_ClaimDetail__c>();
        ASI_TnE_ClaimDetail__c testDetail = new ASI_TnE_ClaimDetail__c( ASI_TnE_ClaimHeader__c = testHeader.id, 
                                                                     ASI_TnE_Receipt_Date__c = date.today(),
                                                                     ASI_TnE_Description__c = 'test description',
                                                                     ASI_TnE_Currency__c = 'TWD',
                                                                     ASI_TnE_Receipt_Amount__c = 100,
                                                                     ASI_TnE_FX_Rate__c = 1,
                                                                     ASI_TnE_CAP_Plan__c = p.id,
                                                                     recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail'));
        detailList.add(testDetail);
        ASI_TnE_ClaimDetail__c testDetail1 = new ASI_TnE_ClaimDetail__c( ASI_TnE_ClaimHeader__c = testHeader.id, 
                                                                     ASI_TnE_Receipt_Date__c = date.today(),
                                                                     ASI_TnE_Description__c = 'test description',
                                                                     ASI_TnE_Currency__c = 'TWD',
                                                                     ASI_TnE_Receipt_Amount__c = 100,
                                                                     ASI_TnE_FX_Rate__c = 1,
                                                                     ASI_TnE_CAP_Plan__c = p.id,
                                                                     recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail'));
        detailList.add(testDetail1);
        insert detailList;
        testHeader.ASI_TnE_Status__c = 'Submitted';
        update testHeader;
        System.Test.stopTest();

    }
}