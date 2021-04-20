@isTest
public class ASI_MFM_TW_PlanPDF_Test
{
    static testMethod void ASI_MFM_RedirectPlanPDFTest() {
        //Test Class for  ASI_MFM_RedirectPlanPDF_Ctr 
        Test.startTest();
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY0000');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                  ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
                                                ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
                                                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
                                                ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000', ASI_MFM_Additional_Brand_Manager_1__c=u.id);
        insert p;
        
        PageReference pageRef2 = new Pagereference('/apex/ASI_MFM_RedirectPlanPDFPage');
        Test.setCurrentPage(pageRef2);
        //ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
        ASI_MFM_RedirectPlanPDF_Ctr ext2 = new ASI_MFM_RedirectPlanPDF_Ctr(new ApexPages.StandardController(p));
        ext2.redirect();
        
        
            
        
        
    }
    
    
    static testMethod void ASI_MFM_PDFTestPlan() {
        Test.startTest();
        Test.setCurrentPage(Page.ASI_MFM_TW_PLan_PDF_Page);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY0000');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
                
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000', ASI_MFM_Additional_Brand_Manager_1__c=u.id);
        insert p;
        
        ASI_MFM_Plan__c p2 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000',ASI_MFM_Status__c='Final');
        insert p2;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test', ASI_MFM_A_and_P_Tree__c = 'Total A&P');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='Spending per Bottle', ASI_MFM_A_and_P_Tree__c = 'Total A&D');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10,ASI_MFM_Total_Cost__c=100
                                                                      ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_Size__c='1');
        insert pi1;
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10,ASI_MFM_Total_Cost__c=100
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi2;
        
        ASI_MFM_Plan_Line_Item__c pi3 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p2.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10,ASI_MFM_Total_Cost__c=100
                                                                      ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2');
        insert pi3;
        
        ASI_MFM_Budget_Setting__c bs = new ASI_MFM_Budget_Setting__c(Name='TW',ASI_MFM_Fiscal_Year__c='FY0000',ASI_MFM_Budget_Type__c='LE2');
        insert bs;
        
        ASI_MFM_Budget_Type_Mappings__c btm = new ASI_MFM_Budget_Type_Mappings__c(Name='TW',ASI_MFM_Budget_Type__c='LE2');
        insert btm;
        
        ASI_MFM_Budget__c bud = new ASI_MFM_Budget__c(ASI_MFM_Fiscal_Year__c='FY0000',ASI_MFM_P1_Amount__c=1000,ASI_MFM_Type__c = 'LE2',ASI_MFM_A_C_Code__c = ac.id,ASI_MFM_Sub_brand_Code__c=subBrand1.id);
        bud.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_TW_Budget');
        insert bud;
        
        ASI_MFM_Budget__c bud2 = new ASI_MFM_Budget__c(ASI_MFM_Fiscal_Year__c='FY0000',ASI_MFM_Type__c = 'LE2',ASI_MFM_A_C_Code__c = ac2.id,ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_Size__c='1');
        bud2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_TW_Budget');
        insert bud2;
        
        
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(p.id);
        req1.setSubmitterId(u.Id);
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');//     Reject
        req2.setNextApproverIds(new Id[] {u.id});
        
        if(result.getNewWorkitemIds().size()>0){
            req2.setWorkitemId(result.getNewWorkitemIds().get(0));
            Approval.process(req2);
        }
        
