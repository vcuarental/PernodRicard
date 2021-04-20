@istest
public class ASI_FOC_TW_SubmitFOCCtrlTestClass {
    //Test Class for ASI_FOC_TW_SubmitFOCController  
    static testMethod void FOC_TW_SubmitController_Test_1(){
        
        user u = [SELECT id, userRole.developerName FROM user WHERE id = :userInfo.getUserId()];    
        u.ASI_MFM_Country__c ='TW';
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
            listAcc.add(new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'),Name='Test Outlet',ASI_TH_CRM_Region__c ='North'));  
            listAcc.add(new Account( RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'),Name='Test Customer'));  
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));    
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
                ASI_CRM_TW_Floor__c = '12')
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
            listItemGp.add(new ASI_MFM_Item_Group__c(RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),Name = 'Item Gp 1',ASI_CRM_Active__c = TRUE,ASI_CRM_Applied_To__c = 'TOT'));
            listItemGp.add(new ASI_MFM_Item_Group__c(RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),Name = 'Item Gp 2',ASI_CRM_Active__c = TRUE,ASI_CRM_Applied_To__c = 'TOT'));
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
            
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
            insert ac;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
            insert ap;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
            insert sub;
            
            
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
            List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
            listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                             ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                             ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            insert listPlan;      
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
            insert listPL;
            
            List<ASI_MFM_Exchange_Rate__c> listXR = new List<ASI_MFM_Exchange_Rate__c>();
            listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1));                                  
            insert listXR;    
           
            test.startTest();
            System.debug(Limits.getDMLRows());
             
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Status__c='Final',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), ASI_MFM_Plan__c=listPlan[0].id,ASI_MFM_Supplier_Name__c = listAcc[3].id, ASI_MFM_Prefix__c=pxo.id); 
            insert po;
            
            List<ASI_MFM_PO_Line_Item__c> poLinelist= new List<ASI_MFM_PO_Line_Item__c> ();
            ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi1);
            ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi2);
            insert poLinelist;
            
            
            List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
            //POSM
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,ASI_CRM_Plan__c=listPlan[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose'));
            insert listFGR;
            
            
            
            List<ASI_FOC_Request_Item__c> listItems = new List<ASI_FOC_Request_Item__c>();
            //POSM
            listItems.add(new ASI_FOC_Request_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_FOC_Request_Item'),
                ASI_FOC_Request_Order__c = listFGR[0].Id,ASI_FOC_Unit_Cost_PC_BT__c=10,
                ASI_FOC_SKU__c = listSKU[0].id,ASI_CRM_Plan_Line_Item__c=listPL[0].id,
                ASI_FOC_Request_Quantity_Bottle__c = 10));
            insert listItems;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listFGR[0]);
            ApexPages.currentPage().getParameters().put('id', listFGR[0].id);  
            ASI_FOC_TW_SubmitFOCController controller = new ASI_FOC_TW_SubmitFOCController(stdController); 
            
            controller.submitRequest2();
            controller.goBack();
            test.stopTest();
        }
    }
    
}