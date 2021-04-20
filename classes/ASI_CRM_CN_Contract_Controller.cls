/* Filename:    ASI_CRM_CN_Contract_Controller.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Controller for page over-ridding contract view, edit, new page for CN CRM
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-03-20   michael.yip@introv.com      Created
 * 2014-06-28   michael.yip@introv.com      Hide PO Modification if there is pending payment request (Draft, Submitted)
 * 2014-06-28   leo.hui@introv.com          Show/Hide PO Modification (PDF) (Draft, PO Modification = true)
 * 2014-09-10   michael.yip@introv.com      Effective Date change to fiscal year start
 * 2014-11-25   twinkle.li@introv.com       Insert an Approval comment with "CN PO Contract Comment" record type when user click PO Modification
 * 2015-06-24  ben.fong@elufasys.com    Show/Hide Suggested Amount and Target Volume of Covered Outlet
 * 2018-11-28  Laputa (Hector)        Bypass Fiscal year checking if the user have bypass flag - 'ASI_CN_FiscalYearBypass'
 * 2018-12-05  Laputa (Keith Yip)        Redirect to Promotion Page if PO type is Wholesaler Promotion/Consumer Promotion/Outlet Promotion
 * 2019-03-07   Laputa (Keith Yip)          Generating the BRSF line and Clone the Group PO to Child PO after creating Promotion Contract
 * 2019-06-13   Keith Yip                   Set default Data source for Promotion PO
 *                                          Set default PO Channel
 */
