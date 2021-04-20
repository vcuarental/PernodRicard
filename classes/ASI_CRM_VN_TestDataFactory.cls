/*
*************************************************************************************************
     * Name:ASI_CRM_VN_TestDataFactory
     * Description: Test Factory to generate Test data
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    --------------------------------------------------
     * 10/11/2015       Laputa: Neha Sonawane            Created
**************************************************************************************************
*/

public class ASI_CRM_VN_TestDataFactory {
   public static Integer businessRegistrationNumber = 123456789;
   public static ASI_HK_CRM_Visitation_Plan_Detail__c getPlanDetail(String custName, String outlet, ID RecordTypeId,ID VisitationPlanId){
        return new ASI_HK_CRM_Visitation_Plan_Detail__c (ASI_TH_CRM_Customer__c = custName,ASI_TH_CRM_Outlet_Name__c = outlet,ASI_CRM_Purpose_of_Visit__c = 'Normal Visit',
                                                         RecordTypeId = RecordTypeId,ASI_HK_CRM_Visitation_Plan__c = VisitationPlanId);
   }                                                    
   public static ASI_HK_CRM_Visitation_Plan__c getVisitationPlan(String visitationPlanName,ID RecordTypeId){
        return new ASI_HK_CRM_Visitation_Plan__c (Name = visitationPlanName,RecordTypeId = RecordTypeId);
   } 

   public static List<ASI_CRM_AccountsAdditionalField__c> getcustomerWithRT(String custName, String outletType,String Image,
                                                                String ContractedWith,String Region ,
                                                                String Area,String Province,String Address, Id pRecordTypeID
                                                                //String sys1, String sys2, String sys3
                                                                ){
        List<ASI_CRM_AccountsAdditionalField__c> objList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c obj = new ASI_CRM_AccountsAdditionalField__c(Name = custName,
                                                           ASI_CRM_VN_OutletType__c = outletType,
                                                           ASI_CRM_CN_Image__c = Image,
                                                           ASI_TH_CRM_Contracted_With__c = ContractedWith,
                                                           ASI_CRM_VN_Region__c= Region,
                                                           ASI_CRM_Area__c = Area,
                                                           ASI_CRM_VN_Province__c = Province,
                                                           ASI_CRM_CN_Address__c = Address,
                                                           RecordTypeId = pRecordTypeID,
                                                           OwnerId = UserInfo.getUserId()
                                                           //ASI_CRM_CN_Sys_Approver_1__c= sys1,
                                                          // ASI_CRM_CN_Sys_Approver_2__c = sys2,
                                                          // ASI_CRM_CN_Sys_Approver_3__c = sys3
                                                           );
                                                           objList.add(obj);
       
        insert objList;
        return objList;
   } 

   public static List<ASI_CRM_AccountsAdditionalField__c> getcustomer(String custName, String outletType,String Image,
                                                                String ContractedWith,String Region ,
                                                                String Area,String Province,String Address
                                                                //String sys1, String sys2, String sys3
                                                                ){
        List<ASI_CRM_AccountsAdditionalField__c> objList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c obj = new ASI_CRM_AccountsAdditionalField__c(Name = custName,
                                                           ASI_CRM_VN_OutletType__c = outletType,
                                                           ASI_CRM_CN_Image__c = Image,
                                                           ASI_TH_CRM_Contracted_With__c = ContractedWith,
                                                           ASI_CRM_VN_Region__c= Region,
                                                           ASI_CRM_Area__c = Area,
                                                           ASI_CRM_VN_Province__c = Province,
                                                           ASI_CRM_CN_Address__c = Address
                                                           //ASI_CRM_CN_Sys_Approver_1__c= sys1,
                                                          // ASI_CRM_CN_Sys_Approver_2__c = sys2,
                                                          // ASI_CRM_CN_Sys_Approver_3__c = sys3
                                                           );
                                                           objList.add(obj);
       
        insert objList;
        return objList;
   } 
   
    public static ASI_CRM_AccountsAdditionalField__c getCustomer(String custName, String outletType, String subType, 
                                                                 String strRecordTypeId){
        return new ASI_CRM_AccountsAdditionalField__c(Name = custName, ASI_CRM_VN_OutletType__c = outletType, 
                                                      ASI_CRM_Outlet_Sub_Type__c = subtype,
                                                      RecordTypeId = strRecordTypeId);
    }
    
