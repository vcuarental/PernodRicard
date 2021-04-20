@isTest
public class ASI_MFM_HK_PO_BalanceCheck_Test {

    static testmethod void test_ASI_MFM_HK_PO_BalanceCheck_failUserName(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        String email = UserInfo.getUserName();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_BalanceCheck/';  
    	req.httpMethod = 'POST';
        String request = '{"concurReportId":"Report001","currentUser":"Peter.Wong@Pernod-Ricard.com","transactions":[{"recordNumber":"92170004", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "Marketing Expense"}, {"recordNumber":"AP150004", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)"}, {"recordNumber":"92170004", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : "Marketing Expense"}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_BalanceCheck.getPORecord();
        
        Test.stopTest();
    }

    static testmethod void test_ASI_MFM_HK_PO_BalanceCheckFail1(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
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
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), Name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Plan__c p2 = [select id, name from ASI_MFM_Plan__c where id = :p.id];
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Total_Cost__c = 100);   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Invoice_Amount_from_JDE__c = 10000, ASI_MFM_T_E_Amount__c = 10000, ASI_MFM_Exchange_Rate__c = 1); 
            insert po;
        
        	ASI_MFM_PO__c po2 = [select id, name from ASI_MFM_PO__c where id = :po.id];

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;            
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_BalanceCheck/';  
    	req.httpMethod = 'POST';
        String username = UserInfo.getUserName();
        String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"poNumber":"'+po.name+'","CAPEXPlanNumber":"'+p2.name+'","recordNumber":"'+p2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "'+p2.name+'"}, {"recordNumber":"'+po2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)2"}, {"recordNumber":"'+po2.name+'", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : "Marketing Expense"}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_BalanceCheck.getPORecord();
        
        Test.stopTest();
    }
    
    
    static testmethod void test_ASI_MFM_HK_PO_BalanceCheckFail2(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
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
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), Name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Plan__c p2 = [select id, name from ASI_MFM_Plan__c where id = :p.id];
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Total_Cost__c = 100);   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Invoice_Amount_from_JDE__c = 10000, ASI_MFM_T_E_Amount__c = 10000, ASI_MFM_Exchange_Rate__c = 1); 
            insert po;
        
        	ASI_MFM_PO__c po2 = [select id, name from ASI_MFM_PO__c where id = :po.id];

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;            
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_BalanceCheck/';  
    	req.httpMethod = 'POST';
        String username = UserInfo.getUserName();
        String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"poNumber":"'+po.name+'","CAPEXPlanNumber":"'+p.name+'","recordNumber":"'+p.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "'+p.name+'"}, {"recordNumber":"'+po.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)2"}, {"recordNumber":"'+po.name+'", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : "Marketing Expense"}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_BalanceCheck.getPORecord();
        
        Test.stopTest();
    }
    
    
    static testmethod void test_ASI_MFM_HK_PO_BalanceCheckSuccess(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
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
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), Name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Plan__c p2 = [select id, name from ASI_MFM_Plan__c where id = :p.id];
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Total_Cost__c = 100);   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Invoice_Amount_from_JDE__c = 10000, ASI_MFM_T_E_Amount__c = 10000, ASI_MFM_Exchange_Rate__c = 1); 
            insert po;
        
        	ASI_MFM_PO__c po2 = [select id, name from ASI_MFM_PO__c where id = :po.id];

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;            
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_BalanceCheck/';  
    	req.httpMethod = 'POST';
        String username = UserInfo.getUserName();
        //String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"recordNumber":"'+p2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "'+p2.name+'"}, {"recordNumber":"'+po2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)2"}, {"recordNumber":"'+po2.name+'", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : "Marketing Expense"}]}';
        String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"recordNumber":"'+p2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "'+p2.name+'"}, {"recordNumber":"'+po2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)"}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_BalanceCheck.getPORecord();
        
        Test.stopTest();
    }
    
    static testmethod void test_ASI_MFM_HK_PO_BalanceCheckFail3(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
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
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), Name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Plan__c p2 = [select id, name from ASI_MFM_Plan__c where id = :p.id];
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Total_Cost__c = 100);   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Invoice_Amount_from_JDE__c = 10000, ASI_MFM_T_E_Amount__c = 10000, ASI_MFM_Exchange_Rate__c = 1); 
            insert po;
        
        	ASI_MFM_PO__c po2 = [select id, name from ASI_MFM_PO__c where id = :po.id];

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;            
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_BalanceCheck/';  
    	req.httpMethod = 'POST';
        String username = UserInfo.getUserName();
        String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"recordNumber":"'+p2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "'+p2.name+'"}, {"recordNumber":"'+p2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)"},{"recordNumber":"'+po2.name+'", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : ""}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_BalanceCheck.getPORecord();
        
        Test.stopTest();
    }
    
    static testmethod void test_ASI_MFM_HK_PO_BalanceCheckFail4(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
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
        
        ASI_HK_CRM_Running_Number__c runNum1 = new ASI_HK_CRM_Running_Number__c();
        runNum1.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Detail';
        runNum1.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum1.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum1;   
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), Name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Plan__c p2 = [select id, name from ASI_MFM_Plan__c where id = :p.id];
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Total_Cost__c = 100);   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Invoice_Amount_from_JDE__c = 10000, ASI_MFM_T_E_Amount__c = 10000, ASI_MFM_Exchange_Rate__c = 1); 
            insert po;
        
        	ASI_MFM_PO__c po2 = [select id, name from ASI_MFM_PO__c where id = :po.id];

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;            
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),ASI_TnE_Status__c='Final',ASI_TnE_KR_External_ID__c='Report001');
		insert header;
        
        ASI_TnE_ClaimDetail__c detail1 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'));
        insert detail1;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_BalanceCheck/';  
    	req.httpMethod = 'POST';
        String username = UserInfo.getUserName();
        String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"recordNumber":"'+p2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "'+p2.name+'"}, {"recordNumber":"'+p2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)"},{"recordNumber":"'+po2.name+'", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : "123"}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_BalanceCheck.getPORecord();
        
        Test.stopTest();
    }
	
	static testmethod void test_Fail5(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
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
        
        ASI_HK_CRM_Running_Number__c runNum1 = new ASI_HK_CRM_Running_Number__c();
        runNum1.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Detail';
        runNum1.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum1.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum1;   
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), Name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Plan__c p2 = [select id, name from ASI_MFM_Plan__c where id = :p.id];
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Total_Cost__c = 100);   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Invoice_Amount_from_JDE__c = 10000, ASI_MFM_T_E_Amount__c = 10000, ASI_MFM_Exchange_Rate__c = 1); 
            insert po;
        
        	ASI_MFM_PO__c po2 = [select id, name from ASI_MFM_PO__c where id = :po.id];
			po2.ASI_MFM_Status__c = 'Final';
			update po2;

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;            
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),ASI_TnE_Status__c='Final',ASI_TnE_KR_External_ID__c='Report001');
		insert header;
        
        ASI_TnE_ClaimDetail__c detail1 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'));
        insert detail1;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_BalanceCheck/';  
    	req.httpMethod = 'POST';
        String username = UserInfo.getUserName();
        String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"RecordNumber":"'+po2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "marketing expense"}, {"recordNumber":"'+po2.name+'", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "marketing expense"},{"recordNumber":"'+po2.name+'", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : "marketing expense"}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_BalanceCheck.getPORecord();
        
        Test.stopTest();
    }
    
}