public without sharing class ASI_CRM_CN_Contract_Controller {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public String PageId {set;get;}
    public ASI_CRM_CN_Contract_BRSF_Line_Item__c totalBRSF {set;get;}
    public ASI_CRM_Contract_Cost__c fix_totalCost {set;get;}
    public ASI_CRM_Contract_Cost__c variable_totalCost{set;get;}
    public Decimal totalBRSF_est_total {set;get;}
    public Decimal totalBRSF_contract_total {set;get;}
    public List <ASI_TH_CRM_Contract__c> LContract {set;get;}
    public List<ASI_CRM_CN_Covered_Outlet__c> ContractOutletList {set;get;}
    public List<ASI_CRM_CN_Covered_Outlet__c> ContractOutletListCopy {set;get;}
    public List<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList{set;get;}
    public boolean showApprovalButton {set;get;}
    public boolean showPOModification {set;get;}
    public boolean showRestorePO {set;get;}
    public boolean showShuttle {set;get;}
    public boolean makePayment {set;get;}
    public boolean showEdit {set;get;}
    public boolean contractUpload {set;get;}
    public boolean isCreate {set;get;}
    public boolean inBAPermissionSet {set;get;}
    public boolean showPOModificationPDF {set;get;}
    public boolean businessLicense {set;get;}    
    public Boolean showReturn {set;get;}  
    public List<ASI_CRM_Contract_Cost__c> LFixCost {set;get;}
    public List<ASI_CRM_Contract_Cost__c> LFixCostDisplay {set;get;}
    public List<ASI_CRM_Contract_Cost__c> LVariableCost {set;get;}
    public List<ASI_CRM_Contract_Cost__c> LVariableCostDisplay {set;get;}
    Public Boolean Selected{set;get;} 
    public decimal Total_Payments_Amount{set;get;}
    public decimal Total_Payment_Paid{set;get;}
    public decimal Total_Payment_PaidInProgress{set;get;}
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF {set;get;}
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSFDisplay {set;get;}
    public boolean pendingPR {set;get;}
    public Integer orgFiscalMonth {set;get;}
    
    public Boolean AllowEditInvestmentType {set;get;} {AllowEditInvestmentType=true;}
    
    public boolean isCNCRM {set;get;}
    public boolean showCN {set;get;}//lokman 27/6/2014 Ammender's Comment
    public string UserId {set;get;}//lokman 27/6/2014 Ammender's Comment
    public boolean ADorAbove {set;get;}//lokman 27/6/2014 Ammender's Comment
    //---- variables for BRSF list - by leo ----
    public List <ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSF_Item {set;get;}
    public map<integer, ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSF_Item_Map {set;get;}
    public List <ASI_CRM_CN_Contract_BRSF_Line_Item__c> Del_BRSF_Item {set;get;}
    public List <ASI_CRM_CN_Contract_BRSF_Line_Item__c> Save_BRSF_Item {set;get;}    
    public Integer indexBRSF {set;get;}
    public Integer rowidBRSF {set;get;}
    public String recordtypeSelected {set;get;}
    
    
    //---- variables for Covered Outlet list - by leo ----
    public List <ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_Item {set;get;}
    public map<integer, ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_Item_Map {set;get;}
    public List <ASI_CRM_CN_Covered_Outlet__c> Del_CoveredOutlet_Item {set;get;}
    public List <ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item {set;get;}    
    public Integer indexCoveredOutlet {set;get;}
    public Integer rowidCoveredOutlet {set;get;}
    public List<SelectOption> ouletPicklist {set; get;}
    public Integer SelectOption{set; get;}
    public Set<id> Selecteddd {set;get;}
    public boolean paymentError {set;get;}
    public integer num {set;get;}
    
    public Set<id> SChildCustomersIds {set; get;}
    public List <ASI_CRM_CN_Covered_Outlet__c> SelectedOutlets {set;get;} 
    public List<ASI_CRM_CN_Covered_Outlet__c>Saved_CoveredOutlet_Temp {set;get;} 
    
    //add PO Summary to PO Modification PDF Stella Sing 2014-07-30
    public list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> paymentRequestSummary {set;get;}
    public decimal PS_TotalPORemainAmt {set;get;}
    public decimal PS_TotalLastEstAmt {set;get;}
    //20160726 Ben @ Elufa
    public Boolean isNewFY {set;get;}
    
    public decimal TotalLastEstAmtCNY {set;get;}
    public decimal TotalLastEstAmtMAF {set;get;}
    public decimal TotalLastEstAmtOthers {set;get;}
    
    public decimal TotalRemainAmtCNY {set;get;}
    public decimal TotalRemainAmtMAF {set;get;}
    public decimal TotalRemainAmtOthers {set;get;}
    
    //public String retURL {get;set;} // added by leo @2014-07-01
    
    //---- added by leo @2014-10-07 ==> special promotion type logic (start) ----
    public List<ASI_CRM_SpecialPromotionTypeSetting__c> LSpecicalPromotionType {set; get;} 
    public decimal DefaultBCRate {set;get;} 
    public boolean BypassCheckContractUpload {set;get;} 
    
    public Boolean showSuggestedAmountAndTargetVolume { get; set; } // Ben 2015-06-24
    public static double totalEstimate = 0; // Ben 2015-06-24
    
    //20160606 Ben @ Elufa
    Public List<SelectOption> poTypeOption {Get; Set;}
    Public Map<String, Boolean> festivalMap{Get; Set;}
    Public Map<String, String> poTypeMap{Get; Set;}
    Public Map<String, ASI_CRM_SpecialPromotionTypeSetting__c> poTypeMap2{Get; Set;}
    Public Boolean needChannelnProvince{Get; Set;}
    
    
    public String GroupContractName{get;set;}
    
    public list<selectOption> GroupContractOptionType {Get; Set;}
    public Boolean ShowNationalContract  {Get; Set;} {ShowNationalContract=false;}
    public Boolean ShowNationalContractOption  {Get; Set;} {ShowNationalContractOption=false;}

    public Boolean DolphinPoPermission{Get; Set;}{DolphinPoPermission=false;}
    public Boolean IsDolphinDivision{Get;Set;}{IsDolphinDivision=false;}
    
    
    
    
    
    
    //20170308 Elufa
    Public List<ASI_CRM_Customer_Group__c> nationGroupList {Get{
        
        //nationGroupList = new List<ASI_CRM_Customer_Group__c>([SELECT id, Name FROM ASI_CRM_Customer_Group__c WHERE recordType.DeveloperName = 'ASI_CRM_CN_National_Group']);
        
        withSharingInnerClass tmp = new withSharingInnerClass();
        
        return tmp.getNationalGroup();
    } Set;}
    Public List<String> nationGroup {Get{
        
        nationGroup = new List<String>();
        
        if(nationGroupList.size() > 0){
            for(ASI_CRM_Customer_Group__c ng : nationGroupList)
                nationGroup.add(ng.id + '###' + ng.Name);
        }
        
        return nationGroup;
        
    } Set;}
    
    
    //20170308 Elufa
    Public List<SelectOption> getAllNationalGroup(){
        
        List<SelectOption> nationalGroupOption = new List<SelectOption>();
        
        
        nationalGroupOption.add(new SelectOption('', '--None--'));
        
        for(ASI_CRM_Customer_Group__c ng : nationGroupList){
            
            nationalGroupOption.add(new SelectOption(ng.id, ng.Name));
        }
        
        
        Return nationalGroupOption;
    }
    //End
    
    public List<ASI_CRM_SpecialPromotionTypeSetting__c> GetAllSpecialPromotionTypeSetting() {

        String recordType = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting');
        
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpList;
        if(ContractSelected.ASI_CRM_New_FY_PO__c){
            tmpList = [SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c FROM ASI_CRM_SpecialPromotionTypeSetting__c
                       WHERE recordtypeid =: recordType AND ASI_CRM_New_FY_Promotion_Type__c = TRUE ORDER BY ASI_CRM_Sequence__c ASC];//20160622 Ben @ Elufa
        }else{
            tmpList = [SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c FROM ASI_CRM_SpecialPromotionTypeSetting__c
                       WHERE recordtypeid =: recordType AND ASI_CRM_New_FY_Promotion_Type__c = FALSE];
        }
        
        return tmpList;
    }
    
    // Ben 2015-06-24 Start
    public void checkSpecialPromotionObj(){
    
        Map<String, Boolean> mapSpecialPromotion = new Map<String, Boolean>();
        
        if(LSpecicalPromotionType != null && LSpecicalPromotionType.size() > 0){
            for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType)
                mapSpecialPromotion.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_SuggestedAmount_And_TargetVolume__c);
        }
        if(mapSpecialPromotion.get(ContractSelected.ASI_TH_CRM_Promotion_Type__c) != null)
            showSuggestedAmountAndTargetVolume = mapSpecialPromotion.get(ContractSelected.ASI_TH_CRM_Promotion_Type__c);
    }
    
    public ASI_CRM_CN_TotalAmount getTotalAmount(){
        
        ASI_CRM_CN_TotalAmount totalAmount = new ASI_CRM_CN_TotalAmount();
        
        totalAmount.totalSuggestedAmount = 0;
        totalAmount.totalTargetVolume = 0;
        
        if(ContractOutletList != null && ContractOutletList.size() > 0){
            for(ASI_CRM_CN_Covered_Outlet__c obj : ContractOutletList){
                if(obj.ASI_CRM_CN_Suggested_Amount__c != null) totalAmount.totalSuggestedAmount += obj.ASI_CRM_CN_Suggested_Amount__c;
                if(obj.ASI_CRM_CN_Target_Volume_Std_Btl__c != null) totalAmount.totalTargetVolume += obj.ASI_CRM_CN_Target_Volume_Std_Btl__c;
            }
        }
        
        return totalAmount;
    }
    
    public class ASI_CRM_CN_TotalAmount{
        public decimal totalSuggestedAmount { get; set; }
        public decimal totalTargetVolume { get; set; }
    }
    
  // Ben 2015-06-24 End
    
    public void CheckSpecialPromotionType() {
        decimal bcRate;
        boolean bypassCheckContractUpload;
        
        if(!isCreate)
            bcRate = ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c;
        else
            bcRate = 90;

        bypassCheckContractUpload = false;
                
        if(ContractSelected != null)
        {
            if(ContractSelected.ASI_TH_CRM_Promotion_Type__c != null)
            {
                if (LSpecicalPromotionType != null && LSpecicalPromotionType.size() > 0)
                {
                    for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType) {
                        if(obj.ASI_CRM_Promotion_Type__c == ContractSelected.ASI_TH_CRM_Promotion_Type__c)
                        {
                            if(obj.ASI_CRM_Override_BC_Rate__c != null)
                                bcRate = obj.ASI_CRM_Override_BC_Rate__c;

                            if(obj.ASI_CRM_Bypass_Contract_Upload_Checking__c != null && obj.ASI_CRM_Bypass_Contract_Upload_Checking__c == true)
                                bypassCheckContractUpload = true;

                            break;
                        }
                    }
                }
            }
            
        }

        ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c = bcRate;
        BypassCheckContractUpload = bypassCheckContractUpload;
    }
    
    public void SetSpecialPromotionType_BCRate() {
        decimal bcRate;
 
        if(!isCreate)
            bcRate = ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c;
        else
            bcRate = poTypeMap2.containsKey(ContractSelected.ASI_TH_CRM_Promotion_Type__c) ? poTypeMap2.get(ContractSelected.ASI_TH_CRM_Promotion_Type__c).ASI_CRM_Override_BC_Rate__c : 0;//90;

        if(ContractSelected != null)
        {
            if(ContractSelected.ASI_TH_CRM_Promotion_Type__c != null){
                //Laputa: 20170708
                if(ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Heavy Contract On'){
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__c !=null){
                        ASI_CRM_AccountsAdditionalField__c Customer =[select Id,ASI_CRM_CN_NewChannel__r.ASI_CRM_BC_Rate__c from ASI_CRM_AccountsAdditionalField__c where id =:ContractSelected.ASI_CRM_CN_Outlet_WS__c];
                        if(Customer.ASI_CRM_CN_NewChannel__r.ASI_CRM_BC_Rate__c!=null){
                            bcRate = Customer.ASI_CRM_CN_NewChannel__r.ASI_CRM_BC_Rate__c;
                        }
                    }
                    AllowEditInvestmentType=false;
                    ContractSelected.ASI_CRM_Investment_Type__c='heavy';
                }else{
                    AllowEditInvestmentType=true;
                    ContractSelected.ASI_CRM_Investment_Type__c='';
                    if (LSpecicalPromotionType != null && LSpecicalPromotionType.size() > 0){
                        for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType) {
                            if(obj.ASI_CRM_Promotion_Type__c == ContractSelected.ASI_TH_CRM_Promotion_Type__c)
                            {
                                if(obj.ASI_CRM_Override_BC_Rate__c != null)
                                    bcRate = obj.ASI_CRM_Override_BC_Rate__c;
                                
                                break;
                            }
                        }
                    }
                }

                //Keith Yip 2019-06-13 Set default Data source for Promotion PO
                if(ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Wholesaler Promotion'){  ContractSelected.ASI_CRM_CN_Data_Source__c ='Min(WS Intake, Outlet Intake)';
                }else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c =='Consumer Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c =='Outlet Promotion'){  ContractSelected.ASI_CRM_CN_Data_Source__c='Outlet Intake';
                }

            }
            
        }

        ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c = bcRate;        
    }

    public void SetSpecialPromotionType_CheckContractUpload() {
        system.debug('SetSpecialPromotionType_CheckContractUpload');
        boolean tmp;
        
        tmp = false;
                
        if(ContractSelected != null)
        {
            system.debug('ContractSelected.ASI_TH_CRM_Promotion_Type__c: ' + ContractSelected.ASI_TH_CRM_Promotion_Type__c);
            if(ContractSelected.ASI_TH_CRM_Promotion_Type__c != null)
            {
                if (LSpecicalPromotionType != null && LSpecicalPromotionType.size() > 0)
                {
                    system.debug('LSpecicalPromotionType: ' + LSpecicalPromotionType);
                
                    for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType) {
                        if(obj.ASI_CRM_Promotion_Type__c == ContractSelected.ASI_TH_CRM_Promotion_Type__c)
                        {
                            if(obj.ASI_CRM_Bypass_Contract_Upload_Checking__c != null && obj.ASI_CRM_Bypass_Contract_Upload_Checking__c == true)
                                tmp = true;

                            break;
                        }
                    }
                }
            }
            
        }

        BypassCheckContractUpload = tmp;
        
        system.debug('BypassCheckContractUpload: ' + BypassCheckContractUpload);
    }
    
    //---- added by leo @2014-10-07 ==> special promotion type logic (end) ----
    
    public ASI_CRM_CN_Contract_Controller(ApexPages.StandardController controller) {
        
        //retURL = ApexPages.currentPage().getParameters().get('retURL'); // added by leo @2014-07-01 
            
        showCN = false;//lokman 27/6/2014 Ammender's Comment end
        pendingPR = false;
        this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
        if(this.ContractSelected != null)
            PageId = ContractSelected.id;
        system.debug('PageId: ' + PageId );

        String recordtypeSelected = ApexPages.currentPage().getParameters().get('RecordType');
        orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        
        if(recordtypeSelected != null && ContractSelected.RecordTypeId == null){
            ContractSelected.RecordTypeId = recordtypeSelected;
        }
        if(ApexPages.currentPage().getParameters().get('outletId') != null){
            ContractSelected.ASI_CRM_CN_Outlet_WS__c = ApexPages.currentPage().getParameters().get('outletId') ;
        }
        init(recordtypeSelected);
        
        //---- added by leo @2014-10-07 ==> special promotion type logic ----
        LSpecicalPromotionType = GetAllSpecialPromotionTypeSetting(); 
        poTypeMap = new Map<String, String>();
        poTypeMap2 = new Map<String, ASI_CRM_SpecialPromotionTypeSetting__c>();
        Map<String, String> poTypeMap3 = new Map<String, String>();
        //20160606 Ben @ Elufa
        poTypeOption = new List<SelectOption>();
        if(LSpecicalPromotionType.size() > 0){
            
            for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType){
                
                if(!showCN){
                  poTypeOption.add(new SelectOption(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type__c));
                }else if(showCN){
                    
                    if(obj.ASI_CRM_Promotion_Type_Chinese_Name__c != NULL && obj.ASI_CRM_Promotion_Type_Chinese_Name__c != ''){
                        poTypeOption.add(new SelectOption(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type_Chinese_Name__c));
                      poTypeMap.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type_Chinese_Name__c);
                    }else{
                        poTypeOption.add(new SelectOption(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type__c));
                        poTypeMap.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type__c);
                    }
                }
                poTypeMap2.put(obj.ASI_CRM_Promotion_Type__c, obj);
                poTypeMap3.put(obj.ASI_CRM_Promotion_Type__c.toUpperCase(), obj.ASI_CRM_Promotion_Type__c);
            }
            
            String PromotionType = ApexPages.currentPage().getParameters().get('ASI_TH_CRM_Promotion_Type__c');
            
            if(isCreate && PromotionType != NULL && PromotionType != ''){ ContractSelected.ASI_TH_CRM_Promotion_Type__c = poTypeMap3.containsKey(PromotionType.toUpperCase()) ? poTypeMap3.get(PromotionType.toUpperCase()) : '';
            }
            if(isCreate && ( ContractSelected.ASI_TH_CRM_Promotion_Type__c == '' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == NULL) ){ ContractSelected.ASI_TH_CRM_Promotion_Type__c = LSpecicalPromotionType[0].ASI_CRM_Promotion_Type__c;
            }
            // On contract creation, Make default as “TOT/MOT Contract” if the Channel Group of the outlet is “OFF TOT” or “OFF MOT” or “BulkPurchase”
            List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT ASI_CRM_CN_DolphinFalcon_Flag__c,ASI_CRM_CN_Dummy_Outlet_Flag__c,ASI_CRM_Channel_Group__r.Name FROM ASI_CRM_AccountsAdditionalField__c WHERE Id = :ContractSelected.ASI_CRM_CN_Outlet_WS__c LIMIT 1];
            ASI_CRM_AccountsAdditionalField__c customer = (customers.size() == 1)? customers.get(0) : null;
            String channelGroupName = customer == null ? '' : customer.ASI_CRM_Channel_Group__r.Name;
            if(customer.ASI_CRM_CN_Dummy_Outlet_Flag__c){
                if(customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin Division'){
                    IsDolphinDivision = true;
                    DolphinPoPermission = true;
                }
            }else{
                if(customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin A' || customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin B'){
                    DolphinPoPermission = true;
                }
            }    
            if (isCreate && (channelGroupName == 'OFF TOT' || channelGroupName == 'OFF MOT' || channelGroupName == 'BulkPurchase')) {
                ContractSelected.ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract';
                ContractSelected.ASI_CRM_CN_Use_PRC_Contract_Template__c = channelGroupName == 'OFF TOT';
                ContractSelected.ASI_CRM_CN_Source_of_Contract__c = 'Renew';
                if(DolphinPoPermission && (customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin A' || customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin B' || customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin Division')){
                    ContractSelected.ASI_CRM_CN_Is_Dolphin__c = true;
                    if(customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin A'){
                        ContractSelected.ASI_CRM_CN_Contract_Classification__c = 'A';
                    }
                    if(customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin B'){
                        ContractSelected.ASI_CRM_CN_Contract_Classification__c = 'B';
                    }
                    if(customer.ASI_CRM_CN_DolphinFalcon_Flag__c == 'Dolphin Division'){
                        ContractSelected.ASI_CRM_CN_Contract_Classification__c = 'Dolphin Division';
                        ContractSelected.ASI_CRM_CN_Use_PRC_Contract_Template__c = false;
                    }
                }
            }

        }
        
        //---- added by leo @2014-10-07 ==> special promotion type logic ----
        if(isCreate){
            //Laputa change th order 
            setCustomerChannel();
            SetSpecialPromotionType_BCRate();
            
            //Added By Laputa 20171218
            List<ASI_MFM_Brand__c> BrandList= [select id,ASI_MFM_Brand_Code__c,ASI_CRM_CN_Bottle_Collection_Rate__c
                                               from ASI_MFM_Brand__c where 
                                               RecordType.DeveloperName ='ASI_FOC_CN_Brand' and ASI_CRM_CN_Bottle_Collection_Rate__c !=null and 
                                               ASI_MFM_Brand_Code__c='MAR'];
            for(ASI_MFM_Brand__c Brands:BrandList){ ContractSelected.ASI_CRM_Martell_BC_Rate__c=Brands.ASI_CRM_CN_Bottle_Collection_Rate__c;
                system.debug('Bottle_Collection_Rate: '+Brands.ASI_CRM_CN_Bottle_Collection_Rate__c);
            }
            
            //ASI_CRM_Martell_BC_Rate__c
        }
            

        SetSpecialPromotionType_CheckContractUpload();
        
        // Ben 2015-06-24
        checkSpecialPromotionObj();
    }
    
    /*lokman 27/6/2014 Ammender's Comment start*/
    public void checkUserID(){
        if([SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()].size()>0)  AdorAbove = true;
    }
    public void chooseLanguage(){
        showCN = USerInfo.getLanguage()=='zh_CN';
    }
    /*lokman 27/6/2014 Ammender's Comment end*/
    public void init(String recordtypeSelected){
        //20160620 Ben @ Elufa
        needChannelnProvince = FALSE;
        paymentError = false;
        showApprovalButton = true;
        showPOModification = false;
        showShuttle = true;
        showRestorePO  = false;
        showEdit = true;
        makePayment = true;
        isCreate = false;
        isCNCRM = true;
        inBAPermissionSet = false;
        showPOModificationPDF = false;
        businessLicense = false;
        /*lokman 27/6/2014 Ammender's Comment start*/
        UserId = UserInfo.getUserId();
        chooseLanguage();
        checkUserID();
        /*lokman 27/6/2014 Ammender's Comment end*/
        if([SELECT Assignee.Name, PermissionSet.name
            FROM PermissionSetAssignment where permissionSet.name ='ASI_CRM_CN_General_BA' and Assigneeid = :Userinfo.getUserid()].size()>0){ inBAPermissionSet = true;
            }
        if (PageId != null){
            LContract = [SELECT Name, ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                         ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c,
                         ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c, 
                         ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c , ASI_CRM_Investment_Type__c,ASI_CRM_Martell_BC_Rate__c,
                         ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                         recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,
                         ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, 
                         ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate,//20160420 Ben @ Elufa added lastModifiedDate
                         ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c, //20160607 Ben @ Elufa
                         ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, //20170128 Elufa
                         ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,//20160619 Leo @ Elufa
                         ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,//20170202 Elufa
                         ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, //20170203 Elufa
                         ASI_CRM_NationalGroup__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_NationalGroup__c,//20170523 
                         ASI_CRM_NationalGroup__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_NationalGroup__r.Name, //20170523
                         ASI_CRM_NationalGroup__r.ASI_CRM_Apply_National_Approval__c, ASI_CRM_NationalGroup__r.ASI_CRM_National_Group__c, //20170523
                         ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,ASI_CRM_CN_Is_Block__c,
                        ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Activity_Times__c,ASI_CRM_CN_Target_Base__c,ASI_CRM_CN_Contract_Classification__c,
                         (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c,
                          ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c,
                          ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
                          From ASI_TH_CRM_PaymentRequests_Contract__r)                       
                         FROM ASI_TH_CRM_Contract__c
                         WHERE id =:pageId FOR UPDATE];
            system.debug('LContract: ' + LContract );
            
            if (LContract != null && LContract.size() > 0){
                
                this.ContractSelected = LContract[0];
                // Added by Michael Yip (Introv) 29Jun2014 for PO Modification, Make Payment button show setting
                Integer PendingPaymentNo = 0;      // NO PO Modification, Make payment if there is pending payment (Status = Draft, Submitted)
                Integer FinalPaymentNo = 0;        // NO Make payment if there is payment marked last payment
                for(ASI_th_crm_paymentrequest__c p : ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r){
                    if(p.ASI_TH_CRM_Status__c == 'Draft' || p.ASI_TH_CRM_Status__c == 'Submitted')
                        PendingPaymentNo += 1;
                    if(p.ASI_CRM_CN_Last_Payment__c && p.ASI_TH_CRM_Status__c == 'Approved')
                        FinalPaymentNo += 1;
                    if(p.ASI_TH_CRM_Status__c == 'Submitted') pendingPR = true;
                }
                // Added by Michael Yip (Introv) 29Jun2014 for PO Modification, Make Payment button show setting
                
                if(LContract[0].recordtypeid != Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')){ isCNCRM = false;
                }
                else{
                    if(ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Last_PO_version__c != null){   //PO modification =true                     
                        showEdit = true;
                        showRestorePO = true;
                        showApprovalButton = true;
                        makePayment = false;
                        showPOModification = false;
                        showShuttle = false;
                        contractUpload=true;
                        showPOModificationPDF = true;
                        businessLicense = true;
                        
                    }
                    else if(ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Last_PO_version__c == null){                        
                        showEdit = true;
                        showRestorePO = false; 
                        showShuttle = true;
                        showPOModification = false;
                        showApprovalButton = true;
                        makePayment = false;
                        contractUpload=true;
                        showPOModificationPDF = false;
                        businessLicense = true;
                    }
                    else if(ContractSelected.ASI_CRM_CN_Status__c == 'Final'){
                        //showPOModification = PendingPaymentNo >0 ? false : true;
                        showPOModification = true;
                        showApprovalButton = false;
                        showShuttle = false;
                        if( ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){  showShuttle = true; }
                        //makePayment = FinalPaymentNo > 0 || PendingPaymentNo > 0 ? false : true; // Added by Michael Yip (Introv) 29Jun2014 for PO Modification, Make Payment button show setting
                        makePayment = true;
                        showEdit=false;
                        showRestorePO = false; 
                        contractUpload=true;
                        if(inBAPermissionSet) showPOModificationPDF = true;
                        else
                            showPOModificationPDF = false;
                        businessLicense  = true;
                    }                    
                    else if (ContractSelected.ASI_CRM_CN_Status__c == 'Archived' || ContractSelected.ASI_CRM_CN_Status__c == 'Submitted'){
                        showEdit = false;
                        showApprovalButton = false;
                        makePayment = false;
                        showShuttle = false;
                        if( ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') { showShuttle = true; }
                        showRestorePO = false;
                        showPOModification = false;
                        showPOModificationPDF = false;
                        businessLicense = false;
                        if(ContractSelected.ASI_CRM_CN_Status__c == 'Submitted' && ContractSelected.ASI_CRM_CN_Last_PO_version__c != null){ showPOModificationPDF = true; }
                    }
                }
                //Payment Request Summary
                if (ContractSelected.ASI_CRM_CN_PO_Modification__c==true){
                    try{
                        paymentRequestSummary = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(null, ContractSelected);
                    }catch(exception e){
                        system.debug('Try paymentRequestSummary failed: ' + e);
                        paymentRequestSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();
                    }  
                    PS_TotalPORemainAmt = 0;
                    PS_TotalLastEstAmt = 0;
                    //20160726 Ben @ Elufa
                    TotalLastEstAmtCNY = 0;
                    TotalLastEstAmtMAF = 0;
                    TotalLastEstAmtOthers = 0;
                    
                    TotalRemainAmtCNY = 0;
                    TotalRemainAmtMAF = 0;
                    TotalRemainAmtOthers = 0;
                    
                    if (paymentRequestSummary != null && paymentRequestSummary.size() > 0){
                        for (ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary prtemp : paymentRequestSummary){
                            PS_TotalPORemainAmt += prtemp.PORemainAmt;
                            PS_TotalLastEstAmt += prtemp.LastPOEstimateAmt;
                            //20160726 Ben @ Elufa
                            TotalLastEstAmtCNY += prtemp.cnyEstLast;
                            TotalLastEstAmtMAF += prtemp.mafEstLast;
                            TotalLastEstAmtOthers += prtemp.othersEstLast;
                            
                            TotalRemainAmtCNY += prtemp.cnyRemaining;
                            TotalRemainAmtMAF += prtemp.mafRemaining;
                            TotalRemainAmtOthers += prtemp.othersRemaining;
                        }
                    } 
                }else{
                    paymentRequestSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();
                }
            }
            //system.debug('ContractSelected = LContract'); 
            LBRSF = [SELECT id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                                ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,
                                ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,
                                ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,
                                ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c
                                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c  
                                WHERE ASI_CRM_CN_Contract__c = :PageId];
            if(LBRSF != null && LBRSF.size()>0){
                //ContractBRSFList = LBRSF[0];
                //Dummy row for displaying total for BRSF
                totalBRSF_est_total=0;
                totalBRSF_contract_total=0;
                totalBRSF = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Est_Monthly_Qty__c=0,ASI_CRM_CN_Contract_Monthly_Qty__c=0,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0,ASI_CRM_CN_Est_Total_Dummy__c=0,ASI_CRM_CN_Contract_Total_Dummy__c=0);
                LBRSFDisplay = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c c : LBRSF){
                    if(c.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                        totalBRSF.ASI_CRM_CN_Est_Monthly_Qty__c += c.ASI_CRM_CN_Est_Monthly_Qty__c;
                    }
                    if(c.ASI_CRM_CN_Contract_Monthly_Qty__c != null){
                        totalBRSF.ASI_CRM_CN_Contract_Monthly_Qty__c += c.ASI_CRM_CN_Contract_Monthly_Qty__c;
                    }
                    if(c.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null){
                        totalBRSF.ASI_CRM_CN_Est_BRSF_Per_Bottle__c += c.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    }
                    if(c.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null){
                        totalBRSF.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c += c.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                    }
                    if(c.ASI_CRM_CN_Est_Total_Dummy__c != null){
                        totalBRSF.ASI_CRM_CN_Est_Total_Dummy__c += c.ASI_CRM_CN_Est_Total_Dummy__c;
                    }
                    if(c.ASI_CRM_CN_Contract_Total_Dummy__c != null){
                        totalBRSF.ASI_CRM_CN_Contract_Total_Dummy__c += c.ASI_CRM_CN_Contract_Total_Dummy__c;
                    }
                    if(c.ASI_CRM_CN_Est_Total__c != null){
                          totalBRSF_est_total += c.ASI_CRM_CN_Est_Total__c;
                    }
                    if(c.ASI_CRM_CN_Contract_Total__c != null){
                        totalBRSF_contract_total += c.ASI_CRM_CN_Contract_Total__c;
                    }
                    

                    LBRSFDisplay.add(c);
                }
                if(LBRSFDisplay.size()>0){
                
                   // LBRSFDisplay.add(totalBRSF);
                }
            }
            Total_Payments_Amount=0;
            Total_Payment_Paid=0;
            Total_Payment_PaidInProgress=0;
            PaymentRequestList = ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r;
            /* Updated by William Yang(Introv) 20141103 to reduce no. of SOQL
            [Select  id,Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c,
                                ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c,
                                ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
                                 FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c=:PageId order by name];
            */
            /*lokman 6/25/2014 start*/
            if(PaymentRequestList != null && PaymentRequestList.size() >0)
                 for(ASI_TH_CRM_PaymentRequest__c payment_req:PaymentRequestList){
                     if( payment_req.ASI_CRM_CN_Total_Payment__c!=null && payment_req.ASI_TH_CRM_Status__c != 'Draft'){
                         Total_Payments_Amount+=payment_req.ASI_CRM_CN_Total_Payment__c;
                     }
                     /*if(payment_req.ASI_CRM_CN_Last_Payment__c ){
                     if(payment_req.ASI_TH_CRM_Status__c=='Submitted' || payment_req.ASI_TH_CRM_Status__c=='Approved')
                         makepayment=false;
                         }*/
                     /*lokman 6/27/2014 start*/
                     if(payment_req.ASI_CRM_CN_Total_Payment__c!=null){
                         Total_Payment_Paid+=payment_req.ASI_CRM_CN_Total_Payment__c;
                     }
                     if(payment_req.ASI_CRM_CN_Paid_In_Progress__c!=null){
                         Total_Payment_PaidInProgress+=payment_req.ASI_CRM_CN_Paid_In_Progress__c;
                     }
                     /*lokman 6/27/2014 end*/
                     }
                 /*lokman 6/25/2014 end*/
                                 
            ContractOutletList = [SELECT id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Suggested_Amount__c, ASI_CRM_CN_Target_Volume_Std_Btl__c, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.ASI_CRM_Account__c, ASI_CRM_CN_Allocated_Amount__c, ASI_CRM_CN_Check_All__c, ASI_CRM_CN_Selected_Covered_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c 
                                 WHERE ASI_CRM_CN_Contract__c = :PageId];
                                 
            //Updated by William Yang (Introv) 2014-11-03 to redue no. of SOQL
            //ASI_CRM_CN_Activity_Code__c
            LFixCost = new List<ASI_CRM_Contract_Cost__c> ();
            LVariableCost = new List<ASI_CRM_Contract_Cost__c> ();
            
            //20160608 Ben @ Elufa
            festivalMap = new Map<String, Boolean>();
            Map<String, Boolean> tmpMap = new Map<String, Boolean>();
            List<ASI_CRM_Contract_Cost_Setting__c> ccs = new List<ASI_CRM_Contract_Cost_Setting__c>([SELECT id, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_Festival_Season__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Contract_Cost_Setting']);
            
            for(ASI_CRM_Contract_Cost_Setting__c obj : ccs){ tmpMap.put('' + obj.ASI_CRM_CN_Promotion_Type__c + obj.ASI_CRM_CN_Activity_Code__c, obj.ASI_CRM_Festival_Season__c);
            }
            //20160608 End
            List<ASI_CRM_Contract_Cost__c> LContractCost = [Select id, name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,
                                      ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :PageId and (ASI_CRM_CN_Cost_Type__c = 'Fixed' or ASI_CRM_CN_Cost_Type__c = 'Variable')
                                                            order by ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC];//20160610 Ben @ Elufa added order by ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c
                
            if(LContractCost != null && LContractCost.size() > 0)
                for(ASI_CRM_Contract_Cost__c cc:LContractCost)
                {
                    if(cc.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                        LFixCost.add(cc);
                    }else if(cc.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                        LVariableCost.add(cc);
                    }
                    if(tmpMap.containsKey(cc.ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c + '' + cc.ASI_CRM_CN_Activity_Code__c)){ festivalMap.put(cc.id, tmpMap.get(cc.ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c + '' + cc.ASI_CRM_CN_Activity_Code__c));
                    }else{//20160706 Ben @ Elufa
                        festivalMap.put(cc.id, FALSE);
                    }
                }
                
            if(LFixCost != null && LFixCost.size()>0){
                fix_totalCost = new ASI_CRM_Contract_Cost__c(name='Fixed Cost Total:', ASI_CRM_MAF_Est__c = 0, ASI_CRM_CNY_Est__c = 0, ASI_CRM_Other_Est__c = 0, ASI_CRM_CN_Estimate_Amount__c = 0,ASI_CRM_CN_Contract_Amount__c = 0, ASI_CRM_CN_Sequence__c=99999999);
                LFixCostDisplay = new List<ASI_CRM_Contract_Cost__c>(); 
                for(ASI_CRM_Contract_Cost__c c : LFixCost){
                    if(c.ASI_CRM_CN_Estimate_Amount__c != null){
                        fix_totalCost.ASI_CRM_CN_Estimate_Amount__c += c.ASI_CRM_CN_Estimate_Amount__c;
                    }
                    if(c.ASI_CRM_CN_Contract_Amount__c != null){
                        fix_totalCost.ASI_CRM_CN_Contract_Amount__c += c.ASI_CRM_CN_Contract_Amount__c;
                    }
                    //20160613 Ben @ Elufa
                    if(festivalMap.containsKey(c.id) && festivalMap.get(c.id) && c.ASI_CRM_MAF_Est__c != null){ fix_totalCost.ASI_CRM_MAF_Est__c += c.ASI_CRM_MAF_Est__c;
                    }
                    if(festivalMap.containsKey(c.id) && festivalMap.get(c.id) && c.ASI_CRM_CNY_Est__c != null){ fix_totalCost.ASI_CRM_CNY_Est__c += c.ASI_CRM_CNY_Est__c;
                    }
                    if(festivalMap.containsKey(c.id) && festivalMap.get(c.id) && c.ASI_CRM_Other_Est__c != null){ fix_totalCost.ASI_CRM_Other_Est__c += c.ASI_CRM_Other_Est__c;
                    }
                    //20160613 End
                    LFixCostDisplay.add(c);
                }
                if(LFixCostDisplay.size()>0){
                   // LFixCostDisplay.add(totalCost);
                }
            }                 

            if(LVariableCost != null && LVariableCost.size()>0){ 
                variable_totalCost = new ASI_CRM_Contract_Cost__c(name='Other Variable Cost Total', ASI_CRM_MAF_Est__c = 0, ASI_CRM_CNY_Est__c = 0, ASI_CRM_Other_Est__c = 0, ASI_CRM_CN_Estimate_Amount__c = 0,ASI_CRM_CN_Contract_Amount__c = 0, ASI_CRM_CN_Sequence__c=99999999);
                LVariableCostDisplay = new List<ASI_CRM_Contract_Cost__c>(); 
                for(ASI_CRM_Contract_Cost__c c : LVariableCost){
                    if(c.ASI_CRM_CN_Estimate_Amount__c != null){
                        variable_totalCost.ASI_CRM_CN_Estimate_Amount__c += c.ASI_CRM_CN_Estimate_Amount__c;
                    }
                    if(c.ASI_CRM_CN_Contract_Amount__c != null){
                        variable_totalCost.ASI_CRM_CN_Contract_Amount__c += c.ASI_CRM_CN_Contract_Amount__c;
                    }
                    //20160613 Ben @ Elufa
                    if(c.ASI_CRM_MAF_Est__c != null){ variable_totalCost.ASI_CRM_MAF_Est__c += c.ASI_CRM_MAF_Est__c;
                    }
                    if(c.ASI_CRM_CNY_Est__c != null){ variable_totalCost.ASI_CRM_CNY_Est__c += c.ASI_CRM_CNY_Est__c;
                    }
                    if(c.ASI_CRM_Other_Est__c != null){ variable_totalCost.ASI_CRM_Other_Est__c += c.ASI_CRM_Other_Est__c;
                    }
                    //20160613 End
                    LVariableCostDisplay.add(c);
                }
                if(LVariableCostDisplay.size()>0){
                   // LVariableCostDisplay.add(totalCost);
                }
            }
        }
        else{
            System.debug(recordtypeSelected);
            ASI_TH_CRM_Contract__c CL1 = new ASI_TH_CRM_Contract__c();
            //CL1.ASI_CRM_New_FY_PO__c = TRUE;//20160602 Ben @ Elufa
            
            if(recordtypeSelected != null){
                if(recordtypeSelected == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')){
                    //ASI_TH_CRM_Contract__c CL1 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),name='Automated, Do not Change');
                    CL1.recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
                    CL1.name = 'Automated, Do not Change';
                    this.ContractSelected = CL1;
                    system.debug(this.ContractSelected);
                }                             
            }
            else{
                // Handle new contract button from CN WS, no recordtype passed, assume cn recordtype
                String CNWS = ApexPages.currentPage().getParameters().get('ASI_CRM_CN_Outlet_WS__c');
                String PromotionType = ApexPages.currentPage().getParameters().get('ASI_TH_CRM_Promotion_Type__c');
                if(CNWS != null && CNWS != ''){
                    //ASI_TH_CRM_Contract__c CL1 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),name='Automated, Do not Change');
                    CL1.recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
                    CL1.name = 'Automated, Do not Change';
                    CL1.ASI_CRM_CN_Outlet_WS__c = CNWS;
                    system.debug('CNWS   ' + CNWS);
                    //20160602 Ben @ Elufa
                    List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>([
                        SELECT id, ASI_CRM_CN_NewChannel__c
                            , ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c
                            , recordType.DeveloperName
                            , ASI_CRM_CN_NewChannel__r.Name
                            , ASI_CRM_CN_Channel_CN__c
                            , ASI_CRM_National_Group__c //20170131 Elufa
                            , ASI_CRM_CN_KA_Account_Chain__c //20170523
                            , ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_National_Group__c //20170523
                            , ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Apply_National_Approval__c //20170523
                        ,ASI_CRM_Channel_Group__c
                        ,ASI_CRM_Channel_Group__r.Name
                        FROM ASI_CRM_AccountsAdditionalField__c
                        WHERE id = :CNWS
                        //AND (NOT ASI_CRM_CN_Channel_CN__c LIKE 'All Customer%')
                        //AND (NOT ASI_CRM_CN_NewChannel__r.Name LIKE 'All Customer%')
                    ]);
                    
                    if(tmpCustomer.size() > 0 && tmpCustomer[0].recordType.DeveloperName.contains('ASI_CRM_Outlet_CN')){
                        if(tmpCustomer[0].ASI_CRM_CN_NewChannel__c != NULL && !tmpCustomer[0].ASI_CRM_CN_NewChannel__r.Name.contains('All Customer')){
                            
                            needChannelnProvince = FALSE;
                            CL1.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                            CL1.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                            CL1.ASI_CRM_PO_City__c = tmpCustomer[0].ASI_CRM_CN_CCity__c;

                        }else if(tmpCustomer[0].ASI_CRM_CN_NewChannel__c == NULL && !tmpCustomer[0].ASI_CRM_CN_Channel_CN__c.contains('All Customer')){
                            
                            needChannelnProvince = FALSE;
                            CL1.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                            CL1.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                            CL1.ASI_CRM_PO_City__c = tmpCustomer[0].ASI_CRM_CN_CCity__c;

                        }else{
                            needChannelnProvince = TRUE;
                        }
                    }else{
                        needChannelnProvince = TRUE;
                    }
                    /*if(tmpCustomer.size() > 0 && tmpCustomer[0].recordType.DeveloperName.contains('ASI_CRM_Outlet_CN')){
                        needChannelnProvince = FALSE;
                        CL1.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                        CL1.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                    }else{
                        needChannelnProvince = TRUE;
                    }*/
                    
                    //20160826 End
                    //CL1.ASI_CRM_New_FY_PO__c = TRUE;
                    //201606 End
                    if(PromotionType != null && PromotionType != ''){
                        CL1.ASI_TH_CRM_Promotion_Type__c = PromotionType;
                    }
                    
                    //20170131 Elufa
                    if(tmpCustomer.size() > 0 && tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c != Null && tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_National_Group__c){//20170523 Changed to ASI_CRM_CN_KA_Account_Chain__c
                        
                        //CL1.ASI_CRM_NationalGroup__c = tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c;
                        
                        if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Apply_National_Approval__c)
                            CL1.ASI_CRM_CN_National_Group_Contract__c = True;
                        else
                            CL1.ASI_CRM_CN_National_Group_Contract__c = False;
                    }else{
                        CL1.ASI_CRM_NationalGroup__c = Null;
                        CL1.ASI_CRM_CN_National_Group_Contract__c = False;
                    }
                    //20170131 End
                    
                    this.ContractSelected = CL1;
                    system.debug(this.ContractSelected);
                }
            }
            //20160830 Ben @ Elufa
            this.ContractSelected.ASI_CRM_New_FY_PO__c = TRUE;
            
            //20160826 Ben @ Elufa
            this.ContractSelected.ASI_CRM_CN_All_Customer_Outlet__c = needChannelnProvince;
            
            isCreate = true;  
        }
        
        //---- BRSF Line Item - by leo (start) ----
        Del_BRSF_Item = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        BRSF_Item_Map = new Map<Integer, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        indexBRSF = 0;

        if(LBRSF != null && LBRSF.size()>0){
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf :LBRSF){
                // Added by Michael Yip (Introv) 12Jul2014 for recalculating dummy total in every reload
                if(brsf.ASI_CRM_CN_Est_Monthly_Qty__c != null && brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null)
                    brsf.ASI_CRM_CN_Est_Total_Dummy__c = brsf.ASI_CRM_CN_Est_Monthly_Qty__c * brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
          
                if(brsf.ASI_CRM_CN_Contract_Monthly_Qty__c != null && brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null)
                    brsf.ASI_CRM_CN_Contract_Total_Dummy__c = brsf.ASI_CRM_CN_Contract_Monthly_Qty__c * brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                // Added by Michael Yip (Introv) 12Jul2014 for recalculating dummy total in every reload
                
                BRSF_Item_Map.put(indexBRSF++, brsf);
            }
        }
        //---- BRSF Line Item - by leo (end) ----

        //==========================================================

        //---- Covered Outlet Line Item - by leo (start) ----
        Del_CoveredOutlet_Item = new List<ASI_CRM_CN_Covered_Outlet__c >();
        CoveredOutlet_Item_Map = new Map<Integer, ASI_CRM_CN_Covered_Outlet__c >();
        indexCoveredOutlet = 0;

        if(ContractOutletList != null && ContractOutletList.size()>0){
            for (ASI_CRM_CN_Covered_Outlet__c  outlet :ContractOutletList){
                CoveredOutlet_Item_Map.put(indexCoveredOutlet++, outlet);
            }
        }
        //---- Covered Outlet Line Item - by leo (end) ----
        
        if (PageId != null){
            retrieveOutletPicklist();
        }
        
        //Added by Twinkle 9Oct2014
        if(inBAPermissionSet==true){
            if(ContractSelected.ASI_CRM_CN_Status__c == 'Submitted')
                showReturn = true;
            else
                showReturn = false;
        }
    }
    
    public PageReference POModification(){
      
        if(pendingPR) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_ContractSubmittedPaymentCheckErrMsg));
            return null;
        }
        
        //Added by Twinkle 11/25/2014 to insert an approval comment
        /*List<ASI_CRM_Approval_Comment__c> LPOContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
        
        if(Global_RecordTypeCache.getRt(contractSelected.recordTypeId).developerName.contains('ASI_CRM_CN_Contract')){
            LPOContractComment_Insert.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c = contractSelected.id, recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')));
        }
        if(LPOContractComment_Insert !=null && LPOContractComment_Insert.size() > 0) 
            insert LPOContractComment_Insert;*/
        //Ended by Twinkle 11/25/2014
     //   if (contractSelected.ASI_CRM_CN_Status__c == 'Final'){
     //   Added by Elufa Support 12/14/2015 to avoid duplicated version
             List<ASI_TH_CRM_Contract__c> cContract = [Select Id, ASI_CRM_CN_Status__c, lastModifiedDate from ASI_TH_CRM_Contract__c where id=:contractSelected.id LIMIT 1];//20160420 Ben @ Elufa Added Field
            if (cContract[0].ASI_CRM_CN_Status__c == 'Final' && cContract[0].lastModifiedDate == contractSelected.lastModifiedDate){//20160420 Ben @ Elufa Added Condition
                contractSelected.ASI_CRM_CN_PO_Modification__c = true;
                contractSelected.ASI_CRM_CN_Status__c = 'Draft';
                //20151228 Ben @ Elufa System
                //contractSelected.ASI_CRM_CN_Return_Comments__c = '';
                //20151228
                update contractSelected;
                return redirectToPage('/apex/ASI_CRM_CN_MainContractPage',contractSelected.id);
            } else {
                if(USerInfo.getLanguage()=='zh_CN')  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Contract has been modified since last update, Please refresh and do modification again!'));
                else    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'请刷新网页，更新PO资料，再PO修改。'));
                
            }

        return null; 
     //Ended by Elufa Support 12/14/2015       
    //  }
        /*Temp remarked by William Yang(Introv) 2014-11-19 to avoid too may soql
        init(contractSelected.recordtypeid);
        */
        
        
    }
    
    public PageReference restorePO(){
        PageReference p;
        String returnId = contractSelected.id;
        //   Added by Elufa Support 12/14/2015 to avoid duplicated version
        List<ASI_TH_CRM_Contract__c> cContract = [Select Id, ASI_CRM_CN_Status__c, lastModifiedDate from ASI_TH_CRM_Contract__c where id=:contractSelected.id LIMIT 1];//20160420 Ben @ Elufa Added Field
            if (cContract[0].ASI_CRM_CN_Status__c == 'Draft' && cContract[0].lastModifiedDate == contractSelected.lastModifiedDate){//20160420 Ben @ Elufa Added Condition
                restore(contractSelected);
                return redirectToPage('/apex/ASI_CRM_CN_MainContractPage',returnId);
            } else {
                if(USerInfo.getLanguage()=='zh_CN')
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Contract has been modified since last update, Please refresh and restore again!'));
                else    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'请刷新网页，更新PO资料，再恢复以前的版本。'));
                
            }

        return null; 
        //Ended by Elufa Support 12/14/2015 
    }
    
    // Added by Twinkle 26Sept2014 for return function
    public PageReference GoReturn(){
    
        /*Updated by William Yang(Introv) 20141103 to reduce no. of SOQL
        List<ASI_TH_CRM_Contract__c> LContract = [Select Id, ASI_CRM_CN_Status__c from ASI_TH_CRM_Contract__c where id=:PageId LIMIT 1]; 
        List<Profile> LProfileID = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        */

        //if(LContract.size() > 0){ 
        if(ContractSelected != null)
        {
            //if(LContract[0].ASI_CRM_CN_Status__c != 'Submitted'){ 
            if(ContractSelected.ASI_CRM_CN_Status__c != 'Submitted'){ 
                if(USerInfo.getLanguage()=='zh_CN')  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot Return PO.\nOnly PO with "Submitted" status can be returned'));
                else    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'PO不得退回！\nPO状态仅在"已提交"时方可退回。'));
            
            } 
            else{
                
                //20151210 Ben @ Elufa System
                List<ASI_TH_CRM_Contract__c> LContract = [Select ASI_CRM_CN_Return_Comments__c from ASI_TH_CRM_Contract__c where id=:PageId LIMIT 1]; 
                if(LContract[0].ASI_CRM_CN_Return_Comments__c != ''){
                    try{
                        LContract[0].ASI_CRM_CN_Return_Comments__c = '';
                        update LContract[0];
                    }catch(dmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error'));
                    }
                }
                //20151210 End
                
                PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_ReturnContractByBAPage?scontrolCaching=1&id='+PageId);
                pageRef.setRedirect(True);
                return pageRef;
            }
        }
        //}
        return null;            
    }
    // End by Twinkle Li 26Sept2014
    
    private void restore(ASI_TH_CRM_Contract__c cont){
        
        List<ASI_TH_CRM_Contract__c> LLastContract = [select Name, ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                                                      ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c,
                                                      ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c, 
                                                      ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_IsClone__c ,
                                                      ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                                      recordtypeid, ASI_CRM_CN_PO_Modification__c ,  ASI_CRM_CN_Contract_Upload__c,ASI_CRM_CN_Business_License__c,
                                                      ASI_CRM_CN_Last_PO_version__c, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Start_Date__c, 
                                                      ASI_CRM_CN_Return_Comments__c,ASI_CRM_Reject_Return_Comments__c//20160229 Ben @ Elufa
                                                      //20160308 Ben @ Elufa
                                                      , ASI_CRM_CN_Last_Approved_By__c, ASI_CRM_CN_Last_Approved_Date__c, ASI_CRM_CN_Last_Recall_By__c
                                                      , ASI_CRM_CN_Last_Recall_Date__c, ASI_CRM_CN_Last_Rejected_By__c, ASI_CRM_CN_Last_Rejected_Date__c
                                                      , ASI_CRM_CN_Last_Submitted_By__c, ASI_CRM_CN_Last_Submitted_Date__c
                                                      //20160308 End
                                                      , ASI_CRM_National_Group__c, ASI_CRM_CN_National_Group_Contract__c//20170202 Elufa
                                                      , ASI_CRM_NationalGroup__c //20170523
                                                      from ASI_TH_CRM_Contract__c  where id = :cont.ASI_CRM_CN_Last_PO_version__c];
        
        if(LLastContract != null && LLastContract.size()==1){
            cont.Name= LLastContract[0].Name;
            cont.ASI_CRM_CN_Vol_Budget_LE__c= LLastContract[0].ASI_CRM_CN_Vol_Budget_LE__c;
            cont.ASI_CRM_CN_Status__c= 'Final';
            cont.ASI_CRM_CN_Source_of_Contract__c= LLastContract[0].ASI_CRM_CN_Source_of_Contract__c;
            cont.ASI_CRM_CN_Source_Others__c= LLastContract[0].ASI_CRM_CN_Source_Others__c;
            cont.ASI_CRM_CN_Reason_without_Budget__c= LLastContract[0].ASI_CRM_CN_Reason_without_Budget__c;
            cont.ASI_TH_CRM_Promotion_Type__c= LLastContract[0].ASI_TH_CRM_Promotion_Type__c;
            cont.ASI_CRM_CN_PP_No__c= LLastContract[0].ASI_CRM_CN_PP_No__c;
            cont.ASI_CRM_CN_PO_Version__c= LLastContract[0].ASI_CRM_CN_PO_Version__c;
            cont.ASI_CRM_CN_PO_Start_Date__c= LLastContract[0].ASI_CRM_CN_PO_Start_Date__c;
            cont.ASI_CRM_CN_PO_No__c= LLastContract[0].ASI_CRM_CN_PO_No__c;
            cont.ASI_CRM_CN_PO_End_Date__c= LLastContract[0].ASI_CRM_CN_PO_End_Date__c;
            cont.ASI_CRM_CN_Outlet_WS__c= LLastContract[0].ASI_CRM_CN_Outlet_WS__c;
            cont.ASI_CRM_CN_Exchange_Rate__c= LLastContract[0].ASI_CRM_CN_Exchange_Rate__c;
            cont.ASI_CRM_CN_Description__c= LLastContract[0].ASI_CRM_CN_Description__c;
            cont.ASI_CRM_CN_Currency__c= LLastContract[0].ASI_CRM_CN_Currency__c;
            cont.ASI_CRM_CN_Budget_LE__c= LLastContract[0].ASI_CRM_CN_Budget_LE__c;
            cont.ASI_CRM_CN_Bottle_Collection_Rate__c= LLastContract[0].ASI_CRM_CN_Bottle_Collection_Rate__c;
            cont.ASI_CRM_CN_Effective_Date__c= LLastContract[0].ASI_CRM_CN_Effective_Date__c;
            cont.ASI_CRM_CN_PO_Modification__c = LLastContract[0].ASI_CRM_CN_PO_Modification__c ;
            cont.ASI_CRM_CN_Contract_Upload__c= LLastContract[0].ASI_CRM_CN_Contract_Upload__c;
            cont.ASI_CRM_CN_Last_PO_version__c= LLastContract[0].ASI_CRM_CN_Last_PO_version__c;
            cont.ASI_CRM_CN_Business_License__c = LLastContract[0].ASI_CRM_CN_Business_License__c;
            cont.ASI_TH_CRM_Start_Date__c = LLastContract[0].ASI_TH_CRM_Start_Date__c;
            cont.ASI_TH_CRM_End_Date__c = LLastContract[0].ASI_TH_CRM_End_Date__c;
            cont.ASI_CRM_Reject_Return_Comments__c = LLastContract[0].ASI_CRM_Reject_Return_Comments__c;//20160229 Ben @ Elufa
            cont.ASI_CRM_CN_Return_Comments__c = LLastContract[0].ASI_CRM_CN_Return_Comments__c;
            //20160308 Ben @ Elufa
            cont.ASI_CRM_CN_Last_Approved_By__c = LLastContract[0].ASI_CRM_CN_Last_Approved_By__c;
            cont.ASI_CRM_CN_Last_Approved_Date__c = LLastContract[0].ASI_CRM_CN_Last_Approved_Date__c;
            cont.ASI_CRM_CN_Last_Recall_By__c = LLastContract[0].ASI_CRM_CN_Last_Recall_By__c;
            cont.ASI_CRM_CN_Last_Recall_Date__c = LLastContract[0].ASI_CRM_CN_Last_Recall_Date__c;
            cont.ASI_CRM_CN_Last_Rejected_By__c = LLastContract[0].ASI_CRM_CN_Last_Rejected_By__c;
            cont.ASI_CRM_CN_Last_Rejected_Date__c = LLastContract[0].ASI_CRM_CN_Last_Rejected_Date__c;
            cont.ASI_CRM_CN_Last_Submitted_By__c = LLastContract[0].ASI_CRM_CN_Last_Submitted_By__c;
            cont.ASI_CRM_CN_Last_Submitted_Date__c = LLastContract[0].ASI_CRM_CN_Last_Submitted_Date__c;
            //20160308 End
            cont.ASI_CRM_National_Group__c = LLastContract[0].ASI_CRM_National_Group__c;//20170202 Elufa
            cont.ASI_CRM_CN_National_Group_Contract__c = LLastContract[0].ASI_CRM_CN_National_Group_Contract__c;//20170202 Elufa
            cont.ASI_CRM_NationalGroup__c = LLastContract[0].ASI_CRM_NationalGroup__c;//20170523
            cont.ASI_CRM_CN_IsClone__c = false;
            update cont;
        }
    if(cont.ASI_CRM_CN_Status__c== 'Final'){
        //update cont;
         //---- original child objects ----
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = [Select id from ASI_CRM_CN_Contract_BRSF_Line_Item__c where ASI_CRM_CN_Contract__c = :cont.id];
        if(LBRSF != null && LBRSF.size()>0) delete LBRSF;        
        List<ASI_CRM_Contract_Cost__c> LContractCost = [Select id from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :cont.id];
        if(LContractCost.size()>0) delete LContractCost;
        List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet = [Select id from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :cont.id];
        if(LCoveredOutlet.size()>0)
            delete LCoveredOutlet;

    List<ASI_CRM_Approval_Comment__c> LComment = [Select id from ASI_CRM_Approval_Comment__c where ASI_CRM_Contract__c = :cont.id];
        if(LCoveredOutlet.size()>0)
            delete LComment;
        /*List<Attachment> LAtth = [Select id from Attachment where Parentid = :cont.id];
        if(LAtth.size()>0)
            delete LAtth;
        List<ASI_TH_CRM_Contract__Feed> LFeed = [Select id from ASI_TH_CRM_Contract__Feed where Type = 'ContentPost' AND ParentId =:cont.id AND Id != null ORDER BY ContentFileName];
        if(LFeed.size()>0)
            delete LFeed;
          */  
        // Change lookup for archived child record
        LBRSF = [Select id, ASI_CRM_CN_Contract__c  from ASI_CRM_CN_Contract_BRSF_Line_Item__c where ASI_CRM_CN_Contract__c = :LLastContract[0].id];
        if(LBRSF.size()>0){
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c itm : LBRSF){
                itm.ASI_CRM_CN_Contract__c = cont.id; 
            }  
            Update LBRSF;
        }      
        LContractCost = [Select id from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :LLastContract[0].id];
        if(LContractCost.size()>0){
            for(ASI_CRM_Contract_Cost__c itm : LContractCost ){
                itm.ASI_CRM_CN_Contract__c = cont.id; 
            }  
            Update LContractCost;
        } 
        LCoveredOutlet = [Select id from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :LLastContract[0].id];
        if(LCoveredOutlet.size()>0){
            for(ASI_CRM_CN_Covered_Outlet__c itm : LCoveredOutlet ){
                itm.ASI_CRM_CN_Contract__c = cont.id; 
            }  
            Update LCoveredOutlet;
        }
            
    LComment = [Select id from ASI_CRM_Approval_Comment__c where ASI_CRM_Contract__c = :LLastContract[0].id];
        if(LComment.size()>0){
            for(ASI_CRM_Approval_Comment__c itm : LComment ){
                itm.ASI_CRM_Contract__c = cont.id; 
            }  
            Update LComment;
        }
      /*  LAtth = [Select id, parentid from Attachment where Parentid = :LLastContract[0].id];
        if(LAtth.size()>0){
            List<Attachment> LAtth_Clone = new List<Attachment>();
            for(Attachment itm : LAtth ){
                Attachment cloneAtth = itm.clone(false, true);
                cloneAtth.ParentId = cont.Id;

                LAtth_Clone.add(cloneAtth);
            }  
            Delete LAtth;
        }
        LFeed = [Select ContentFileName, RelatedRecordId, ParentId, Body, ContentData from ASI_TH_CRM_Contract__Feed where Type = 'ContentPost' AND ParentId =:LLastContract[0].id AND Id != null ORDER BY ContentFileName];
        if(LFeed.size()>0){
            List<FeedItem> LFeed_Clone = new List<FeedItem>();
            for(ASI_TH_CRM_Contract__Feed itm : LFeed ){
                FeedItem cloneFeed = new FeedItem();
                cloneFeed.ParentId = cont.Id;
                cloneFeed.Body = itm.Body;
                cloneFeed.ContentData = itm.ContentData;
                cloneFeed.ContentFileName = itm.ContentFileName;

                LFeed_Clone.add(cloneFeed); 
            }
            System.debug(LFeed_Clone);
            insert LFeed_Clone;  
            Delete LFeed;
        }
        System.debug(LLastContract); */
        // Change to draft before deleting to comply with only draft can be deleted
        list<ASI_TH_CRM_Contract__c> ContractsNotDraft = new list<ASI_TH_CRM_Contract__c>();
        for(ASI_TH_CRM_Contract__c c : LLastContract){
            if(c.ASI_CRM_CN_Status__c!='Draft') {
                c.ASI_CRM_CN_Status__c = 'Draft';
                c.ASI_CRM_CN_PO_Version__c = '0.0';
                ContractsNotDraft.add(c);
            }
        }
        //update LLastContract;
        update ContractsNotDraft;
        delete LLastContract;
        }
    }
    
    public PageReference UpdateContractRecord() 
    {
        if(!ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
            contractSelected.ASI_CRM_CN_Contract_Classification__c = null;
        }
        Boolean redirect = true;
        try{
            // Check against PO start date with today if insert, otherwise with createddate
            Date checkAgainstDate = system.today();
            //disabled checking with createddate
            /*if(pageID != null)
                checkAgainstDate = contractSelected.createddate.date();
            */
            //20160721 Leo @ Elufa, check city is in province
            Set<id> checkCitySet = new Set<id>();
            Boolean cityInProvince = false;
            
            //Add by laputa
           
            List<ASI_CRM_City__c> citys = new List<ASI_CRM_City__c>([SELECT id,
                ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Create_Heavy_Contract_On__c,ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,
                ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Create_TOT_MOT_Contract__c
                                                                     FROM ASI_CRM_City__c 
                                                                     WHERE recordType.developerName = 'ASI_CRM_CN_City'
                                                                     AND ASI_CRM_CN_Province__c =: ContractSelected.ASI_CRM_PO_Province__c
                                                                     ORDER BY Name]);
            
            List<ASI_CRM_AccountsAdditionalField__c> selectedOutlet = new List<ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_CN_Inactive_Flag__c 
                                                                                                                    From ASI_CRM_AccountsAdditionalField__c
                                                                                                                    WHERE id = : ContractSelected.ASI_CRM_CN_Outlet_WS__c
                                                                                                                    limit 1
                                                                                                                   ]);
            
            Map<Id, ASI_CRM_KA_Account__c> mapKAAccount = new Map<Id, ASI_CRM_KA_Account__c>();
            if(pageId == Null && ContractSelected.ASI_CRM_NationalGroup__c != Null){  mapKAAccount = new Map<Id, ASI_CRM_KA_Account__c>([SELECT id, ASI_CRM_Apply_National_Approval__c FROM ASI_CRM_KA_Account__c WHERE id = : ContractSelected.ASI_CRM_NationalGroup__c]);
            }

            //Keith Yip 2019-06-13
            List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT ASI_CRM_Channel_Group__r.Name FROM ASI_CRM_AccountsAdditionalField__c WHERE Id = :ContractSelected.ASI_CRM_CN_Outlet_WS__c LIMIT 1];
            ASI_CRM_AccountsAdditionalField__c customer = (customers.size() == 1)? customers.get(0) : null;
            String channelGroupName = customer == null ? '' : customer.ASI_CRM_Channel_Group__r.Name;
            if(ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Wholesaler Promotion'||ContractSelected.ASI_TH_CRM_Promotion_Type__c =='Consumer Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c =='Outlet Promotion' || test.isRunningTest()) {
                List<ASI_CRM_CN_Channel__c> newChannelList = [select Id,Name from ASI_CRM_CN_Channel__c where Name in('TOT', 'MOT') and RecordType.DeveloperName = 'ASI_CRM_CN_New_Channel'];
                Map<String, Id> newChannelMapByName = new Map<String, Id>();
                for (ASI_CRM_CN_Channel__c channel : newChannelList) {
                    newChannelMapByName.put(channel.Name, channel.Id);
                }
                if (channelGroupName == 'OFF MOT') {
                    ContractSelected.ASI_CRM_PO_Channel__c = newChannelMapByName.get('MOT');
                }else if (channelGroupName == 'OFF TOT') {
                    ContractSelected.ASI_CRM_PO_Channel__c = newChannelMapByName.get('TOT');
                }
            }

            
            if(selectedOutlet[0].ASI_CRM_CN_Inactive_Flag__c){
                if(USerInfo.getLanguage()=='zh_CN') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'不能为已关闭店家修改或创建合同'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not allowed to create/modify a PO with inactive Outlet'));
                return null; 
            }

            // if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract'){
            //     Date strDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c - 1;
            //     Date validateDate = Date.newInstance(System.today().Year(), System.today().Month() - 1, 1);
            //     List<ASI_TH_CRM_Contract__c> historicalContarct = [SELECT Id,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c 
            //                                                         FROM ASI_TH_CRM_Contract__c 
            //                                                         WHERE ASI_CRM_CN_PO_End_Date__c = :strDate AND ASI_CRM_CN_Is_Dolphin__c = true 
            //                                                             AND ASI_CRM_CN_Outlet_WS__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c
            //                                                             AND ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract'];
            //     if(historicalContarct.size() == 0 && ContractSelected.ASI_CRM_CN_PO_Start_Date__c < validateDate){
            //     if(USerInfo.getLanguage()=='zh_CN'){
            //             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'新签约合同开始日期不能早于当前日期的上月1号'));
            //     }else{
            //             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'PO Start Date of a new signing contarct Cannot be earlier than the 1st of last month of the current date'));
            //     }
            //         return null; 
            //     }
            // }
            
            /*if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c && ContractSelected.ASI_CRM_CN_Contract_Classification__c == 'C' && ContractSelected.ASI_CRM_CN_Use_PRC_Contract_Template__c){
                if(USerInfo.getLanguage()=='zh_CN'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'门店类别为C时,不能使用线上合同模板'));
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not allowed to use contract template when Store Type is C'));
                }
                return null; 
            }*/            
            
            //Add by laputa
            Boolean AllowCreateHCO=false;
            Boolean AllowCreate2nd = false;
            for(ASI_CRM_City__c city: citys){
                checkCitySet.add(city.id);
        AllowCreateHCO=city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Create_Heavy_Contract_On__c;
                AllowCreate2nd = city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Is_2nd_KPI_PO__c;
            }
            Boolean AllowCreateTOT=false;
            for(ASI_CRM_City__c city: citys){
                checkCitySet.add(city.id);
                AllowCreateTOT=city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Create_TOT_MOT_Contract__c;
            }


            
            //20170202 Elufa
            if(ContractSelected.ASI_CRM_NationalGroup__c != Null && ( ContractSelected.ASI_CRM_NationalGroup__r.ASI_CRM_Apply_National_Approval__c || (pageId == Null && mapKAAccount.containsKey(ContractSelected.ASI_CRM_NationalGroup__c)))){//20170524 added KA account logic
                ContractSelected.ASI_CRM_CN_National_Group_Contract__c = True;
            }else{
                ContractSelected.ASI_CRM_CN_National_Group_Contract__c = False;//20170309 Elufa
            }
            //20170202 End
            
            if(ContractSelected.ASI_CRM_PO_City__c != NULL && String.valueOf(ContractSelected.ASI_CRM_PO_City__c).trim() != '' && !checkCitySet.contains(ContractSelected.ASI_CRM_PO_City__c)){
                if(USerInfo.getLanguage()=='zh_CN')
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'该城市不在省份内'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'City is not in Province'));
                return null; 
            }
            //20160721 Leo @ Elufa, check city is in province
            
            
            //Add by laputa-- //Start Date/End Day should be within Group Contract period
            System.debug(LoggingLevel.INFO, '*** contractSelected.ASI_CRM_CN_Group_Contract__c: ' + contractSelected.ASI_CRM_CN_Group_Contract__c);
            if(ContractSelected.ASI_CRM_CN_Group_Contract__c!=null && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On'){
                
                ASI_TH_CRM_Contract__c NationalGroup =[select id,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c 
                                                       from  ASI_TH_CRM_Contract__c where  id=:ContractSelected.ASI_CRM_CN_Group_Contract__c];
                if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c<NationalGroup.ASI_CRM_CN_PO_Start_Date__c || 
                   ContractSelected.ASI_CRM_CN_PO_End_Date__c>NationalGroup.ASI_CRM_CN_PO_End_Date__c){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_PO_Date_GroupContract));
                       if(!Test.isRunningTest()) return null; 
                   }
            }
            //Add by laputa
            if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On' && !AllowCreateHCO){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'您所在的地区暂时还无法新建重大夜店合同。'));
                    if(!Test.isRunningTest()) return null; 
            }
            if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract' && !AllowCreateTOT){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'您所在的地区暂时还无法新建TOT/MOT合同。'));
                    if(!Test.isRunningTest()) return null;
            }

            if(contractSelected.ASI_CRM_CN_PO_Modification__c || (ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CN_FiscalYearBypass') || checkLaterThenThisFY(contractSelected.ASI_CRM_CN_PO_Start_Date__c,checkAgainstDate))){
                if (PageId == null){
                    //3.30 add
                    if (AllowCreateHCO && AllowCreate2nd && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On') {
                        ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c = true;
                    }
                    insert ContractSelected;
                    PageId = ContractSelected.id;
                    //laputa 
                    if(ContractSelected.Id!=null && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On'){
                        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                            ContractSelected = [SELECT Id,Name,ASI_CRM_Auto_PO_Modification_Time__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_CN_IsClone__c,ASI_CRM_CN_Is_2nd_KPI_PO__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_CTD_Monthly_Default_Date__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_CTD_Monthly_Default_Date__c,
                                             ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Group_Contract__c, ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Investment_Type__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                                             ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c, 
                                             ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                                             ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                             ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,
                                             ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                                             ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c , ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,  ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                             recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c, 
                                             ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                             ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,
                                             (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c From ASI_TH_CRM_PaymentRequests_Contract__r)
                                             FROM ASI_TH_CRM_Contract__c WHERE id =:ContractSelected.Id ];
                            ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(ContractSelected);
                        } else {
                        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(ContractSelected);
                        }
                        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(ContractSelected);
                    }
                    if(ContractSelected.Id!=null && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract'){
                        insert ASI_CRM_CN_ContractOffUtilClass.GeneratingVolumeValueTargetLine(ContractSelected);
                    }
                    if(ContractSelected.Id!=null && (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Consumer Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c =='Outlet Promotion')){
                        System.debug(ContractSelected.ASI_CRM_PO_Channel__c);
                        insert ASI_CRM_CN_PromotionContractUtilClass.GeneratingVolumeValueTargetLine(ContractSelected);
                    }
                }else{
                    update ContractSelected;
                }
            }
            else{
                String error_Msg = Label.ASI_CRM_CN_Contract_Start_Date_in_Last_FY;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error_Msg ));
                return null;
                //redirect = false;
            }
        }
        catch(exception e){
            redirect = false;
          
           // ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
           // system.assertEquals(Null, msg);
            apexpages.addmessages(e);
        }
       
        //PageReference redirect = new PageReference('/apex/ASI_CRM_CN_MainContractPage'); 
        //redirect.getParameters().put('id',PageId); 
        //redirect.setRedirect(true); 
        //return redirect;

        if(!redirect && !test.isRunningTest()){
            return null;
        }
        //return redirectToPage('/apex/ASI_CRM_CN_MainContractPage',PageId);
        
        
        PageReference Pageredirect;
        
        //changed by laputa 20170602
        if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On') {
            //3.30add
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                Pageredirect = new PageReference('/apex/ASI_CRM_CN_ViewHeavyContractPage2nd');
            } else {
                Pageredirect = new PageReference('/apex/ASI_CRM_CN_ViewHeavyContractPage');
            }
            Pageredirect.getParameters().put('id', PageId);
            Pageredirect.setRedirect(true);
        } else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract') {
            Pageredirect = new PageReference('/apex/ASI_CRM_CN_ViewContractOffPage');
            Pageredirect.getParameters().put('id', PageId);
            Pageredirect.setRedirect(true);
        //<<2018-12-05 Keith Yip
        } else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' ||
                  ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Consumer Promotion' ||
                  ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion') {  
            Pageredirect = new PageReference('/apex/ASI_CRM_CN_PromotionContractPage');
            Pageredirect.getParameters().put('id', PageId);
            Pageredirect.setRedirect(true);
        //>>2018-12-05 Keith Yip    
        } else{ //system.assertEquals(Null, ContractSelected.ASI_TH_CRM_Promotion_Type__c);
            Pageredirect = new PageReference('/apex/ASI_CRM_CN_MainContractPage'); 
            Pageredirect.getParameters().put('id',PageId); 
            Pageredirect.setRedirect(true);
            
        }
        return Pageredirect;
        
        
    }
    
    public PageReference changeContractUpload(){
        contractSelected.ASI_CRM_CN_Contract_Upload__c = !contractSelected.ASI_CRM_CN_Contract_Upload__c;
        update contractSelected;
        return redirectToPage('/apex/ASI_CRM_CN_MainContractPage',PageId);
    }
    public PageReference changeBusinessLicense(){
        //contractSelected.ASI_CRM_CN_Contract_Upload__c = !contractSelected.ASI_CRM_CN_Contract_Upload__c;
        if(contractSelected.ASI_CRM_CN_Business_License__c == 'Unqualified'){
            contractSelected.ASI_CRM_CN_Business_License__c = 'Qualified';
        }
        else{
            contractSelected.ASI_CRM_CN_Business_License__c = 'Unqualified';
        }
        update contractSelected;
        return redirectToPage('/apex/ASI_CRM_CN_MainContractPage',PageId);
    }
    
    public PageReference UpdateContractDetailRecord(){
        checkContractTotalForPOMod();
        
        List<ASI_CRM_Contract_Cost__c> LCostUpdate = new List<ASI_CRM_Contract_Cost__c>();
        if(LVariableCost != null && LVariableCost.size() > 0)
            LCostUpdate.addAll(LVariableCost);
        if(LFixCost != null && LFixCost.size() > 0)
        for(ASI_CRM_Contract_Cost__c c : LFixCost){
            if(c.ASI_CRM_CN_Sequence__c != 99999999){
                
                LCostUpdate.add(c);
            } 
        }
        if(LCostUpdate != null && LCostUpdate.size() > 0){
            
            // Ben 2015-06-24 Start
          for(ASI_CRM_Contract_Cost__c obj : LCostUpdate){
                
                //20160610 Ben @ Elufa
                if(festivalMap.containsKey(obj.id) && festivalMap.get(obj.id) && ContractSelected.ASI_CRM_New_FY_PO__c)
                  obj.ASI_CRM_Other_Est__c = ( obj.ASI_CRM_CN_Estimate_Amount__c != NULL ? obj.ASI_CRM_CN_Estimate_Amount__c : 0 )  - ( obj.ASI_CRM_MAF_Est__c != NULL ? obj.ASI_CRM_MAF_Est__c : 0 )  - ( obj.ASI_CRM_CNY_Est__c != NULL ? obj.ASI_CRM_CNY_Est__c : 0 );
                //20160610 End
                
                //20160722 Ben @ Elufa
                if( (obj.ASI_CRM_CN_Estimate_Amount__c == NULL || obj.ASI_CRM_CN_Estimate_Amount__c >= 0) && obj.ASI_CRM_Other_Est__c < 0 && ContractSelected.ASI_CRM_New_FY_PO__c){
                    
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'其他(预估)不能小于0'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Others(Est.) cannot be negative'));
                    return null;
                }
                //20160722 End
                
                //20160826 Ben @ Elufa
                if( (obj.ASI_CRM_CN_Estimate_Amount__c == NULL || obj.ASI_CRM_CN_Estimate_Amount__c >= 0) && obj.ASI_CRM_CNY_Est__c < 0 && ContractSelected.ASI_CRM_New_FY_PO__c){
                    
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'春节(预估)不能小于0'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'CNY(Est.) cannot be negative'));
                    return null;
                }
                //20160826 End
                
                //20160826 Ben @ Elufa
                if( (obj.ASI_CRM_CN_Estimate_Amount__c == NULL || obj.ASI_CRM_CN_Estimate_Amount__c >= 0) && obj.ASI_CRM_MAF_Est__c < 0 && ContractSelected.ASI_CRM_New_FY_PO__c){
                    
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'中秋(预估)不能小于0'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'MAF(Est.) cannot be negative'));
                    return null;
                }
                //20160826 End
                
                if(obj.ASI_CRM_CN_Estimate_Amount__c != null)
                totalEstimate += obj.ASI_CRM_CN_Estimate_Amount__c;
          }
      // Ben 2015-06-24 End
            
          update LCostUpdate;
        }
        
        //=============================================================================
        
        //2014-07-29 Stella Sing Add new line with subbrand '999' when Save
        if(ContractSelected.ASI_CRM_CN_PO_Modification__c == true){
            decimal BRSFDiff = 0;
            set<integer> BRSFitemSet = new set<integer>();
            try{
                id subbrand999 = [SELECT id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true 
                AND ASI_MFM_Sub_brand_Code__c = '999'
                 AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') 
                 LIMIT 1].id;
                system.debug('subbrand999: ' + subbrand999 );
                //Find existing summary item & Sum up total Estimate BRSF
                for (integer i : BRSF_Item_Map.keySet()){
                    if ( BRSF_Item_Map.get(i).ASI_CRM_CN_Sub_Brand__c == subbrand999){
                        BRSFitemSet.add(i);
                        Del_BRSF_Item.add(BRSF_Item_Map.get(i));
                    }else{
                    //Calculate total Estimated BRSF & Expected BRSF difference
                    if(BRSF_Item_Map.get(i).ASI_CRM_CN_Est_Monthly_Qty__c != null && BRSF_Item_Map.get(i).ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null)
                        BRSFDiff += BRSF_Item_Map.get(i).ASI_CRM_CN_Est_Monthly_Qty__c * BRSF_Item_Map.get(i).ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                    }
                }
                //Remove existing summary item
                if (BRSFitemSet.size() > 0){
                    for (integer j : BRSFitemSet){
                        BRSF_Item_Map.remove(j);
                    }
                }
                system.debug('BRSF_Item_Map: ' + BRSF_Item_Map);
                
                List<ASI_CRM_Contract_Cost_Setting__c> LSetting = [Select name, id, ASI_CRM_CN_Activity_Code__c 
                    from ASI_CRM_Contract_Cost_Setting__c 
                    where ASI_CRM_CN_BRSF_Activity_Code_Default__c = true and ASI_CRM_CN_Promotion_Type__c = :contractSelected.ASI_TH_CRM_Promotion_Type__c];
                
                
                //Add new summary item if have differences
                if (ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c != null){
                    if (ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c - BRSFDiff != 0){
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c pom_newbrsf = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                        pom_newbrsf.ASI_CRM_CN_Sub_Brand__c = subbrand999;
                        pom_newbrsf.ASI_CRM_CN_Est_Monthly_Qty__c = 1;
                        pom_newbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 0;
                        pom_newbrsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
                        //20151201 Ben @ Elufa System
                        system.debug('check111 ' + ((ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c - BRSFDiff)/ContractSelected.ASI_CRM_CN_No_of_Months__c));
                        pom_newbrsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = ((ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c - BRSFDiff)/ContractSelected.ASI_CRM_CN_No_of_Months__c).setScale(2, System.RoundingMode.CEILING);//(ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c - BRSFDiff)/ContractSelected.ASI_CRM_CN_No_of_Months__c
                        //20151201 End
                        //Added by William Yang (Introv) 20150327 to fix rounding issue
                       // pom_newbrsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = pom_newbrsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c.setScale(2).round(System.RoundingMode.HALF_UP);
                        
                        if(LSetting.size()>0){
                            pom_newbrsf.ASI_CRM_CN_Activity_Code__c = LSetting[0].ASI_CRM_CN_Activity_Code__c;
                        }
                        BRSF_Item_Map.put(indexBRSF++, pom_newbrsf); 
                    }
                }
            }catch(exception e){

            }            
        }
        //------------------------------------------------------------
        
        //---- delete BRSF Line Items - by leo (start) ----
        
        if(Del_BRSF_Item != null && Del_BRSF_Item.size()>0)
        {
            List <ASI_CRM_CN_Contract_BRSF_Line_Item__c> Del_BRSF_Item_Temp = new List <ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c b : Del_BRSF_Item)
            {
                if(b.Id != null)
                    Del_BRSF_Item_Temp.add(b);
            }

            if(Del_BRSF_Item_Temp != null && Del_BRSF_Item_Temp.size() > 0)
            {
                delete Del_BRSF_Item_Temp;
                Del_BRSF_Item.clear();
            }
        }
        //---- delete BRSF Line Items - by leo (end) ----
        
        
        //---- save BRSF Line Items - by leo (start) ----
        Save_BRSF_Item = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for (integer i : BRSF_Item_Map.keySet())
        {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf = BRSF_Item_Map.get(i);
            if(brsf.ASI_CRM_CN_Contract__c == null)
            {
                brsf.ASI_CRM_CN_Contract__c = ContractSelected.Id;
                brsf.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
            }
            
            // Added by Michael Yip (Introv) 12Jul2014 to convert null btl incentive to zero
            if(brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null)
                brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0;
            if(brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null)
                brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
            // Added by Michael Yip (Introv) 12Jul2014 to convert null btl incentive to zero
            
            System.Debug('ASI_CRM_CN_Est_Monthly_Qty__c: ' + brsf.ASI_CRM_CN_Est_Monthly_Qty__c);
            System.Debug('ASI_CRM_CN_Est_BRSF_Per_Bottle__c: ' + brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);
            System.Debug('ASI_CRM_CN_No_of_Months__c: ' + ContractSelected.ASI_CRM_CN_No_of_Months__c);
            
            if(brsf.ASI_CRM_CN_Est_Monthly_Qty__c != null && brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null)
                brsf.ASI_CRM_CN_Est_Total_Dummy__c = brsf.ASI_CRM_CN_Est_Monthly_Qty__c * brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                
            System.Debug('ASI_CRM_CN_Est_Total_Dummy__c: ' + brsf.ASI_CRM_CN_Est_Total_Dummy__c);


            if(brsf.ASI_CRM_CN_Contract_Monthly_Qty__c != null && brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null)
                brsf.ASI_CRM_CN_Contract_Total_Dummy__c = brsf.ASI_CRM_CN_Contract_Monthly_Qty__c * brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
            
            Save_BRSF_Item.add(brsf);
        }
        
        // Ben 2015-06-24 Start
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c obj : Save_BRSF_Item){
            if(obj.ASI_CRM_CN_Est_Total_Dummy__c != null)
              totalEstimate += obj.ASI_CRM_CN_Est_Total_Dummy__c;
        }
    // Ben 2015-06-24 End
        
        if(Save_BRSF_Item != null && Save_BRSF_Item.size() > 0)
        {
            try{        
                upsert Save_BRSF_Item;
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
                return null;
            }
        }
        //---- save BRSF Line Items - by leo (end) ----

        //============================================================================
        
        
        //---- delete Covered Outlet Line Items - by leo (start) ----        
        if(Del_CoveredOutlet_Item != null && Del_CoveredOutlet_Item.size()>0)
        {
            List <ASI_CRM_CN_Covered_Outlet__c> Del_CoveredOutlet_Item_Temp = new List <ASI_CRM_CN_Covered_Outlet__c>();

            for (ASI_CRM_CN_Covered_Outlet__c b : Del_CoveredOutlet_Item)
            {
                System.Debug('delete item id: ' + b.Id);
                System.Debug('delete item: ' + b);
                if(b.Id != null)
                {
                    System.Debug('(add to list) delete item id: ' + b.Id);
                    Del_CoveredOutlet_Item_Temp.add(b);
                }
            }

            if(Del_CoveredOutlet_Item_Temp != null && Del_CoveredOutlet_Item_Temp.size() > 0)
            {
                delete Del_CoveredOutlet_Item_Temp;
                Del_CoveredOutlet_Item.clear();
            }
        }
        //---- delete Covered Outlet Line Items - by leo (end) ----

        //---- save Covered Outlet Line Items - by leo (start) ----
        //---- updated by Stella Li      
        Save_CoveredOutlet_Item = new List<ASI_CRM_CN_Covered_Outlet__c>();
        Saved_CoveredOutlet_Temp = new List<ASI_CRM_CN_Covered_Outlet__c>();
         
        for (integer i : CoveredOutlet_Item_Map.keySet())
        {
                ASI_CRM_CN_Covered_Outlet__c outlet = CoveredOutlet_Item_Map.get(i);
                if(outlet.ASI_CRM_CN_Contract__c == null){
                    outlet.ASI_CRM_CN_Contract__c = ContractSelected.Id;
                    outlet.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet');
                }
                if(outlet != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true && outlet.ASI_CRM_CN_Outlet__c != null){
                    Save_CoveredOutlet_Item.add(outlet);            
                }          
                else if (outlet.id != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == false) { 
                    Saved_CoveredOutlet_Temp.add(outlet);            
                }
            
        }        

        if(Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0)
        {
            //20161028 Elufa
            
            Set<Id> effectiveChildsSet = new Set<Id>();
            Set<Id> invalidChilds = new Set<Id>();
            
            Boolean isAllCustomer = False;
            
            if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS'){
                
                for(ASI_CRM_Effective_supplier__c obj : [SELECT id
                                                         , ASI_CRM_Supplier__c
                                                         , ASI_CRM_Account__c
                                                         FROM ASI_CRM_Effective_supplier__c
                                                         WHERE ASI_CRM_Supplier__c = : ContractSelected.ASI_CRM_CN_Outlet_WS__c
                                                        ]){
                                                            effectiveChildsSet.add(obj.ASI_CRM_Account__c);
                                                        }
                
                /*for(ASI_CRM_CN_Covered_Outlet__c obj : Save_CoveredOutlet_Item) {
                    
                    //20161028 Elufa
                    if(!effectiveChildsSet.contains(obj.ASI_CRM_CN_Outlet__c)){
                        invalidChilds.add(obj.ASI_CRM_CN_Outlet__c);
                    }
                    //20161028 End
                }*/
            }else if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN'){//20170128 Elufa add validation for outlet
                
                isAllCustomer = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c != Null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name.toLowerCase().contains('all customer');
                
                if(!isAllCustomer){
                    for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE ASI_CRM_CN_Parent_Outlet__c = : ContractSelected.ASI_CRM_CN_Outlet_WS__c
                                                                 ]){
                                                                     effectiveChildsSet.add(obj.id);
                                                                 }
                    
                    for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE ASI_CRM_CN_Parent_Outlet__c IN : effectiveChildsSet
                                                                 ]){
                                                                     effectiveChildsSet.add(obj.id);
                                                                 }
                }
            }
            
            //20161028 End
            
            // Ben 2015-06-24 Start
            double totalSuggestedAmount = 0;
            for(ASI_CRM_CN_Covered_Outlet__c obj : Save_CoveredOutlet_Item) {
                
                if(obj.ASI_CRM_CN_Suggested_Amount__c != null){
                  totalSuggestedAmount += obj.ASI_CRM_CN_Suggested_Amount__c;
                }
                
                //20161028 Elufa
                if(!effectiveChildsSet.contains(obj.ASI_CRM_CN_Outlet__c)){
                    invalidChilds.add(obj.ASI_CRM_CN_Outlet__c);
                }
                //20161028 End
            }
            
            //20161028 Elufa
            if(invalidChilds.size() > 0 && !isAllCustomer){
                
                String errorMsg = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? 'This wholesaler is not effective supplier of below outlets and thus they can\'t be cover outlet : ' : 'This Outlet is not effective parent of below outlets and thus they can\'t be cover outlet : ';
                String errorMsgCN = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? '该经销商并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ' : '该母店家并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ';
                
                for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id
                                                              , Name
                                                              FROM ASI_CRM_AccountsAdditionalField__c
                                                              WHERE Id IN : invalidChilds
                                                             ]){
                                                                 errorMsg += obj.Name + ',';
                                                                 errorMsgCN += obj.Name + ',';
                                                             }
                
                errorMsg += ' If it is necessary to be covered, Please contact Admin';
                errorMsgCN += ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? ' 若此覆盖店家与供货商暂无展开合作，但确认需加入，请和Admin联系' : ' 如确认需加入，请和Admin联系';
                
                
                if(USerInfo.getLanguage()=='zh_CN')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsgCN));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                
                Return Null;
            }
            //20161028 End
            
            Map<String, Boolean> mapSpecialPromotion = new Map<String, Boolean>();
        
          if(LSpecicalPromotionType != null && LSpecicalPromotionType.size() > 0){
              for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType)
                  mapSpecialPromotion.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Validate_TotalSuggestedAmount__c);
          }
            
            if(mapSpecialPromotion.containsKey(ContractSelected.ASI_TH_CRM_Promotion_Type__c) && mapSpecialPromotion.get(ContractSelected.ASI_TH_CRM_Promotion_Type__c) && totalEstimate != totalSuggestedAmount){
                Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Total suggested amount should equal to total PO est. amount.'));
                return null;
            }
            // Ben 2015-06-24 End
                
            try{        
                upsert Save_CoveredOutlet_Item;
            }   catch (DmlException ex) {
                system.debug('Duplication');
                ApexPages.addMessages(ex);
                return null;
            }
        }   
        if  (Saved_CoveredOutlet_Temp!= null && Saved_CoveredOutlet_Temp.size() > 0)
        {
            try{    
                delete Saved_CoveredOutlet_Temp;    
            }   catch (DmlException ex) {
                system.debug('Duplication');
                ApexPages.addMessages(ex);
                return null;
            }
        }   
        
        //---- save Covered Outlet Line Items - by leo (end) ----
        
        //=============================================================================
        update ContractSelected;
        
        system.debug('Go to Main Page');
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_MainContractPage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true);
        return redirect;
    }
    
    public PageReference redirectToPage(String pagePath, String pid){
        paymentError = false;
        PageReference redirect = new PageReference(pagePath); 
        redirect.getParameters().put('id',pid); 
        redirect.setRedirect(true);    
        return redirect;
    }
    
    public PageReference GoURL() 
    {
        /*PageReference redirect = new PageReference('/apex/ASI_CRM_CN_MainContractPage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
    
        return redirect;*/
        return redirectToPage('/apex/ASI_CRM_CN_MainContractPage',PageId);
    }
    
    public boolean checkLaterThenThisFY(Date inputDate, Date CheckAgainstDate){
        Boolean result = true;
        if(contractSelected.ASI_CRM_CN_PO_Version__c == null || contractSelected.ASI_CRM_CN_PO_Version__c == '' || contractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
            Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);
            if(CheckAgainstDate.month() < orgFiscalMonth ){    //still in last fiscal year
                orgFiscalYear = orgFiscalYear.addYears(-1);
            }
            System.debug(inputDate);
            System.debug(orgFiscalYear);
            if(inputDate < orgFiscalYear){
                result = false;
            }
        }
        return result;
    }
    
    
    public PageReference GoPayment() 
    {
        /*lokman 2/7/2014 SIT issue 201 start*/
        Map <String, String> labelAPIName = new Map <String, String> ();
        
        Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.fields.getMap();
        for (Schema.SObjectField field : fieldsMap.values())
        {
            labelAPIName.put( field.getDescribe().getName(),field.getDescribe().getLabel());
        }
        
        String payment_no = labelAPIName.get('Name');
            
        //  payment with same contract
        //Updated by William Yang (Introv) 20141103 to reduce no. of SOQL
        /*
        List<ASI_TH_CRM_PaymentRequest__c> Payment_list=[Select id,Name,ASI_TH_CRM_Contract__c,ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Status__c From ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__c =:Pageid And ASI_TH_CRM_Status__c!='Draft'];
        */
            String error_Msg = Label.ASI_CRM_CN_ErrorMsg_MakePayment; 
            //for(ASI_TH_CRM_PaymentRequest__c paymentrequest : Payment_list){
            
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest:ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {    
                if(paymentrequest.ASI_CRM_CN_Last_Payment__c==true && paymentrequest.ASI_TH_CRM_Status__c!='Draft'){
                    /*add msg */
                    error_Msg+=' '+payment_no+paymentrequest.Name;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error_Msg));
                       
                    return null;
                }
               
            }
             
        /*lokman 2/7/2014 SIT issue 201 end*/ 
    
        if(BypassCheckContractUpload)
        {
            PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditPayment_Header_Page'); 
            redirect.getParameters().put('contractid',PageId);
            redirect.setRedirect(true); 
        
            return redirect;
        }
        else
        {
            if(!ContractSelected.ASI_CRM_CN_Contract_Upload__c){
                PaymentError = true;
                return null;
            }
            else
            {
                PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditPayment_Header_Page'); 
                redirect.getParameters().put('contractid',PageId);
                //redirect.getParameters().put('retURL',retURL); 
                redirect.setRedirect(true); 
            
                return redirect;
            }
        }
    }
    
    public PageReference GoEdit() 
    {
        /*paymentError = false;
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditContractPage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
    
        return redirect;*/
        return redirectToPage('/apex/ASI_CRM_CN_EditContractPage',PageId);
    }
    
    public PageReference GoEditDetails() 
    {
        /*paymentError = false;
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditContractDetailPage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
    
        return redirect;*/
        return redirectToPage('/apex/ASI_CRM_CN_EditContractDetailPage',PageId);
    }
    
    public PageReference GoEditOutlet() 
    {
        /*paymentError = false;
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditContractOutletPage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
    
        return redirect;*/
        return redirectToPage('/apex/ASI_CRM_CN_EditContractOutletPage',PageId);
    }
    
    public PageReference saveRedirect(){
        /*paymentError = false;
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_MainContractPage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true);    
        return redirect;*/
        return redirectToPage('/apex/ASI_CRM_CN_MainContractPage',PageId);
    }
    
    public PageReference submitApproval(){
    
        //Updated by William Yang (Introv) 20141104 for #160
        Boolean validByACCode = true;
        if(paymentRequestSummary != null && paymentRequestSummary.size() >0)
            for (ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary p:paymentRequestSummary)
                if( (p.POEstimateAmt>=0 && p.POEstimateAmt < p.PaidAmt) || (p.POEstimateAmt<0 && p.POEstimateAmt > p.PaidAmt))
                {
                    validByACCode = false;
                    break;
                }
        if (!validByACCode){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_ContractAmountByACCheckErrMsg));
            return null;
        }
        
        if ( ( (contractSelected.ASI_CRM_CN_Total_Contract_Amount__c >= 0 && contractSelected.ASI_CRM_CN_Total_Contract_Amount__c < (Total_Payments_Amount - 0.1)) || 
                (contractSelected.ASI_CRM_CN_Total_Contract_Amount__c <0 && contractSelected.ASI_CRM_CN_Total_Contract_Amount__c > (Total_Payments_Amount - 0.1))) 
            && contractSelected.ASI_CRM_CN_PO_Version__c != '0.0'){//20160719 Ben @ Elufa added  && contractSelected.ASI_CRM_CN_PO_Version__c != '0.0'
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_ContractTotalAmountCheckErrMsg));
            return null;
        }
        
        //20170327 Elufa
        if(contractSelected.ASI_CRM_CN_PO_Start_Date__c != Null && getFiscalYearStart(date.today()) > getFiscalYearStart(contractSelected.ASI_CRM_CN_PO_Start_Date__c) && contractSelected.ASI_CRM_CN_Last_Rejected_Date__c == Null && contractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
            
            if(USerInfo.getLanguage()=='zh_CN')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'您不能够提交上财政年度的合同'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not allowed to submit last fiscal year PO'));
            return null;
        }
        //20170327 End
        
        //contractSelected.ASI_CRM_CN_Effective_Date__c=Date.today();
        /* Edited by Michael Yip (Introv) 11Sep2014 for effective date logic
         *   1.      For contract start date in current year and past years,
         *   The Contract Effective will be based on "Submit for approval" date 's Fiscal Year Start. (Not created date)
         *   For PO Modification, the effective date will also based on new submit for approval date 's Fiscal Year Start.
         *   2.      For the next year and future years,
         *   The Contract Effective will be based on contract start date's Fiscal Year Start.
         *   For PO Modification, the effective date will also based on contract start date's Fiscal Year Start.
         */
        if(contractSelected.ASI_CRM_CN_PO_Start_Date__c != null){
            System.debug(contractSelected.ASI_CRM_CN_PO_Start_Date__c +'/'+getFiscalYearStart(system.today()).addYears(1));
            if(contractSelected.ASI_CRM_CN_PO_Start_Date__c <getFiscalYearStart(system.today()).addYears(1)){ // Case 1
                contractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
            }
            else{
                contractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(contractSelected.ASI_CRM_CN_PO_Start_Date__c);
            }
        }
        else{
            contractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
        }
         
        update contractSelected;
        //Ben @ Elufa 20150924
        //Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        //req.setObjectId(PageId);
        //Approval.ProcessResult result = Approval.process(req);
        //End
        //return redirectToPage('/p/process/Submit',PageId);
        return new PageReference('/apex/ASI_CN_SubmitApprovalPage?id=' + PageId);//redirectToPage('/apex/ASI_CRM_CN_MainContractPage',PageId);
    }
    
    // Added by Michael Yip (Introv) 11Sep2014 for effective date logic
    // Method to get the fiscal year start date of input date
    public date getFiscalYearStart(Date inputDate){        
        //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Date fiscalYearStart;
        if(inputDate != null){            
            fiscalYearStart = Date.newinstance(inputDate.year(), orgFiscalMonth, 1);
            if(inputDate.month() < orgFiscalMonth && inputDate.year() == inputDate.year())
                fiscalYearStart = fiscalYearStart.addYears(-1);
        }
        System.debug(inputDate + '/' + fiscalYearStart);
        return fiscalYearStart;
    }
        
    public void GroupContractChange(){
         if(ContractSelected.ASI_CRM_CN_Group_Contract__c!=null){
             System.debug(ContractSelected.ASI_CRM_CN_Group_Contract__c);
             ASI_TH_CRM_Contract__c GroupContract = [select ASI_CRM_CN_Data_Source__c, ASI_CRM_CN_Festival_Season__c from ASI_TH_CRM_Contract__c where id =:ContractSelected.ASI_CRM_CN_Group_Contract__c];
             if(GroupContract != null){
                 System.debug(GroupContract);
                 ContractSelected.ASI_CRM_CN_Data_Source__c = GroupContract.ASI_CRM_CN_Data_Source__c;
                 ContractSelected.ASI_CRM_CN_Festival_Season__c = GroupContract.ASI_CRM_CN_Festival_Season__c;
             }
         }
    }

    //****** BRSF Line Item - functions - (start) ******
    public void AddNew_BRSF(){
        ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item'));
        List<ASI_CRM_Contract_Cost_Setting__c> LSetting = [Select name, id, ASI_CRM_CN_Activity_Code__c 
            from ASI_CRM_Contract_Cost_Setting__c 
            where ASI_CRM_CN_BRSF_Activity_Code_Default__c = true and ASI_CRM_CN_Promotion_Type__c = :contractSelected.ASI_TH_CRM_Promotion_Type__c];
        if(LSetting.size()>0){
            brsf.ASI_CRM_CN_Activity_Code__c = LSetting[0].ASI_CRM_CN_Activity_Code__c;
        }
        BRSF_Item_Map.put(indexBRSF++, brsf);
        for (Integer i:BRSF_Item_Map.keySet()){
             if(BRSF_Item_Map.get(i).ASI_CRM_CN_Est_Monthly_Qty__c != null && BRSF_Item_Map.get(i).ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null)
                BRSF_Item_Map.get(i).ASI_CRM_CN_Est_Total_Dummy__c = BRSF_Item_Map.get(i).ASI_CRM_CN_Est_Monthly_Qty__c * BRSF_Item_Map.get(i).ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
             if(BRSF_Item_Map.get(i).ASI_CRM_CN_Contract_Monthly_Qty__c != null && BRSF_Item_Map.get(i).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null)
                BRSF_Item_Map.get(i).ASI_CRM_CN_Contract_Total_Dummy__c = BRSF_Item_Map.get(i).ASI_CRM_CN_Contract_Monthly_Qty__c * BRSF_Item_Map.get(i).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
        }
    }

    public void Clone_BRSF(){
        ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf = BRSF_Item_Map.get(rowidBRSF);
        ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf_Clone = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();

        brsf_Clone.ASI_CRM_CN_Sub_Brand__c = brsf.ASI_CRM_CN_Sub_Brand__c;
        brsf_Clone.ASI_CRM_CN_Est_Monthly_Qty__c = brsf.ASI_CRM_CN_Est_Monthly_Qty__c;
        brsf_Clone.ASI_CRM_CN_Contract_Monthly_Qty__c = brsf.ASI_CRM_CN_Contract_Monthly_Qty__c;
        brsf_Clone.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
        brsf_Clone.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
        brsf_Clone.ASI_CRM_CN_Est_Total_Dummy__c = brsf.ASI_CRM_CN_Est_Total_Dummy__c;
        brsf_Clone.ASI_CRM_CN_Contract_Total_Dummy__c = brsf.ASI_CRM_CN_Contract_Total_Dummy__c;
        brsf_Clone.ASI_CRM_CN_Activity_Code__c = brsf.ASI_CRM_CN_Activity_Code__c;
        brsf_Clone.ASI_CRM_CN_Contract__c = ContractSelected.Id;
        brsf_Clone.recordtypeid = Global_RecordTypeCache.getRTid('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');

        BRSF_Item_Map.put(indexBRSF++, brsf_Clone);
    }

    public void RemoveRow_BRSF(){   
        Del_BRSF_Item.add(BRSF_Item_Map.get(rowidBRSF));
        BRSF_Item_Map.remove(rowidBRSF);
        
    }    
    
    
    
    public void calcBRSF_EstTotal(){        
        if(BRSF_Item_Map!=null && BRSF_Item_Map.get(rowidBRSF)!=null && BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Est_Monthly_Qty__c != null && BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null)
            BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Est_Total_Dummy__c = BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Est_Monthly_Qty__c * BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
    }

    public void calcBRSF_ContractTotal(){        
        if(BRSF_Item_Map!=null && BRSF_Item_Map.get(rowidBRSF)!=null && BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Contract_Monthly_Qty__c != null && BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null)
            BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Contract_Total_Dummy__c = BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Contract_Monthly_Qty__c * BRSF_Item_Map.get(rowidBRSF).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
    }
    //****** BRSF Line Item - functions - (end) ******
    
    //##################################
    
    //****** Covered Outlet Line Item - functions - (start) ******
    public void AddNew_CoveredOutlet(){
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        CoveredOutlet_Item_Map.put(indexCoveredOutlet++, outlet );
        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
        
       
    }
    
    // Stella Li =====StartLine=====
    public void Addall_CoveredOutlet(){
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        Selecteddd = new Set<id>();
        Set<id> SChildCustomersIds = new Set<id>();
        
        //Updated by William Yang(Introv) 20141103 to reduce no. of SOQL
        //ASI_TH_CRM_Contract__c contract = [SELECT ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName FROM ASI_TH_CRM_Contract__c where id = :PageId];
        String recordType = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName;
        Integer limitRecord = 0;
    
        if(recordType == 'ASI_CRM_Outlet_CN' || test.isRunningTest()){
            /*
            List <ASI_CRM_CN_Covered_Outlet__c> Selected = [Select ASI_CRM_CN_Outlet__r.Id From ASI_CRM_CN_Covered_Outlet__c Where ASI_CRM_CN_Contract__c=: PageId];
            */
            List <ASI_CRM_CN_Covered_Outlet__c> Selected = ContractOutletList;
            for ( ASI_CRM_CN_Covered_Outlet__c s:Selected ){
                 Selecteddd.add(s.ASI_CRM_CN_Outlet__r.Id);
            }
   
            List<ASI_CRM_AccountsAdditionalField__c> childCustomers = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c AND Id NOT IN :Selecteddd  limit 200];
    
            if(childCustomers!= null && childCustomers.size() > 0) {          
                for(ASI_CRM_AccountsAdditionalField__c customer : childCustomers){ 
                    if(limitRecord < 200){                 
                        outlet = new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Outlet__c = customer.id);
                        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
                        SChildCustomersIds.add(customer.Id);
                        CoveredOutlet_Item_Map.put(indexCoveredOutlet++,outlet);
                        limitRecord++;  
                    }  
                    else
                        break;
                }
            }  
                      
            if(SChildCustomersIds != null && SChildCustomersIds.size() > 0 && limitRecord < 200){
                List<ASI_CRM_AccountsAdditionalField__c> childChildCustomers = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c IN :SChildCustomersIds limit 200];        
                if(childChildCustomers != null && childChildCustomers.size() > 0 ) {                                  
                    for(ASI_CRM_AccountsAdditionalField__c childCustomer : childChildCustomers){  
                        if(limitRecord < 200){               
                            outlet = new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Outlet__c = childcustomer.id);
                            outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
                            CoveredOutlet_Item_Map.put(indexCoveredOutlet++,outlet);
                            limitRecord++;  
                        }
                        else
                            break;
                    }
                }
            }
        }
    }
            

   // Stella Li ====EndLine=====
 
    public void Clone_CoveredOutlet(){
        ASI_CRM_CN_Covered_Outlet__c outlet = CoveredOutlet_Item_Map.get(rowidCoveredOutlet);
        ASI_CRM_CN_Covered_Outlet__c outlet_Clone = new ASI_CRM_CN_Covered_Outlet__c();

        outlet_Clone.ASI_CRM_CN_Outlet__c = outlet.ASI_CRM_CN_Outlet__c;
        outlet_Clone.ASI_CRM_CN_Contract__c = ContractSelected.Id;
        
        
       CoveredOutlet_Item_Map.put(indexCoveredOutlet++, outlet_Clone);
    }

    public void RemoveRow_CoveredOutlet(){   
        Del_CoveredOutlet_Item.add(CoveredOutlet_Item_Map.get(rowidCoveredOutlet));
        CoveredOutlet_Item_Map.remove(rowidCoveredOutlet);
        
    }
    //****** Covered Outlet Line Item - functions - (end) ******
    
    //-------- Added by Stella Sing, Button link to ASI_CRM_CN_ContractProfitShuttlePDF_Page ----------//
    public pageReference ContractShuttle(){
        string url = '/apex/ASI_CRM_CN_ContractProfitShuttlePDF_Page?id=' + PageId;
        pageReference newPage = new pageReference(url);
        newPage.setRedirect(true);
        return newPage;
    }
    //------- Button Link to ASI_CRM_CN_ContractProfitShuttlePDF_Page End ------------- //
    
   

    public void retrieveOutletPicklist(){
        ouletPicklist = new List<SelectOption>();
        
        //Updated by William Yang(Introv) 20141103 to reduce no. of SOQL
        //ASI_TH_CRM_Contract__c contract = [SELECT ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName FROM ASI_TH_CRM_Contract__c where id = :PageId];
        String recordType = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName;

        if(recordType == 'ASI_CRM_Outlet_CN'){
            List<ASI_CRM_AccountsAdditionalField__c> childCustomers = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c];
            //----- edited by leo @20140704 (start) -----
            Set<id> SChildCustomersIds = new Set<id>();
            for(ASI_CRM_AccountsAdditionalField__c customer : childCustomers){
                ouletPicklist.add(new SelectOption(customer.Id, customer.name ));

                SChildCustomersIds.add(customer.Id);
            }

            if(SChildCustomersIds != null && SChildCustomersIds.size() > 0)
            {
                List<ASI_CRM_AccountsAdditionalField__c> childChildCustomers = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c IN :SChildCustomersIds];

                if(childChildCustomers != null && childChildCustomers.size() > 0) {
                    for(ASI_CRM_AccountsAdditionalField__c childCustomer : childChildCustomers){
                        ouletPicklist.add(new SelectOption(childCustomer.Id, childCustomer.name ));
                    }
                }
            }
            //----- edited by leo @20140704 (end) -----
        }else if (recordType == 'ASI_CRM_CN_WS'){
            List<ASI_CRM_Effective_supplier__c> suppliers = [SELECT ASI_CRM_Account__r.Id, ASI_CRM_Account__r.Name FROM ASI_CRM_Effective_supplier__c WHERE ASI_CRM_Supplier__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c AND ASI_CRM_Last_tran_date__c > LAST_YEAR];
            
            for(ASI_CRM_Effective_supplier__c supplier : suppliers){
                ouletPicklist.add(new SelectOption(supplier.ASI_CRM_Account__r.Id, supplier.ASI_CRM_Account__r.Name ));
            } 
        }
      
    }

    public void genGroupContractPicklist(){
        System.debug(ContractSelected.ASI_CRM_CN_PO_Start_Date__c);
        System.debug(ContractSelected.ASI_CRM_CN_PO_End_Date__c);
        System.debug(ContractSelected.ASI_CRM_CN_Outlet_WS__c);

        List<SelectOption> options = new List<SelectOption>();
        for (ASI_TH_CRM_Contract__c groupPO : ASI_CRM_CN_OffContractTriggerClass.getAvailableGroupPO(ContractSelected)) {
            System.debug('groupPO Id ' + groupPO.Id);
            options.add(new SelectOption(groupPO.Id, groupPO.ASI_CRM_CN_PO_No__c));

        }
        GroupContractOptionType = options;
    }

    public void genPromotionGroupContractPicklist(){       
        List<SelectOption> options = new List<SelectOption>();
        for (ASI_TH_CRM_Contract__c groupPO : ASI_CRM_CN_PromotionContractUtilClass.getAvailableGroupPO(ContractSelected)) {
            System.debug('groupPO Id ' + groupPO.Id);
            options.add(new SelectOption(groupPO.Id, groupPO.ASI_CRM_CN_PO_No__c));

        }
        GroupContractOptionType = options;
    }

    //****** Validation: Contract Est. Total vs Remaining Payment Amount for PO Modification - (start) ******
    public Boolean checkContractTotalForPOMod(){
        if(contractSelected.ASI_CRM_CN_PO_Modification__c != null)
        {
            if(USerInfo.getLanguage()=='zh_CN')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'PO修改'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'PO Modification'));
            return null;
        }
        
        return false;
    }
    
    //20160606 Ben @ Elufa
    Public void setCustomerChannel(){
        
        if(ContractSelected != NULL && ContractSelected.ASI_CRM_CN_Outlet_WS__c != NULL){
            
            ContractSelected.ASI_CRM_PO_Channel__c = NULL;
            ContractSelected.ASI_CRM_PO_Province__c = NULL;
            
            List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_CN_NewChannel__c
                                                                                                                 , ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c
                                                                                                                 , recordType.DeveloperName,ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c //add by laputa 
                                                                                                                 , ASI_CRM_CN_Channel_CN__c
                                                                                                                 , ASI_CRM_CN_NewChannel__r.Name
                                                                                                                 , ASI_CRM_National_Group__c,ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Auto_link_to_PO_Open__c
                                                                                                                 , ASI_CRM_CN_KA_Account_Chain__c, ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Inactive__c
                                                                                                                 , ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_National_Group__c
                                                                                                                 , ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Apply_National_Approval__c
                                                                                                                 FROM ASI_CRM_AccountsAdditionalField__c
                                                                                                                 WHERE id = : ContractSelected.ASI_CRM_CN_Outlet_WS__c
                                                                                                                 //AND (NOT ASI_CRM_CN_Channel_CN__c LIKE 'All Customer%')
                                                                                                                 //AND (NOT ASI_CRM_CN_NewChannel__r.Name LIKE 'All Customer%')
                                                                                                                ]);
            //20160713 Ben @ Elufa
            if(tmpCustomer.size() > 0 && tmpCustomer[0].recordType.DeveloperName.contains('ASI_CRM_Outlet_CN')){
                if(tmpCustomer[0].ASI_CRM_CN_NewChannel__c != NULL && !tmpCustomer[0].ASI_CRM_CN_NewChannel__r.Name.contains('All Customer')){
                    
                    needChannelnProvince = FALSE;
                    ContractSelected.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                    ContractSelected.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                    ContractSelected.ASI_CRM_PO_City__c = tmpCustomer[0].ASI_CRM_CN_CCity__c;

                }else if(tmpCustomer[0].ASI_CRM_CN_NewChannel__c == NULL && !tmpCustomer[0].ASI_CRM_CN_Channel_CN__c.contains('All Customer')){
                    
                    needChannelnProvince = FALSE;
                    ContractSelected.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                    ContractSelected.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                    ContractSelected.ASI_CRM_PO_City__c = tmpCustomer[0].ASI_CRM_CN_CCity__c;

                }else{
                    needChannelnProvince = TRUE;
                }
                
                if(tmpCustomer[0].ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c=='On'){
                    //Add by Laputa
                    if(tmpCustomer[0].ASI_CRM_CN_Commercial_Team__c == 'Prestige' && tmpCustomer[0].ASI_CRM_CN_NewChannel__r.Name !='Restaurant'){ // 
                        ContractSelected.ASI_TH_CRM_Promotion_Type__c='Heavy Contract On';
                        ContractSelected.ASI_CRM_Investment_Type__c='heavy';
                    }else{
                        ContractSelected.ASI_TH_CRM_Promotion_Type__c='Contract On';
                        ContractSelected.ASI_CRM_Investment_Type__c='';
                    }
                }
                
                //KA Account 
                if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c!=null && !tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Inactive__c ){
                    if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Auto_link_to_PO_Open__c){
                        //finding the last One in this KA Account
                        ASI_TH_CRM_Contract__c contract=ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c);
                        ContractSelected.ASI_CRM_CN_Group_Contract__c=contract.Id;
                        ShowNationalContract= true;
                    }else{
                        GroupContractOptionType=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c);
                        ShowNationalContractOption=true;
                        //Getting the list
                        //GroupContractOptionType
                    }
                    
                }

                
                if (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract') {
                    ShowNationalContractOption=true;
                }

            }else{
                needChannelnProvince = TRUE;
            }
            /*if(tmpCustomer.size() > 0 && tmpCustomer[0].recordType.DeveloperName.contains('ASI_CRM_Outlet_CN')){
                needChannelnProvince = FALSE;
                ContractSelected.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                ContractSelected.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
            }else{
                needChannelnProvince = TRUE;
            }*/
            
            //20170131 Elufa
            if(tmpCustomer.size() > 0 && tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c != Null && tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_National_Group__c){//20170524 Changed to ASI_CRM_CN_KA_Account_Chain__c
                //ContractSelected.ASI_CRM_NationalGroup__c = tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c;
                
                if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Apply_National_Approval__c)
                    ContractSelected.ASI_CRM_CN_National_Group_Contract__c = True;
                else
                    ContractSelected.ASI_CRM_CN_National_Group_Contract__c = False;
            }else{
                //ContractSelected.ASI_CRM_NationalGroup__c = Null;
                ContractSelected.ASI_CRM_CN_National_Group_Contract__c = False;
            }
            //20170131 End
            
            //20160826 Ben @ Elufa
            ContractSelected.ASI_CRM_CN_All_Customer_Outlet__c = needChannelnProvince;
            //20160826 End
        }
    }
    //20160606 End
    
    //****** Validation: Contract Est. Total vs Remaining Payment Amount for PO Modification - (end) ******
    
       @RemoteAction
    public static String[] findSObjects(string obj, string qry, string rec) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';
        
        List <ASI_MFM_Sub_brand__c> sub_brand = new List<ASI_MFM_Sub_brand__c>();
        map<string, id> map_recordtype =ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');
        
        
        try {
            sub_brand=[SELECT Name,ASI_MFM_Active_for_CRM__c,RecordTypeid FROM ASI_MFM_Sub_brand__c 
                       WHERE ASI_MFM_Active_for_CRM__c=TRUE 
                       AND RecordTypeid=:map_recordtype.get('ASI_FOC_CN_Sub_brand') 
                       AND Name like :key 
                       AND ASI_MFM_Brand__r.ASI_CRM_CN_Competitor__c = FALSE
                       ORDER BY NAME];
            
            for(ASI_MFM_Sub_brand__c sb:sub_brand){
                results.add(sb.Name);  }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }
    
    @RemoteAction
    public static String[] findCitySObjects(string obj) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        List<String> results = new List<String>();
        
        List<ASI_CRM_City__c> citys = new List<ASI_CRM_City__c>();
        
        try {
            citys=[SELECT id,Name,ASI_CRM_CN_Province__r.Name
                   FROM ASI_CRM_City__c 
                   WHERE recordType.developerName = 'ASI_CRM_CN_City'
                   ORDER BY Name];
            
            for(ASI_CRM_City__c city:citys){
                String temp = city.Name + '$$$' + city.Id + '$$$' + city.ASI_CRM_CN_Province__r.Name;
                results.add(temp);
            }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
    }
    
    Public with sharing Class withSharingInnerClass{
        
        Public List<ASI_CRM_Customer_Group__c> getNationalGroup(){
            
            List<ASI_CRM_Customer_Group__c> tmp = new List<ASI_CRM_Customer_Group__c>([SELECT id, Name FROM ASI_CRM_Customer_Group__c WHERE recordType.DeveloperName = 'ASI_CRM_CN_National_Group']);
            
            return tmp;
        }
    }

    public void changeDolphin(){
        System.debug(LoggingLevel.INFO, '*** : contractSelected' + contractSelected);
        ContractSelected.ASI_CRM_CN_Activity_Times__c = null;
        ContractSelected.ASI_CRM_CN_Target_Base__c = null;
        if(IsDolphinDivision){
            ContractSelected.ASI_CRM_CN_Contract_Classification__c = 'Dolphin Division';
        }
        //ContractSelected.ASI_CRM_CN_Contract_Classification__c = null;
    }

}