        ApexPages.StandardController scons = new ApexPages.StandardController(p);
        ApexPages.currentPage().getParameters().put('id', scons.getId());
        ApexPages.currentPage().getParameters().put('headId', p.id);
        ASI_MFM_TW_Plan_PDF_ComptController ext = new ASI_MFM_TW_Plan_PDF_ComptController();
        ext.lbBrand = 'a';
        ext.lbOutletType = 'a';
        ext.lbNoOfOutlet = 'a';
        ext.lbTargetVolume = 'a';
        ext.lbSpendingBottle = 'a';
        ext.lbFOC = 'a';
        ext.lbCash = 'a';
        ext.lbTotal = 'a';
        ext.lbBudgetPerBottle = 'a';
        ext.headerId = p.id;
        ext.init();
        ext.getapprovalDetails();
        test.stopTest(); 
    }
    
    static testMethod void ASI_MFM_PDFTestPlan2() {
        Test.startTest();
        Test.setCurrentPage(Page.ASI_MFM_TW_Plan2In1PDF_Page_ver2);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='Trade A&P and A&D Plan', ASI_MFM_Fiscal_year__c='FY0000');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
                
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000', ASI_MFM_Additional_Brand_Manager_1__c=u.id);
        insert p;
        
        ASI_MFM_Plan__c p2 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000',ASI_MFM_Status__c='Final');
        insert p2;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test', ASI_MFM_A_and_P_Tree__c = 'Total A&P');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='Spending per Bottle', ASI_MFM_A_and_P_Tree__c = 'Total A&D');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10,ASI_MFM_Total_Cost__c=100
                                                                      ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_Size__c='1');
        insert pi1;
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10,ASI_MFM_Total_Cost__c=100
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi2;
        
        ASI_MFM_Plan_Line_Item__c pi3 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p2.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10,ASI_MFM_Total_Cost__c=100
                                                                      ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2');
        insert pi3;
        
        ASI_MFM_Budget_Setting__c bs = new ASI_MFM_Budget_Setting__c(Name='TW',ASI_MFM_Fiscal_Year__c='FY0000',ASI_MFM_Budget_Type__c='LE2');
        insert bs;
        
        ASI_MFM_Budget_Type_Mappings__c btm = new ASI_MFM_Budget_Type_Mappings__c(Name='TW',ASI_MFM_Budget_Type__c='LE2');
        insert btm;
        
        ASI_MFM_Budget__c bud = new ASI_MFM_Budget__c(ASI_MFM_Fiscal_Year__c='FY0000',ASI_MFM_P1_Amount__c=1000,ASI_MFM_Type__c = 'LE2',ASI_MFM_A_C_Code__c = ac.id,ASI_MFM_Sub_brand_Code__c=subBrand1.id);
        bud.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_TW_Budget');
        insert bud;
        
        ASI_MFM_Budget__c bud2 = new ASI_MFM_Budget__c(ASI_MFM_Fiscal_Year__c='FY0000',ASI_MFM_Type__c = 'LE2',ASI_MFM_A_C_Code__c = ac2.id,ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_Size__c='1');
        bud2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_TW_Budget');
        insert bud2;
        
        /*
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(p.id);
        req1.setSubmitterId(u.Id);
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');//     Reject
        req2.setNextApproverIds(new Id[] {u.id});
        
        if(result.getNewWorkitemIds().size()>0){
            req2.setWorkitemId(result.getNewWorkitemIds().get(0));
            Approval.process(req2);
        }
        */
        ApexPages.StandardController scons = new ApexPages.StandardController(p);
        ApexPages.currentPage().getParameters().put('id', scons.getId());
        ApexPages.currentPage().getParameters().put('headId', p.id);
        ASI_MFM_TW_Plan2In1Pdf_Ctrl_ver2 ext = new ASI_MFM_TW_Plan2In1Pdf_Ctrl_ver2();
        ext.lbBrand = 'a';
        ext.lbOutletType = 'a';
        ext.lbNoOfOutlet = 'a';
        ext.lbTargetVolume = 'a';
        ext.lbSpendingBottle = 'a';
        ext.lbFOC = 'a';
        ext.lbCash = 'a';
        ext.lbTotal = 'a';
        ext.lbBudgetPerBottle = 'a';
        ext.headerId = p.id;
        ext.init();
        ext.getapprovalDetails();
        test.stopTest(); 
    }
}