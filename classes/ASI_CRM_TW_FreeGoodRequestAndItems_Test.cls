/*Created by Twinkle Li @introv 13/03/2017
*
* Testclass for:
* ASI_CRM_TW_FreeGoodsRequest_TriggerCls
* ASI_CRM_TW_RequestItem_TriggerCls
* ASI_CRM_TW_InputFOCItemsController
* ASI_CRM_TW_GenFOCRequestItems_Ctrl
* ASI_CRM_TW_FOCRequestPDF_Ctrl
*/

@isTest
public class ASI_CRM_TW_FreeGoodRequestAndItems_Test {
    private static string getFiscalYear(){
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
    
    public static testMethod void ASI_CRM_TW_FreeGoodRequest_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';
        update u;
        
        System.runAs(u) {
            ASI_MFM_BU__c testBuCode = ASI_MFM_CAP_TestClassHelper.createOPEXBUCode();

            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_Default_BU__c = testBuCode.id);
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_Default_BU__c = testBuCode.id);
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_Default_BU__c = testBuCode.id);
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
             ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(
                 recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                 name='testAC',
                 ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
            insert ac;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), 
                name='testAP');
            insert ap;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
            );
            insert sub;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
                Name = 'TOT (酒店)',
                ASI_CRM_CN_Channel_Code__c = 'TOT');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
                Name = 'Piano Bar (PB)', 
                ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
                ASI_CRM_CN_Channel__c = channel.id, 
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
            insert subChannel;   
            
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
                Name = 'PB (鋼琴酒吧)', 
                ASI_TH_CRM_Code__c = 'TW_PB',
                ASI_CRM_Sub_Channel__c = subChannel.id
            );
            insert outletType;
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet', 
                ASI_TH_CRM_Region__c ='North')
            );  
            listAcc.add(new Account(
                recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), 
                Name='Name3')
            );       
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), 
                Name='Test Customer')
            );  
            insert listAcc;
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listAcc[0].id, 
                ASI_TH_CRM_OutletType__c = outletType.id, 
                ASI_CRM_Region__c = 'North',
                ASI_CRM_Channel__c = channel.id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.id,
                ASI_CRM_City__c = 'Test City', 
                ASI_CRM_Town__c = 'Test Town', 
                ASI_CRM_TW_Street__c = 'Test Street', 
                ASI_CRM_TW_Number__c = '1', 
                ASI_CRM_TW_Floor__c = '12',
                ASI_CRM_MY_GeoConverStatus__c = 'Completed')
            );
            insert listAccountAdditionalField;
            
            List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
            listPlan.add(new ASI_MFM_Plan__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
                name='test', 
                ASI_MFM_End_Date__c=Date.today().addMonths(1), 
                ASI_MFM_Prefix__c=pxp.id,
                ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', 
                ASI_MFM_Start_Date__c=Date.today(), 
                ASI_MFM_Status__c = 'Final')
            );
            listPlan.add(new ASI_MFM_Plan__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
                name='test', 
                ASI_MFM_End_Date__c=Date.today().addMonths(1), 
                ASI_MFM_Prefix__c=pxp.id,
                ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', 
                ASI_MFM_Start_Date__c=Date.today(), 
                ASI_MFM_Status__c = 'Final')
            );
            insert listPlan;      
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing1',
                ASI_MFM_Customer_Name__c = listAcc[2].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id, 
                // ASI_MFM_Month_1_Cost__c = 1000,
                ASI_MFM_Total_Cost__c = 1000)
            );
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing2',
                ASI_MFM_Customer_Name__c = listAcc[2].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id,
                // ASI_MFM_Month_1_Cost__c = 2000,
                ASI_MFM_Total_Cost__c = 2000)
            );
            insert listPL;
            
            List<ASI_FOC_Route_Type__c> listFOCRT = new List<ASI_FOC_Route_Type__c>();
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_FOC_Route_Type'))
            );
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_POSM_Route_Type'))
            );
            insert listFOCRT;
            
            test.startTest();
                
            List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
            //FOC
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Delivery_To__c = listAcc[0].id,
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_CRM_Plan__c = listPlan[0].Id,
				ASI_FOC_Request_Status__c = 'Approved')
            );
            //POSM
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Delivery_To__c = listAcc[0].id,
                //ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose')
            );
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Delivery_To__c = listAcc[0].id,
                //ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose')
            );
            /*listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_FOC_Request_Type__c = 'Memo',
                ASI_FOC_Account_DA__c = listAcc[3].Id,
                ASI_FOC_MFM_Consumer_AP_PO_Number__c = )
            );*/
            /*listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_FOC_Request_Type__c = 'Memo',
                ASI_FOC_Purpose__c = 'Event',
                ASI_FOC_Date_of_Delivery__c = system.today(),
                ASI_FOC_Request_Status__c = 'Draft',
                ASI_FOC_Description__c = 'aa',
                ASI_FOC_Receiptor_Name__c = 'aa',
                ASI_FOC_Receiptor_Mobile__c = '123',
                ASI_FOC_Deliver_to_Address_Line_1__c = 'aa')
            );*/
            ASI_CRM_TW_FreeGoodsRequest_TriggerCls.SetDeliveryInstruction(listFGR, null);
            ASI_CRM_TW_FreeGoodsRequest_TriggerCls.SetReceiver(listFGR, null);

            insert listFGR;
            
            /*listFGR[0].ASI_FOC_Request_Status__c = 'Final';
            listFGR[1].ASI_FOC_Request_Status__c = 'Final';
            update listFGR;*/
            
            listFGR[0].ASI_FOC_Request_Status__c = 'Completed';
            listFGR[1].ASI_FOC_Request_Status__c = 'Completed';
            update listFGR;
            
            delete listFGR[2];

            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                //ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_Delivery_To__c = listAcc[0].id,
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_FOC_Request_Type__c = 'Memo',
                ASI_FOC_Purpose__c = 'Event',
                ASI_FOC_Date_of_Delivery__c = system.today(),
                ASI_FOC_Request_Status__c = 'Draft',
                ASI_FOC_Description__c = 'aa',
                ASI_FOC_Receiptor_Name__c = 'aa',
                ASI_FOC_Receiptor_Mobile__c = '123',
                ASI_FOC_Deliver_to_Address_Line_1__c = 'aa')
            );
            insert listFGR[3];

            system.debug('+++listFGR: '+listFGR.size());
            system.debug('+++listFGR: '+listFGR);

            Account acc = new Account(recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name = 'Outlet HK Test Data');
            insert acc;
            
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pro;  
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name = 'Test PO', recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO_Read_Only'), ASI_MFM_Status__c = 'Final', ASI_MFM_Is_FOC_PO__c = true, ASI_MFM_Net_off_FOC_PO__c = false, ASI_MFM_JDE_FOC_Return_Amount__c = -1000, ASI_MFM_Prefix__c = pxo.id
                , ASI_MFM_Sys_Approver_2__c = u.id);
            insert po;

            ASI_FOC_Free_Goods_Request__c HKFGR = new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_FOC_Request_Type__c = 'Memo',
                ASI_FOC_Account_DA__c = acc.Id,
                ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.id,
                ASI_FOC_Request_Status__c = 'Draft',
                ASI_FOC_Date_of_Delivery__c = system.today()+1,
                ASI_FOC_Description__c = 'aa',
                ASI_FOC_Receiptor_Name__c = 'aa',
                ASI_FOC_Receiptor_Mobile__c = '123',
                ASI_FOC_Deliver_to_Address_Line_1__c = 'aa');

            insert HKFGR;
            update HKFGR;

            test.stopTest();
        }
    }
        
    public static testMethod void ASI_CRM_TW_FOC_RequestItems_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';
        update u;
        
        System.runAs(u) {
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
             ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(
                 recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                 name='testAC',
                 ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
            insert ac;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), 
                name='testAP');
            insert ap;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
                Name = 'TOT (酒店)',
                ASI_CRM_CN_Channel_Code__c = 'TOT');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
                Name = 'Piano Bar (PB)', 
                ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
                ASI_CRM_CN_Channel__c = channel.id, 
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
            insert subChannel;   
            
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
                Name = 'PB (鋼琴酒吧)', 
                ASI_TH_CRM_Code__c = 'TW_PB',
                ASI_CRM_Sub_Channel__c = subChannel.id
            );
            insert outletType;
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet', 
                ASI_TH_CRM_Region__c ='North')
            );  
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), 
                Name='Test Customer')
            );  
            insert listAcc;

            contact ct = new contact(
                lastname='a', firstname='b', ASI_HK_CRM_Main_Contact__c = true, accountid = listAcc[0].id, recordtypeid = Global_RecordTypeCache.getRtId('ContactASI_CRM_TW_Contact')
            );

            insert ct;

            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listAcc[0].id, 
                ASI_TH_CRM_OutletType__c = outletType.id, 
                ASI_CRM_Region__c = 'North',
                ASI_CRM_Channel__c = channel.id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.id,
                ASI_CRM_City__c = 'Test City', 
                ASI_CRM_Town__c = 'Test Town', 
                ASI_CRM_TW_Street__c = 'Test Street', 
                ASI_CRM_TW_Number__c = '1', 
                ASI_CRM_TW_Floor__c = '12',
                ASI_CRM_MY_GeoConverStatus__c = 'Completed')
            );
            insert listAccountAdditionalField;
            
            List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
            listPlan.add(new ASI_MFM_Plan__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
                name='test', 
                ASI_MFM_End_Date__c=Date.today().addMonths(1), 
                ASI_MFM_Prefix__c=pxp.id,
                ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', 
                ASI_MFM_Start_Date__c=Date.today(), 
                ASI_MFM_Status__c = 'Final')
            );
            listPlan.add(new ASI_MFM_Plan__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
                name='test', 
                ASI_MFM_End_Date__c=Date.today().addMonths(1), 
                ASI_MFM_Prefix__c=pxp.id,
                ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', 
                ASI_MFM_Start_Date__c=Date.today(), 
                ASI_MFM_Status__c = 'Final')
            );
            insert listPlan;      
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing1',
                ASI_MFM_Customer_Name__c = listAcc[1].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id, 
                // ASI_MFM_Month_1_Cost__c = 1000,
                ASI_MFM_Total_Cost__c = 1000)
            );
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing2',
                ASI_MFM_Customer_Name__c = listAcc[1].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id,
                // ASI_MFM_Month_1_Cost__c = 2000,
                ASI_MFM_Total_Cost__c = 2000)
            );
            insert listPL;
            
            List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>();
            listSubBrand.add(new ASI_MFM_Sub_brand__c(    
                name = 'Sub-Brand 1',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_TH_CRM_Active__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'))
            );
            insert listSubBrand;
            
            List<ASI_MFM_Item_Group__c> listItemGp = new List<ASI_MFM_Item_Group__c>();
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 1',
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 2',
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listItemGp;
            
            List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = new List<ASI_CRM_MY_SKUPriceCost__c>();
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_TW_SKU_Price_Cost'),
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'A&D FOC Unit Cost',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listSKUpc;
            
            List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
            listSKU.add(new ASI_MFM_SKU_Code__c(
                name = 'FOC SKU',
                ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = listSubBrand[0].id,
                ASI_MFM_Item_Group__c = listItemGp[0].id,
                ASI_HK_CRM_IsPOSProduct__c = FALSE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
            );
            listSKU.add(new ASI_MFM_SKU_Code__c(
                name = 'POSM SKU',
                ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = listSubBrand[0].id,
                ASI_MFM_Item_Group__c = listItemGp[0].id,
                ASI_HK_CRM_IsPOSProduct__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
            );
            insert listSKU;
            
            List<ASI_FOC_Route_Type__c> listFOCRT = new List<ASI_FOC_Route_Type__c>();
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_FOC_Route_Type'))
            );
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_POSM_Route_Type'))
            );
            insert listFOCRT;
                
            List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
            //FOC
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_CRM_Plan__c = listPlan[0].Id)
            );
            //POSM
            /*listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose')
            );*/
            insert listFGR;
            
            test.startTest();
            
            List<ASI_FOC_Request_Item__c> listItems = new List<ASI_FOC_Request_Item__c>();
            //FOC
            listItems.add(new ASI_FOC_Request_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_FOC_Request_Item'),
                ASI_FOC_Request_Order__c = listFGR[0].Id,
                ASI_CRM_Plan_Line_Item__c = listPL[0].Id,
                ASI_FOC_SKU__c = listSKU[0].id,
                ASI_FOC_Request_Quantity_Bottle__c = 10)
            );
            //POSM
            /*listItems.add(new ASI_FOC_Request_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_POSM_Request_Item'),
                ASI_FOC_Request_Order__c = listFGR[1].Id,
                ASI_FOC_SKU__c = listSKU[1].id,
                ASI_FOC_Request_Quantity_Bottle__c = 10)
            );*/
            insert listItems;
            //delete listItems[0];
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listFGR[0]);
            ApexPages.currentPage().getParameters().put('id', listFGR[0].id);  
            ASI_CRM_TW_FOCRequestPDF_Ctrl controller = new ASI_CRM_TW_FOCRequestPDF_Ctrl(stdController); 
            
            ASI_CRM_TW_ItemGroup_UtilityCls controller2 = new ASI_CRM_TW_ItemGroup_UtilityCls();
            Set<Id> setItmGpId = new Set<Id>{listItemGp[0].Id};
            List<String> strType = new List<String>{'A&D FOC Unit Cost'};
            controller2.getAllSKUpc('TOT', setItmGpId, strType);
            
            test.stopTest();
        }
    }
    
    public static testMethod void ASI_CRM_TW_POSM_RequestItems_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';
        update u;
        
        System.runAs(u) {
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
                Name = 'TOT (酒店)',
                ASI_CRM_CN_Channel_Code__c = 'TOT');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
                Name = 'Piano Bar (PB)', 
                ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
                ASI_CRM_CN_Channel__c = channel.id, 
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
            insert subChannel;   
            
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
                Name = 'PB (鋼琴酒吧)', 
                ASI_TH_CRM_Code__c = 'TW_PB',
                ASI_CRM_Sub_Channel__c = subChannel.id
            );
            insert outletType;
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet', 
                ASI_TH_CRM_Region__c ='North')
            );  
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), 
                Name='Test Customer')
            );  
            insert listAcc;
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listAcc[0].id, 
                ASI_TH_CRM_OutletType__c = outletType.id, 
                ASI_CRM_Region__c = 'North',
                ASI_CRM_Channel__c = channel.id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.id,
                ASI_CRM_City__c = 'Test City', 
                ASI_CRM_Town__c = 'Test Town', 
                ASI_CRM_TW_Street__c = 'Test Street', 
                ASI_CRM_TW_Number__c = '1', 
                ASI_CRM_TW_Floor__c = '12',
                ASI_CRM_MY_GeoConverStatus__c = 'Completed')
            );
            insert listAccountAdditionalField;
            
            List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>();
            listSubBrand.add(new ASI_MFM_Sub_brand__c(    
                name = 'Sub-Brand 1',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_TH_CRM_Active__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'))
            );
            insert listSubBrand;
            
            List<ASI_MFM_Item_Group__c> listItemGp = new List<ASI_MFM_Item_Group__c>();
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 1',
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 2',
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listItemGp;
            
            List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = new List<ASI_CRM_MY_SKUPriceCost__c>();
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_TW_SKU_Price_Cost'),
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'A&D FOC Unit Cost',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listSKUpc;
            
            List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
            listSKU.add(new ASI_MFM_SKU_Code__c(
                name = 'FOC SKU',
                ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = listSubBrand[0].id,
                ASI_MFM_Item_Group__c = listItemGp[0].id,
                ASI_HK_CRM_IsPOSProduct__c = FALSE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
            );
            listSKU.add(new ASI_MFM_SKU_Code__c(
                name = 'POSM SKU',
                ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = listSubBrand[0].id,
                ASI_MFM_Item_Group__c = listItemGp[0].id,
                ASI_HK_CRM_IsPOSProduct__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
            );
            insert listSKU;
            
            List<ASI_FOC_Route_Type__c> listFOCRT = new List<ASI_FOC_Route_Type__c>();
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_FOC_Route_Type'))
            );
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_POSM_Route_Type'))
            );
            insert listFOCRT;
                
            List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
            //POSM
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose')
            );
            insert listFGR;
            
            test.startTest();
            
            List<ASI_FOC_Request_Item__c> listItems = new List<ASI_FOC_Request_Item__c>();
            //POSM
            listItems.add(new ASI_FOC_Request_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_POSM_Request_Item'),
                ASI_FOC_Request_Order__c = listFGR[0].Id,
                ASI_FOC_SKU__c = listSKU[1].id,
                ASI_FOC_Request_Quantity_Bottle__c = 10)
            );
            insert listItems;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listFGR[0]);
            ApexPages.currentPage().getParameters().put('id', listFGR[0].id);  
            ASI_CRM_TW_FOCRequestPDF_Ctrl controller = new ASI_CRM_TW_FOCRequestPDF_Ctrl(stdController); 
            
            ASI_CRM_TW_InputFOCItemsController controller1 = new ASI_CRM_TW_InputFOCItemsController(stdController); 
            
            delete listItems[0];
            
            test.stopTest();
        }
    }
    
    public static testMethod void ASI_CRM_TW_GenFOCRequestItems_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';
        update u;
        
        System.runAs(u) {
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
             ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(
                 recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                 name='testAC',
                 ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
            insert ac;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), 
                name='testAP');
            insert ap;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
                Name = 'TOT (酒店)',
                ASI_CRM_CN_Channel_Code__c = 'TOT');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
                Name = 'Piano Bar (PB)', 
                ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
                ASI_CRM_CN_Channel__c = channel.id, 
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
            insert subChannel;   
            
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
                Name = 'PB (鋼琴酒吧)', 
                ASI_TH_CRM_Code__c = 'TW_PB',
                ASI_CRM_Sub_Channel__c = subChannel.id
            );
            insert outletType;
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet', 
                ASI_TH_CRM_Region__c ='North')
            );  
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), 
                Name='Test Customer')
            );  
            insert listAcc;
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listAcc[0].id, 
                ASI_TH_CRM_OutletType__c = outletType.id, 
                ASI_CRM_Region__c = 'North',
                ASI_CRM_Channel__c = channel.id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.id,
                ASI_CRM_City__c = 'Test City', 
                ASI_CRM_Town__c = 'Test Town', 
                ASI_CRM_TW_Street__c = 'Test Street', 
                ASI_CRM_TW_Number__c = '1', 
                ASI_CRM_TW_Floor__c = '12',
                ASI_CRM_MY_GeoConverStatus__c = 'Completed')
            );
            insert listAccountAdditionalField;
            
            List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
            listPlan.add(new ASI_MFM_Plan__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
                name='test', 
                ASI_MFM_End_Date__c=Date.today().addMonths(1), 
                ASI_MFM_Prefix__c=pxp.id,
                ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', 
                ASI_MFM_Start_Date__c=Date.today(), 
                ASI_MFM_Status__c = 'Final')
            );
            insert listPlan;      
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing1',
                ASI_MFM_Customer_Name__c = listAcc[1].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id, 
                // ASI_MFM_Month_1_Cost__c = 1000,
                ASI_MFM_Total_Cost__c = 1000)
            );
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing2',
                ASI_MFM_Customer_Name__c = listAcc[1].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id,
                // ASI_MFM_Month_1_Cost__c = 2000,
                ASI_MFM_Total_Cost__c = 2000)
            );
            insert listPL;
                
            List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
            //FOC
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_CRM_Plan__c = listPlan[0].Id)
            );
            insert listFGR;
            
            test.startTest();
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listFGR[0]);
            ApexPages.currentPage().getParameters().put('id', listFGR[0].Id);
            ASI_CRM_TW_GenFOCRequestItems_Ctrl controller = new ASI_CRM_TW_GenFOCRequestItems_Ctrl(stdController); 
            controller.GenFOCItems();
           
            test.stopTest();
        }
    }
    private static testMethod void ASI_CRM_TW_FreeGoodRequest_Trg_FOCApprover(){
       List<RecordType> DynamicApprRouteRTId =  [Select Id From RecordType Where SobjectType = 'ASI_CRM_Dynamic_Approval_Route__c' and DeveloperName = 'ASI_CRM_TW_Dynamic_Approval_Route'];
       List<RecordType> FixApprRouteRTId =      [Select Id From RecordType Where SobjectType = 'ASI_CRM_Fix_Approval_Route__c' and DeveloperName = 'ASI_CRM_TW_Fix_Approval_Route'];
       List<RecordType> focRTId =               [Select Id From RecordType Where SobjectType = 'ASI_FOC_Free_Goods_Request__c' and DeveloperName = 'ASI_CRM_TW_FOC_Request'];
       List<RecordType> planRTId =              [Select Id From RecordType Where SobjectType = 'ASI_MFM_Plan__c' and DeveloperName = 'ASI_MFM_TW_Plan'];
       List<RecordType> requestItemFOCRTId =    [Select Id From RecordType Where SobjectType = 'ASI_FOC_Request_Item__c' and DeveloperName = 'ASI_CRM_TW_FOC_Request_Item'];
       
        Profile profile = [select id from profile where name='System Administrator'];
       User currentUser = TestFactory.createStandardUser('xxx');
       currentUser.ManagerId = UserInfo.getUserId();
       currentUser.ProfileId = profile.Id;
       Insert currentUser;

       User currentUser2 = TestFactory.createStandardUser('yyy');
       currentUser2.ManagerId = currentUser.Id;
       currentUser2.ProfileId = profile.Id;
       Insert currentUser2;

       User currentUser3 = TestFactory.createStandardUser('zzz');
       currentUser3.ManagerId = currentUser2.Id;
       currentUser3.ProfileId = profile.Id;
       currentUser3.Department = 'Sales (Domestic & International Markets) - SIP';
       //currentUser3.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';
       currentUser3.ASI_MFM_Department__c = 'Finance';
       //currentUser3.BypassTriggers__c = 'ASI_CRM_TW_FreeGoodsRequest_TriggerCls';
       Insert currentUser3;

       ASI_CRM_Dynamic_Approval_Route__c acdar1 = new ASI_CRM_Dynamic_Approval_Route__c();
       acdar1.ASI_CRM_User__c = currentUser2.Id;
       acdar1.ASI_CRM_End_of_Dynamic_Route__c = false;
       acdar1.ASI_CRM_Type__c = 'FOC';
       acdar1.RecordTypeId = DynamicApprRouteRTId[0].Id;
       acdar1.ASI_CRM_Skip_to_Next_Level__c = false;
       Insert acdar1;

       ASI_CRM_Dynamic_Approval_Route__c acdar2 = new ASI_CRM_Dynamic_Approval_Route__c();
       acdar2.ASI_CRM_User__c = currentUser.Id;
       acdar2.ASI_CRM_End_of_Dynamic_Route__c = false;
       acdar2.ASI_CRM_Type__c = 'FOC';
       acdar2.RecordTypeId = DynamicApprRouteRTId[0].Id;
       acdar2.ASI_CRM_Skip_to_Next_Level__c = true;
       Insert acdar2;

       ASI_CRM_Fix_Approval_Route__c acfar1 = new ASI_CRM_Fix_Approval_Route__c();
       acfar1.ASI_CRM_Department__c = 'MKT';
       acfar1.ASI_CRM_CN_Approver_1__c = currentUser2.Id;
       acfar1.ASI_CRM_CN_Type__c = 'FOC';
       acfar1.ASI_CRM_Company__c='NON-TRADE';
       acfar1.RecordTypeId = FixApprRouteRTId[0].Id;
       Insert acfar1;
       
       System.runAs(currentUser3)
       {
           acfar1.Id = null;       
           acfar1.ASI_CRM_Department__c = 'TMKT';
           Insert acfar1;
           
           acfar1.Id = null;       
           acfar1.ASI_CRM_Department__c = 'FIN';
           Insert acfar1;
           
           acfar1.Id = null;       
           acfar1.ASI_CRM_Department__c = 'OP';
           Insert acfar1;

            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
            insert px;
            
            user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pr;
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
            insert rt;
            
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
            insert rtm;
            
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
            insert rrd;
            
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
            insert subBrand1;
            
            test.startTest();
            
            ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName');
            insert p1;
            
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC',ASI_MFM_Reporting_Category__c='Consumer');
            insert ac;
            
            Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3');           
            insert acc2;
            
            ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p1.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
                ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
            insert pi;           


           ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
           foc.RecordTypeId = focRTId[0].Id;
           foc.OwnerId = currentUser3.Id;
           Insert foc;

           ASI_FOC_Request_Item__c focReqItem1 = new ASI_FOC_Request_Item__c();
           focReqItem1.ASI_FOC_Request_Order__c = foc.Id;
           focReqItem1.ASI_FOC_Request_Quantity_Bottle__c = 1;
           focReqItem1.ASI_FOC_Request_Quantity_PC__c = 1;
           focReqItem1.ASI_CRM_Plan_Line_Item__c = pi.Id;
           focReqItem1.RecordTypeId = requestItemFOCRTId[0].Id;
           Insert focReqItem1;
           
           Update foc;
       }
    }
    private static testMethod void ASI_CRM_TW_FreeGoodRequest_Trg_POSMApprover(){
       List<RecordType> DynamicApprRouteRTId =  [Select Id From RecordType Where SobjectType = 'ASI_CRM_Dynamic_Approval_Route__c' and DeveloperName = 'ASI_CRM_TW_Dynamic_Approval_Route'];
       List<RecordType> FixApprRouteRTId =      [Select Id From RecordType Where SobjectType = 'ASI_CRM_Fix_Approval_Route__c' and DeveloperName = 'ASI_CRM_TW_Fix_Approval_Route'];
       List<RecordType> planRTId =              [Select Id From RecordType Where SobjectType = 'ASI_MFM_Plan__c' and DeveloperName = 'ASI_MFM_TW_Plan'];
       List<RecordType> posmRTId =              [Select Id From RecordType Where SobjectType = 'ASI_FOC_Free_Goods_Request__c' and DeveloperName = 'ASI_CRM_TW_POSM_Request'];
       List<RecordType> requestItemPOSMRTId =   [Select Id From RecordType Where SobjectType = 'ASI_FOC_Request_Item__c' and DeveloperName = 'ASI_CRM_TW_POSM_Request_Item'];
       List<RecordType> SKURTId =   [Select Id From RecordType Where SobjectType = 'ASI_MFM_SKU_Code__c' and DeveloperName = 'ASI_MFM_TW_SKU_Code'];

        Profile profile = [select id from profile where name='System Administrator'];
       User currentUser = TestFactory.createStandardUser('xxx');
       currentUser.ManagerId = UserInfo.getUserId();
       currentUser.ProfileId = profile.Id;
       Insert currentUser;

       User currentUser2 = TestFactory.createStandardUser('yyy');
       currentUser2.ManagerId = currentUser.Id;
       currentUser2.ProfileId = profile.Id;
       Insert currentUser2;

       User currentUser3 = TestFactory.createStandardUser('zzz');
       currentUser3.ManagerId = currentUser2.Id;
       currentUser3.ProfileId = profile.Id;
       currentUser3.Department = 'Sales (Domestic & International Markets) - SIP';
       currentUser3.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';
       //currentUser3.BypassTriggers__c = 'ASI_CRM_TW_FreeGoodsRequest_TriggerCls';
       Insert currentUser3;

       ASI_CRM_Dynamic_Approval_Route__c acdar1 = new ASI_CRM_Dynamic_Approval_Route__c();
       acdar1.ASI_CRM_User__c = currentUser2.Id;
       acdar1.ASI_CRM_End_of_Dynamic_Route__c = false;
       acdar1.ASI_CRM_Type__c = 'POSM';
       acdar1.RecordTypeId = DynamicApprRouteRTId[0].Id;
       acdar1.ASI_CRM_Skip_to_Next_Level__c = false;
       Insert acdar1;
       
       ASI_CRM_Dynamic_Approval_Route__c acdar2 = new ASI_CRM_Dynamic_Approval_Route__c();
       acdar2.ASI_CRM_User__c = currentUser.Id;
       acdar2.ASI_CRM_End_of_Dynamic_Route__c = false;
       acdar2.ASI_CRM_Type__c = 'POSM';
       acdar2.RecordTypeId = DynamicApprRouteRTId[0].Id;
       acdar2.ASI_CRM_Skip_to_Next_Level__c = true;
       Insert acdar2;
       
       ASI_CRM_Fix_Approval_Route__c acfar1 = new ASI_CRM_Fix_Approval_Route__c();
       acfar1.ASI_CRM_Department__c = 'MKT';
       acfar1.ASI_CRM_CN_Approver_1__c = currentUser2.Id;
       acfar1.ASI_CRM_CN_Type__c = 'POSM';
       acfar1.RecordTypeId = FixApprRouteRTId[0].Id;
       Insert acfar1;

       System.runAs(currentUser3)
       {
           ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
           foc.RecordTypeId = posmRTId[0].Id;
           foc.OwnerId = currentUser3.Id;
           Insert foc;
           
           List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
           ASI_MFM_SKU_Code__c sku1 = new ASI_MFM_SKU_Code__c();
           sku1.ASI_CRM_Department__c = 'Sales';
           sku1.ASI_HK_CRM_IsPOSProduct__c = true;
           sku1.ASI_HK_CRM_Active__c = true;
           sku1.RecordTypeId = SKURTId[0].Id;

           ASI_MFM_SKU_Code__c sku2 = new ASI_MFM_SKU_Code__c();
           sku2.ASI_CRM_Department__c = 'MKT';
           sku2.ASI_HK_CRM_IsPOSProduct__c = true;
           sku2.ASI_HK_CRM_Active__c = true;
           sku2.RecordTypeId = SKURTId[0].Id;

           ASI_MFM_SKU_Code__c sku3 = new ASI_MFM_SKU_Code__c();
           sku3.ASI_CRM_Department__c = 'OP';
           sku3.ASI_HK_CRM_IsPOSProduct__c = true;
           sku3.ASI_HK_CRM_Active__c = true;
           sku3.RecordTypeId = SKURTId[0].Id;

           ASI_MFM_SKU_Code__c sku4 = new ASI_MFM_SKU_Code__c();
           sku4.ASI_CRM_Department__c = 'HR';
           sku4.ASI_HK_CRM_IsPOSProduct__c = true;
           sku4.ASI_HK_CRM_Active__c = true;
           sku4.RecordTypeId = SKURTId[0].Id;

           skuList.add(sku1);
           skuList.add(sku2);
           skuList.add(sku3);
           skuList.add(sku4);
           Insert skuList;

           List<ASI_FOC_Request_Item__c> reqItemList = new List<ASI_FOC_Request_Item__c>();
           ASI_FOC_Request_Item__c focReqItem1 = new ASI_FOC_Request_Item__c();
           focReqItem1.ASI_FOC_Request_Order__c = foc.Id;
           focReqItem1.RecordTypeId = requestItemPOSMRTId[0].Id;
           focReqItem1.ASI_FOC_Request_Quantity_Bottle__c = 1;
           focReqItem1.ASI_FOC_Request_Quantity_PC__c = 1;
           focReqItem1.ASI_FOC_SKU__c = sku1.Id;
           
           ASI_FOC_Request_Item__c focReqItem2 = new ASI_FOC_Request_Item__c();
           focReqItem2.ASI_FOC_Request_Order__c = foc.Id;
           focReqItem2.RecordTypeId = requestItemPOSMRTId[0].Id;
           focReqItem2.ASI_FOC_Request_Quantity_Bottle__c = 1;
           focReqItem2.ASI_FOC_Request_Quantity_PC__c = 1;
           focReqItem2.ASI_FOC_SKU__c = sku2.Id;
           
           ASI_FOC_Request_Item__c focReqItem3 = new ASI_FOC_Request_Item__c();
           focReqItem3.ASI_FOC_Request_Order__c = foc.Id;
           focReqItem3.RecordTypeId = requestItemPOSMRTId[0].Id;
           focReqItem3.ASI_FOC_Request_Quantity_Bottle__c = 1;
           focReqItem3.ASI_FOC_Request_Quantity_PC__c = 1;
           focReqItem3.ASI_FOC_SKU__c = sku3.Id;
           
           ASI_FOC_Request_Item__c focReqItem4 = new ASI_FOC_Request_Item__c();
           focReqItem4.ASI_FOC_Request_Order__c = foc.Id;
           focReqItem4.RecordTypeId = requestItemPOSMRTId[0].Id;
           focReqItem4.ASI_FOC_Request_Quantity_Bottle__c = 1;
           focReqItem4.ASI_FOC_Request_Quantity_PC__c = 1;
           focReqItem4.ASI_FOC_SKU__c = sku4.Id;
           
           reqItemList.add(focReqItem1);
           reqItemList.add(focReqItem2);
           reqItemList.add(focReqItem3);
           reqItemList.add(focReqItem4);
           Insert reqItemList;

           Update foc;
       }
    }
}