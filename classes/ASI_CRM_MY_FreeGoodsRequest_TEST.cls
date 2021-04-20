@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_FreeGoodsRequest_TriggerCls
 2. ASI_CRM_MY_FOCClaimsCtl
 3. ASI_CRM_MY_FOCItemMassEditCtl
 4. ASI_CRM_MY_FOCRequestItem_TriggerCls
****************************************/
public class ASI_CRM_MY_FreeGoodsRequest_TEST{
 
    static testMethod void freeGoodsRequest_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
            
            
            date myDate = date.today();
            
            integer y = myDate.year();
            integer m = myDate.month();
            integer d = date.daysInMonth(y, m);
        
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            //ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');

            ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
            contract.Name = 'Auto-generated Number';
            contract.ASI_TH_CRM_Start_Date__c = date.newinstance(y - 1, m, 1);
            contract.ASI_TH_CRM_End_Date__c = date.newinstance(y + 1, m, 1);
            contract.ASI_TH_CRM_Contract_Status__c = 'Draft';
            contract.ASI_TH_CRM_Promotion_Type__c = 'Contract';
            contract.ASI_CRM_CN_Outlet_WS__c = customer1.id;
            contract.ASI_CRM_Version__c = '1';
            contract.ASI_CRM_Obsolete_Version__c = FALSE;
            contract.RecordTypeId = idRTContractNormal;
            
            insert contract;
            
            //新增税率
            ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
            insert rateConf;

            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT id, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id and ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            ASI_CRM_MY_TestClassHelper.createContractSAVRSetupCode();
            
            ASI_CRM_ContractTarget__c ct = new ASI_CRM_ContractTarget__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget'));
            insert ct;
            
