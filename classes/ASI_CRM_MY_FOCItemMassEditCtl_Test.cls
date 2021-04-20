/***************************************************************************************************
 * Name : ASI_CRM_MY_FOCItemMassEditCtl_Test
 * Test Class for ASI_CRM_MY_FOCItemMassEditCtl
 * Revision History:
 * 1. 11/12/2020 - [Ceterna 11122020] - Change sku id tracking to sku name and sku code for query  
  **************************************************************************************************/
@isTest
public class ASI_CRM_MY_FOCItemMassEditCtl_Test {
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
            
            con.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
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
            controller2.FOC = fg;
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
            controller2.validateFOCOrderItems(fg);
                     /* [Ceterna 11122020] Start  */     
            ApexPages.currentPage().getParameters().put('node',sku1.Name);
            /* [Ceterna 11122020] End */
             ApexPages.currentPage().getParameters().put('node1','0');
            controller2.populatePrice();
        }
    }
    
}