/*********************************************************************************
 * Name: ASI_CRM_TH_OpenVisitForm_Test
 * 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 24/05/2016       Introv: Twinkle LI      Created, Test Class for ASI_CRM_TH_WS_OpenVisitFormCtrl & ASI_CRM_TH_Outlet_OpenVisitFormCtrl
*********************************************************************************/
@isTest 
public with sharing class ASI_CRM_TH_OpenVisitForm_Test{
    public static ASI_HK_CRM_Visitation_Plan_Detail__c dataInsert(){ 
        ASI_HK_CRM_Running_Number__c customerCodeRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Customer_Code', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = 'TH_A{000000}' );        
        insert customerCodeRunningNumber;
    
        ASI_HK_CRM_Running_Number__c contractRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Contract__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '{YY/YY}{0000}' );        
        insert contractRunningNumber;   
        
        ASI_HK_CRM_Running_Number__c paymentRequestRunningNumber= new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_PaymentRequest__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '60{YY}{0000}' );        
        insert paymentRequestRunningNumber;    
        
        List<ASI_CRM_TH_Picklist_Setting__c> listPicklists = new List<ASI_CRM_TH_Picklist_Setting__c>();
        listPicklists.add(new ASI_CRM_TH_Picklist_Setting__c(
            ASI_CRM_Value__c ='objective1;objective2', 
            ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c', 
            ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail', 
            ASI_CRM_Field__c = 'ASI_TH_CRM_Objectives__c', 
            Name = 'VPD Objectives (Outlet)')
        );
        listPicklists.add(new ASI_CRM_TH_Picklist_Setting__c(
            ASI_CRM_Value__c ='objective1;objective2', 
            ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c', 
            ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail', 
            ASI_CRM_Field__c = 'ASI_TH_CRM_Objectives__c', 
            Name = 'VPD Objectives (WS)')
        );
        listPicklists.add(new ASI_CRM_TH_Picklist_Setting__c(
            ASI_CRM_Value__c ='who1;who2', 
            ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c', 
            ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail', 
            ASI_CRM_Field__c = 'ASI_TH_CRM_Who__c', 
            Name = 'VPD Who (Outlet)')
        );
        listPicklists.add(new ASI_CRM_TH_Picklist_Setting__c(
            ASI_CRM_Value__c ='who1;who2', 
            ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c', 
            ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail', 
            ASI_CRM_Field__c = 'ASI_TH_CRM_Who__c', 
            Name = 'VPD Who (WS)')
        );
        insert listPicklists;
        
        Id recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Brand__cASI_TH_CRM_BRAND');
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(
            RecordTypeId = RecordTypeId, 
            Name = 'Brand 1'
        );
        insert brand;
      
        recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand');
        List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>();
        listSubBrand.add(new ASI_MFM_Sub_brand__c(
            RecordTypeId = RecordTypeId, 
            Name = 'Sub-brand Outlet - Competitor', 
            ASI_MFM_Brand__c = brand.id, 
            ASI_TH_CRM_Active__c = true,
            ASI_CRM_Outlet_Visit__c = true,
            ASI_TH_CRM_Product_Group_1__c = 'Competitor')
        );
        listSubBrand.add(new ASI_MFM_Sub_brand__c(
            RecordTypeId = RecordTypeId, 
            Name = 'Sub-brand Outlet - Competitor', 
            ASI_MFM_Brand__c = brand.id, 
            ASI_TH_CRM_Active__c = true,
            ASI_CRM_Outlet_Visit__c = true,
            ASI_TH_CRM_Product_Group_1__c = 'Competitor')
        );
        listSubBrand.add(new ASI_MFM_Sub_brand__c(
            RecordTypeId = RecordTypeId, 
            Name = 'Sub-brand WS - PRT', 
            ASI_MFM_Brand__c = brand.id, 
            ASI_TH_CRM_Active__c = true,
            ASI_CRM_WS_Visit__c = true)
        );
        listSubBrand.add(new ASI_MFM_Sub_brand__c(
            RecordTypeId = RecordTypeId, 
            Name = 'Sub-brand WS - PRT', 
            ASI_MFM_Brand__c = brand.id, 
            ASI_TH_CRM_Active__c = true,
            ASI_CRM_WS_Visit__c = true)
        );
        listSubBrand.add(new ASI_MFM_Sub_brand__c(
            RecordTypeId = RecordTypeId, 
            Name = 'Sub-brand WS - Competitor', 
            ASI_MFM_Brand__c = brand.id, 
            ASI_TH_CRM_Active__c = true,
            ASI_CRM_WS_Visit__c = true,
            ASI_TH_CRM_Product_Group_1__c = 'Competitor')
        );
        listSubBrand.add(new ASI_MFM_Sub_brand__c(
            RecordTypeId = RecordTypeId, 
            Name = 'Sub-brand WS - Competitor', 
            ASI_MFM_Brand__c = brand.id, 
            ASI_TH_CRM_Active__c = true,
            ASI_CRM_WS_Visit__c = true,
            ASI_TH_CRM_Product_Group_1__c = 'Competitor')
        );
        insert listSubBrand;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Group_Outlet_Type__cASI_CRM_TH_Group_Outlet_Type');
        ASI_CRM_Group_Outlet_Type__c grpOutletType = new ASI_CRM_Group_Outlet_Type__c(
            RecordTypeId = recordtypeId,
            ASI_CRM_SG_Group_Outlet_Name__c='Group Outlet Type 1'
        );
        insert grpOutletType;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_TH_CRM_Outlet_Type');
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
            RecordTypeId = recordtypeId,
            Name = 'HEB-High Energy',
            ASI_TH_CRM_Code__c = 'HEB',
            ASI_CRM_Group_Outlet_Type__c = grpOutletType.id
        );
        insert outletType;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletImage__cASI_TH_CRM_Outlet_Image');
        ASI_TH_CRM_OutletImage__c outletImage = new ASI_TH_CRM_OutletImage__c(
            RecordTypeId = recordtypeId,
            Name = 'Iconic',
            ASI_TH_CRM_Code__c = 'TH_ICN'
        );
        insert outletImage;
         
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_ServicePack__cASI_CRM_TH_ServicePack');    
        ASI_CRM_ServicePack__c  servicePack = new ASI_CRM_ServicePack__c(
            RecordTypeId = recordtypeId,
            ASI_CRM_SG_Outlet_Type__c = grpOutletType.id,
            ASI_CRM_OutletImage__c = outletImage.id,
            ASI_CRM_Outlet_Type__c = outletType.id
        );
        insert servicePack;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_ServicePackItem__cASI_CRM_TH_ServicePackItem');   
        List<ASI_CRM_ServicePackItem__c> listServicePackItem = new List<ASI_CRM_ServicePackItem__c>();
        listServicePackItem.add(new ASI_CRM_ServicePackItem__c(
            RecordTypeId = recordtypeId,
            ASI_CRM_ServicePack__c = servicePack.Id,
            ASI_CRM_Subbrand__c = listSubBrand[2].id)
        );
        listServicePackItem.add(new ASI_CRM_ServicePackItem__c(
            RecordTypeId = recordtypeId,
            ASI_CRM_ServicePack__c = servicePack.Id,
            ASI_CRM_Subbrand__c = listSubBrand[3].id)
        );
        insert listServicePackItem;
        
        recordTypeid = Global_RecordTypeCache.getRtId('AccountASI_TH_CRM_Potential_Outlet');
        Account potentialOutlet = new Account(
            RecordTypeId = recordTypeid, 
            Name = 'TH Potential Outlet'
        );
        insert potentialOutlet;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Potential_Outlet');
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId = recordTypeid, 
            Name = 'TH Potential Outlet', 
            ASI_CRM_Account__c = potentialOutlet.id,
            ASI_CRM_Service_Pack__c = servicePack.id,
            ASI_TH_CRM_OutletImage__c = outletImage.id,
            ASI_TH_CRM_OutletType__c = outletType.id
        );
        insert customer;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_TH_CRM_Actual_Offtake');
        List<ASI_TH_CRM_Actual_Offtake__c> listActOfftake = new List<ASI_TH_CRM_Actual_Offtake__c>();
        listActOfftake.add(new ASI_TH_CRM_Actual_Offtake__c(
            ASI_TH_CRM_Outlet__c = potentialOutlet.id,
            ASI_TH_CRM_Sub_brand__c = listSubBrand[0].id,
            ASI_TH_CRM_Offtake_G_L_Date__c = date.valueOf('2016-05-15'),
            ASI_TH_CRM_Quantity__c = 1000)
        );
        listActOfftake.add(new ASI_TH_CRM_Actual_Offtake__c(
            ASI_TH_CRM_Outlet__c = potentialOutlet.id,
            ASI_TH_CRM_Sub_brand__c = listSubBrand[2].id,
            ASI_TH_CRM_Offtake_G_L_Date__c = date.valueOf('2016-05-15'),
            ASI_TH_CRM_Quantity__c = 1000)
        );
        listActOfftake.add(new ASI_TH_CRM_Actual_Offtake__c(
            ASI_TH_CRM_Outlet__c = potentialOutlet.id,
            ASI_TH_CRM_Sub_brand__c = listSubBrand[4].id,
            ASI_TH_CRM_Offtake_G_L_Date__c = date.valueOf('2016-05-15'),
            ASI_TH_CRM_Quantity__c = 1000)
        );
        insert listActOfftake;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_TH_CRM_National');
        List<ASI_HK_CRM_Promotion__c> listPromotion = new List<ASI_HK_CRM_Promotion__c>();
        listPromotion.add(new ASI_HK_CRM_Promotion__c(
            RecordTypeid = recordTypeid, 
            Name = 'Event Promotion', 
            ASI_CRM_Type__c = 'Event',
            ASI_HK_CRM_Promotion_Start_Date__c = date.valueOf('2016-05-01'), 
            ASI_HK_CRM_Promotion_End_Date__c = date.valueOf('2016-05-31'))
        );
        listPromotion.add(new ASI_HK_CRM_Promotion__c(
            RecordTypeid = recordTypeid, 
            Name = 'GWP Promotion', 
            ASI_CRM_Type__c = 'GWP',
            ASI_CRM_Outlet_Type__c = 'HEB',
            ASI_HK_CRM_Promotion_Start_Date__c = date.valueOf('2016-05-01'), 
            ASI_HK_CRM_Promotion_End_Date__c = date.valueOf('2016-05-31'))
        );
        insert listPromotion;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion_Detail__cASI_TH_CRM_Outlet');
        ASI_HK_CRM_Promotion_Detail__c promotionDetail = new ASI_HK_CRM_Promotion_Detail__c(
            RecordTypeid = recordTypeid, 
            ASI_HK_CRM_Account__c = potentialOutlet.id, 
            ASI_HK_CRM_Promotion__c = listPromotion[0].id
        );
        insert promotionDetail;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Status__cASI_CRM_TH_PromotionStatus');
        List<ASI_CRM_Promotion_Status__c> listPromotionStatus = new List<ASI_CRM_Promotion_Status__c>();
        listPromotionStatus.add(new ASI_CRM_Promotion_Status__c(
            ASI_CRM_Account__c = potentialOutlet.id, 
            ASI_CRM_Promotion__c = listPromotion[0].id,
            ASI_CRM_Status__c = 'Proposed')
        );
        listPromotionStatus.add(new ASI_CRM_Promotion_Status__c(
            ASI_CRM_Account__c = potentialOutlet.id, 
            ASI_CRM_Promotion__c = listPromotion[1].id,
            ASI_CRM_Status__c = 'Proposed',
            ASI_CRM_GWP_Allocation__c = 0)
        );
        listPromotionStatus.add(new ASI_CRM_Promotion_Status__c(
            ASI_CRM_Account__c = potentialOutlet.id, 
            ASI_CRM_Promotion__c = listPromotion[1].id,
            ASI_CRM_Status__c = 'Rejected',
            ASI_CRM_GWP_Allocation__c = 10)
        );
        insert listPromotionStatus;
        
        ASI_CRM_Sales_Movement__c salesMovement = new ASI_CRM_Sales_Movement__c(
            ASI_CRM_Account__c = potentialOutlet.id,
            ASI_CRM_Date__c = date.valueOf('2016-05-21'), 
            ASI_CRM_Sub_brand__c = listSubBrand[0].id
        );
        insert salesMovement;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_TH_CRM_Visitation_Plan');
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(
            RecordTypeid = recordTypeid,
            Name = 'Visitation Plan 1', 
            ASI_HK_CRM_Year__c = '2016', 
            ASI_HK_CRM_Month__c = 'May'
        );      
        insert visitationPlan;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_TH_CRM_Visitation_Plan_Detail');    
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
            RecordTypeid = recordTypeid,
            ASI_HK_CRM_Account__c = potentialOutlet.id, 
            ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
            ASI_HK_CRM_Visit_Date__c = Date.newInstance(2016,5,21), 
            ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2016-05-21 11:00:00'), 
            ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2016-05-21 12:00:00')
        );
        insert vpDetail;
        
        return vpDetail;
    }
	public static Attachment attachmentInsert(Id parentId){
    	Attachment attach = new Attachment();
        attach.name = 'Test Attachment';
        Blob body = Blob.valueOf('Test Attachment Body');
        attach.body = body;
        attach.ParentId = parentId;
        insert attach;
        
        return attach;
    }
    
    static testMethod void Outlet_OpenVisitForm_Test(){
        ASI_HK_CRM_Visitation_Plan_Detail__c  vpd = dataInsert();
        Attachment attach = attachmentInsert(vpd.id);
        
        ApexPages.standardController stdcontroller = new ApexPages.standardController(vpd);
        ApexPages.currentPage().getParameters().put('vpid', vpd.id);    
        ApexPages.currentPage().getParameters().put('accid', vpd.ASI_HK_CRM_Account__c);
        
        List<String> strObjectives = new List<String> {'objective1'};
        List<String> strWhos = new List<String> {'who1'};
        
        ASI_CRM_TH_Outlet_OpenVisitFormCtrl controller = new ASI_CRM_TH_Outlet_OpenVisitFormCtrl(stdcontroller); 
        
        List<SelectOption> SalesMovntOpt = controller.getSalesMovntOpt();
        List<SelectOption> PromoOpt = controller.getPromoOpt();
        List<SelectOption> PromoTypeList = controller.getPromoTypeList();
        List<SelectOption> ObjectiveList = controller.getObjectiveList();
        List<SelectOption> WhoList = controller.getWhoList();
        List<SelectOption> ActivitiesList = controller.getActivitiesList();
        List<SelectOption> PromoMaterialsList = controller.getPromoMaterialsList();
        List<SelectOption> ProductDisplayList = controller.getProductDisplayList();
        List<SelectOption> SpecialDisplayList = controller.getSpecialDisplayList();
        List<SelectOption> BarSupplyList = controller.getBarSupplyList();
        List<SelectOption> SignageList = controller.getSignageList();
        
        //Case 1
        controller.VisitDateF = datetime.valueOf('2015-05-21 12:00:00');
        controller.VisitDateT = datetime.valueOf('2015-05-20 13:00:00');
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 2
        controller.VisitDateF = datetime.valueOf('2015-05-21 12:00:00');
        controller.VisitDateT = datetime.valueOf('2015-05-21 13:00:00');
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 3
        controller.strCxlReason= 'Changed';
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 4
        controller.strOutletTypeCode = 'LEB';
        controller.selectedObjectives = strObjectives;
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 6
        controller.selectedWho = strWhos;
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 7
        controller.presencePrtProduct();
        controller.presenceCompetitorProduct();
        controller.errorMessage();
        controller.getMultiSelectValues('[a;b]');
        controller.getSalesMovntOpt();
        controller.AddRow();
        controller.RemoveRow();
        
        //Attachment
        String output = ASI_CRM_TH_Outlet_OpenVisitFormCtrl.insertAttachment((String)vpd.ASI_HK_CRM_Visitation_Plan__c, attach.Body.toString(), attach.name, null, null);
        
        //PRT product
        controller.lstSalesMovnt[0].strSalesMovntPresence = 'Y';
        controller.lstSalesMovnt[0].decListPrice = null;
        
        controller.lstSalesMovnt[1].strSalesMovntPresence = 'N';
        controller.lstSalesMovnt[1].strSalesMovntVisibility = 'Y';
        controller.lstSalesMovnt[1].decListPrice = 10;
        
        //Competitor product
        controller.lstSalesMovnt_Competitor[0].strSalesMovntPresence = 'Y';
        controller.lstSalesMovnt_Competitor[0].decListPrice = null;
        
        controller.lstSalesMovnt_Competitor[1].strSalesMovntPresence = 'N';
        controller.lstSalesMovnt_Competitor[1].strSalesMovntVisibility = 'Y';
        controller.lstSalesMovnt_Competitor[1].decListPrice = 10;
 
        //Promotion Status - Event
        controller.lstPromoStatus[0].joinDate = date.valueOf('2016-04-30');
        controller.lstPromoStatus[0].status = 'Proposed';

        //Promotion Status - GWP
        controller.lstPromoStatus[1].status = 'Rejected';
        controller.lstPromoStatus[1].gwpAllocation = null; 
        
        controller.isQuickSave = true;
        controller.QuickSave();
        controller.Save(); 
    }     
    
    static testMethod void WS_OpenVisitForm_Test(){
        ASI_HK_CRM_Visitation_Plan_Detail__c  vpd = dataInsert();
        
        ApexPages.standardController stdcontroller = new ApexPages.standardController(vpd);
        ApexPages.currentPage().getParameters().put('vpid', vpd.id);    
        ApexPages.currentPage().getParameters().put('accid', vpd.ASI_HK_CRM_Account__c);
        
        List<String> strObjectives = new List<String> {'objective1'};
        List<String> strWhos = new List<String> {'who1'};
        
        ASI_CRM_TH_WS_OpenVisitFormCtrl controller = new ASI_CRM_TH_WS_OpenVisitFormCtrl(stdcontroller); 
        
        List<SelectOption> SalesMovntOpt = controller.getSalesMovntOpt();
        List<SelectOption> PromoOpt = controller.getPromoOpt();
        List<SelectOption> ObjectiveList = controller.getObjectiveList();
        List<SelectOption> WhoList = controller.getWhoList();
        
        //Case 1
        controller.VisitDateF = datetime.valueOf('2015-05-21 12:00:00');
        controller.VisitDateT = datetime.valueOf('2015-05-20 13:00:00');
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 2
        controller.VisitDateF = datetime.valueOf('2015-05-21 12:00:00');
        controller.VisitDateT = datetime.valueOf('2015-05-21 13:00:00');
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 3
        controller.strCxlReason= 'Changed';
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 4
        controller.selectedObjectives = strObjectives;
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 6
        controller.selectedWho = strWhos;
        
        controller.isQuickSave = true;
        controller.QuickSave();
        
        //Case 7
        controller.presencePrtProduct();
        controller.presenceCompetitorProduct();
        controller.errorMessage(); 
        controller.getMultiSelectValues('[a;b]');
        controller.getSalesMovntOpt();
        
        //PRT product
        controller.lstSalesMovnt[0].strSalesMovntPresence = 'Y';
        controller.lstSalesMovnt[0].decCurrentStock = null;
        controller.lstSalesMovnt[0].decListPrice = null;
        
        controller.lstSalesMovnt[1].strSalesMovntPresence = 'N';
        controller.lstSalesMovnt[1].strSalesMovntVisibility = 'Y';
        controller.lstSalesMovnt[1].decCurrentStock = 10;
        
        //Competitor product
        controller.lstSalesMovnt_Competitor[0].strSalesMovntPresence = 'Y';
        controller.lstSalesMovnt_Competitor[0].decCurrentStock = null;
        controller.lstSalesMovnt_Competitor[0].decListPrice = null;
        
        controller.lstSalesMovnt_Competitor[1].strSalesMovntPresence = 'N';
        controller.lstSalesMovnt_Competitor[1].strSalesMovntVisibility = 'Y';
        controller.lstSalesMovnt_Competitor[1].decCurrentStock = 10;
        
        controller.isQuickSave = true;
        controller.QuickSave();
        controller.Save(); 
        
    }     
}