@isTest
public class ASI_MFM_HK_PO_Webservice_AmountRele_Test {

     static testmethod void test_ASI_MFM_HK_PO_Webservice_AmountRelease_Fail(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_Webservice_AmountRelease/';  
    	req.httpMethod = 'POST';
        String request = '[{"transactions":[{"concurReportId":null}]}]';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res; 
        
        ASI_MFM_HK_PO_Webservice_AmountRelease.getPORecord();
        
        Test.stopTest();
    }
    
    static testmethod void test_ASI_MFM_HK_PO_Webservice_AmountRelease_Success(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_Webservice_AmountRelease/';  
    	req.httpMethod = 'POST';
        String request = '[{"transactions":[{"concurReportId":"Report001"}, {"concurReportId":"Report002"}, {"concurReportId":"Report003"}]}]';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res; 
        
        ASI_MFM_HK_PO_Webservice_AmountRelease.getPORecord();
        
        Test.stopTest();
    }
    
    static testmethod void test_ASI_MFM_HK_PO_Webservice_AmountRelease_Success2(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        List<Account> accList = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3');           
        accList.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'), Name='Name2');           
        accList.add(acc1);
        insert accList;

		ASI_HK_CRM_Running_Number__c runNum = new ASI_HK_CRM_Running_Number__c();
        runNum.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Header';
        runNum.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum;   
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Invoice_Amount_from_JDE__c = 10000, ASI_MFM_T_E_Amount__c = 10000); 
            insert po;

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;            
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),ASI_TnE_KR_External_ID__c='Report001',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_Webservice_AmountRelease/';  
    	req.httpMethod = 'POST';
		String request = '[{"transactions":[{"concurReportId":"Report001"}, {"concurReportId":"Report002"}, {"concurReportId":"Report003"}]}]';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_Webservice_AmountRelease.getPORecord();
        
        Test.stopTest();
    }
    
}