            ASI_CRM_ContractSalesStaffIncentive__c ss = new ASI_CRM_ContractSalesStaffIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_MY_SalesStaffIncentive'));
            insert ss;
            
            ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MY_VolumeIncentive'));
            insert vi;
            
            ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', ASI_CRM_Type__c = 'Type', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive'));
            insert oi;
            
            ASI_CRM_PromoterPlacement__c pp = new ASI_CRM_PromoterPlacement__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PromoterPlacement__cASI_CRM_MY_PromoterPlacement'));
            insert pp;
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            update con;
            
            Id strRTId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_NPL_CN_Normal_Goods_Warehouse');
            ASI_FOC_Warehouse__c G_WH = new ASI_FOC_Warehouse__c(ASI_FOC_Warehouse_Code__c='XXX999SH', ASI_MFM_Location_Code__c='SH', Recordtypeid=strRTId);
            insert G_WH;
          	
            ASI_FOC_Free_Goods_Request__c fg = new ASI_FOC_Free_Goods_Request__c();
            fg.ASI_CRM_Outlet__c = customer1.id;
            fg.ASI_CRM_Contract__c = con.id;
            fg.ASI_FOC_Description__c = 'TEST';
            fg.ASI_CRM_MY_Event_Period__c = 'TEST';
            fg.ASI_CRM_Status__c = 'Draft';
            fg.ASI_CRM_Date_From__c = date.newinstance(y, m, 1);
            fg.ASI_CRM_Date_To__c = date.newinstance(y, m, d);
            fg.ASI_CRM_Auto_Generation__c = true;
            fg.ASI_FOC_To_Regional_Warehouse__c = G_WH.Id;
            fg.recordTypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_MY_FreeGoodsRequest');
            insert fg;
            
            fg.ASI_FOC_Description__c = 'TESTING';
            update fg;
            //Canter start 2019/11/12
            List<ASI_FOC_Free_Goods_Request__c> fgList = new List<ASI_FOC_Free_Goods_Request__c>();
            fgList.add(fg);
            map<id, ASI_FOC_Free_Goods_Request__c> fgMap = new map<id, ASI_FOC_Free_Goods_Request__c>();
            fgMap.put(fg.id, fg);
            ASI_FOC_Free_Goods_Request_TriggerClass.routineBeforeUpsert(fgList,fgMap);
            //Canter end 2019/11/12
            
            ASI_FOC_Request_Item__c fg_L = new ASI_FOC_Request_Item__c();
            fg_L.ASI_FOC_Request_Order__c = fg.id;
            fg_L.ASI_FOC_SKU__c = sku1.id;
            fg_L.ASI_FOC_Issued_Qty__c = 24;
            fg_L.ASI_CRM_SetupCode__c = 'SAVR';
            fg_L.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_FOC_MY_RequestItem');
            fg_L.CurrencyIsoCode = 'MYR';
            insert fg_L;
            
            
            ASI_FOC_Free_Goods_Request__c[] fg_LL = [SELECT id FROM ASI_FOC_Free_Goods_Request__c LIMIT 1];
            
            ApexPages.StandardController standardCtl = new ApexPages.StandardController(fg);
            ApexPages.currentpage().getparameters().put('id', fg.id);
            ASI_CRM_MY_FOCClaimsCtl controller = new ASI_CRM_MY_FOCClaimsCtl(standardCtl);
            controller.getFOCItem();
            
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(fg_LL);
            ApexPages.currentpage().getparameters().put('id', fg.id);
            ASI_CRM_MY_FOCItemMassEditCtl controller2 = new ASI_CRM_MY_FOCItemMassEditCtl(standardSetCtl);
            controller2.ADDNEW();
            controller2.CLONESELECTED();
            controller2.DELETESELECTED();
            controller2.BEGINNING();
            controller2.PREVIOUS();
            controller2.NEXT();
            controller2.END();
            controller2.ADDNEW();
            controller2.SAVE();
            controller2.QUICKSAVE();
            controller2.onCommitted();
            
        }
    }
    
    static testMethod void testTriggers() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
        insert rt;
        ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                     ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
        insert rc;  
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
        insert po;
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        final Integer numOfSKU = 5;
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));   
        }
        insert skuList;
        
        ASI_MFM_Expense_Control_Form__c logisticSetting = new ASI_MFM_Expense_Control_Form__c();
        logisticSetting.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_CN_Logistics_Btl_Control_Form');
        logisticSetting.Name = 'Other';
        logisticSetting.ASI_CRM_CN_FG_Bottle_Size__c = 'Other';
        logisticSetting.ASI_CRM_CN_FG_Logistics_Cost_per_Btl__c = 10;
        insert logisticSetting;
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id,ASI_FOC_Purpose__c='MKT STK4 Order',ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true, ASI_FOC_Event_PO_Remarks__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));
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
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;        
        Id strRTId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_NPL_CN_Normal_Goods_Warehouse');
        ASI_FOC_Warehouse__c G_WH = new ASI_FOC_Warehouse__c(ASI_FOC_Warehouse_Code__c='XXX999SH', ASI_MFM_Location_Code__c='SH', Recordtypeid=strRTId,ASI_FOC_Warehouse_Type__c='Region Warehouse',ASI_FOC_Region__c = region.Id);
        insert G_WH;
        
        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'Free Goods Request',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'POSM',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'HQ STK4 Order',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'Central STK4 Order',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'MKT STK4 Order',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
        insert LDynApproval ;
        
        Id currentUserId = UserInfo.getUserId(); 
        List<ASI_CRM_Fix_Approval_Route__c> listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='POSM', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId,recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')));
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='POSM', ownerid=currentUserId,recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')));
        insert listFixRoute;
        
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
        
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P',ASI_FOC_Request_Status__c='In Progress',ASI_MFM_FromWarehouse__c=G_WH.Id,ASI_FOC_Purpose__c='MKT STK4 Order',ASI_MFM_ForPOSMCart__c =true, ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only'));
        insert fr;
        ASI_FOC_Free_Goods_Request__c fr2 = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P',ASI_FOC_Request_Status__c='In Progress',ASI_MFM_FromWarehouse__c=G_WH.Id,ASI_FOC_Purpose__c='MKT STK4 Order',ASI_MFM_ForPOSMCart__c =true, ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request_Read_Only'));
        insert fr2;
        
        List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
        
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
        ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
        
        riList.add(ri);
        riList.add(ri2);
        
        insert riList;
        test.startTest();
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
        
        fr2.ASI_FOC_Sys_Submitted__c = true;
        fr2.ASI_FOC_Rejected_by_System__c = False;
        fr2.ASI_FOC_Request_Status__c = 'In Progress';//20180131 Introv
        fr2.ASI_FOC_CN_Already_4_Days__c = true;
        update fr2;
        
        //20180430 Introv
        ASI_FOC_Free_Goods_Request_TriggerClass.getApprovalComments(new Set<Id>{fr.id});
        
        test.stopTest();
    }
    
    static testMethod void testTriggers_3() {
        
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
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        
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
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Rejected_by_System__c = True, ASI_FOC_Request_Status__c = 'Rejected by Logistic', ASI_FOC_Request_Type__c='Logistic Cost',ASI_FOC_Purpose__c='MKT STK4 Order', ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c=true, ASI_FOC_Event_PO_Remarks__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only'));
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
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        
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
        
        List<user> sysAdminList = [SELECT id From USER WHERE Profile.Name Like 'System Administrator' and IsActive = true];
        
        user sysAdmin = sysAdminList.size() > 0 ? sysAdminList[0] : [SELECT id From USER WHERE id = : userInfo.getUserId()];
            
            system.runAs(sysAdmin){
                test.startTest();
                ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Sys_Submitted__c = True, ASI_FOC_Sys_Approved_By_Logistic__c = True, ASI_FOC_Request_Status__c = 'Approved by Logistic',ASI_FOC_Purpose__c='MKT STK4 Order', ASI_FOC_Request_Type__c='Logistic Cost', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only'));
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
            }
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
    
    
     static testMethod void testTriggers_MKT_Normal() {
        ASI_HK_CRM_ThresholdValues__c threshold = new ASI_HK_CRM_ThresholdValues__c(ASI_HK_CRM_SO_Urgent_Cutoff_Time_1__c = '10:00', ASI_HK_CRM_SO_Urgent_Cutoff_Time_2__c = '16:00');
        insert threshold;
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c = u.userRole.developerName, ASI_FOC_Department__c = 'Marketing', ASI_FOC_Line_Manager__c = u.id, ASI_FOC_Director__c = u.id, ASI_FOC_Sales_POS_Approver__c = u.id, ASI_FOC_LUX_Approver__c = u.id, ASI_FOC_Finance_Director__c = u.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Route_Type__cASI_FOC_HK_Route_Type'));
        insert rt;

        Account acc = new Account(recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name = 'Outlet HK Test Data');
        insert acc;
        
        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'),
            ASI_MFM_OPEX__c = true
        );
        insert buCode; 
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Default_BU__c=buCode.id,ASI_MFM_Module__c ='PO', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_HK_Prefix'));
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name = 'Test PO', recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO_Read_Only'), ASI_MFM_Status__c = 'Final', ASI_MFM_Is_FOC_PO__c = true, ASI_MFM_Net_off_FOC_PO__c = false, ASI_MFM_JDE_FOC_Return_Amount__c = -1000, ASI_MFM_Prefix__c = pxo.id
            , ASI_MFM_Sys_Approver_2__c = u.id);
        insert po;
        
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU'), Name = 'Testing SKU', ASI_FOC_Stock_Price__c  = 10, ASI_MFM_SKU_Code__c = 'Testing SKU', ASI_FOC_Inventory__c = 100);
        insert sku;
        
        test.startTest();
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Wine/Spirits', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales_Admin'),
            ASI_FOC_Account_DA__c = acc.id, ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.id, ASI_FOC_Date_of_Delivery__c = Date.today(), ASI_FOC_Urgent_Order__c = true, ASI_FOC_Delivery_Window_Instruction__c = 'Between', ASI_FOC_Delivery_Time_1__c = '11:00');
        insert fr;      
        
        fr.ASI_FOC_Request_Type__c = 'POS';
        fr.ASI_FOC_Delivery_Remarks__c = 'test';
        fr.ASI_FOC_Urgent_Order__c = false;
        fr.ASI_FOC_Date_of_Delivery__c = Date.today()+1;
        
        update fr;
        
        ASI_FOC_Request_Item__c ri3 = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_HK_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_SKU__c = sku.id, ASI_FOC_Request_Quantity_Bottle__c = 10);
        insert ri3;
        
        PageReference pageRef = Page.ASI_FOC_HK_Request_NotifySalesAdminPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(fr);
        ASI_FOC_HK_Request_NotifySalesAdminCON con = new ASI_FOC_HK_Request_NotifySalesAdminCON(sc);
                
        con.notifySalesAdmin();
        
        test.stopTest();
    }
    
    static testMethod void testTriggers_MKT_Normal_2() {
        ASI_HK_CRM_ThresholdValues__c threshold = new ASI_HK_CRM_ThresholdValues__c(ASI_HK_CRM_SO_Urgent_Cutoff_Time_1__c = '10:00', ASI_HK_CRM_SO_Urgent_Cutoff_Time_2__c = '16:00');
        insert threshold;
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c = u.userRole.developerName, ASI_FOC_Department__c = 'Marketing', ASI_FOC_Line_Manager__c = u.id, ASI_FOC_Director__c = u.id, ASI_FOC_Sales_POS_Approver__c = u.id, ASI_FOC_LUX_Approver__c = u.id, ASI_FOC_Finance_Director__c = u.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Route_Type__cASI_FOC_HK_Route_Type'));
        insert rt;

        Account acc = new Account(recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name = 'Outlet HK Test Data');
        insert acc;
        
        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'),
            ASI_MFM_OPEX__c = true
        );
        insert buCode;
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c ='PO',ASI_MFM_Default_BU__c=buCode.Id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_HK_Prefix'));
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name = 'Test PO', recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO_Read_Only'), ASI_MFM_Status__c = 'Final', ASI_MFM_Is_FOC_PO__c = true, ASI_MFM_Net_off_FOC_PO__c = false, ASI_MFM_JDE_FOC_Return_Amount__c = -1000, ASI_MFM_Prefix__c = pxo.id
            , ASI_MFM_Sys_Approver_2__c = u.id);
        insert po;
        
        
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU'), Name = 'Testing SKU', ASI_FOC_Stock_Price__c  = 10, ASI_MFM_SKU_Code__c = 'Testing SKU', ASI_FOC_Inventory__c = 100);
        insert sku;
        
        sku.ASI_FOC_Inventory__c = 99;
        update sku;
        
        test.startTest();
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Wine/Spirits', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales_Admin'),
            ASI_FOC_Account_DA__c = acc.id, ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.id, ASI_FOC_Date_of_Delivery__c = Date.today(), ASI_FOC_Urgent_Order__c = true, ASI_FOC_Delivery_Window_Instruction__c = 'Between', ASI_FOC_Delivery_Time_1__c = '11:00');
        insert fr;      
                
        ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_HK_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_SKU__c = sku.id, ASI_FOC_Request_Quantity_Bottle__c = 10);
        insert ri2;
        
        ri2.ASI_FOC_Request_Quantity_Bottle__c = 20;
        update ri2;
        
        delete ri2;
        
        test.stopTest();
    }
    
    static testMethod void testTriggers2_Sales_Normal() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c = u.userRole.developerName, ASI_FOC_Department__c = 'Sales', ASI_FOC_Line_Manager__c = u.id, ASI_FOC_Director__c = u.id, ASI_FOC_Sales_POS_Approver__c = u.id, ASI_FOC_LUX_Approver__c = u.id, ASI_FOC_Finance_Director__c = u.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Route_Type__cASI_FOC_HK_Route_Type'));
        insert rt;

        Account acc = new Account(recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name = 'Outlet HK Test Data');
        insert acc;
        
         ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'),
            ASI_MFM_OPEX__c = true
        );
        insert buCode;
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c ='PO', ASI_MFM_Default_BU__c=buCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_HK_Prefix'));
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name = 'Test PO', recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO_Read_Only'), ASI_MFM_Status__c = 'Final', ASI_MFM_Is_FOC_PO__c = true, ASI_MFM_Net_off_FOC_PO__c = false, ASI_MFM_JDE_FOC_Return_Amount__c = -1000, ASI_MFM_Prefix__c = pxo.id);
        insert po;
        
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU'), Name = 'Testing SKU', ASI_FOC_Stock_Price__c  = 10, ASI_MFM_SKU_Code__c = 'SKU1');
        insert sku;
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Wine/Spirits', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales'),
            ASI_FOC_Account_DA__c = acc.id, ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.id, ASI_FOC_Date_of_Delivery__c = Date.today(), ASI_FOC_Urgent_Order__c = true, ASI_FOC_Delivery_Window_Instruction__c = 'Between', ASI_FOC_Delivery_Time_1__c = '11:00'
                , ASI_FOC_STK_4_Count_Sales_Volume__c = false);
        insert fr;
        
        test.startTest();
        
        ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_HK_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_SKU__c = sku.id, ASI_FOC_Request_Quantity_Bottle__c = 1);
        insert ri;

        delete ri;
        
        test.stopTest();
    }
    
    static testMethod void testTriggers2_Sales_WineSpirit() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c = u.userRole.developerName, ASI_FOC_Department__c = 'Sales', ASI_FOC_Line_Manager__c = u.id, ASI_FOC_Director__c = u.id, ASI_FOC_Sales_POS_Approver__c = u.id, ASI_FOC_LUX_Approver__c = u.id, ASI_FOC_Finance_Director__c = u.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Route_Type__cASI_FOC_HK_Route_Type'));
        insert rt;

        Account acc = new Account(recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name = 'Outlet HK Test Data');
        insert acc;
        
        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'),
            ASI_MFM_OPEX__c = true
        );
        insert buCode;
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c ='PO',ASI_MFM_Default_BU__c=buCode.Id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_HK_Prefix'));
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name = 'Test PO', recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO_Read_Only'), ASI_MFM_Status__c = 'Final', ASI_MFM_Is_FOC_PO__c = true, ASI_MFM_Net_off_FOC_PO__c = false, ASI_MFM_JDE_FOC_Return_Amount__c = -1000, ASI_MFM_Prefix__c = pxo.id);
        insert po;
        
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU'), Name = 'Testing SKU', ASI_FOC_Stock_Price__c  = 10, ASI_MFM_SKU_Code__c = 'SKU1');
        insert sku;
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Wine/Spirits', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales'),
            ASI_FOC_Account_DA__c = acc.id, ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.id, ASI_FOC_Date_of_Delivery__c = Date.today(), ASI_FOC_Urgent_Order__c = true, ASI_FOC_Delivery_Window_Instruction__c = 'Between', ASI_FOC_Delivery_Time_1__c = '11:00'
                , ASI_FOC_STK_4_Count_Sales_Volume__c = false);
        insert fr;
        
        test.startTest();
        
        fr.ASI_FOC_Delivery_Remarks__c = 'test';
        fr.ASI_FOC_Urgent_Order__c = false;
        fr.ASI_FOC_Date_of_Delivery__c = Date.today()+1;
        update fr;
        
        PageReference pageRef = Page.ASI_FOC_HK_Request_NotifySalesAdminPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(fr);
        ASI_FOC_HK_Request_NotifySalesAdminCON con = new ASI_FOC_HK_Request_NotifySalesAdminCON(sc);
        
        //Test no request detail line
        con.notifySalesAdmin();
        con.goBack();
        
        ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_HK_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_SKU__c = sku.id, ASI_FOC_Request_Quantity_Bottle__c = 10);
        insert ri2; 
        
        delete fr;
        
        test.stopTest();
    }
}