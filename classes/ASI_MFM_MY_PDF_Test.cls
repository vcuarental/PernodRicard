@isTest
private class ASI_MFM_MY_PDF_Test {    
    static testMethod void ASI_MFM_MY_PDFTestPO() {
        Test.setCurrentPage(Page.ASI_MFM_MY_PO_PDF_Page);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_MY_Prefix'));
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_MY_Prefix'));
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        List<ASI_MFM_PO_Line_Item__c> poiList = new List<ASI_MFM_PO_Line_Item__c>();
        
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,
        ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
        ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10);
        poiList.add(poi1);
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,
        ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poiList.add(poi2);
        
        insert poiList;
        
        ASI_MFM_MY_PO_PDF_PageController ext = new ASI_MFM_MY_PO_PDF_PageController(new ApexPages.StandardController(po));
        ext.getLongDate();
        
        test.stopTest(); 
    }
    
    static testMethod void ASI_MFM_PDFTestPlan() {
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='MY';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_MY_Prefix'));
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Active__c = true); // Note :use Payment Prefix
        insert rtm;
        // ASI MFM Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        insert rrd;
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        insert rrd2;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode');
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_End_Date__c = Date.today().addMonths(1), 
        ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Draft');
        insert p;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC2', ASI_MFM_A_C_Code__c='5210.STK1');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Total_Cost__c = 10, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Total_Cost__c = 100, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2');
        insert pi2;
        //System.assertEquals(10, pi.ASI_MFM_Total_Cost__c);
        //System.assertEquals(100, pi2.ASI_MFM_Total_Cost__c);
        update p;
        //System.assertEquals(10, pi.ASI_MFM_Total_Cost__c);
        //System.assertEquals(100, pi2.ASI_MFM_Total_Cost__c);
        //System.assertEquals(110, p.ASI_MFM_Plan_Amount__c);
        
        //System.assertEquals(20, p.ASI_MFM_Plan_Amount__c);
        
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(p.id);
        req1.setSubmitterId(u.Id);
        req1.setNextApproverIds(new Id[] {u.id});
        req1.setSkipEntryCriteria(true);
        req1.setProcessDefinitionNameOrId('ASI_MFM_MY_Plan_Approval_Process');
        Approval.ProcessResult result = Approval.process(req1);
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');//     Reject
        req2.setNextApproverIds(new Id[] {u.id});
        
        if(result.getNewWorkitemIds().size()>0){
            req2.setWorkitemId(result.getNewWorkitemIds().get(0));
            Approval.process(req2);
        }*/
        Test.startTest();
        //create Approval Process
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(p.Id);
        req1.setNextApproverIds(new Id[] {u.id});
        Approval.ProcessResult result1 = Approval.process(req1);
        
        List<Id> newWorkItemIds = result1.getNewWorkitemIds();
        
        //System.assertEquals(null, newWorkItemIds);
        if (newWorkItemIds.size() > 0){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {u.id});
            req2.setWorkitemId(newWorkItemIds.get(0));
            Approval.ProcessResult result2 =  Approval.process(req2);
        }
        Test.setCurrentPage(Page.ASI_MFM_MY_Plan_PDF_Page);
        ApexPages.StandardController scons = new ApexPages.StandardController(p);
        ApexPages.currentPage().getParameters().put('id', scons.getId());
        ASI_MFM_MY_Plan_PDF_PageController ext = new ASI_MFM_MY_Plan_PDF_PageController(scons);
        ext.getapprovalDetails();
        
        delete pi;
        
        test.stopTest(); 
    }
}