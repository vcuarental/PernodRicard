@isTest 
private class ASI_FOC_testClass_DL {
    @TestSetup
    static void preTestData() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        userA.ASI_CRM_Sales_Team__c = 'HQ-Others';
        update userA;
        ASI_CRM_Region__c hqRegion = new ASI_CRM_Region__c(Name = 'Headquarter');
        insert hqRegion;
        ASI_CRM_Division__c hqDiv = new ASI_CRM_Division__c(Name = 'HQ(Div)');
        hqDiv.ASI_CRM_Region__c = hqRegion.Id;
        insert hqDiv;
        ASI_CRM_Sales_Team__c steam = new ASI_CRM_Sales_Team__c();
        steam.Name = 'HQ-Others';
        steam.ASI_CRM_Division__c = hqDiv.Id;
        insert steam;
    }

    static testMethod void testSubmitRequestController() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_POSM_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_POSM_Logistic_Approver__c = userInfo.getUserId(), ASI_FOC_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_Logistic_Approver__c = userInfo.getUserId());
        insert rt;
        
        List<ASI_FOC_Route_Criteria__c> rc_list = new List<ASI_FOC_Route_Criteria__c>();
        ASI_FOC_Route_Criteria__c rc1 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=0, ASI_FOC_POSM_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc2 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=1, ASI_FOC_POSM_Threshold__c=1, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc3 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=2, ASI_FOC_POSM_Threshold__c=2, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc4 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=3, ASI_FOC_POSM_Threshold__c=3, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc5 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=4, ASI_FOC_POSM_Threshold__c=4, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc6 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=5, ASI_FOC_POSM_Threshold__c=5, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc7 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=6, ASI_FOC_POSM_Threshold__c=6, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc8 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=7, ASI_FOC_POSM_Threshold__c=7, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc9 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=8, ASI_FOC_POSM_Threshold__c=8, ASI_FOC_Approver__c=userInfo.getUserId());
        rc_list.add(rc1);
        rc_list.add(rc2);
        rc_list.add(rc3);
        rc_list.add(rc4);
        rc_list.add(rc5);
        rc_list.add(rc6);
        rc_list.add(rc7);
        rc_list.add(rc8);
        rc_list.add(rc9);
        insert rc_list;  
        
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
        insert po;
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Event_PO_Remarks__c = 'test',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));
        insert fr;
        
        apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
        ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
        cx.goBack();
        cx.submitRequest();
        
        fr.ASI_FOC_Request_Status__c = 'Open';
        update fr;
        cx.submitRequest();
        
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30000, ASI_FOC_Brand_Director_Approval_Required__c=true);
        insert ri;  
        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);
        cx.submitRequest();
        
        ri.ASI_FOC_Brand_Approver__c = u.id;
        update ri;        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);        
        cx.submitRequest();         
        
        po.ASI_FOC_PO_Final_Amount__c = 40000;
        update po;        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);
        cx.submitRequest();
        cx.confirm();
    }
        
    }
    
    static testMethod void testTriggers_FreeGoods() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));   
        }
        insert skuList;
        
        ASI_FOC_Warehouse__c whc = new ASI_FOC_Warehouse__c(name='test');
        insert whc;
        
        ASI_MFM_Expense_Control_Form__c ecf = new ASI_MFM_Expense_Control_Form__c(name='Product barter', ASI_MFM_Tax_Saving_Purpose__c='Product barter');
        insert ecf;
        
        ASI_MFM_Expense_Control_Form__c logisticSetting = new ASI_MFM_Expense_Control_Form__c();
        logisticSetting.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_CN_Logistics_Btl_Control_Form');
        logisticSetting.Name = 'Other';
        logisticSetting.ASI_CRM_CN_FG_Bottle_Size__c = 'Other';
        logisticSetting.ASI_CRM_CN_FG_Logistics_Cost_per_Btl__c = 10;
        insert logisticSetting;
        
        test.startTest();
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Event_PO_Remarks__c = 'test',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));
        insert fr;
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item'));
        insert ri;
        
        fr.ASI_MFM_FromWarehouse__c = whc.id;
        fr.ASI_FOC_To_Regional_Warehouse__c = whc.id;
        fr.ASI_FOC_Purpose__c = 'Product barter';
        update fr;
    }
        test.stopTest();
    }
    
    static testMethod void testTriggers() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));   
        }
        insert skuList;
        
        //test.startTest();
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Event_PO_Remarks__c = 'test',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));
        insert fr;
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
        insert ri;
        test.startTest();
        fr.ASI_FOC_Sys_Submitted__c = true;
        update fr;
        ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
        update ri;
        fr = [select id from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        fr.ASI_FOC_Sys_Approved_By_Finance__c = true;
        update fr;         
        ASI_CRM_TOV__c tov = new ASI_CRM_TOV__c(ASI_CRM_Free_Goods_Request__c = fr.id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV'));
        insert tov;
        tov.ASI_CRM_Status__c = 'Released';
        update tov;
        tov.ASI_CRM_Status__c = 'Received';
        update tov; 
        test.stopTest();
    }
    }
    
    static testMethod void testTriggers_2() {
        
        //20180130 Introv
        
        List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        insert tmpItemGroup;
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                             , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                            );
        
        Insert tmpSku;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));   
        }
        insert skuList;
        
        test.startTest();
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request_Read_Only'));
        insert fr;
        
        List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
        
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
        ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
        
        riList.add(ri);
        riList.add(ri2);
        
        insert riList;
        fr.ASI_FOC_Sys_Submitted__c = true;
        fr.ASI_FOC_Rejected_by_System__c = False;
        fr.ASI_FOC_Request_Status__c = 'In Progress';//20180131 Introv
        fr.ASI_FOC_CN_Already_4_Days__c = true;
        update fr;
        ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
        update ri;
        //fr = [select id from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        //fr.ASI_FOC_Sys_Approved_By_Finance__c = true;
        update fr;
        
        fr.ASI_FOC_Request_Status__c = 'Rejected';
        fr.ASI_FOC_Rejected_by_System__c = True;
        fr.ASI_FOC_Sys_Approved_By_Finance__c = False;
        fr.ASI_FOC_Sys_Submitted__c = False;
        Update fr;
        
        //20180430 Introv
        ASI_FOC_Free_Goods_Request_TriggerClass.getApprovalComments(new Set<Id>{fr.id});
        
        test.stopTest();
    }
    
    static testMethod void testTriggers_3() {
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        //20180130 Introv
        
        List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        insert tmpItemGroup;
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                             , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                            );
        
        Insert tmpSku;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));   
        }
        insert skuList;
        
        test.startTest();
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Rejected_by_System__c = True, ASI_FOC_Request_Status__c = 'Rejected by Logistic', ASI_FOC_Request_Type__c='Logistic Cost', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only'));
        insert fr;
        
        List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
        
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_ETL_Complete__c = true, ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
        ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_FOC_ETL_Complete__c = true, ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
        
        riList.add(ri);
        riList.add(ri2);
        
        //insert riList;
        ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
        //update ri;
        
        fr.ASI_FOC_Rejected_by_System__c = True;
        //update fr;
        
        List<ASI_FOC_Free_Goods_Request__c> tmpFGList = RetrieveFOCInfo(Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap(), 'WHERE id = \'' + fr.id + '\'');
        
        Map<id, ASI_FOC_Free_Goods_Request__c> tmpFGMap = new Map<id, ASI_FOC_Free_Goods_Request__c>();
        
        for(ASI_FOC_Free_Goods_Request__c obj : tmpFGList){
            
            ASI_FOC_Free_Goods_Request__c tmp = new ASI_FOC_Free_Goods_Request__c();
            tmp.ASI_FOC_Rejected_by_System__c = False;
            
            tmpFGMap.put(obj.id, tmp);
        }
        
        ASI_FOC_Free_Goods_Request_TriggerClass.routineAfterUpdate(tmpFGList, tmpFGMap);
        
        insert riList;
        ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
        update ri;
        fr.ASI_FOC_Sys_Submitted__c = True;
        fr.ASI_FOC_Sys_Approved_By_Logistic__c = True;
        fr.ASI_FOC_Request_Status__c = 'Approved by Logistic';
        Update fr;
        
        tmpFGList = new List<ASI_FOC_Free_Goods_Request__c>();
        tmpFGList.add(fr);
        
        ASI_FOC_Free_Goods_Request_TriggerClass.routineAfterUpdate(tmpFGList, tmpFGMap);
        
        test.stopTest();
    }
    }
    
    static testMethod void testTriggers_4() {
        
        //20180130 Introv
        
        List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
        List<ASI_CRM_Fix_Approval_Route__c> fixList = new List<ASI_CRM_Fix_Approval_Route__c>();
        fixList.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_Finance_Approver__c = userInfo.getUserId()
                                                      , ASI_CRM_Logistic_Approver__c = userInfo.getUserId()
                                                      , ASI_CRM_CN_Type__c = 'Free Goods Request'
                                                      , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')
                                                     ));
        
        Insert fixList;
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        insert tmpItemGroup;
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                             , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                            );
        
        Insert tmpSku;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            
            ASI_MFM_SKU_Code__c tmp = skuGen.generateSKU(null);
            tmp.ASI_FOC_Brand_Director_Approval_Required__c = True;
            skuList.add(tmp);   
        }
        insert skuList;
        
        /*List<user> sysAdminList = [SELECT id From USER WHERE Profile.Name Like 'ASI System Admin%'];
        
        user sysAdmin = sysAdminList.size() > 0 ? sysAdminList[0] : [SELECT id From USER WHERE id = : userInfo.getUserId()];
            
            system.runAs(sysAdmin){*/
                test.startTest();
                ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Sys_Submitted__c = True, ASI_FOC_Sys_Approved_By_Logistic__c = True, ASI_FOC_Request_Status__c = 'Approved by Logistic', ASI_FOC_Request_Type__c='Logistic Cost', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only'));
                insert fr;
                //Update fr;
                List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
                
                ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Brand_Director_Approval_Status__c = 'Approved', ASI_FOC_ETL_Complete__c = true, ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
                //ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_FOC_ETL_Complete__c = true, ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
                
                riList.add(ri);
                
                List<ASI_FOC_Free_Goods_Request__c> tmpFGList = RetrieveFOCInfo(Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap(), 'WHERE id = \'' + fr.id + '\'');
                
                Map<id, ASI_FOC_Free_Goods_Request__c> tmpFGMap = new Map<id, ASI_FOC_Free_Goods_Request__c>();
                
                insert riList;
                ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
                update ri;
                fr.ASI_FOC_Sys_Submitted__c = True;
                fr.ASI_FOC_Sys_Approved_By_Logistic__c = True;
                fr.ASI_FOC_Request_Status__c = 'Approved by Logistic';
                Update fr;
                
                tmpFGList = new List<ASI_FOC_Free_Goods_Request__c>();
                tmpFGList.add(fr);
                
                ASI_FOC_Free_Goods_Request_TriggerClass.routineAfterUpdate(tmpFGList, tmpFGMap);
                
                fr.ASI_FOC_Request_Status__c = 'Open';
                Update fr;
                
                ri.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
                update ri;
                delete riList;
                
                test.stopTest();
            //}
    }
    
    static testMethod void testRegionApproval() {
        
        //20180130 Introv
        
        List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
        List<ASI_CRM_Fix_Approval_Route__c> fixList = new List<ASI_CRM_Fix_Approval_Route__c>();
        fixList.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c  = userInfo.getUserId()
                                                      , ASI_CRM_CN_Approver_2__c  = userInfo.getUserId()
                                                      , ASI_CRM_CN_Region_Area_Channel__c = 'TestRegion'
                                                      , ASI_CRM_CN_Type__c = 'POSM'
                                                      , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')
                                                     ));
        
        Insert fixList;
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        insert tmpItemGroup;
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                             , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                            );
        
        Insert tmpSku;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            
            ASI_MFM_SKU_Code__c tmp = skuGen.generateSKU(null);
            tmp.ASI_FOC_Brand_Director_Approval_Required__c = True;
            skuList.add(tmp);   
        }
        insert skuList;
        
        
        List<ASI_CRM_Region__c> tmpRegion = new List<ASI_CRM_Region__c>();
        tmpRegion.add(new ASI_CRM_Region__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region')
                                            	, Name = 'TestRegion'
                                            	, OwnerID = userinfo.getUserId()
        									));
        
        insert tmpRegion;
        
        List<ASI_FOC_Warehouse__c> tmpWarehouse = new List<ASI_FOC_Warehouse__c>();
        tmpWarehouse.add(new ASI_FOC_Warehouse__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse')
                                                   , Name = 'TestWarehouse'
                                                   , ASI_FOC_Warehouse_Code__c = 'TestCode'
                                                   , ASI_FOC_JDE_Customer_Number__c = 'TestWarehouse'
                                                   , ASI_FOC_Warehouse_Type__c = 'Region Warehouse'
                                                   , ASI_FOC_Region__c = tmpRegion[0].id
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        
        insert tmpWarehouse;
        
        List<ASI_MFM_Inventory_Balance__c> tmpIB = new List<ASI_MFM_Inventory_Balance__c>();
        tmpIB.add(new ASI_MFM_Inventory_Balance__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance')
                                                   , ASI_MFM_SKU__c = skuList[0].id
                                                   , ASI_MFM_Warehouse__c = tmpWarehouse[0].id
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        
        insert tmpIB;
        
        
        List<ASI_MFM_InventoryBalanceDetail__c> tmpIBDList = new List<ASI_MFM_InventoryBalanceDetail__c>();
        
        ASI_MFM_InventoryBalanceDetail__c tmpIBD = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                   , Name = '20181019'
                                                   , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                   , ASI_MFM_Quantity__c = 100
                                                   , ASI_MFM_SFDCAvailableQuantity__c = 100
                                                   , ASI_MFM_JDEAvailableQuantity__c = 100
                                                   , ASI_MFM_Action__c = 'Disposal'
                                                  );
        
        ASI_MFM_InventoryBalanceDetail__c tmpIBD2 = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                   , Name = '20181019'
                                                   , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                   , ASI_MFM_Quantity__c = 200
                                                   , ASI_MFM_SFDCAvailableQuantity__c = 200
                                                   , ASI_MFM_JDEAvailableQuantity__c = 200
                                                   , ASI_MFM_Action__c = 'Disposal'
                                                  );
        
        tmpIBDList.add(tmpIBD);
        tmpIBDList.add(tmpIBD2);
                
        insert tmpIBDList;
        
        
        
        /*List<user> sysAdminList = [SELECT id From USER WHERE Profile.Name Like 'ASI System Admin%'];
        
        user sysAdmin = sysAdminList.size() > 0 ? sysAdminList[0] : [SELECT id From USER WHERE id = : userInfo.getUserId()];
            
            system.runAs(sysAdmin){*/
                
                ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_MFM_ForPOSMCart__c = TRUE, ASI_FOC_To_Regional_Warehouse__c = tmpWarehouse[0].id, ASI_FOC_Sys_Submitted__c = True, ASI_FOC_Sys_Approved_By_Logistic__c = True, ASI_FOC_Request_Status__c = 'Approved by Logistic', ASI_FOC_Request_Type__c='Logistic Cost', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM'));
                insert fr;
                //Update fr;
                List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
                
                ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_MFM_IBD__c = tmpIBDList[0].id, ASI_FOC_Brand_Director_Approval_Status__c = 'Approved', ASI_FOC_ETL_Complete__c = false, ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
                //ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_FOC_ETL_Complete__c = true, ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
                
                riList.add(ri);
        
                List<ASI_FOC_Free_Goods_Request__c> tmpFGList = RetrieveFOCInfo(Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap(), 'WHERE id = \'' + fr.id + '\'');
                
                Map<id, ASI_FOC_Free_Goods_Request__c> tmpFGMap = new Map<id, ASI_FOC_Free_Goods_Request__c>();
                
                insert riList;
                test.startTest();
        
        		List<ASI_MFM_CN_JCT_FGL_IBD__c> jctList = new List<ASI_MFM_CN_JCT_FGL_IBD__c>();
        		jctList.add(new ASI_MFM_CN_JCT_FGL_IBD__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_CN_JCT_FGL_IBD__cASI_MFM_CN_POSM')
                    ,ASI_MFM_Request_Item__c=riList[0].id,ASI_MFM_IBD__c=tmpIBDList[0].id));
                insert jctList;

                ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
                update ri;
                fr.ASI_FOC_Sys_Submitted__c = True;
                fr.ASI_FOC_Sys_Approved_By_Logistic__c = True;
                fr.ASI_FOC_Request_Status__c = 'Approved by Logistic';
                Update fr;
                
                tmpFGList = new List<ASI_FOC_Free_Goods_Request__c>();
                tmpFGList.add(fr);
                
                ASI_FOC_Free_Goods_Request_TriggerClass.routineAfterUpdate(tmpFGList, tmpFGMap);
                
        
        		//fr.ASI_FOC_Request_Status__c = 'Final';
                //Update fr;
        		
        		//tmpIBDList[0].ASI_MFM_JDEAvailableQuantity__c = 99;
        		//tmpIBDList[1].ASI_MFM_JDEAvailableQuantity__c = 199;
                //Update tmpIBDList;

        
                fr.ASI_FOC_Request_Status__c = 'Open';
                Update fr;
                
                fr.recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
                Update fr;
                
                ri.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
                update ri;
                delete riList;
                
                test.stopTest();
            //}
    }
    
    static testMethod void testRegionApproval2() {
        
        //20180130 Introv
        
        List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
        List<ASI_CRM_Fix_Approval_Route__c> fixList = new List<ASI_CRM_Fix_Approval_Route__c>();
        fixList.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c  = userInfo.getUserId()
                                                      , ASI_CRM_CN_Approver_2__c  = userInfo.getUserId()
                                                      , ASI_CRM_CN_Region_Area_Channel__c = 'TestRegion'
                                                      , ASI_CRM_CN_Type__c = 'POSM'
                                                      , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')
                                                     ));
        
        Insert fixList;
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        insert tmpItemGroup;
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                             , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                            );
        
        Insert tmpSku;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            
            ASI_MFM_SKU_Code__c tmp = skuGen.generateSKU(null);
            tmp.ASI_FOC_Brand_Director_Approval_Required__c = True;
            skuList.add(tmp);   
        }
        insert skuList;
        
        
        List<ASI_CRM_Region__c> tmpRegion = new List<ASI_CRM_Region__c>();
        tmpRegion.add(new ASI_CRM_Region__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region')
                                            	, Name = 'TestRegion'
                                            	, OwnerID = userinfo.getUserId()
        									));
        
        insert tmpRegion;
        
        List<ASI_FOC_Warehouse__c> tmpWarehouse = new List<ASI_FOC_Warehouse__c>();
        tmpWarehouse.add(new ASI_FOC_Warehouse__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse')
                                                   , Name = 'TestWarehouse'
                                                   , ASI_FOC_Warehouse_Code__c = 'TestCode'
                                                   , ASI_FOC_JDE_Customer_Number__c = 'TestWarehouse'
                                                   , ASI_FOC_Warehouse_Type__c = 'Region Warehouse'
                                                   , ASI_FOC_Region__c = tmpRegion[0].id
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        
        insert tmpWarehouse;
        
        List<ASI_MFM_Inventory_Balance__c> tmpIB = new List<ASI_MFM_Inventory_Balance__c>();
        tmpIB.add(new ASI_MFM_Inventory_Balance__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance')
                                                   , ASI_MFM_SKU__c = skuList[0].id
                                                   , ASI_MFM_Warehouse__c = tmpWarehouse[0].id
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        
        insert tmpIB;
        
        
        List<ASI_MFM_InventoryBalanceDetail__c> tmpIBDList = new List<ASI_MFM_InventoryBalanceDetail__c>();
        
        ASI_MFM_InventoryBalanceDetail__c tmpIBD = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                   , Name = '20181019'
                                                   , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                   , ASI_MFM_Quantity__c = 100
                                                   , ASI_MFM_SFDCAvailableQuantity__c = 100
                                                   , ASI_MFM_JDEAvailableQuantity__c = 100
                                                   , ASI_MFM_Action__c = 'Disposal'
                                                  );
        
        ASI_MFM_InventoryBalanceDetail__c tmpIBD2 = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                   , Name = '20181019'
                                                   , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                   , ASI_MFM_Quantity__c = 200
                                                   , ASI_MFM_SFDCAvailableQuantity__c = 200
                                                   , ASI_MFM_JDEAvailableQuantity__c = 200
                                                   , ASI_MFM_Action__c = 'Disposal'
                                                  );
        
        tmpIBDList.add(tmpIBD);
        tmpIBDList.add(tmpIBD2);
                
        insert tmpIBDList;
        
        
        
        /*List<user> sysAdminList = [SELECT id From USER WHERE Profile.Name Like 'ASI System Admin%'];
        
        user sysAdmin = sysAdminList.size() > 0 ? sysAdminList[0] : [SELECT id From USER WHERE id = : userInfo.getUserId()];
            
            system.runAs(sysAdmin){*/
                //test.startTest();
                //202009 add by LEO BLS
                ASI_FOC_Free_Goods_Request__c frApprovalHeader = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Status__c = 'Approved by Logistic'
                                                                                    , ASI_FOC_Request_Type__c='POSM'
                                                                                    , ASI_FOC_Description__c='POSM'
                                                                                    , ASI_FOC_Batch_Import_KEY__c = 'Test1234'
                                                                                    , recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_CN_POSM_Batch_Approval'));
                insert frApprovalHeader;
                
                ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_POSM_Request_Approval__c = frApprovalHeader.Id,ASI_MFM_ForPOSMCart__c = TRUE, ASI_FOC_To_Regional_Warehouse__c = tmpWarehouse[0].id, ASI_FOC_Sys_Submitted__c = True, ASI_FOC_Sys_Approved_By_Logistic__c = True, ASI_FOC_Request_Status__c = 'Approved by Logistic', ASI_FOC_Request_Type__c='Logistic Cost', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM'));
                insert fr;
                //Update fr;  
                
                //202009 add by LEO BLS
                ASI_FOC_Request_Item__c riApprovalHeader = new ASI_FOC_Request_Item__c(  ASI_FOC_Brand_Director_Approval_Status__c = 'Open'
                                                                                        , ASI_FOC_Request_Order__c=fr.id
                                                                                        , ASI_FOC_POSM_Request_Approval__c = frApprovalHeader.Id
                                                                                        , ASI_FOC_Batch_Import_KEY__c = 'Test12345'                                                                                       
                                                                                        , recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_CRM_CN_POSM_Request_Item_Batch_Approval'));
                insert riApprovalHeader;

                List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
                
                ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_MFM_Request_Item_Approval__c=riApprovalHeader.Id ,ASI_MFM_IBD__c = tmpIBDList[0].id, ASI_FOC_Brand_Director_Approval_Status__c = 'Approved', ASI_FOC_ETL_Complete__c = false, ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
                //ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_FOC_ETL_Complete__c = true, ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
                
                riList.add(ri);
        
                List<ASI_FOC_Free_Goods_Request__c> tmpFGList = RetrieveFOCInfo(Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap(), 'WHERE id = \'' + fr.id + '\'');
                
                Map<id, ASI_FOC_Free_Goods_Request__c> tmpFGMap = new Map<id, ASI_FOC_Free_Goods_Request__c>();
                
                insert riList;
        
        		List<ASI_MFM_CN_JCT_FGL_IBD__c> jctList = new List<ASI_MFM_CN_JCT_FGL_IBD__c>();
        		jctList.add(new ASI_MFM_CN_JCT_FGL_IBD__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_CN_JCT_FGL_IBD__cASI_MFM_CN_POSM')
                    ,ASI_MFM_Request_Item__c=riList[0].id,ASI_MFM_IBD__c=tmpIBDList[0].id));
                insert jctList;

                ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
                update ri;
                fr.ASI_FOC_Sys_Submitted__c = True;
                fr.ASI_FOC_Sys_Approved_By_Logistic__c = True;
                fr.ASI_FOC_Request_Status__c = 'Approved by Logistic';
                Update fr;
                
                tmpFGList = new List<ASI_FOC_Free_Goods_Request__c>();
                tmpFGList.add(fr);
                
        
        		test.startTest();
                ASI_FOC_Free_Goods_Request_TriggerClass.routineAfterUpdate(tmpFGList, tmpFGMap);
                
                //202009 add by Leo BLS
                riApprovalHeader.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
                try{update riApprovalHeader;}catch(Exception e){}
                riApprovalHeader.ASI_FOC_Brand_Director_Approval_Status__c = 'Rejected';
                update riApprovalHeader;

                //202009 add by LEO BLS
                frApprovalHeader.ASI_FOC_Request_Status__c ='Final';
                update frApprovalHeader;
                frApprovalHeader.ASI_FOC_Request_Status__c ='Rejected';
                update frApprovalHeader;
        
        
        		fr.ASI_FOC_Request_Status__c = 'Final';
                Update fr;
        		
        		tmpIBDList[0].ASI_MFM_JDEAvailableQuantity__c = 99;
        		tmpIBDList[1].ASI_MFM_JDEAvailableQuantity__c = 199;
                Update tmpIBDList;

        
                fr.ASI_FOC_Request_Status__c = 'Open';
                Update fr;
                
                fr.recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
                Update fr;
                
                ri.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
                update ri;
                delete riList;
                
                test.stopTest();
            //}
    }
    
    static testMethod void testItemApproval() {
        
        //20180130 Introv
        list<User> users = new list<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        users.add(user2);
        users.add(user1);
        insert users;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
        
        System.runAs(user1) {
            List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
            
            List<ASI_CRM_Fix_Approval_Route__c> fixList = new List<ASI_CRM_Fix_Approval_Route__c>();
            fixList.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c  = userInfo.getUserId()
                                                          , ASI_CRM_CN_Approver_2__c  = userInfo.getUserId()
                                                          , ASI_CRM_CN_Region_Area_Channel__c = 'TestRegionItem'
                                                          , ASI_CRM_CN_Type__c = 'POSM'
                                                          , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')
                                                         ));
            
            Insert fixList;
            
            tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                       , Name = 'TestItemGroup'
                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                       , OwnerID = userinfo.getUserId()
                                                      ));
            insert tmpItemGroup;
            
            ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                                 , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                                 , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                                 , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                                );
            
            Insert tmpSku;
            
            user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
            insert rt;
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                         ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
            insert rc;  
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            final Integer numOfSKU = 5;
            List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
            ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
            for (Integer i = 0; i < numOfSKU; i++) {
                
                ASI_MFM_SKU_Code__c tmp = skuGen.generateSKU(null);
                tmp.ASI_FOC_Brand_Director_Approval_Required__c = True;
                skuList.add(tmp);   
            }
            insert skuList;
            
            
            List<ASI_CRM_Region__c> tmpRegion = new List<ASI_CRM_Region__c>();
            tmpRegion.add(new ASI_CRM_Region__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region')
                                                    , Name = 'TestRegion'
                                                    , OwnerID = userinfo.getUserId()
                                                ));
            
            insert tmpRegion;
            
            List<ASI_FOC_Warehouse__c> tmpWarehouse = new List<ASI_FOC_Warehouse__c>();
            tmpWarehouse.add(new ASI_FOC_Warehouse__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse')
                                                       , Name = 'TestWarehouse'
                                                       , ASI_FOC_Warehouse_Code__c = 'TestCode'
                                                       , ASI_FOC_JDE_Customer_Number__c = 'TestWarehouse'
                                                       , ASI_FOC_Warehouse_Type__c = 'Region Warehouse'
                                                       , ASI_FOC_Region__c = tmpRegion[0].id
                                                       , OwnerID = userinfo.getUserId()
                                                      ));
            
            insert tmpWarehouse;
            
            List<ASI_MFM_Inventory_Balance__c> tmpIB = new List<ASI_MFM_Inventory_Balance__c>();
            tmpIB.add(new ASI_MFM_Inventory_Balance__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance')
                                                       , ASI_MFM_SKU__c = skuList[0].id
                                                       , ASI_MFM_Warehouse__c = tmpWarehouse[0].id
                                                       , OwnerID = userinfo.getUserId()
                                                      ));
            
            insert tmpIB;
            
            
            List<ASI_MFM_InventoryBalanceDetail__c> tmpIBDList = new List<ASI_MFM_InventoryBalanceDetail__c>();
            
            ASI_MFM_InventoryBalanceDetail__c tmpIBD = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                       , Name = '20181019'
                                                       , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                       , ASI_MFM_Quantity__c = 100
                                                       , ASI_MFM_SFDCAvailableQuantity__c = 100
                                                       , ASI_MFM_JDEAvailableQuantity__c = 100
                                                       , ASI_MFM_Action__c = 'Disposal'
                                                       , ASI_MFM_SFDCOwner__c = user2.id
                                                      );
            
            ASI_MFM_InventoryBalanceDetail__c tmpIBD2 = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                       , Name = '20181019'
                                                       , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                       , ASI_MFM_Quantity__c = 200
                                                       , ASI_MFM_SFDCAvailableQuantity__c = 200
                                                       , ASI_MFM_JDEAvailableQuantity__c = 200
                                                       , ASI_MFM_Action__c = 'Disposal'
                                                       , ASI_MFM_SFDCOwner__c = user2.id
                                                      );
            
            tmpIBDList.add(tmpIBD);
            tmpIBDList.add(tmpIBD2);
                    
            insert tmpIBDList;

            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_MFM_ForPOSMCart__c = TRUE, ASI_FOC_To_Regional_Warehouse__c = tmpWarehouse[0].id, ASI_FOC_Request_Status__c = 'Open', ASI_FOC_Request_Type__c='Logistic Cost', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM'));
            insert fr;
            //Update fr;
            List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_MFM_IBD__c = tmpIBDList[0].id, ASI_FOC_Brand_Director_Approval_Status__c = 'Approved', ASI_FOC_ETL_Complete__c = true, ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item'));
            ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_MFM_IBD__c = tmpIBDList[1].id, ASI_FOC_Brand_Director_Approval_Status__c = 'Approved', ASI_FOC_ETL_Complete__c = true, ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item'));
            
            riList.add(ri);
            riList.add(ri2);
            
            List<ASI_FOC_Free_Goods_Request__c> tmpFGList = RetrieveFOCInfo(Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap(), 'WHERE id = \'' + fr.id + '\'');
            
            Map<id, ASI_FOC_Free_Goods_Request__c> tmpFGMap = new Map<id, ASI_FOC_Free_Goods_Request__c>();
            
            insert riList;
            test.startTest();
            
            List<ASI_MFM_CN_JCT_FGL_IBD__c> jctList = new List<ASI_MFM_CN_JCT_FGL_IBD__c>();
            jctList.add(new ASI_MFM_CN_JCT_FGL_IBD__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_CN_JCT_FGL_IBD__cASI_MFM_CN_POSM')
                                                      ,ASI_MFM_Request_Item__c=riList[0].id,ASI_MFM_IBD__c=tmpIBDList[0].id));
            insert jctList;

            fr.ASI_FOC_Request_Status__c = 'In Progress';
            Update fr;
            
            ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
            update ri;
            ri2.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
            update ri2;
            fr.ASI_FOC_Sys_Submitted__c = True;
            fr.ASI_FOC_Sys_Approved_By_Logistic__c = True;
            fr.ASI_FOC_Request_Status__c = 'Approved by Logistic';
            Update fr;

            tmpFGList = new List<ASI_FOC_Free_Goods_Request__c>();
            tmpFGList.add(fr);
            
            ASI_FOC_Free_Goods_Request_TriggerClass.routineAfterUpdate(tmpFGList, tmpFGMap);
            
            fr.ASI_FOC_Request_Status__c = 'Open';
            Update fr;
            
            fr.recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
            Update fr;
            
            ri.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
            update ri;
            delete riList;
            
            test.stopTest();
            
        }
    }
    
    static testMethod void testStatusChange() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));   
        }
        insert skuList;
        
        test.startTest();
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Event_PO_Remarks__c = 'test',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Status__c = 'Open');
        insert fr;
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
        
        
        insert ri;
        fr.ASI_FOC_Number_of_Saves__c = 1;
        update fr;
        fr.recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request_Read_Only');
       	fr.ASI_FOC_Request_Status__c = 'Submitted';
        update fr;
		
		/*[WL 1.0 Begin]*/
		system.debug('WL 1.0 Debug Begin');
		fr.ASI_FOC_Sys_Submitted__c = true;
		fr.ASI_FOC_Sys_Approved_By_Logistic__c = true;
		fr.ASI_FOC_Sys_Approved_By_Finance__c = true;
		fr.ASI_FOC_Request_Status__c = 'Approved by Logistic';
		fr.ASI_FOC_Number_of_Saves__c = 2;
        fr.ASI_FOC_Rejected_by_System__c = false;//20180129 Introv
        update fr;
		
		/*[WL 1.0 End]*/
		
        fr.ASI_FOC_Rejected_by_System__c = True;//20180129 Introv
        fr.recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only');
       	fr.ASI_FOC_Request_Status__c = 'Rejected by Logistic';
        update fr;   
        delete fr; 
    }
        test.stopTest();     
    }
    
    static testMethod void LineItemTriggerTest() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));  
        }
        skuList[0].ASI_FOC_Brand_Director_Approval_Required__c = true;
        insert skuList;
        
        //test.startTest();
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Event_PO_Remarks__c = 'test',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true, ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));
        insert fr;
        test.startTest();
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'),ASI_FOC_Cancel_Quantity_PC_BT__c = 1, ASI_FOC_Original_Request_Quantity_PC_BT__c = 1);
        insert ri;
        fr.ASI_FOC_Sys_Submitted__c = true;
        update fr;
        ri.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
        update ri;
        fr = [select id from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        fr.ASI_FOC_Sys_Approved_By_Finance__c = true;
        update fr;         
        test.stopTest();
        delete fr; 
        }       
    }
    
    static testMethod void testPOSMApprovalRouteController() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_POSM_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_POSM_Logistic_Approver__c = userInfo.getUserId(), ASI_FOC_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_Logistic_Approver__c = userInfo.getUserId());
        insert rt;
        
        List<ASI_FOC_Route_Criteria__c> rc_list = new List<ASI_FOC_Route_Criteria__c>();
        ASI_FOC_Route_Criteria__c rc1 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=0, ASI_FOC_POSM_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc2 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=1, ASI_FOC_POSM_Threshold__c=1, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc3 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=2, ASI_FOC_POSM_Threshold__c=2, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc4 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=3, ASI_FOC_POSM_Threshold__c=3, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc5 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=4, ASI_FOC_POSM_Threshold__c=4, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc6 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=5, ASI_FOC_POSM_Threshold__c=5, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc7 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=6, ASI_FOC_POSM_Threshold__c=6, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc8 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=7, ASI_FOC_POSM_Threshold__c=7, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc9 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=8, ASI_FOC_POSM_Threshold__c=8, ASI_FOC_Approver__c=userInfo.getUserId());
        rc_list.add(rc1);
        rc_list.add(rc2);
        rc_list.add(rc3);
        rc_list.add(rc4);
        rc_list.add(rc5);
        rc_list.add(rc6);
        rc_list.add(rc7);
        rc_list.add(rc8);
        rc_list.add(rc9);
        insert rc_list;  
        
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generatePOSMSKU(null));
        }
        insert skuList;
        
        ASI_FOC_Delivery_Zone__c dz = new ASI_FOC_Delivery_Zone__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'));
        insert dz;
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_MFM_ForPOSMCart__c = TRUE, ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', ASI_FOC_CN_Delivery_Zone__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM'));
        insert fr;
        Test.startTest();
        apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
        ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
        cx.goBack();
        cx.submitRequest();
        
        fr.ASI_FOC_Request_Status__c = 'Open';
        update fr;
        cx.submitRequest();
        
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30000, ASI_FOC_Brand_Director_Approval_Required__c=true);
        insert ri;  
        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);
        cx.submitRequest();
        
        ri.ASI_FOC_Brand_Approver__c = u.id;
        update ri;        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);        
        cx.submitRequest();         
        
        po.ASI_FOC_PO_Final_Amount__c = 40000;
        update po;        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);
        cx.submitRequest();
        cx.confirm();
        Test.stopTest();
        
    }
   
    static testMethod void testLineApprovalController() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE 'ASI System Administrator']; //20180205 Introv changed System Administrator to ASI System Administrator //20181206 Introv tested that it could pass on staging, so please ignore failure on B5
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        u.ASI_CRM_Sales_Team__c = 'HQ-Others';
        update u;
        
        System.runAs(u){
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_POSM_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_POSM_Logistic_Approver__c = userInfo.getUserId(), ASI_FOC_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_Logistic_Approver__c = userInfo.getUserId());
            insert rt;
            
            List<ASI_FOC_Route_Criteria__c> rc_list = new List<ASI_FOC_Route_Criteria__c>();
            ASI_FOC_Route_Criteria__c rc1 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                          ASI_FOC_Threshold__c=0, ASI_FOC_POSM_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
            ASI_FOC_Route_Criteria__c rc2 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                          ASI_FOC_Threshold__c=1, ASI_FOC_POSM_Threshold__c=1, ASI_FOC_Approver__c=userInfo.getUserId());
            
            rc_list.add(rc1);
            rc_list.add(rc2);
            insert rc_list;  
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
            insert po;
            
            final Integer numOfSKU = 5;
            List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
            ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
            for (Integer i = 0; i < numOfSKU; i++) {
                skuList.add(skuGen.generatePOSMSKU(null));
            }
            insert skuList;
            
            ASI_FOC_Delivery_Zone__c dz = new ASI_FOC_Delivery_Zone__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'));
            insert dz;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Event_PO_Remarks__c = 'test',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_FOC_Request_Type__c='Consumer A&P',ASI_FOC_Sys_Approved_By_Logistic__c=true, ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', ASI_FOC_CN_Delivery_Zone__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'),ASI_FOC_Description__c='test');
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30000, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId());
            insert ri; 
            
            ri.ASI_FOC_ETL_Complete__c=true;
            update ri;
            Test.startTest();
        	System.debug(Limits.getDMLRows());
            fr.ASI_FOC_Rejected_by_System__c = true;
            update fr;
            Test.stopTest();
        }
    }
    
    static testMethod void testHeaderApprovalController() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE 'ASI System Administrator']; //20180205 Introv changed System Administrator to ASI System Administrator //20181206 Introv tested that it could pass on staging, so please ignore failure on B5
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        u.ASI_CRM_Sales_Team__c = 'HQ-Others';
        update u;
        
        System.runAs(u){
            
            //20180130 Introv
            
            List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
            
            tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                       , Name = 'TestItemGroup'
                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                       , OwnerID = userinfo.getUserId()
                                                      ));
            insert tmpItemGroup;
            
            ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                                 , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                                 , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                                 , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                                );
            
            Insert tmpSku;
            
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_POSM_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_POSM_Logistic_Approver__c = userInfo.getUserId(), ASI_FOC_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_Logistic_Approver__c = userInfo.getUserId());
            insert rt;
            
            List<ASI_FOC_Route_Criteria__c> rc_list = new List<ASI_FOC_Route_Criteria__c>();
            ASI_FOC_Route_Criteria__c rc1 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                          ASI_FOC_Threshold__c=0, ASI_FOC_POSM_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
            ASI_FOC_Route_Criteria__c rc2 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                          ASI_FOC_Threshold__c=1, ASI_FOC_POSM_Threshold__c=1, ASI_FOC_Approver__c=userInfo.getUserId());
            
            rc_list.add(rc1);
            rc_list.add(rc2);
            insert rc_list;  
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
            insert po;
            
            final Integer numOfSKU = 5;
            List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
            ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
            for (Integer i = 0; i < numOfSKU; i++) {
                skuList.add(skuGen.generatePOSMSKU(null));
            }
            insert skuList;
            
            ASI_FOC_Delivery_Zone__c dz = new ASI_FOC_Delivery_Zone__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'));
            insert dz;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Event_PO_Remarks__c = 'test',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,ASI_FOC_Request_Type__c='Consumer A&P',ASI_FOC_Sys_Approved_By_Logistic__c=true, ASI_FOC_PO__c=po.id, ASI_FOC_CN_Delivery_Zone__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'),ASI_FOC_Description__c='test', ASI_FOC_Sys_Submitted__c = true, ASI_FOC_Request_Status__c='Approved by Logistic');
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30000, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
            insert ri; 
            
            ri.ASI_FOC_ETL_Complete__c=true;
            fr.ASI_FOC_Request_Status__c = 'In Progress';//20180131 Introv
            
            update ri;
            update fr;
            
            ASI_FOC_Free_Goods_Request__c frw = [Select recordtype.developerName, ASI_FOC_Sys_Submitted__c, ASI_FOC_Sys_Item_Count__c, ASI_FOC_Sys_Approved_By_Logistic__c, ASI_FOC_SYS_Total_BD_Approval_Items__c, ASI_FOC_SYS_Total_BD_Approved_Items__c, ASI_FOC_Request_Status__c
                                                 , ASI_FOC_SYS_Total_Lines__c, ASI_FOC_SYS_Total_RequestWithQuantity__c FROM ASI_FOC_Free_Goods_Request__c where id = : fr.id];
            system.debug('20180130 ' + frw);
        }
    }
    
    static testMethod void testRejectController() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_POSM_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_POSM_Logistic_Approver__c = userInfo.getUserId(), ASI_FOC_Finance_Approver__c = userInfo.getUserId(), ASI_FOC_Logistic_Approver__c = userInfo.getUserId());
        insert rt;
        
        List<ASI_FOC_Route_Criteria__c> rc_list = new List<ASI_FOC_Route_Criteria__c>();
        ASI_FOC_Route_Criteria__c rc1 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=0, ASI_FOC_POSM_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        ASI_FOC_Route_Criteria__c rc2 = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                      ASI_FOC_Threshold__c=1, ASI_FOC_POSM_Threshold__c=1, ASI_FOC_Approver__c=userInfo.getUserId());
        
        rc_list.add(rc1);
        rc_list.add(rc2);
        insert rc_list;  
        
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
        insert po;
        
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generatePOSMSKU(null));
        }
        insert skuList;
        
        ASI_FOC_Delivery_Zone__c dz = new ASI_FOC_Delivery_Zone__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'));
        insert dz;
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_MFM_ForPOSMCart__c = TRUE, ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', ASI_FOC_CN_Delivery_Zone__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM'));
        insert fr;
        Test.startTest();
        System.debug(Limits.getDMLRows());
        apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
        ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
        cx.goBack();
        cx.submitRequest();
        
        fr.ASI_FOC_Request_Status__c = 'Open';
        update fr;
        cx.submitRequest();
        
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30000, ASI_FOC_Brand_Director_Approval_Required__c=true);
        insert ri;  
        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);
        cx.submitRequest();
        
        ri.ASI_FOC_Brand_Approver__c = u.id;
        update ri;        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);        
        cx.submitRequest();         
        
        po.ASI_FOC_PO_Final_Amount__c = 40000;
        update po;        
        fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, recordtypeid, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
        sc = new apexpages.Standardcontroller(fr);
        cx = new ASI_FOC_SubmitRequestController(sc);
        cx.submitRequest();
        cx.confirm();
        fr.ASI_FOC_Rejected_by_System__c = true;
        update fr;
        Test.stopTest();
    }
    
    Private Static List<ASI_FOC_Free_Goods_Request__c> RetrieveFOCInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
        
        String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_FOC_Free_Goods_Request__c ' + whereClause;
        
        List<ASI_FOC_Free_Goods_Request__c> fixApprovalList = (List<ASI_FOC_Free_Goods_Request__c>) Database.query(query);
        return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_FOC_Free_Goods_Request__c>();
    }
    
    Private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    // 20190628 Wilson Chow
    @isTest
    static void testCreateFOCPOSMReadOnlyBeforeUpdate() {
        ASI_FOC_PO__c po_20190628_1 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_1;

        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList_20190628 = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList_20190628.add(skuGen.generatePOSMSKU(null));
        }
        insert skuList_20190628;

        ASI_FOC_Delivery_Zone__c dz_20190628 =
                new ASI_FOC_Delivery_Zone__c(
                        Name = 'dz_20190628',
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'));
        insert dz_20190628;

        ASI_FOC_Free_Goods_Request__c fr_20190628_1 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_MFM_ForPOSMCart__c = TRUE,
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_Request_Status__c='test',
                        ASI_FOC_CN_Delivery_Zone__c='dz_20190628',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        ASI_FOC_PO__c=po_20190628_1.id,
                        ASI_FOC_Purpose__c = 'Product barter',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only'));
        insert fr_20190628_1;
    }

    @isTest
    static void testFreeGoodsRequestBeforeUpsertError() {
        ASI_FOC_PO__c po_20190628_2 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_2;

        ASI_MFM_Expense_Control_Form__c expcf_20190628_1 =
                new ASI_MFM_Expense_Control_Form__c(
                        Name = '20190628_1',
                        ASI_MFM_Module__c = 'Consumer A&P Payment',
                        ASI_MFM_AB_Policy_Required__c = true,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form'),
                        ASI_MFM_Tax_Saving_Purpose__c = 'STK4'
                );
        insert expcf_20190628_1;

        ASI_FOC_Free_Goods_Request__c fr_20190628_2 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        ASI_FOC_PO__c=po_20190628_2.id,
                        ASI_MFM_Tax_Saving_Purpose__c = expcf_20190628_1.id,
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));

        try {
            insert fr_20190628_2;
        }
        catch(Exception e) {

        }
    }

    @isTest
    static void testFreeGoodsRequestBeforeUpsert_taxSavingPurpose() {
        ASI_FOC_PO__c po_20190628_3 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_3;

        ASI_MFM_Expense_Control_Form__c expcf_20190628_2 =
                new ASI_MFM_Expense_Control_Form__c(
                        Name = '20190628_2',
                        ASI_MFM_Module__c = 'Consumer A&P Payment',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form'),
                        ASI_MFM_Tax_Saving_Purpose__c = 'STK4'
                );
        insert expcf_20190628_2;

        ASI_FOC_Free_Goods_Request__c fr_20190628_3 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_PO__c=po_20190628_3.id,
                        ASI_FOC_Purpose__c = 'STK4',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));

        try {
            insert fr_20190628_3;
        }
        catch(Exception e) {

        }
    }

    @isTest
    static void testFreeGoodsRequestSetDynamicApprovalRoute_HQ_STK4_Order() {
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_PO__c po_20190628_4 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_4;

        ASI_CRM_Dynamic_Approval_Route__c dy_route_2 =
                new ASI_CRM_Dynamic_Approval_Route__c(
                        ASI_CRM_Type__c = 'HQ STK4 Order',
                        ASI_CRM_Approval_Limit__c = 1,
                        ASI_CRM_User__c = UserInfo.getUserId(),
                        ASI_CRM_End_of_Dynamic_Route__c = True,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')
        );
        insert dy_route_2;

        ASI_FOC_Free_Goods_Request__c fr_20190628_4 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_PO__c=po_20190628_4.id,
                        ASI_FOC_Purpose__c = 'HQ STK4 Order',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,
                        ASI_FOC_Event_PO_Remarks__c = 'test',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));

        insert fr_20190628_4;
        update fr_20190628_4;
    }
    }

    @isTest
    static void testFreeGoodsRequestSetDynamicApprovalRoute_Central_STK4_Order() {
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_PO__c po_20190628_5 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_5;

        ASI_CRM_Dynamic_Approval_Route__c dy_route_3 =
                new ASI_CRM_Dynamic_Approval_Route__c(
                        ASI_CRM_Type__c = 'Central STK4 Order',
                        ASI_CRM_Approval_Limit__c = 1,
                        ASI_CRM_User__c = UserInfo.getUserId(),
                        ASI_CRM_End_of_Dynamic_Route__c = True,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')
                );
        insert dy_route_3;

        ASI_FOC_Free_Goods_Request__c fr_20190628_5 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_PO__c=po_20190628_5.id,
                        ASI_FOC_Purpose__c = 'Central STK4 Order',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,
                        ASI_FOC_Event_PO_Remarks__c = 'test',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));

        insert fr_20190628_5;
        update fr_20190628_5;
    }
    }

    @isTest
    static void testFreeGoodsRequestSetDynamicApprovalRoute_MKT_STK4_Order() {
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_PO__c po_20190628_6 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_6;

        ASI_CRM_Dynamic_Approval_Route__c dy_route_4 =
                new ASI_CRM_Dynamic_Approval_Route__c(
                        ASI_CRM_Type__c = 'MKT STK4 Order',
                        ASI_CRM_Approval_Limit__c = 1,
                        ASI_CRM_User__c = UserInfo.getUserId(),
                        ASI_CRM_End_of_Dynamic_Route__c = True,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')
                );
        insert dy_route_4;

        ASI_FOC_Free_Goods_Request__c fr_20190628_6 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_PO__c=po_20190628_6.id,
                        ASI_FOC_Purpose__c = 'MKT STK4 Order',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,
                        ASI_FOC_Event_PO_Remarks__c = 'test',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));

        insert fr_20190628_6;
        update fr_20190628_6;
    }
    }

    @isTest
    static void testFreeGoodsRequestSetDynamicApprovalRoute_FreeGoodRequest() {
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_PO__c po_20190628_7 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_7;

        ASI_CRM_Dynamic_Approval_Route__c dy_route_5 =
                new ASI_CRM_Dynamic_Approval_Route__c(
                        ASI_CRM_Type__c = 'Free Goods Request',
                        ASI_CRM_Approval_Limit__c = 1,
                        ASI_CRM_User__c = UserInfo.getUserId(),
                        ASI_CRM_End_of_Dynamic_Route__c = True,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')
                );
        insert dy_route_5;

        ASI_FOC_Free_Goods_Request__c fr_20190628_7 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_PO__c=po_20190628_7.id,
                        ASI_FOC_Purpose__c = 'Free Goods Request',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,
                        ASI_FOC_Event_PO_Remarks__c = 'test',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));

        insert fr_20190628_7;
        update fr_20190628_7;
    }
    }

    @isTest
    static void testFreeGoodsRequestSetDynamicApprovalRoute_POSM() {
        User userA = [SELECT Id FROM User WHERE Username = 'one.testing@introv.com'];
        System.runAs(userA){
        ASI_FOC_PO__c po_20190628_8 =
                new ASI_FOC_PO__c(
                        name='test',
                        ASI_FOC_PO_Final_Amount__c=100000,
                        ASI_FOC_Date__c=date.today());
        insert po_20190628_8;

        ASI_CRM_Dynamic_Approval_Route__c dy_route_6 =
                new ASI_CRM_Dynamic_Approval_Route__c(
                        ASI_CRM_Type__c = 'POSM',
                        ASI_CRM_Approval_Limit__c = 1,
                        ASI_CRM_User__c = UserInfo.getUserId(),
                        ASI_CRM_End_of_Dynamic_Route__c = True,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')
                );
        insert dy_route_6;

        ASI_FOC_Free_Goods_Request__c fr_20190628_8 =
                new ASI_FOC_Free_Goods_Request__c(
                        ASI_FOC_Request_Type__c='Consumer A&P',
                        ASI_FOC_PO__c=po_20190628_8.id,
                        ASI_FOC_Purpose__c = 'POSM',
                        ASI_FOC_Apply_Tax_Saving_Logic__c = true,
                        ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true,
                        ASI_FOC_Event_PO_Remarks__c = 'test',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));

        insert fr_20190628_8;
        update fr_20190628_8;
    }
    }
    // 20190628 Wilson Chow
}