    public static ASI_HK_CRM_Running_Number__c getRunningNumber(String objName, Integer rNumber, String format, Integer fMonth, 
                                                                Integer fYear){
     return new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = objName, ASI_HK_CRM_Running_Number__c = rNumber, 
                                             ASI_HK_CRM_Format__c = format, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = fMonth, 
                                             ASI_HK_CRM_Fiscal_Year__c = fYear);
   }
  
   
    public static ASI_CRM_ServicePack__c getServicePack(String servicePackName, String grpoutletType, Integer pgOutlet,Integer sigOutlet,
                                                        Integer vipRoom,Integer podiumStand,Integer glorifier,Integer dummyBots,
                                                        Integer pgUniform,Integer glassware,Integer diceCup, Integer drinkMenu, 
                                                        Integer promActivity, Integer incentive, String imageLevel, Integer callFreq,
                                                        Integer callLength,String damdAction){
        return new ASI_CRM_ServicePack__c(Name = servicePackName, ASI_CRM_SG_Outlet_Type__c = grpoutletType, 
                                          ASI_CRM_No_of_PG_in_one_outlet__c = pgOutlet, 
                                          ASI_CRM_No_of_Signage_per_outlet__c = sigOutlet, ASI_CRM_No_of_VIP_room__c = vipRoom, 
                                          ASI_CRM_No_of_Podium_stand__c = podiumStand, ASI_CRM_No_of_Glorifier__c = glorifier,
                                          ASI_CRM_No_of_Dummy_Bots__c = dummyBots, ASI_CRM_No_of_PG_uniform__c = pgUniform, 
                                          ASI_CRM_No_of_Glassware__c = glassware,ASI_CRM_No_of_Dice_Dice_Cup__c = diceCup, 
                                          ASI_CRM_No_of_Drink_menus__c = drinkMenu,
                                          ASI_CRM_No_of_Promotion_activiti_per_yr__c = promActivity,
                                          ASI_CRM_Incentives_US_year__c = incentive,ASI_CRM_SG_Segmentation__c = imageLevel,
                                          ASI_CRM_CallFrequency__c = callFreq, ASI_CRM_CallLength__c = callLength,
                                          ASI_CRM_SG_DAMD_Action__c = damdAction);
    } 
    
    public static ASI_CRM_ServicePackItem__c getServicePackItem(String actVis, String subBrand,String servicePackId){
        return new ASI_CRM_ServicePackItem__c(ASI_CRM_SG_Act_Vis__c = actVis, ASI_CRM_Sub_brand_Code__c = subBrand,ASI_CRM_ServicePack__c = servicePackId);
    } 
 
    public static ASI_CRM_AccountsAdditionalField__c getCustomer(String custName, String outletType, String subType, 
                                                                 String strRecordTypeId, String servicePackId){
        return new ASI_CRM_AccountsAdditionalField__c(Name = custName, ASI_CRM_VN_OutletType__c = outletType, 
                                                      ASI_CRM_Outlet_Sub_Type__c = subtype,
                                                      RecordTypeId = strRecordTypeId, ASI_CRM_Service_Pack__c = servicePackId);
    }
    public static ASI_CRM_AccountsAdditionalField__c getCustomerAccount(String custName, String outletType, String subType, 
                                                                        String strRecordTypeId,
                                                                        String servicePackId,String AccountID){
        return new ASI_CRM_AccountsAdditionalField__c(Name = custName, ASI_CRM_VN_OutletType__c = outletType, 
                                                      ASI_CRM_Outlet_Sub_Type__c = subtype,
                                                      RecordTypeId = strRecordTypeId, ASI_CRM_Service_Pack__c = servicePackId,
                                                      ASI_CRM_Account__c=AccountID);
    }
     public static ASI_CRM_AccountsAdditionalField__c getCustomerRegion(String custName, String AccountID, String VN_Region, 
                                                                        String strRecordTypeId){
        return new ASI_CRM_AccountsAdditionalField__c(Name = custName, ASI_CRM_Account__c=AccountID, ASI_CRM_VN_Region__c = VN_Region,
                                                      RecordTypeId = strRecordTypeId);
    }
    public static ASI_MFM_Sub_brand__c getSubBrand(Boolean Active,String custName,String strRecordTypeId){
        return new ASI_MFM_Sub_brand__c(ASI_CRM_Active__c=Active,Name = custName,RecordTypeId = strRecordTypeId);
    }
    public static ASI_CRM_Promoter__c getPromoter(String custName,String VNID,String MobileNo,String strRecordTypeId){
        return new ASI_CRM_Promoter__c(Name = custName,ASI_CRM_VNId__c=VNID,ASI_CRM_MobileNo__c=MobileNo,RecordTypeId = strRecordTypeId);
    }
    public static ASI_TH_CRM_RSP__c getRSP(String SubBrandID,String CustomerID,String PromoterID,String UserID,DateTime CurrentDateTime,
                                           DateTime SubmitDateTime,String strRecordTypeId){
        return new ASI_TH_CRM_RSP__c(ASI_TH_CRM_Sub_Brand__c=SubBrandID,
                                     ASI_CRM_CN_Customer__c=CustomerID,
                                     ASI_CRM_Promoter__c=PromoterID,
                                     ASI_CRM_PGLeader__c=UserID,
                                     ASI_CRM_DateTime__c=CurrentDateTime,
                                     ASI_CRM_SubmitDateTime__c=SubmitDateTime,RecordTypeId = strRecordTypeId);
    }
    
    public static ASI_GiftBox_Request_Header__c getGiftBox(Date orderDate,String customerId, String strRecordTypeId){
        return new ASI_GiftBox_Request_Header__c(ASI_CRM_Order_Date__c = orderDate, RecordTypeId = strRecordTypeId);
    }
    
    public static User getUser(string alias, string email, string lastname, string emailencodingkey, string languagelocalekey, 
                               string localesidkey, string timezonesidkey, string username, Id profileid){
        
        return new User(Alias = alias,Email = email,EmailEncodingKey = 'ISO-8859-1',LastName = lastname,
                        LanguageLocaleKey = languagelocalekey,Localesidkey = localesidkey , TimeZoneSidKey = timezonesidkey,
                        Username = username, ProfileId = profileid);      
    }
    
    public static ASI_GiftBox_Notification_User__c getGiftBoxNotificationUser(String notificationUserName, Id fUser,Id hrUser,Id mUser){
        return new ASI_GiftBox_Notification_User__c(Name=notificationUserName, Finance_User__c = fUser, HR_User__c = hrUser, 
                                                    MKT_User__c = mUser);
    }
    public static ASI_GiftBox_Notification_Mapping__c getMapping(String userRole, Id mId){
        return new ASI_GiftBox_Notification_Mapping__c (ASI_GiftBox_User_Role_Name__c = userRole, Notification_Id__c = mId);
    }
   
   public static ASI_HK_CRM_Visitation_Plan__c getPlans(String planName, String pYear, String pMonth){
       return new ASI_HK_CRM_Visitation_Plan__c(Name = planName, ASI_HK_CRM_Year__c = pYear, ASI_HK_CRM_Month__c = pMonth);
   }
    
    // DC - 01/22/2016 Marked RecordTypeId as @TestVisible for test class.
    @TestVisible private static Id RecordTypeId = null;
    private static final ASI_HK_CRM_AccountGenerator acctGen;


    /**
    *   Description : This method will generate List of Account with Dummy Data
    *
    *   Parameters :
    *   @totalRecords : How many Records you want to generate ?
    *   @withIds : Do you want returned records with generateId? If null then false
    **/
    public static List<Account> getAccounts(Integer totalRecords, Boolean withIds,String recordtypeDeveloperName,String SobjectType)
    {
        List<Account> acctList = new List<Account>();
        if(withIds == null)
            withIds = false;

        for(Integer i=0;i<totalRecords;i++)
        {
            Account a = new Account();
            a.name = constructTestString(20);
            //a.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            //acctList.add(acctGen.generateAccount(recordtypeDeveloperName));
            acctList.add(a);
        }
        if(withIds)
            insert acctList;

        return acctList;
    }

    /**
    *   This method is used to generate Random String of supplied length
    */
    public static String constructTestString(Integer length) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        return key.substring(0,length);
    }

    /**
    *   Description : This method will generate List of ASI_CRM_AccountsAdditionalField__c with Dummy Data
    *
    *   Parameters :
    *   @size : How many Records you want to generate ?
    *   @withIds : Do you want returned records with generateId? If null then false
    *   @accounts : List of parent Accounts 
    **/
    public static List<ASI_CRM_AccountsAdditionalField__c> generateCustomers(Integer size,List<Account> accounts,Boolean withIds,
                                                                              String recordtypeDeveloperName,String SobjectType){
        List<ASI_CRM_AccountsAdditionalField__c> customers = new List<ASI_CRM_AccountsAdditionalField__c>();
        if(withIds == null)
            withIds = false;

        for(Integer i=0; i<size; i++){
            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
            customer.Name = 'Test Customer'+i;
            customer.ASI_CRM_Account__c = accounts[i].Id;
            customer.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            customer.ASI_CRM_Business_Registration_Number__c = string.valueOf(businessRegistrationNumber);
            customers.add(customer);
            businessRegistrationNumber = businessRegistrationNumber + 1;
        }

        if(withIds)
            insert customers;

        return customers;
    }

    public static List<ASI_HK_CRM_Promotion__c> getPromotions(Integer size,Boolean withIds,String recordtypeDeveloperName,
                                                              String SobjectType,Date startDate, Date endDate){
        List<ASI_HK_CRM_Promotion__c> pmtList = new List<ASI_HK_CRM_Promotion__c>();
        if(withIds == null)
            withIds = false;
        for (Integer i = 0; i < size; i += 2) {
            ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c();
            promotion.name = 'PMT-'+i;
            promotion.ASI_HK_CRM_Promotion_Start_Date__c=startDate;
            promotion.ASI_HK_CRM_Promotion_End_Date__c = endDate;
            promotion.ASI_HK_CRM_Promotion_Name__c='Test Promotion'+i;
            promotion.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            pmtList.add(promotion);
        }
        if(withIds)
            insert pmtList;
        return pmtList;
    }

   
    /**
    *   Description : This method will get Record type Id's from RecordType
    *
    *   Parameters :
    *   @Developername : Recordtype DeveloperName
    **/
    public static Id getRecordTypeId(String Developername,String SobjectType){
        if(RecordTypeId==null)
            RecordTypeId = [Select Id from RecordType where Developername=:Developername and SobjectType=:SobjectType].Id;  
        return RecordTypeId;
    }
    
    public static List<ASI_HK_CRM_Visitation_Plan__c> getVisitationPlan(Integer size,Boolean withIds,String recordtypeDeveloperName,
                                                                        String SobjectType){
        List<ASI_HK_CRM_Visitation_Plan__c> visitationtionPlans = new List<ASI_HK_CRM_Visitation_Plan__c>();
        if(withIds == null)
            withIds = false;
        for (Integer i = 0; i < size; i ++) {
            ASI_HK_CRM_Visitation_Plan__c visitationtionPlan = new ASI_HK_CRM_Visitation_Plan__c();
            visitationtionPlan.name = 'PMT-'+i;
            visitationtionPlan.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            visitationtionPlans.add(visitationtionPlan);
        }
        
        if(withIds)
            insert visitationtionPlans;
        return visitationtionPlans;
    }

    public static List<ASI_HK_CRM_Visitation_Plan_Detail__c> getVisitationPlanDetails(Integer size,Boolean withIds,
                                                                                      String recordtypeDeveloperName,
                                                                                      String SobjectType, 
                                                                                      Id customerId,
                                                                                      Id visitationtionPlanId){
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationtionPlanDetails = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        if(withIds == null)
            withIds = false;
        for (Integer i = 0; i < size; i ++) {
            ASI_HK_CRM_Visitation_Plan_Detail__c visitationtionPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
            visitationtionPlanDetail.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            visitationtionPlanDetail.ASI_CRM_MY_Customer__c = customerId;
            visitationtionPlanDetail.ASI_HK_CRM_Visitation_Plan__c = visitationtionPlanId;
            visitationtionPlanDetail.ASI_CRM_Purpose_of_Visit__c = 'Normal Visit';
            visitationtionPlanDetails.add(visitationtionPlanDetail);
        }
        if(withIds)
            insert visitationtionPlanDetails;
        return visitationtionPlanDetails;
    }
    
    public static ASI_MFM_Sub_brand__c getSubBrand(String custName){
        return new ASI_MFM_Sub_brand__c(Name = custName);
    }

    public static Account getAccount(string name) {
        return new Account(Name = name);
    }
    
    public static ASI_TH_CRM_Actual_Offtake__c getActualOffTake(Id accountId, Id customerId, Id subBrandId, Date offTakeDate, boolean isDelete){
        return new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_From_Wholesaler__c= accountId,
                                                ASI_CRM_SG_Customer__c = customerId,
                                                ASI_TH_CRM_Outlet__c= accountId,
                                                ASI_TH_CRM_Sub_brand__c= subBrandId,
                                                ASI_TH_CRM_Offtake_G_L_Date__c= offTakeDate,
                                                ASI_TH_CRM_Delete__c = isDelete);
    }

    /*
     * DC - Migrated methods from ASI_CRM_VN_AccountProsSegControllerTest class for resolving
     * the issue related to the class showing up in code coverage panel.
     */
    //Create Test Record for ASI_CRM_Pros_Segmentation__c
    public static List<ASI_CRM_Pros_Segmentation__c> createProsSegmentList(Integer pNumber){
    
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = new List<ASI_CRM_Pros_Segmentation__c>();
            for(Integer i = 0; i < pNumber; i++){
                listProsSeg.add(new ASI_CRM_Pros_Segmentation__c());
            }
        return listProsSeg;
    }    
    
    //Create customer test record
    public static List<ASI_CRM_AccountsAdditionalField__c> createCustomer(Integer pNumber){
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
            for(Integer i = 0; i < pNumber; i++){
                listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet_Inactive')));
            }
        return listCustomer;        
    }
    
    //Create Group Outlet Type
    public static List<ASI_CRM_Group_Outlet_Type__c> createGroupOutlet(Integer pNumber){
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = new List<ASI_CRM_Group_Outlet_Type__c>();
            for(Integer i = 0; i < pNumber; i++){
                listGroupOutlet.add(new ASI_CRM_Group_Outlet_Type__c());
            }
        return listGroupOutlet;                
    }  
    
    //Create Service Pack
    public static List<ASI_CRM_ServicePack__c> createServicePack(Integer pNumber){        
        List<ASI_CRM_ServicePack__c> listServicePack = new List<ASI_CRM_ServicePack__c>();
            for(Integer i = 0; i < pNumber; i++){
                listServicePack.add(new ASI_CRM_ServicePack__c());
            }
        return listServicePack;               
    }
    
    //Create Volume Potential Threshold
    public static List<ASI_CRM_Volume_Potential_Threshold__c> createVlmPtlThrshold(Integer pNumber){
        List<ASI_CRM_Volume_Potential_Threshold__c> listVlmPtlThrshold = new List<ASI_CRM_Volume_Potential_Threshold__c>();
            for(Integer i = 0; i < pNumber; i++){
                listVlmPtlThrshold.add(new ASI_CRM_Volume_Potential_Threshold__c());
            }
        return listVlmPtlThrshold;        
    }
    
    //Create Image LevelThreshold
    public static List<ASI_CRM_Image_Level_Threshold__c> createImgLevelThrshold(Integer pNumber){
        List<ASI_CRM_Image_Level_Threshold__c> listImgLevelThrshold = new List<ASI_CRM_Image_Level_Threshold__c>();
            for(Integer i = 0; i < pNumber; i++){
                listImgLevelThrshold.add(new ASI_CRM_Image_Level_Threshold__c());
            }
        return listImgLevelThrshold;                
    }
    
    //Create DAMD Threshold
    public static List<ASI_CRM_DAMD_Threshold__c> createDamd(Integer pNumber){
        List<ASI_CRM_DAMD_Threshold__c> listDamd = new List<ASI_CRM_DAMD_Threshold__c>();
            for(Integer i = 0; i < pNumber; i++){
                listDamd.add(new ASI_CRM_DAMD_Threshold__c());
            }
        return listDamd;                
    } 
        
}