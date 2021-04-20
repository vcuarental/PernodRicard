@isTest
private class ASI_MFM_PDF_Test {
    
    static testMethod void ASI_MFM_PDFTestPlan() {
        Test.startTest();
        Test.setCurrentPage(Page.ASI_MFM_PLan_PDF_PAGE);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
                
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id);
        insert p;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC2', ASI_MFM_A_C_Code__c='5210.STK1');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2');
        insert pi2;
        
        ASI_MFM_Plan_PDF_PageController ext = new ASI_MFM_Plan_PDF_PageController(new ApexPages.StandardController(p));
        test.stopTest(); 
    }
    
    static testMethod void ASI_MFM_PDFTestPayment() {
        Test.setCurrentPage(Page.ASI_MFM_Payment_PDF_Page);
          
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        List<Account> accountToInsert = new List<Account>();
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2',ASI_MFM_Applicable__c =true);           
        accountToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3',ASI_MFM_Applicable__c =true);           
        accountToInsert.add(acc2);
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name3',ASI_MFM_Applicable__c =true);           
        accountToInsert.add(acc3);
        
        insert accountToInsert;

        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        Test.startTest();
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
        ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        

        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
               
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id);
        insert py;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment_List_Item_Description__c='測試 1',recordTypeId=rt_map.get('ASI_MFM_TW_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        ASI_MFM_Payment_PDF_PageController ext = new ASI_MFM_Payment_PDF_PageController(new ApexPages.StandardController(py));
        test.stopTest(); 
    }
    
    static testMethod void ASI_MFM_PDFTestPO() {
        Test.setCurrentPage(Page.ASI_MFM_PO_PDF_Page);
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');  
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;             
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test', ASI_MFM_Prefix__c=px.id,
        ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
        ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
       ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test3', ASI_MFM_Prefix__c=px.id,
        ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
        ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today());
        insert p3;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');    
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');   
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        insert acc1;
        
        Test.startTest();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                    
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id,
        ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        ASI_MFM_PO_PDF_PageController ext = new ASI_MFM_PO_PDF_PageController(new ApexPages.StandardController(po));
        
        test.stopTest(); 
    }
}