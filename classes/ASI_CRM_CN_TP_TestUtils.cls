/**
 * @Author      
 * @CreateDate  2019-04-10
 * @Description 
 */
@isTest
public without sharing class ASI_CRM_CN_TP_TestUtils {

    public static User generateAdminUser(String userName){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'ASI_CN'];
        User adminUser = new User(
            Alias = 'Admin', Email = 'admin@org.com', EmailEncodingKey = 'UTF-8', UserRoleId = r.Id,
            LastName = 'Admin', LanguageLocaleKey = 'zh_CN', LocaleSidKey = 'zh_CN', ProfileId = p.Id, 
            IsActive = true, TimeZoneSidKey='Asia/Shanghai', UserName = userName,
            CompanyName = 'Pernod Ricard China', Autofollow__c = false, BypassTriggers__c = 'Autofollow_User_InsertUpdate');
        insert adminUser;
        return adminUser;
    }
    //
    public static User createUser(String profileName) {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = :profileName];
        User salesMan = new User();
        salesMan.Email = 'zhan971014@qq.com';
        salesMan.LastName = 'zhan';
        salesMan.Username = salesMan.Email;
        salesMan.CommunityNickname = 'zhan';
        salesMan.Alias = 'zhan';
        salesMan.ProfileId = userProfile.Id;
        salesMan.TimeZoneSidKey = 'Asia/Shanghai';
        salesMan.LocaleSidKey = 'zh_CN';
        salesMan.EmailEncodingKey = 'UTF-8';
        salesMan.LanguageLocaleKey = 'zh_CN';
        INSERT salesMan;
        return salesMan;
    }
  
  public static ASI_CRM_Division__c getDivision(){
    ASI_CRM_Division__c division =  new ASI_CRM_Division__c();
    division.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Division__cASI_CRM_CN_Region');
    division.Name = 'Shanghai(Div)';
    division.ASI_CRM_CN_Chinese_Name__c = '上海';
    division.ASI_CRM_English_Name__c = 'Shanghai(Div)';
    division.ASI_CRM_Division_Code__c = '1000';
    division.ASI_CRM_Sequence__c = 0;
    division.ASI_CRM_External_Id__c = 'CN_Shanghai(Div)';
    return division;
  }
  public static ASI_CRM_CN_Area__c getArea(ASI_CRM_Division__c division){
    ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c();
    area.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Area__cASI_CRM_CN_Area');
    area.Name = '上海';
    area.ASI_CRM_CN_Area_Code__c = '101';
    area.ASI_CRM_English_Name__c = 'Shanghai';
    area.ASI_CRM_CN_Chinese_Name__c = '上海';
    area.ASI_CRM_Division__c = division.id;
    return area;
  }
  public static ASI_CRM_Province__c getProvince(){
    ASI_CRM_Province__c province = new ASI_CRM_Province__c();
    province.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Province__cASI_CRM_CN_Province');
    province.Name = '上海';
    province.ASI_CRM_Province_Code__c = 'SHANGHAI';
    province.ASI_CRM_Chinese_Name__c = '上海';
    province.ASI_CRM_English_Name__c = 'Shanghai';
    province.ASI_CRM_External_ID__c = 'CN_SHANGHAI';
    return province;
  }
  public static ASI_CRM_City__c getCity(ASI_CRM_Province__c province){
    ASI_CRM_City__c city = new ASI_CRM_City__c();
    city.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City');
    city.Name = '上海 Shanghai';
    city.ASI_CRM_English_Name__c = 'Shanghai';
    city.ASI_CRM_Chinese_Name__c = '上海';
    city.ASI_CRM_CN_Province__c = province.id;
    city.ASI_CRM_CN_City_Tier__c = '1';
    city.ASI_CRM_CN_T1_Located__c = true;
    return city;
  }
  public static ASI_CRM_CN_Channel__c getChannel(){
    ASI_CRM_CN_Channel__c cnChannel = new ASI_CRM_CN_Channel__c();
    cnChannel.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_Channel');
    cnChannel.Name = 'Hypermarket';
    cnChannel.ASI_CRM_For_Outlet__c = true;
    cnChannel.ASI_CRM_External_ID__c = 'CN_New_Hypermarket';
    return cnChannel;
  }

  public static ASI_CRM_AccountsAdditionalField__c getAccountsAdditional(ASI_CRM_City__c city,ASI_CRM_CN_Channel__c cnChannel){
    ASI_CRM_AccountsAdditionalField__c accountAdditionField = new ASI_CRM_AccountsAdditionalField__c();
    accountAdditionField.Name = '大润发上海总部(OFSHA0035)';
    accountAdditionField.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
    accountAdditionField.ASI_CRM_CN_CCity__c = city.id;
    accountAdditionField.ASI_CRM_CN_Phone_Number__c = '021-54377588';
    accountAdditionField.ASI_CRM_CN_Email__c = 'prc.sfdc.test@pernod-ricard.com';
    accountAdditionField.ASI_CRM_CN_Eng_Name__c = 'RT-Mart Shanghai HQ';
    accountAdditionField.ASI_CRM_CN_Address__c = '春申路2801号';
    //accountAdditionField.ASI_CRM_CN_NewChannel__c = cnChannel.id;
    accountAdditionField.ASI_CRM_CN_Commercial_Team__c = 'Prestige';
    accountAdditionField.ASI_CRM_CN_New_Image__c = 'Leading';
    accountAdditionField.ASI_CRM_CN_CR12_Btl_per_month__c = 0;
    return accountAdditionField;
  }
  
  public static ASI_CRM_KA_Account__c getKaAccount(){
    ASI_CRM_KA_Account__c kaAcc = new ASI_CRM_KA_Account__c();
    kaAcc.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_KA_Account');
    kaAcc.Name = 'A Best 新一佳';
    kaAcc.ASI_CRM_Chi_Name__c = '新一佳';
    return kaAcc;
  }
  public static ASI_TH_CRM_Contract__c getContract(ASI_CRM_AccountsAdditionalField__c accountAdditionField){
    ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
    contract.recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
    contract.ASI_CRM_CN_PO_No__c = '20190045';
    contract.ASI_CRM_CN_PO_Version__c = '0.0';
    contract.ASI_CRM_New_FY_PO__c = true;
    contract.ASI_CRM_CN_Outlet_WS__c = accountAdditionField.id;
    contract.ASI_TH_CRM_Promotion_Type__c = 'Promotion';
    contract.ASI_CRM_CN_Status__c = 'Draft';
    contract.ASI_CRM_CN_Description__c = 'This is Test';
    return contract;
  }
  
  public static ASI_MFM_Prefix__c getPrefix(){
    ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c();
    prefix.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');
    prefix.Name = 'CN Trade Plan';
    prefix.ASI_MFM_Module__c = 'Plan';
    prefix.Plan_Type__c = 'Trade Plan';
    prefix.ASI_MFM_Fiscal_year__c = 'FY1920';
    return prefix;
  }
  public static ASI_MFM_Role_Prefix_Relationship__c getPrefixRelationShip(ASI_MFM_Prefix__c prefix){
    ASI_MFM_Role_Prefix_Relationship__c  prefixRelation = new ASI_MFM_Role_Prefix_Relationship__c();
    prefixRelation.ASI_MFM_Prefix__c = prefix.id;
    prefixRelation.ASI_MFM_Role_Name__c = 'ASI_CN';
    return prefixRelation;
  }

  public static ASI_MFM_Plan__c getTradePlan(ASI_TH_CRM_Contract__c contract,ASI_MFM_Prefix__c prefix,ASI_CRM_CN_Channel__c cnChannel,ASI_CRM_KA_Account__c kaAcc){
    ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c();
    plan.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan');
    plan.Name = 'CN Trade Plan0065__FY19';
    plan.ASI_MFM_Status__c = 'Complete';
    plan.ASI_CRM_CN_TP_KA_Account__c = kaAcc.id;
    plan.ASI_MFM_Fiscal_year__c = 'FY1920';
    plan.ASI_MFM_Prefix__c = prefix.id;
    plan.ASI_CRM_CN_TP_Channel__c = cnChannel.id;
    plan.ASI_CRM_CN_TP_Contract__c = contract.id;
    return plan;
  }
  public static ASI_MFM_Sub_brand__c getSubBrand(){
    ASI_MFM_Sub_brand__c sbrand = new ASI_MFM_Sub_brand__c ();
    sbrand.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
    sbrand.Name = 'Aberlour 16 Yo-AR6';
    sbrand.ASI_MFM_Sub_brand_Code__c = 'AR6';
    sbrand.ASI_HK_CRM_English_Name__c = 'Aberlour 16YO';
    sbrand.ASI_CRM_CN_CHI_NAME_C__c = '雅伯乐16年';
    return sbrand;
  }
  public static ASI_MFM_Plan_Line_Item__c getPLItem(ASI_MFM_Plan__c plan,ASI_MFM_Sub_brand__c sbrand){
    ASI_MFM_Plan_Line_Item__c pLItem = new ASI_MFM_Plan_Line_Item__c();
    pLItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_CRM_CN_TP_Trade_Plan_Line_Item');
    pLItem.ASI_MFM_Plan__c = plan.id;
    pLItem.ASI_MFM_Remarks__c = 'Q4';
    pLItem.ASI_CRM_CN_TP_Promotion_Content__c = '雅伯乐16年580元';
    pLItem.ASI_CRM_CN_TP_DM__c = 'Y';
    pLItem.ASI_CRM_CN_TP_Secend_Display_Stores_NO__c = 5;
    pLItem.ASI_CRM_CN_TP_Secend_Display__c = '端架';
    pLItem.ASI_CRM_CN_TP_Display_Fee__c = 200;
    pLItem.ASI_MFM_Sub_brand_Code__c = sbrand.id;
    pLItem.ASI_CRM_CN_TP_Bottle_Size__c = '70';
    pLItem.ASI_CRM_CN_TP_Normal_Purchase_Price__c = 568;
    pLItem.ASI_CRM_CN_TP_Promotion_Purchase_Price__c = 548;
    pLItem.ASI_CRM_CN_TP_Promotion_Mode__c = '进价核销';
    pLItem.ASI_CRM_CN_TP_Estimated_Qty__c = 300;
    return pLItem;
  }
  public static ASI_TH_CRM_PaymentRequest__c getPaymentRequest(ASI_CRM_AccountsAdditionalField__c accountAdditionField,ASI_TH_CRM_Contract__c contract){
    ASI_TH_CRM_PaymentRequest__c pRequest = new ASI_TH_CRM_PaymentRequest__c();
    pRequest.Name = '010';
    pRequest.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
    pRequest.ASI_CRM_CN_Payment_Raised_Date__c = Date.newInstance(2020,3,24);
    pRequest.ASI_TH_CRM_Contract__c = contract.id;
    pRequest.ASI_CRM_CN_OutletWS__c = accountAdditionField.id;
    return pRequest;
  }
  public static ASI_TH_CRM_PaymentRequestLineItem__c getPRequestLineItem(ASI_TH_CRM_PaymentRequest__c pRequest){
    ASI_TH_CRM_PaymentRequestLineItem__c pRLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
    pRLineItem.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_TP_Payment_Request_Detail_TradePlan');
    pRLineItem.ASI_TH_CRM_Payment_Request__c = pRequest.id;
    pRLineItem.ASI_TH_CRM_Amount__c = 50;
    return pRLineItem;
  }
  
  public static ASI_MFM_Plan__c getApprovalPlan(ASI_CRM_KA_Account__c kaAcc,ASI_MFM_Prefix__c prefix){
    ASI_MFM_Plan__c approvalPlan = new ASI_MFM_Plan__c();
    approvalPlan.Name = 'No2345';
    approvalPlan.ASI_CRM_CN_TP_KA_Account__c = kaAcc.id;
    approvalPlan.ASI_MFM_Status__c = 'Draft';
    approvalPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Approval');
    approvalPlan.ASI_MFM_Prefix__c = prefix.id;
    return approvalPlan;
  }
  public static ASI_MFM_Plan__c getBudgetPlan(ASI_CRM_KA_Account__c kaAcc,ASI_MFM_Prefix__c prefix){
    ASI_MFM_Plan__c budgetPlan = new ASI_MFM_Plan__c();
    budgetPlan.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Budget_Plan');
    budgetPlan.ASI_MFM_Status__c = 'Draft';
    budgetPlan.ASI_CRM_CN_TP_KA_Account__c = kaAcc.id;
    budgetPlan.ASI_MFM_Fiscal_year__c = 'FY1920';
    budgetPlan.ASI_MFM_Budget_Amount__c = 8200000;
    budgetPlan.ASI_MFM_Plan_Description__c = '2020/4/1';
    budgetPlan.ASI_CRM_CN_TP_LY_Promotion_Vol__c = 840;
    budgetPlan.ASI_CRM_CN_TP_LY_Cont_Margin_Amount__c = 96100000.5;
    budgetPlan.ASI_CRM_CN_TP_LY_Amount__c = 6800000;
    budgetPlan.ASI_CRM_CN_TP_LY_Gross_Sales_Amount__c = 36890010.68;
    budgetPlan.ASI_CRM_CN_TP_LY_DM_Display_Amount__c = 16000;
    budgetPlan.ASI_MFM_Prefix__c = prefix.id;
    return budgetPlan;
  }
  public static ASI_CRM_CN_Contract_BRSF_Line_Item__c getBRSFLineItem(ASI_MFM_Sub_brand__c subBrand,ASI_TH_CRM_Contract__c contract){
    ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
    brsfLItem.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_TradePlan_BRSF_Line_Item');
    brsfLItem.ASI_CRM_CN_Sub_Brand__c = subBrand.id;
    brsfLItem.ASI_CRM_CN_Est_Monthly_Qty__c = 5000;
    brsfLItem.ASI_CRM_CN_Contract_Monthly_Qty__c = 5000;
    brsfLItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 10;
    brsfLItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 10;
    brsfLItem.ASI_CRM_CN_Contract__c = contract.id;
    brsfLItem.ASI_CRM_CN_Contract_Total_Dummy__c = 550000;
    brsfLItem.ASI_CRM_CN_Est_Total_Dummy__c = 550000;
    brsfLItem.ASI_CRM_CN_Contract__c = contract.id;
    brsfLItem.ASI_CRM_CN_Contract_Total_Dummy__c = 550000;
    brsfLItem.ASI_CRM_CN_Est_Total_Dummy__c = 550000;
    return brsfLItem;
  }
  public static ASI_MFM_Event__c getOutLet(ASI_MFM_Plan__c tradePlan,ASI_CRM_AccountsAdditionalField__c accountsAddtion){
    ASI_MFM_Event__c outLet = new ASI_MFM_Event__c();
    outLet.Name = 'outLet';
    outLet.ASI_MFM_Status__c = 'Proposal';
    outLet.ASI_MFM_Event_Type__c = 'CRM';
    outLet.ASI_CRM_CN_TP_Plan__c = tradePlan.id;
    outLet.ASI_MFM_Start_Date__c = Date.newInstance(2019,7,1);
    outLet.ASI_MFM_End_Date__c =Date.newInstance(2020,5,1);
    outLet.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_CRM_CN_TP_Outlet');
    outLet.ASI_CRM_CN_TP_Customer__c = accountsAddtion.id;
    return outLet;
  }
  public static ASI_CRM_Contract_Cost__c getContractCost(ASI_TH_CRM_Contract__c contract){
    ASI_CRM_Contract_Cost__c contractCostInstance = new ASI_CRM_Contract_Cost__c();
    contractCostInstance.Name = 'PRC - Outlet Price Promotion';
    contractCostInstance.ASI_CRM_CN_Contract__c = contract.id;
    contractCostInstance.ASI_CRM_CN_Chinese_Description__c = ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE;
    contractCostInstance.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost');
    contractCostInstance.ASI_CRM_CN_Estimate_Amount__c = 3;
    contractCostInstance.ASI_CRM_CNY_Est__c = 3;
    contractCostInstance.ASI_CRM_Other_Est__c = 3;
    contractCostInstance.ASI_CRM_CN_Contract_Amount__c = 2;
    contractCostInstance.ASI_CRM_CN_Cost_Type__c = 'Fixed';
    return contractCostInstance;
  }
}