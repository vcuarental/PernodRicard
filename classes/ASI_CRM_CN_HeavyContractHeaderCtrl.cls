/* Filename  :  ASI_CRM_CN_HeavyContractHeaderCtrl.cls
* Author     :  Laputa
* Purpose    :  Controller for editing heavy contract header on Page 
* Study From :  ASI_CRM_CN_HeavyContractHeaderEditPage
* Testing    :  
* History
* -----------------------------------------------------------------------------
* 2017-06-26   Laputa      Created

*/
public class ASI_CRM_CN_HeavyContractHeaderCtrl {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public String PageId {set;get;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}

    public Id subbrand999 ;
    public boolean showCN {set;get;}
    public boolean EditDate {get; set;}{EditDate=true;}

    public boolean isCTD {get;set;}{isCTD = true;}
    
    public boolean ReadOnlyModule {get; set;}{ReadOnlyModule=false;}
    
    public boolean POModification {get; set;}
    
    public Boolean AutoLinkToPO {get; set;} {AutoLinkToPO = false;}
    public Date StartDate  {get; set;}
    public Date EndDate  {get; set;}
    
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public String Msg {get;set;} {Msg='';}
    public Integer NoOfMonths {get; set;}{NoOfMonths=1;}
    
    //**********Group Contract**************
    public boolean IsNewContract  {get;set;} {IsNewContract=false;}
    public list<selectOption> GroupContractOptionType {Get; Set;}
    Public Boolean needChannelnProvince{Get; Set;}
    
    
    
    
    public ASI_CRM_CN_HeavyContractHeaderCtrl(ApexPages.StandardController controller) {
        subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1].id;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String CustomerId = ApexPages.currentPage().getParameters().get('ASI_CRM_CN_Outlet_WS__c');
        
        String isEdit = params.get('POModification');
        POModification = isEdit == '1' ? true : false;
        
        
        if(CustomerId!=null){// create New with KA Account 
            AutoLinkToPO = false;
            ContractSelected = new ASI_TH_CRM_Contract__c(ASI_CRM_Investment_Type__c='Heavy',ASI_CRM_New_FY_PO__c=true, ASI_CRM_CN_PO_Version__c='0.0',ASI_CRM_SG_Events__c=true,ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                          ASI_CRM_CN_Outlet_WS__c=CustomerId,name='Automated, Do not Change');
            
            IsNewContract=true;
            List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Local_Group__c ,
                ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c, 
                recordType.DeveloperName,ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c , ASI_CRM_CN_Channel_CN__c, ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_National_Group__c,
                ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Auto_link_to_PO_Open__c, ASI_CRM_CN_KA_Account_Chain__c, ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Inactive__c,
                ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_National_Group__c, ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Apply_National_Approval__c
                FROM ASI_CRM_AccountsAdditionalField__c
                WHERE id = : ContractSelected.ASI_CRM_CN_Outlet_WS__c ]);
            
            
            
            
            if(tmpCustomer.size() > 0 && tmpCustomer[0].recordType.DeveloperName.contains('ASI_CRM_Outlet_CN')){
                if(tmpCustomer[0].ASI_CRM_CN_NewChannel__c != NULL && !tmpCustomer[0].ASI_CRM_CN_NewChannel__r.Name.contains('All Customer')){
                    needChannelnProvince = FALSE;
                    ContractSelected.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                    ContractSelected.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                }else if(tmpCustomer[0].ASI_CRM_CN_NewChannel__c == NULL && !tmpCustomer[0].ASI_CRM_CN_Channel_CN__c.contains('All Customer')){
                    
                    needChannelnProvince = FALSE;
                    ContractSelected.ASI_CRM_PO_Channel__c = tmpCustomer[0].ASI_CRM_CN_NewChannel__c;
                    ContractSelected.ASI_CRM_PO_Province__c = tmpCustomer[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                    
                }else{
                    needChannelnProvince = TRUE;
                }
                
                
                if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c!=null ){
                    if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_National_Group__c){
                        ContractSelected.ASI_CRM_CN_National_Group_Contract__c = True;
                    }
                    if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Local_Group__c){
                        ContractSelected.ASI_CRM_CN_Local_Group_Contract__c = True;
                    }
                    
                    if(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__r.ASI_CRM_Auto_link_to_PO_Open__c){
                        AutoLinkToPO = true;
                        //finding the last One in this KA Account
                        ASI_TH_CRM_Contract__c contract=ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c);
                        ContractSelected.ASI_CRM_CN_Group_Contract__c=contract.Id;
                        ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c= contract.ASI_CRM_CN_Bottle_Collection_Rate__c!=null? contract.ASI_CRM_CN_Bottle_Collection_Rate__c:97;
                        ContractSelected.ASI_CRM_Martell_BC_Rate__c= contract.ASI_CRM_Martell_BC_Rate__c!=null? contract.ASI_CRM_Martell_BC_Rate__c:97;
                        
                    }else{
                        //ASI_CRM_CN_Bottle_Collection_Rate__c ASI_CRM_Martell_BC_Rate__c
                        List<ASI_TH_CRM_Contract__c> ContractList = [Select Id,Name, CreatedDate,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_Martell_BC_Rate__c from ASI_TH_CRM_Contract__c 
                                                                     where ( RecordType.DeveloperName ='ASI_CRM_CN_Group_Contract' or RecordType.DeveloperName like 'ASI_CRM_CN_Local_Group_Contract%') 
                                                                     and ASI_CRM_NationalGroup__c =:tmpCustomer[0].ASI_CRM_CN_KA_Account_Chain__c and 
                                                                     ASI_CRM_Active_Dummy_PO__c=true order by CreatedDate DESC];
                        GroupContractOptionType = new list<selectOption>();
                        system.debug('ContractList 2018 : '+ ContractList);
                        if(ContractList.size()>0){
                            ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c= ContractList[0].ASI_CRM_CN_Bottle_Collection_Rate__c!=null? ContractList[0].ASI_CRM_CN_Bottle_Collection_Rate__c:97;
                            ContractSelected.ASI_CRM_Martell_BC_Rate__c= ContractList[0].ASI_CRM_Martell_BC_Rate__c!=null? ContractList[0].ASI_CRM_Martell_BC_Rate__c:97;
                            for(ASI_TH_CRM_Contract__c NationalContract: ContractList){
                                GroupContractOptionType.add(new SelectOption(NationalContract.Id, NationalContract.Name)); 
                            }
                        }
                    }
                }
            }
            
            
            
        }else{
            this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
            if(this.ContractSelected != null)
                PageId = ContractSelected.id;
            
            
            
            this.ContractSelected = [SELECT Id,Name,ASI_CRM_Auto_PO_Modification_Time__c,
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
                                     FROM ASI_TH_CRM_Contract__c WHERE id =:pageId ];
            //save the contract Date
            StartDate=ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
            EndDate=ContractSelected.ASI_CRM_CN_PO_End_Date__c;
            
            
            NoOfMonths=integer.valueOf(ContractSelected.ASI_CRM_CN_No_of_Months__c) ;
            if(ContractSelected.ASI_CRM_CN_PO_Version__c!='0.0'){
                EditDate=false;
            }else if(ContractSelected.ASI_CRM_CN_Status__c!='Draft'){
                EditDate=false;
            }
            if(POModification){
                EditDate=true;
                if (ContractSelected.ASI_CRM_CN_CTD_Monthly_Default_Date__c != null && ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0') {
                    isCTD = false;
                } else {
                    isCTD=true;
                }
            }
            
            if(ContractSelected.ASI_CRM_CN_Status__c=='Archived' || ContractSelected.ASI_CRM_CN_Status__c=='FY landing Archive'){ 
                ReadOnlyModule=true;
            }
        }
        
        
    }
    
    
    
    public void ChangingGroupContract(){
        List<ASI_TH_CRM_Contract__c> ContractList = [Select Id,Name, CreatedDate,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_Martell_BC_Rate__c from ASI_TH_CRM_Contract__c 
                                                     where id=:ContractSelected.ASI_CRM_CN_Group_Contract__c];
        if(ContractList.size()>0){
            ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c= ContractList[0].ASI_CRM_CN_Bottle_Collection_Rate__c!=null? ContractList[0].ASI_CRM_CN_Bottle_Collection_Rate__c:97;
            ContractSelected.ASI_CRM_Martell_BC_Rate__c= ContractList[0].ASI_CRM_Martell_BC_Rate__c!=null? ContractList[0].ASI_CRM_Martell_BC_Rate__c:97;
        }
        
    }
    
    
    
    //*****************Save the record for Group Contract*****************
    public PageReference SaveNewContract(){
        // if (String.isEmpty(ContractSelected.Id)) {
        //     ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c = true;
        // }
        PageReference pageRef = null;
        UpsertPermission=true;
        msg='';
        
        
        
        //Start Date/End Day should be within Group Contract period
        if(ContractSelected.ASI_CRM_CN_Group_Contract__c!=null && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On'){
            ASI_TH_CRM_Contract__c NationalGroup =[select id,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c 
                                                   from  ASI_TH_CRM_Contract__c where  id=:ContractSelected.ASI_CRM_CN_Group_Contract__c];
            if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c<NationalGroup.ASI_CRM_CN_PO_Start_Date__c || ContractSelected.ASI_CRM_CN_PO_End_Date__c>NationalGroup.ASI_CRM_CN_PO_End_Date__c){
                UpsertPermission=false;
                msg=Label.ASI_CRM_CN_PO_Date_GroupContract;
            }
        }
        
        Set<id> checkCitySet = new Set<id>();
        
        List<ASI_CRM_City__c> citys = new List<ASI_CRM_City__c>([SELECT id,ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Create_Heavy_Contract_On__c,ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Is_2nd_KPI_PO__c FROM ASI_CRM_City__c  WHERE recordType.developerName = 'ASI_CRM_CN_City'
                                                                 AND ASI_CRM_CN_Province__c =: ContractSelected.ASI_CRM_PO_Province__c ORDER BY Name]);
        Boolean AllowCreate2nd = false;
        for(ASI_CRM_City__c city: citys){
            // checkCitySet.add(city.id);
            // AllowCreateHCO=city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Create_Heavy_Contract_On__c;
            AllowCreate2nd = city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Is_2nd_KPI_PO__c;
        }

        if (String.isEmpty(ContractSelected.Id) && AllowCreate2nd && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On') {
            ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c = true;
        }
        List<ASI_CRM_AccountsAdditionalField__c> selectedOutlet = new List<ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_CN_Inactive_Flag__c   From ASI_CRM_AccountsAdditionalField__c WHERE id = : ContractSelected.ASI_CRM_CN_Outlet_WS__c
            limit 1 ]);
        
        Map<Id, ASI_CRM_KA_Account__c> mapKAAccount = new Map<Id, ASI_CRM_KA_Account__c>();
        if(pageId == Null && ContractSelected.ASI_CRM_NationalGroup__c != Null){
            mapKAAccount = new Map<Id, ASI_CRM_KA_Account__c>([SELECT id, ASI_CRM_Apply_National_Approval__c,ASI_CRM_National_Group__c,ASI_CRM_Local_Group__c FROM ASI_CRM_KA_Account__c 
                                                               WHERE id = : ContractSelected.ASI_CRM_NationalGroup__c]);
        }
        
        if(selectedOutlet[0].ASI_CRM_CN_Inactive_Flag__c){
            if(USerInfo.getLanguage()=='zh_CN'){
                UpsertPermission=false;
                msg='不能为已关闭店家修改或创建合同';
            }else{
                UpsertPermission=false;
                msg='Not allowed to create/modify a PO with inactive Outlet';
            }
        }
        
        
        if(ContractSelected.ASI_CRM_PO_City__c != NULL && String.valueOf(ContractSelected.ASI_CRM_PO_City__c).trim() != '' && !checkCitySet.contains(ContractSelected.ASI_CRM_PO_City__c)){
            if(USerInfo.getLanguage()=='zh_CN'){
                UpsertPermission=false;
                msg='该城市不在省份内';
            }else{
                UpsertPermission=false;
                msg= 'City is not in Province' ;
            }
            
        }

        if(String.isBlank(ContractSelected.ASI_CRM_CN_Source_of_Contract__c)){
            msg += '</br> Please input Source of Contract.请输入合同来源' + '</br>';
            UpsertPermission=false;
        }
        
        if(UpsertPermission){
            System.Savepoint pSavepoint = Database.setSavepoint();
            try{//ContractSelected.ASI_CRM_CN_National_Group_Contract__c = True;//ASI_CRM_CN_Local_Group_Contract__c
                
                insert ContractSelected;
                PageId = ContractSelected.id;
                
                //generate BRSF Lines
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
                
                
                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    pageRef= new PageReference('/apex/ASI_CRM_CN_ViewHeavyContractPage2nd');
                } else {
                    pageRef= new PageReference('/apex/ASI_CRM_CN_ViewHeavyContractPage');
                }
                pageRef.getParameters().put('id',PageId);
                pageRef.setRedirect(true);
            } catch(Exception e){
                UpsertPermission=false;
                msg += ErrorMsgTransform(e.getMessage()) ;
                Database.rollback(pSavepoint);
                //ASI_MFM_ByPass_Setting.ErrorHandling( e.getMessage() , 'Fialed 123 : ASI_CRM_CN_HeavyContractHeaderCtrl','ASI_CRM_CN_HeavyContractHeaderCtrl.SaveNewContract');
            }
        }
        return pageRef; 
    }
    
    public static Date GenerateCutOffDate(Date ctdDate){
        Integer strDay=16;
        Date returnDate;
        Integer strDate = ctdDate.day();
        Integer strMonth;
        Integer strEndDay;

        if (strDate >= strDay){
            strMonth = ctdDate.month() - 1;
        }
        else if (strDate < strDay){
            strMonth = ctdDate.month() - 2;
        }
        strEndDay = Date.daysInMonth(ctdDate.year(), strMonth);
        returnDate = Date.newInstance(ctdDate.year(),strMonth,strEndDay);

        return returnDate;
    }
    
    //*****************Save the record po edit or PO Modification*****************
    public PageReference SaveItems(){
        PageReference pageRef = null;
        UpsertPermission=true;
        msg='';
        
        
        if(!ValdationChecking()){
            UpsertPermission=false;
        }

        if (POModification && contractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            if (ContractSelected.ASI_CRM_CN_CTD_Monthly_Default_Date__c!= null) {
                Date CutOffDay = GenerateCutOffDate(ContractSelected.ASI_CRM_CN_CTD_Monthly_Default_Date__c);
                Date ctdmothDate = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, EndDate, 'MIN'));
                // System.debug(LoggingLevel.INFO, '*** CutOffDay: ' + CutOffDay);
                if (ctdmothDate > ContractSelected.ASI_CRM_CN_PO_End_Date__c) {
                    if(USerInfo.getLanguage()=='zh_CN'){
                        UpsertPermission=false;
                        msg='PO结束日期不得早于CTD Monthly的cutoffdate';
                    }else{
                        UpsertPermission=false;
                        msg='PO end date cannot be earlier than CTD Monthly\'s cutoffdate';
                    }
                }
            }
        }
        if(UpsertPermission){
            System.Savepoint pSavepoint = Database.setSavepoint();
            //POModificationProcess1(contractSelected);
            
            
            
            try{
                if(POModification){
                    if (contractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                        POModificationProcess12nd(contractSelected);
                    } else {
                        POModificationProcess1(contractSelected);
                    }
                    
                }else{
                    update ContractSelected;
                    ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(ContractSelected,NoOfMonths,StartDate,EndDate);
                }
                
                system.debug('Passed');
                pageRef = new PageReference('/'+PageId);
                pageRef.setRedirect(true);
                
            } catch(Exception e){ 
                // String ErrorMsg=;
                //if(ErrorMsg.contains('Please select correct PO period')){ErrorMsg='Please select correct PO period.';}
                //if(ErrorMsg.contains('Contract Date Overlap.')){ErrorMsg='Contract Date Overlap';}
                //if(ErrorMsg.contains('合同日期重叠')){ErrorMsg='合同日期重叠'; }
                //ErrorMsgTransform
                msg += ErrorMsgTransform(e.getMessage()) + '</br>';
                UpsertPermission=false;
                Database.rollback(pSavepoint);
            }
            
        }
        
        return pageRef; 
    }
    
    public static String ErrorMsgTransform(String InputErrorMsg){
        String ReturnString = '';
        if(InputErrorMsg!=null){
            if(InputErrorMsg.contains('Please select correct PO period')){
                ReturnString='Please select correct PO period.';
            }else if(InputErrorMsg.contains('Contract Date Overlap.')){
                ReturnString='Contract Date Overlap';
            }else if(InputErrorMsg.contains('合同日期重叠')){
                ReturnString='合同日期重叠'; 
            }else{
                ReturnString = InputErrorMsg;
            }
        }
        
        return ReturnString;
    }
    
    
    public boolean ValdationChecking(){
        Boolean isProcess = true;
        
        if(ContractSelected.ASI_CRM_CN_Group_Contract__c!=null){// is group contract
            if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c<ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c || 
               ContractSelected.ASI_CRM_CN_PO_End_Date__c>ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c){
                   
                   msg +=Label.ASI_CRM_CN_PO_Date_GroupContract + '</br>';
                   isProcess=false;
               }
        }
        System.debug(LoggingLevel.INFO, '*** ContractSelected.ASI_CRM_CN_Source_of_Contract__c: ' + ContractSelected.ASI_CRM_CN_Source_of_Contract__c);
        if(ContractSelected.ASI_CRM_CN_Source_of_Contract__c == Null || ContractSelected.ASI_CRM_CN_Source_of_Contract__c == ''){
            msg += ' Please input Source of Contract.请输入合同来源' + '</br>';
            isProcess=false;
        }
        
        
        if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c == Null){
            msg += ' Please input Start Date.请输入开始日期' + '</br>';
            isProcess=false;
        }
        
        if(ContractSelected.ASI_CRM_CN_PO_End_Date__c == Null){
            msg += ' Please input End Date.请输入结束日期' + '</br>';
            isProcess=false;
        }
        
        if(ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c == Null){
            msg += ' Please input Bottle Collection Rate.请输入空瓶回收率' + '</br>';
            isProcess=false;
        }
        if(ContractSelected.ASI_CRM_Martell_BC_Rate__c == Null && ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0' && ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Group_Contract__c==null){
            msg += 'Please input Martell Bottle Collection Rate.请输入马爹利空瓶回收率' + '</br>';
            isProcess=false;
        }
        
        
        if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c!=null && ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()!=1){
            msg += Label.ASI_CRM_CN_PO_Start_Date_Validation+'<br/>';
            isProcess=false;
        }
        
        //checking end day         
        Date LastEndDate = ContractSelected.ASI_CRM_CN_PO_End_Date__c!=null?ContractSelected.ASI_CRM_CN_PO_End_Date__c.addMonths(1).toStartOfMonth().addDays(-1):null;
        if(LastEndDate!=null && ContractSelected.ASI_CRM_CN_PO_End_Date__c != LastEndDate){
            msg +=Label.ASI_CRM_CN_PO_End_Date_Validation+'<br/>';// End Date should be the last day of the month .
            isProcess=false;
        }
        
        
        return isProcess;
    }

    //更新固定费用的module上的预计总金额
    //v0FCConAmount,v0FCEstimateTotalAmount,v0FCPerEstimateAmount
    public void updateFCModuleAmount (Id contractId,Map<Id,Decimal> v0FCConAmount,Map<Id,Decimal> v0FCEstimateTotalAmount,Map<Id,Decimal> v0FCPerEstimateAmount) {
        List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();
        for (ASI_CRM_Module__c module : [SELECT Id, ASI_CRM_CN_Expected_Est_Total__c,
                                                ASI_CRM_CN_AC_Code__c, ASI_CRM_Contract__c,
                                                ASI_CRM_Line_Type__c, ASI_CRM_Volume_Base__c
                                         FROM ASI_CRM_Module__c
                                         WHERE ASI_CRM_Contract__c =: contractId
                                         AND ASI_CRM_Line_Type__c = 'Fixed']) {
            if (v0FCPerEstimateAmount.containsKey(module.ASI_CRM_CN_AC_Code__c)) {
                module.ASI_CRM_CN_Expected_Est_Total__c = v0FCPerEstimateAmount.get(module.ASI_CRM_CN_AC_Code__c);
                // module.ASI_CRM_Expected_V0_FC_Estimated_Total__c = v0FCEstimateTotalAmount.get(module.ASI_CRM_CN_AC_Code__c);
                // module.ASI_CRM_V0_FC_Contract_Total__c = v0FCConAmount.get(module.ASI_CRM_CN_AC_Code__c);
                // module.ASI_CRM_Previous_Version_FC_Est_Total__c = v0FCPerEstimateAmount.get(module.ASI_CRM_CN_AC_Code__c);
                // module.ASI_CRM_FC_Estimate_Adjustment_Amount__c = 0.00;
                moduleList.add(module);
            }
        }
        if (moduleList != null && moduleList.size() > 0) {
            update moduleList;
        }
    }

    public Decimal formatterQty(Decimal qty) {
        String myNumber = String.valueOf(qty);
        String myTruncatedNumber = '';
        if (myNumber.contains('.')) {
            myTruncatedNumber = myNumber.subString(0,myNumber.indexOf('.'));
        } else {
            myTruncatedNumber = myNumber;
        }
        Decimal d = Decimal.valueOf(myTruncatedNumber);
        return d;
    }


    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> updateLineData(ASI_TH_CRM_Contract__c contract) {
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractDetailLines =[SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Product_Category_Name__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                              WHERE ASI_CRM_CN_Contract__c = :contract.Id] ;
        Date CutOffDay = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Date v0TillEndPOM = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, contract.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        Integer mothNo = Contract.ASI_CRM_CN_PO_Start_Date__c.monthsBetween(v0TillEndPOM.addDays(1));
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('ASI_CRM_Subbrand_Volume__c').getDescribe().Fields.getMap();
        // List<String> selectFields = new List<String>();

        // if (fMap != null){
        //     for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
        //         Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
        //         if (fd.isCreateable()){ // field is creatable
        //             selectFields.add(fd.getName());
        //         }
        //     }
        // }
        String queryStr = 'OwnerId,CurrencyIsoCode,RecordTypeId,ASI_CRM_AVG_Offtake_BTL__c,ASI_CRM_AVG_Offtake_CR12__c,ASI_CRM_AVG_Offtake_STD_Billing__c,ASI_CRM_AVG_Offtake_STD__c,ASI_CRM_AVG_Offtake__c,ASI_CRM_Account__c,ASI_CRM_CN_Payment_Request_Line_Item__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_WS_Tier__c,ASI_CRM_Empty_Bottle_Btl__c,ASI_CRM_Empty_Bottle_CR12__c,ASI_CRM_Empty_Bottle_GS__c,ASI_CRM_Empty_Bottle_Std_Billing__c,ASI_CRM_Empty_Bottle_Std_Btl__c,ASI_CRM_Empty_Bottle__c,ASI_CRM_End_Date__c,ASI_CRM_External_ID__c,ASI_CRM_Green_Cap_Btl__c,ASI_CRM_Green_Cap_CR12__c,ASI_CRM_Green_Cap_GS__c,ASI_CRM_Green_Cap_STD__c,ASI_CRM_Green_Cap_Std_Billing__c,ASI_CRM_Green_Cap__c,ASI_CRM_Month__c,ASI_CRM_Offtake_Btl__c,ASI_CRM_Offtake_CR12__c,ASI_CRM_Offtake_GS__c,ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_Offtake_Std__c,ASI_CRM_Offtake__c,ASI_CRM_PR_DIRECT_GS_LESS_50ML__c,ASI_CRM_PR_DIRECT_GS__c,ASI_CRM_PR_Direct_Btl__c,ASI_CRM_PR_Direct_CR12__c,ASI_CRM_PR_Direct_GS_L50__c,ASI_CRM_PR_Direct_L50_Btl__c,ASI_CRM_PR_Direct_L50_CR12__c,ASI_CRM_PR_Direct_L50_STD_Billing__c,ASI_CRM_PR_Direct_L50_STD__c,ASI_CRM_PR_Direct_L50__c,ASI_CRM_PR_Direct_STD_Billing__c,ASI_CRM_PR_Direct_STD__c,ASI_CRM_PR_Direct__c,ASI_CRM_PR_SHIPMENT__c,ASI_CRM_PR_Shipment_Btl__c,ASI_CRM_PR_Shipment_CR12__c,ASI_CRM_PR_Shipment_GS_L50__c,ASI_CRM_PR_Shipment_GS__c,ASI_CRM_PR_Shipment_L50_Btl__c,ASI_CRM_PR_Shipment_L50_CR12__c,ASI_CRM_PR_Shipment_L50_STD_Billing__c,ASI_CRM_PR_Shipment_L50_STD__c,ASI_CRM_PR_Shipment_L50__c,ASI_CRM_PR_Shipment_STD_Billing__c,ASI_CRM_PR_Shipment_STD__c,ASI_CRM_Red_Cap_Btl__c,ASI_CRM_Red_Cap_CR12__c,ASI_CRM_Red_Cap_GS__c,ASI_CRM_Red_Cap_STD_Billing__c,ASI_CRM_Red_Cap_STD__c,ASI_CRM_Red_Cap__c,ASI_CRM_Subbrand__c,ASI_CRM_T1_Depletion_BTL__c,ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T1_Depletion_GS_LESS_50ML__c,ASI_CRM_T1_Depletion_GS__c,ASI_CRM_T1_Depletion_L50_BTL__c,ASI_CRM_T1_Depletion_L50_CR12__c,ASI_CRM_T1_Depletion_L50_GS__c,ASI_CRM_T1_Depletion_L50_STD_Billing__c,ASI_CRM_T1_Depletion_L50_STD__c,ASI_CRM_T1_Depletion_L50__c,ASI_CRM_T1_Depletion_STD_Billing__c,ASI_CRM_T1_Depletion_STD__c,ASI_CRM_T1_Depletion__c,ASI_CRM_T1_DepletiontoALL_Btl__c,ASI_CRM_T1_DepletiontoALL_CR12__c,ASI_CRM_T1_DepletiontoALL_GS__c,ASI_CRM_T1_DepletiontoALL_L50_GS__c,ASI_CRM_T1_DepletiontoALL_L50_STD_Billin__c,ASI_CRM_T1_DepletiontoALL_L50_STD__c,ASI_CRM_T1_DepletiontoALL_STD_Billing__c,ASI_CRM_T1_DepletiontoALL_STD__c,ASI_CRM_T1_DepletiontoT2_L50_BTL__c,ASI_CRM_T1_DepletiontoT2_L50_CR12__c,ASI_CRM_T1_DepletiontoT2_L50__c,ASI_CRM_T1_DepletiontoT2__c,ASI_CRM_T23_DepletiontoALL_BTL__c,ASI_CRM_T23_DepletiontoALL_CR12__c,ASI_CRM_T23_DepletiontoALL_GS__c,ASI_CRM_T23_DepletiontoALL_L50_BTL__c,ASI_CRM_T23_DepletiontoALL_L50_CR12__c,ASI_CRM_T23_DepletiontoALL_L50_GS__c,ASI_CRM_T23_DepletiontoALL_L50_STD_Billi__c,ASI_CRM_T23_DepletiontoALL_L50_STD__c,ASI_CRM_T23_DepletiontoALL_STD_Billing__c,ASI_CRM_T23_DepletiontoALL_STD__c,ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_T2_Depletion_GS_50ML__c,ASI_CRM_T2_Depletion_GS__c,ASI_CRM_T2_Depletion_L50_BTL__c,ASI_CRM_T2_Depletion_L50_CR12__c,ASI_CRM_T2_Depletion_L50_GS__c,ASI_CRM_T2_Depletion_L50_STD_Billing__c,ASI_CRM_T2_Depletion_L50_STD__c,ASI_CRM_T2_Depletion_L50__c,ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_T2_Depletion_STD__c,ASI_CRM_T2_Depletion__c,ASI_CRM_T2_DepletiontoT3_L50__c,ASI_CRM_T2_DepletiontoT3__c,ASI_CRM_T2_Receive_Scan_GS__c,ASI_CRM_T2_receive_scan_BTL__c,ASI_CRM_T2_receive_scan_CR12__c,ASI_CRM_T2_receive_scan_STD_Billing__c,ASI_CRM_T2_receive_scan_STD__c,ASI_CRM_T2_receive_scan__c,ASI_CRM_Total_Depletion_To_T2_GS__c,ASI_CRM_WS_INV_BTL__c,ASI_CRM_WS_INV_CR12__c,ASI_CRM_WS_INV_STD_Billing__c,ASI_CRM_WS_INV_STD__c,ASI_CRM_WS_INV__c,ASI_CRM_WS_Inventory_GS__c,ASI_CRM_Year__c,ASI_CRM_Yellow_Cap_Btl__c,ASI_CRM_Yellow_Cap_CR12__c,ASI_CRM_Yellow_Cap_GS__c,ASI_CRM_Yellow_Cap_STD_Billing__c,ASI_CRM_Yellow_Cap_STD__c,ASI_CRM_Yellow_Cap__c,ASI_CRMT_2T3Depletion_ToALL_TY_VS_LY_YTD__c,ASI_CRM_CN_Division_Code__c,ASI_CRM_Empty_Bottle_Last_FY_MTD_9L__c,ASI_CRM_Empty_Bottle_Last_FY_MTD_Std_Btl__c,ASI_CRM_Empty_Bottle_Last_FY_YTD_9L__c,ASI_CRM_Empty_Bottle_Last_FY_YTD_Std_Btl__c,ASI_CRM_Empty_Bottle_This_FY_VS_Last_FY__c,ASI_CRM_Empty_Bottle_This_FY_YTD_9L__c,ASI_CRM_Empty_Bottle_This_FY_YTD_Std_Btl__c,ASI_CRM_Green_Cap_Last_FY_MTD_9L__c,ASI_CRM_Green_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Green_Cap_Last_FY_YTD_9L__c,ASI_CRM_Green_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Green_Cap_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Green_Cap_This_FY_YTD_9L__c,ASI_CRM_Green_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_Intake_9L__c,ASI_CRM_Intake_Btl__c,ASI_CRM_Intake_CR12__c,ASI_CRM_Intake_GS__c,ASI_CRM_Intake_Last_FY_MTD_9L__c,ASI_CRM_Intake_Last_FY_MTD_Std_Btl__c,ASI_CRM_Intake_Last_FY_YTD_9L__c,ASI_CRM_Intake_Last_FY_YTD_Std_Btl__c,ASI_CRM_Intake_Std_Billing__c,ASI_CRM_Intake_Std_Btl__c,ASI_CRM_Intake_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Intake_This_FY_YTD_9L__c,ASI_CRM_Intake_This_FY_YTD_Std_Btl__c,ASI_CRM_Offtake_Last_FY_MTD_9L__c,ASI_CRM_Offtake_Last_FY_MTD_Std_Btl__c,ASI_CRM_Offtake_Last_FY_YTD_9L__c,ASI_CRM_Offtake_Last_FY_YTD_Std_Btl__c,ASI_CRM_Offtake_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Offtake_This_FY_YTD_9L__c,ASI_CRM_Offtake_This_FY_YTD_Std_Btl__c,ASI_CRM_POS_9L__c,ASI_CRM_POS_Btl__c,ASI_CRM_POS_CR12__c,ASI_CRM_POS_GS__c,ASI_CRM_POS_LY_FY_9L__c,ASI_CRM_POS_LY_FY_Std_Btl__c,ASI_CRM_POS_LY_MTD_9L__c,ASI_CRM_POS_LY_MTD_Std_Btl__c,ASI_CRM_POS_LY_YTD_9L__c,ASI_CRM_POS_LY_YTD_Std_Btl__c,ASI_CRM_POS_Std_Billing__c,ASI_CRM_POS_Std_Btl__c,ASI_CRM_POS_This_FY_VS_Last_FY_YTD__c,ASI_CRM_POS_YTD_Std_Btl_9L__c,ASI_CRM_POS_YTD_Std_Btl_Std_Btl__c,ASI_CRM_PR_Direct_Last_FY_MTD_9L__c,ASI_CRM_PR_Direct_Last_FY_MTD_Std_Btl__c,ASI_CRM_PR_Direct_Last_FY_YTD_9L__c,ASI_CRM_PR_Direct_Last_FY_YTD_Std_Btl__c,ASI_CRM_PR_Direct_This_FY_VS_Last_FY_YTD__c,ASI_CRM_PR_Direct_This_FY_YTD_9L__c,ASI_CRM_PR_Direct_This_FY_YTD_Std_Btl__c,ASI_CRM_PR_Shipment_LY_MTD_Std_Btl__c,ASI_CRM_PR_Shipment_LY_YTD_Std_Btl__c,ASI_CRM_PR_Shipment_Last_FY_MTD_9L__c,ASI_CRM_PR_Shipment_Last_FY_YTD_9L__c,ASI_CRM_PR_Shipment_TY_VS_LY_YTD__c,ASI_CRM_PR_Shipment_TY_YTD_Std_Btl__c,ASI_CRM_PR_Shipment_This_FY_YTD_9L__c,ASI_CRM_Red_Cap_Last_FY_MTD_9L__c,ASI_CRM_Red_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Red_Cap_Last_FY_YTD_9L__c,ASI_CRM_Red_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Red_Cap_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Red_Cap_This_FY_YTD_9L__c,ASI_CRM_Red_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_T1DepletionTo_ALL_TY_YTD_Std_Btl__c,ASI_CRM_T1Depletion_ToALL_LY_YTD_Std_Btl__c,ASI_CRM_T1_Depletion_Last_FY_MTD_9L__c,ASI_CRM_T1_Depletion_Last_FY_MTD_Std_Btl__c,ASI_CRM_T1_Depletion_Last_FY_YTD_9L__c,ASI_CRM_T1_Depletion_Last_FY_YTD_Std_Btl__c,ASI_CRM_T1_Depletion_This_FY_VS_Last_FY__c,ASI_CRM_T1_Depletion_This_FY_YTD_9L__c,ASI_CRM_T1_Depletion_This_FY_YTD_Std_Btl__c,ASI_CRM_T1_Depletion_to_ALL_LY_MTD_9L__c,ASI_CRM_T1_Depletion_to_ALL_LY_MTD_Std__c,ASI_CRM_T1_Depletion_to_ALL_LY_YTD_9L__c,ASI_CRM_T1_Depletion_to_ALL_TY_VS_LY_YTD__c,ASI_CRM_T1_Depletion_to_ALL_TY_YTD_9L__c,ASI_CRM_T2T3DepletionToALL_LY_YTD_StdBtl__c,ASI_CRM_T2T3_Depletion_to_ALL_TY_YTD_Std__c,ASI_CRM_T2_Depletion_Last_FY_MTD_9L__c,ASI_CRM_T2_Depletion_Last_FY_MTD_Std_Btl__c,ASI_CRM_T2_Depletion_Last_FY_YTD_9L__c,ASI_CRM_T2_Depletion_Last_FY_YTD_Std_Btl__c,ASI_CRM_T2_Depletion_This_FY_VS_Last_FY__c,ASI_CRM_T2_Depletion_This_FY_YTD_9L__c,ASI_CRM_T2_Depletion_This_FY_YTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_LY_MTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_LY_YTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_Last_FY_MTD_9L__c,ASI_CRM_T2_Receive_Scan_Last_FY_YTD_9L__c,ASI_CRM_T2_Receive_Scan_TY_VS_LY_YTD__c,ASI_CRM_T2_Receive_Scan_TY_YTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_This_FY_YTD_9L__c,ASI_CRM_T2_T3_Depletion_to_ALL_LY_MTD_9L__c,ASI_CRM_T2_T3_Depletion_to_ALL_TY_YTD_9L__c,ASI_CRM_WS_Inventory_Last_FY_9L__c,ASI_CRM_WS_Inventory_Last_FY_Std_Btl__c,ASI_CRM_WS_Inventory_TY_VS_LY_YTD__c,ASI_CRM_Yellow_Cap_Last_FY_MTD_9L__c,ASI_CRM_Yellow_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Yellow_Cap_Last_FY_YTD_9L__c,ASI_CRM_Yellow_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Yellow_Cap_This_FY_VS_Last_FYYTD__c,ASI_CRM_Yellow_Cap_This_FY_YTD_9L__c,ASI_CRM_Yellow_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_CN_Greater_Region_Code__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Black_Cap_CR12__c,ASI_CRM_Black_Cap_GS__c,ASI_CRM_Black_Cap_Last_FY_MTD_9L__c,ASI_CRM_Black_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Black_Cap_Last_FY_YTD_9L__c,ASI_CRM_Black_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Black_Cap_STD__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Black_Cap_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Black_Cap_This_FY_YTD_9L__c,ASI_CRM_Black_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_Black_Cap__c,ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Exclude_From_Payment_Volume__c,ASI_CRM_DeductCapWithIssue_StdBill__c,ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Deductible_Cap_with_Issues_Btl__c,ASI_CRM_Deductible_Cap_with_Issues_CR12__c,ASI_CRM_Deductible_Cap_with_Issues__c,ASI_CRM_Grey_Cap_Btl__c,ASI_CRM_Grey_Cap_CR12__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Grey_Cap_Std_Btl__c,ASI_CRM_Grey_Cap__c,ASI_CRM_Penalty_Coefficient_Applied__c,ASI_CRM_Times_of_cap_with_issues__c,ASI_CRM_CN_Contract__c,ASI_CRM_CN_Intake_GS_T1_price__c,ASI_CRM_CN_Original_Contract_Start_Date__c,ASI_CRM_CN_Product_Category_Agg__c,ASI_CRM_CN_Supplier__c,';

        Map<Id,String> subBrandIdMaps = new Map<Id,String>();

        for (ASI_MFM_Sub_brand__c brand : [SELECT Id,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c FROM ASI_MFM_Sub_brand__c 
                                           WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand' 
                                           AND ASI_CRM_CN_Sub_brand_Grade__c!=null 
                                           AND  ASI_MFM_Brand__r.ASI_CRM_CN_Competitor__c =FALSE 
                                           AND ASI_MFM_Active_for_CRM__c=TRUE  
                                           AND ASI_MFM_Sub_brand_Code__c != '999']) {
            subBrandIdMaps.put(brand.Id, brand.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c);
        }
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                             FROM ASI_CRM_CN_Covered_Outlet__c
                             WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];
        }catch(exception e){
            CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }  
        set<id> AllOutlet = new set<id>();
        
        if (ContractSelected.ASI_CRM_Volume_Option__c == 'Normal' || ContractSelected.ASI_CRM_Volume_Option__c == 'Wholesaler Only' ||ContractSelected.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(ContractSelected.ASI_CRM_CN_Outlet_WS__c);
        }
        if (ContractSelected.ASI_CRM_Volume_Option__c == 'Normal' || ContractSelected.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || ContractSelected.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }

        date TillEnd = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, ContractSelected.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        // Id conId = ContractSelected.Id;
        // Id accId = ContractSelected.ASI_CRM_CN_Outlet_WS__c;
        Date startDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
        queryStr += 'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,';
        queryStr += 'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,';
        queryStr += 'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c';
        String volumeSql = 'SELECT '+ queryStr + ' FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_End_Date__c >=: startDate AND ASI_CRM_End_Date__c <= :TillEnd AND ASI_CRM_CN_Competitor_Sub_brand__c != true AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false and ASI_CRM_Subbrand__c !=null' ;

        System.debug(LoggingLevel.INFO, '*** volumeSql: ' + volumeSql);
        List<ASI_CRM_Subbrand_Volume__c> volumeList = Database.query(volumeSql);
        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfitemMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Id brsfmoduleId;
        Id bRSFActivityCodeId;
        Id bRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');

        Id vecModuleId;
        Id vecActivityCodeId;

        Set<Id> psfModuleId = new Set<Id>();
        Id psfcode;

        Set<Id> fcmoduleIds = new Set<Id>();
        Map<Id,Id> fcactivityCodeId = new Map<Id,Id>();

        System.debug(LoggingLevel.INFO, '*** Contract.ASI_CRM_CN_No_of_Months__c: ' + Contract.ASI_CRM_CN_No_of_Months__c);

        for (Integer i = contractDetailLines.size() - 1;i > = 0; i --) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine = contractDetailLines.get(i);
            if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){
                    ContractLine.ASI_CRM_CN_Is_Payment_New__c = false;
                    if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                        bRSFActivityCodeId = contractLine.ASI_CRM_CN_Activity_Code__c;
                        brsfmoduleId = contractLine.ASI_CRM_Module__c;
                        // ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0.00;

                        ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c = contractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                        brsfitemMap.put(contractLine.ASI_CRM_CN_Sub_Brand__c, contractLine);
                        contractDetailLines.remove(i);
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'PSF' && !psfModuleId.contains(ContractLine.ASI_CRM_Module__c)) {
                        psfModuleId.add(ContractLine.ASI_CRM_Module__c);
                        psfcode = ContractLine.ASI_CRM_CN_Activity_Code__c;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'Variable Event Cost') {
                        vecModuleId = ContractLine.ASI_CRM_Module__c;
                        vecActivityCodeId = ContractLine.ASI_CRM_CN_Activity_Code__c;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'Fixed' && !fcmoduleIds.contains(ContractLine.ASI_CRM_Module__c)) {
                        fcmoduleIds.add(ContractLine.ASI_CRM_Module__c);
                        fcactivityCodeId.put(ContractLine.ASI_CRM_Module__c, ContractLine.ASI_CRM_CN_Activity_Code__c);
                    }
                }
            }
        }

        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        //Looping the Sub-Brand Grade
        for(ASI_CRM_Sub_Brand_Grade__c sbg:ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c )){
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }else{
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);  
            }
        }

        if (mothNo >= (contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c!= null ?contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c:6) || Test.isRunningTest()) {


            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : brsfitemMap.values()) {
                item.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                item.ASI_CRM_CN_Est_Total_Dummy__c = 0.00;
                item.ASI_CRM_CN_Is_Payment_New__c = false;
            }
            System.debug(LoggingLevel.INFO, '*** volumeList: ' + volumeList);
            List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT Id,CreatedDate, ASI_TH_CRM_Contract__c
                                                              FROM ASI_TH_CRM_PaymentRequest__c
                                                              WHERE ASI_TH_CRM_Contract__c=:contract.Id
                                                              ORDER BY CreatedDate DESC];
            ASI_TH_CRM_PaymentRequest__c newestPayment = new ASI_TH_CRM_PaymentRequest__c();
            // List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();

            Map<Id,Map<Id,Decimal>> paymentPriceMap = new Map<Id,Map<Id,Decimal>>();
            if (paymentList != null && paymentList.size() > 0) {
                newestPayment = paymentList.get(0);
                Set<Id> moduleIds = new Set<Id>();
                for (ASI_CRM_Module__c module : [SELECT ASI_CRM_Line_Type__c, ASI_CRM_Parent_Module__c 
                                                  FROM ASI_CRM_Module__c
                                                  WHERE ASI_CRM_Contract__c=: contract.Id 
                                                  AND ASI_CRM_Payment_Request__c =: newestPayment.Id]) {
                    moduleIds.add(module.Id);
                }
                // Map<Id,Map<Id,Decimal>> paymentPriceMap = new Map<Id,Map<Id,Decimal>>();
                for (ASI_TH_CRM_PaymentRequestLineItem__c payment : [SELECT ASI_CRM_CN_Incentive_BT__c,
                                                                             ASI_CRM_CN_Sub_Brand__c,
                                                                             ASI_CRM_Module__r.ASI_CRM_Parent_Module__c
                                                                      FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                                                      WHERE ASI_CRM_Module__c IN:moduleIds
                                                                      AND ASI_CRM_CN_Sub_Brand__c != null]) {
                    if (paymentPriceMap.containsKey(payment.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c)) {
                        paymentPriceMap.get(payment.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).put(payment.ASI_CRM_CN_Sub_Brand__c, payment.ASI_CRM_CN_Incentive_BT__c);
                    } else {
                        paymentPriceMap.put(payment.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,new Map<Id,Decimal>{payment.ASI_CRM_CN_Sub_Brand__c => payment.ASI_CRM_CN_Incentive_BT__c});
                    }
                }

            }

            // List<Date> dateList = new List<Date>();
            Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
            // dateList.add(setDate);

            String channel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
            String region = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            String cityInvestementGrade = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
            String newImage = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;

            Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdMaps.keySet());

            Map<Id,String> gradeNameMap = new Map<Id,String>();
            //销量中新增的brsf
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> newItemList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            for (ASI_CRM_Subbrand_Volume__c volume : volumeList) {
                Decimal VolumeBtl = ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume, 'std');
                if (brsfitemMap.containsKey(volume.ASI_CRM_Subbrand__c)) {

                    Decimal qty = brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c + (VolumeBtl.divide(mothNo, 4) == null ? 0 : VolumeBtl.divide(mothNo, 4));
                    // Decimal estQty = formatterQty(qty);
                    brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c = qty;
                    // brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c += VolumeBtl.divide(mothNo, 4) != null ? VolumeBtl.divide(mothNo, 4) : 0;
                    brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Total_Dummy__c = brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c*brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                    // brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Contract_Total_Dummy__c = brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Contract_Monthly_Qty__c*brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                } else {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c newItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                    newItem.ASI_CRM_CN_Sub_Brand__c = volume.ASI_CRM_Subbrand__c;
                    newItem.ASI_CRM_CN_Contract__c = contract.Id;
                    newItem.ASI_CRM_Module__c = brsfmoduleId;
                    newItem.ASI_CRM_CN_Activity_Code__c = bRSFActivityCodeId;
                    newItem.ASI_CRM_Sub_Brand_Grade__c = volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                    newItem.ASI_CRM_Type__c= 'BRSF';
                    newItem.ASI_CRM_Volume_Base__c = 'By Sub-Brand';
                    newItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = 0.00;
                    newItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0.00;
                    newItem.ASI_CRM_CN_Contract_Total_Dummy__c = 0.00;
                    newItem.ASI_CRM_CN_Contract_Monthly_Qty__c = 0.00;
                    newItem.ASI_CRM_Sub_Brand_Grade__c = volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                    newItem.RecordTypeId = bRSFLineRtId;
                    newItem.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newItem.ASI_CRM_CN_Sub_Brand__c,setDate,'BRSFMax','');
                    newItem.ASI_CRM_Line_Name__c = volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                    // Decimal estQty = formatterQty(VolumeBtl.divide(mothNo, 4));
                    newItem.ASI_CRM_CN_Est_Monthly_Qty__c = VolumeBtl.divide(mothNo, 4);
                    if (paymentPriceMap.containsKey(newItem.ASI_CRM_Module__c)) {
                        Map<Id,Decimal> priceMap = paymentPriceMap.get(newItem.ASI_CRM_Module__c);
                        if (priceMap.containsKey(newItem.ASI_CRM_CN_Sub_Brand__c)) {
                            newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newItem.ASI_CRM_CN_Sub_Brand__c);
                        }
                    }
                    if (newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newItem.ASI_CRM_CN_Sub_Brand__c,setDate,'BRSFDefault','');
                        newItem.ASI_CRM_CN_Is_Payment_New__c = true;
                    }
                    if (newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        newItem.ASI_CRM_CN_Is_Payment_New__c = true;
                        newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(SubBrandGradeMap,volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFDefault',contract);
                    }
                    if (newItem.ASI_CRM_Max_Incentive__c == null) {
                        newItem.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newItem.ASI_CRM_CN_Sub_Brand__c,setDate,'BRSFMax','');
                    }
                    if (newItem.ASI_CRM_Max_Incentive__c == null) {
                        newItem.ASI_CRM_Max_Incentive__c = GeneratingIncentive(SubBrandGradeMap,volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFMax',contract);
                    }
                    newItem.ASI_CRM_CN_Est_Total_Dummy__c = newItem.ASI_CRM_CN_Est_Monthly_Qty__c*newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                    //3.28add
                    // newItem.ASI_CRM_CN_Is_Payment_New__c = true;
                    gradeNameMap.put(newItem.ASI_CRM_Sub_Brand_Grade__c, volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                    newItemList.add(newItem);
                    brsfitemMap.put(newItem.ASI_CRM_CN_Sub_Brand__c,newItem);
                }
            }

            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : brsfitemMap.values()) {
                line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Monthly_Qty__c*line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Monthly_Qty__c*line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
            }

            //在其他module添加newItemList的数据
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : newItemList) {
                if (String.isNotBlank(vecModuleId)) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = line.clone();
                    newLine.ASI_CRM_Module__c = vecModuleId;
                    newLine.ASI_CRM_Type__c = 'Variable Event Cost';
                    newLine.ASI_CRM_CN_Activity_Code__c = vecActivityCodeId;

                    newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = null;
                    if (paymentPriceMap.containsKey(newLine.ASI_CRM_Module__c)) {
                        Map<Id,Decimal> priceMap = paymentPriceMap.get(newLine.ASI_CRM_Module__c);
                        if (priceMap.containsKey(newLine.ASI_CRM_CN_Sub_Brand__c)) {
                            newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newLine.ASI_CRM_CN_Sub_Brand__c);
                            newLine.ASI_CRM_CN_Is_Payment_New__c = false;
                        }
                    }

                    // if (newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                    //     newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'VECDefault','');
                    // }

                    // newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'VECDefault',contract);
                    newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : 0;

                    newLine.ASI_CRM_CN_Est_Total_Dummy__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*newLine.ASI_CRM_CN_Est_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                    contractDetailLines.add(newLine);
                }

                if (psfModuleId != null && psfModuleId.size() > 0) {
                    for (Id mId : psfModuleId) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = line.clone();
                        newLine.ASI_CRM_Module__c = mId;
                        newLine.ASI_CRM_Type__c = 'PSF';
                        newLine.ASI_CRM_CN_Activity_Code__c = psfcode;

                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = null;
                        if (paymentPriceMap.containsKey(newLine.ASI_CRM_Module__c)) {
                            Map<Id,Decimal> priceMap = paymentPriceMap.get(newLine.ASI_CRM_Module__c);
                            if (priceMap.containsKey(newLine.ASI_CRM_CN_Sub_Brand__c)) {
                                newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newLine.ASI_CRM_CN_Sub_Brand__c);
                                newLine.ASI_CRM_CN_Is_Payment_New__c = false;
                            }
                        }

                        // if (newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        //     newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'PSFDefault','');
                        // }

                        // newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'PSFDefault',contract);
                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : 0;


                        newLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'PSFMax','');
                        newLine.ASI_CRM_Max_Incentive__c = newLine.ASI_CRM_Max_Incentive__c == null ? GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'PSFMax',contract) : newLine.ASI_CRM_Max_Incentive__c;
                        newLine.ASI_CRM_CN_Est_Total_Dummy__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*newLine.ASI_CRM_CN_Est_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                        contractDetailLines.add(newLine);
                    }
                }

                if (fcmoduleIds != null && fcmoduleIds.size() > 0) {
                    for (Id mId : fcmoduleIds) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = line.clone();
                        newLine.ASI_CRM_Module__c = mId;
                        newLine.ASI_CRM_Type__c = 'Fixed';

                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = null;
                        newLine.ASI_CRM_CN_Activity_Code__c = fcactivityCodeId.get(newLine.ASI_CRM_Module__c);
                        if (paymentPriceMap.containsKey(newLine.ASI_CRM_Module__c)) {
                            Map<Id,Decimal> priceMap = paymentPriceMap.get(newLine.ASI_CRM_Module__c);
                            if (priceMap.containsKey(newLine.ASI_CRM_CN_Sub_Brand__c)) {
                                newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newLine.ASI_CRM_CN_Sub_Brand__c);
                                newLine.ASI_CRM_CN_Is_Payment_New__c = false;
                            }
                        }

                        // newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'FCDefault',contract);
                        // if (newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        //     newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'FCDefault',newLine.ASI_CRM_CN_Activity_Code__c);
                        // }
                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : 0;
                        

                        newLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'FCMax',newLine.ASI_CRM_CN_Activity_Code__c);
                        newLine.ASI_CRM_CN_Est_Total_Dummy__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*newLine.ASI_CRM_CN_Est_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                        contractDetailLines.add(newLine);
                    }
                }
            }
        } else{

            Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> v00brsfitemMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : [SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Product_Category_Name__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :contract.ASI_CRM_CN_V0_0_PO_version__c AND ASI_CRM_Type__c= 'BRSF' AND ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != '999']) {
                v00brsfitemMap.put(item.ASI_CRM_CN_Sub_Brand__c, item);
            }
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : brsfitemMap.values()) {
                if (v00brsfitemMap.containsKey(item.ASI_CRM_CN_Sub_Brand__c)) {
                    Decimal estQty = v00brsfitemMap.get(item.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Est_Monthly_Qty__c*v00brsfitemMap.get(item.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_No_of_Months__c/contract.ASI_CRM_CN_No_of_Months__c;
                    item.ASI_CRM_CN_Est_Monthly_Qty__c = estQty;
                }
            }
        }

        
        contractDetailLines.addAll(brsfitemMap.values());

        //循环其他的line，更新销售量以及金额
        
            
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c contractLine:contractDetailLines) {
            if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){
                    if (brsfitemMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine = brsfitemMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        if (subBrandIdMaps.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)) {
                            ContractLine.ASI_CRM_Line_Name__c = subBrandIdMaps.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        }
                        ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c = brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c != null ? brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c : 0;
                        ContractLine.ASI_CRM_CN_Est_Total_Dummy__c = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                        ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c = brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c;

                        ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                    }
                }
            }
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> detailLines = updateModuleQty(contractDetailLines,contract);
        return detailLines;

    }

    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> updateModuleQty(List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractDetailLines,ASI_TH_CRM_Contract__c contract) {

        //Module
        // Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>(); // Map <Id, ASI_CRM_Module__c>
        
        // for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Remark_Display__c,ASI_CRM_Remark_Options__c,ASI_CRM_CN_Expected_Est_Total__c,ASI_CRM_Created_PO_Version__c,ASI_CRM_CN_AC_Code__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Group_Contract__c,ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c from ASI_CRM_Module__c where ASI_CRM_Contract__c =:pageId ]){
        //     ModuleMap.put(Module.Id,Module);
        // }
        Set<String> SBBrandSet = new Set<String>();

        Set<Id> sbbrandIds = new Set<Id>();
        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> subbrandLineMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>> gradeLineMap = new Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>>();
        Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>> categoryLineMap = new Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>>();

        Map<String, String> ProductCategoryMap= new Map<String, String> ();   //Map : <Sub-Brand Id,Product Category Name>
            

            // System.debug(LoggingLevel.INFO, '*** ProductCategoryMap: ' + ProductCategoryMap);

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : contractDetailLines) {
            if (line.ASI_CRM_CN_Sub_Brand__c!=null && line.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999' && line.ASI_CRM_Type__c == 'BRSF') {
                line.ASI_CRM_CN_Est_Monthly_Qty__c = formatterQty(line.ASI_CRM_CN_Est_Monthly_Qty__c);
                line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c*line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c*line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                subbrandLineMap.put(line.ASI_CRM_CN_Sub_Brand__c, line);
                SBBrandSet.add(line.ASI_CRM_CN_Sub_Brand__c);

                sbbrandIds.add(line.ASI_CRM_CN_Sub_Brand__c);
                if (gradeLineMap.containsKey(line.ASI_CRM_Sub_Brand_Grade__c)) {
                    gradeLineMap.get(line.ASI_CRM_Sub_Brand_Grade__c).add(line);
                } else {
                    gradeLineMap.put(line.ASI_CRM_Sub_Brand_Grade__c, new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> {line});
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** subbrandLineMap: ' + subbrandLineMap);

        for(ASI_MFM_Sub_brand__c sb:[select Id,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_MFM_Brand__c, ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name from ASI_MFM_Sub_brand__c where RecordType.DeveloperName  like '%CN%' and  id in: SBBrandSet]){
            if(sb.ASI_MFM_Brand__c!=null){
                if(sb.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){  
                ProductCategoryMap.put(sb.Id, sb.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name);//
                } 
            }
        }

        Map<String, ASI_MFM_Sub_brand__c> SubBrandGradeMapping= new Map<String, ASI_MFM_Sub_brand__c> ();  
        for(ASI_MFM_Sub_brand__c sb:[select Id,Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c 
                                     from ASI_MFM_Sub_brand__c 
                                     where RecordType.DeveloperName  like '%CN%' and  id in: SBBrandSet]){
            SubBrandGradeMapping.put(sb.Id, sb);
        }

        Map<String,Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>> nosubbrandMap = new Map<String,Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>>();

        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> lastversionbytotalMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        if (contract.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c != '0.0') {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : [SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Product_Category_Name__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :contract.ASI_CRM_CN_Last_PO_version__c AND ASI_CRM_Volume_Base__c!= 'By Sub-Brand']) {
                if (item.ASI_CRM_Volume_Base__c == 'By Grade') {
                    if (nosubbrandMap.containsKey(item.ASI_CRM_Module__c)) {
                        nosubbrandMap.get(item.ASI_CRM_Module__c).put(item.ASI_CRM_Sub_Brand_Grade__c,item);
                    } else {
                        nosubbrandMap.put(item.ASI_CRM_Module__c, new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>{item.ASI_CRM_Sub_Brand_Grade__c => item});
                    }
                }
                if (item.ASI_CRM_Volume_Base__c == 'By Category') {
                    if (nosubbrandMap.containsKey(item.ASI_CRM_Module__c)) {
                        nosubbrandMap.get(item.ASI_CRM_Module__c).put(item.ASI_CRM_Product_Category_Name__c,item);
                    } else {
                        nosubbrandMap.put(item.ASI_CRM_Module__c, new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>{item.ASI_CRM_Product_Category_Name__c => item});
                    }
                }

                if (item.ASI_CRM_Volume_Base__c == 'By Total') {
                    lastversionbytotalMap.put(item.ASI_CRM_Module__c, item);
                }
            }
        }


        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : contractDetailLines) {
            if (line.ASI_CRM_Type__c == 'BRSF') {
                if (ProductCategoryMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)) {
                    String category = ProductCategoryMap.get(line.ASI_CRM_CN_Sub_Brand__c);
                    if (categoryLineMap.containsKey(category)) {
                        categoryLineMap.get(category).add(line);
                    } else {
                        categoryLineMap.put(category, new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> {line});
                    }
                }
            }
        }


        Map<String,Decimal> CR12FactorMap= new Map<String,Decimal> ();
        
        CR12FactorMap= ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(sbbrandIds,ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c);

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : contractDetailLines) {
            if (line.ASI_CRM_Type__c != 'BRSF') {
                if (line.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && subbrandLineMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfline = subbrandLineMap.get(line.ASI_CRM_CN_Sub_Brand__c);
                    line.ASI_CRM_CN_Est_Monthly_Qty__c = brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c;

                    line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c*line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*Contract.ASI_CRM_CN_No_of_Months__c;

                    line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c*line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*Contract.ASI_CRM_CN_No_of_Months__c;
                }
                if (line.ASI_CRM_Volume_Base__c == 'By Grade') {
                    if (gradeLineMap.containsKey(line.ASI_CRM_Sub_Brand_Grade__c)) {
                        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsflineList = gradeLineMap.get(line.ASI_CRM_Sub_Brand_Grade__c);
                        line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0.00;
                        line.ASI_CRM_Est_Total_QTY_std_Btl__c = 0.00;
                        line.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c = 0.00;
                        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine : brsflineList) {
                            Decimal CR12Factor=1;
                            if(CR12FactorMap.containsKey(brsfLine.ASI_CRM_CN_Sub_Brand__c)){
                                CR12Factor=CR12FactorMap.get(brsfLine.ASI_CRM_CN_Sub_Brand__c);
                            }
                            // System.debug(LoggingLevel.INFO, '*** CR12Factor: ' + CR12Factor);
                            line.ASI_CRM_CN_Est_Monthly_Qty__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null ? 0: brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c);

                            line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor *Contract.ASI_CRM_CN_No_of_Months__c;

                            line.ASI_CRM_Est_Total_QTY_std_Btl__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c *Contract.ASI_CRM_CN_No_of_Months__c;
                            
                            line.ASI_CRM_Est_Monthly_Volume_CR12__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Contract_Monthly_Volume_CR12__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                            if (SubBrandGradeMapping.get(brsfLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<=4 ) {

                                line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c ;

                                line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c ;
                            }

                        }

                        if (line.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                            if (nosubbrandMap.containsKey(line.ASI_CRM_Module__c)) {
                                if (nosubbrandMap.get(line.ASI_CRM_Module__c).containsKey(line.ASI_CRM_Sub_Brand_Grade__c)) {
                                    ASI_CRM_CN_Contract_BRSF_Line_Item__c lastLine = nosubbrandMap.get(line.ASI_CRM_Module__c).get(line.ASI_CRM_Sub_Brand_Grade__c);
                                    line.ASI_CRM_CN_Est_Total_Dummy__c = (lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0 || lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null) ? 0 : (lastLine.ASI_CRM_CN_Est_Total_Dummy__c/lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                                }
                            }
                        } else {
                            line.ASI_CRM_CN_Est_Total_Dummy__c = (line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0 || line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null) ? 0 : (line.ASI_CRM_CN_Contract_Total_Dummy__c/line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                        }
                    }
                }

                if (line.ASI_CRM_Volume_Base__c == 'By Category') {
                    if (categoryLineMap.containsKey(line.ASI_CRM_Product_Category_Name__c)) {
                        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsflineList = categoryLineMap.get(line.ASI_CRM_Product_Category_Name__c);
                        line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0.00;
                        line.ASI_CRM_Est_Total_QTY_std_Btl__c = 0.00;
                        line.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c = 0.00;
                        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine : brsflineList) {
                            Decimal CR12Factor=1;
                            if(CR12FactorMap.containsKey(brsfLine.ASI_CRM_CN_Sub_Brand__c)){
                                CR12Factor=CR12FactorMap.get(brsfLine.ASI_CRM_CN_Sub_Brand__c);
                            }
                            // System.debug(LoggingLevel.INFO, '*** CR12Factor: ' + CR12Factor);
                            line.ASI_CRM_CN_Est_Monthly_Qty__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null ? 0: brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c);

                            line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor *Contract.ASI_CRM_CN_No_of_Months__c;

                            line.ASI_CRM_Est_Total_QTY_std_Btl__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c *Contract.ASI_CRM_CN_No_of_Months__c;
                            
                            line.ASI_CRM_Est_Monthly_Volume_CR12__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Contract_Monthly_Volume_CR12__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                            if (SubBrandGradeMapping.get(brsfLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<=4 ) {

                                line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c ;

                                line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c ;
                            }
                        }

                        if (line.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                            if (nosubbrandMap.containsKey(line.ASI_CRM_Module__c)) {
                                if (nosubbrandMap.get(line.ASI_CRM_Module__c).containsKey(line.ASI_CRM_Product_Category_Name__c)) {
                                    ASI_CRM_CN_Contract_BRSF_Line_Item__c lastLine = nosubbrandMap.get(line.ASI_CRM_Module__c).get(line.ASI_CRM_Product_Category_Name__c);
                                    line.ASI_CRM_CN_Est_Total_Dummy__c = (lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0 || lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null) ? 0 : (lastLine.ASI_CRM_CN_Est_Total_Dummy__c/lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                                }
                            }
                        } else {
                            line.ASI_CRM_CN_Est_Total_Dummy__c = (line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0 || line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null) ? 0 : (line.ASI_CRM_CN_Contract_Total_Dummy__c/line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                        }
                    }
                }

                if (line.ASI_CRM_Volume_Base__c == 'By Total') {
                    line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0.00;
                    line.ASI_CRM_Est_Total_QTY_std_Btl__c = 0.00;
                    line.ASI_CRM_Est_Monthly_Volume_CR12__c = 0.00;
                    line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c = 0.00;
                    line.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                    line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c = 0.00;
                    line.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0.00;
                    line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c = 0.00;
                    line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c = 0.00;
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine : subbrandLineMap.values()) {
                        Decimal CR12Factor=1;
                        if(CR12FactorMap.containsKey(brsfLine.ASI_CRM_CN_Sub_Brand__c)){
                            CR12Factor=CR12FactorMap.get(brsfLine.ASI_CRM_CN_Sub_Brand__c);
                        }

                        line.ASI_CRM_CN_Est_Monthly_Qty__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null ? 0: brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c);

                        line.ASI_CRM_Est_Monthly_Volume_CR12__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                        line.ASI_CRM_Contract_Monthly_Volume_CR12__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                        line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor *Contract.ASI_CRM_CN_No_of_Months__c;

                        line.ASI_CRM_Est_Total_QTY_std_Btl__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c *Contract.ASI_CRM_CN_No_of_Months__c;

                        if (SubBrandGradeMapping.get(brsfLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<=4 ) {

                            line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c ;

                            line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c ;
                        }
                    }

                    if (line.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                        if (lastversionbytotalMap.containsKey(line.ASI_CRM_Module__c)) {
                            ASI_CRM_CN_Contract_BRSF_Line_Item__c lastLine = lastversionbytotalMap.get(line.ASI_CRM_Module__c);
                            line.ASI_CRM_CN_Est_Total_Dummy__c = (lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0 || lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null) ? 0 : (lastLine.ASI_CRM_CN_Est_Total_Dummy__c/lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                        }
                    } else {
                        line.ASI_CRM_CN_Est_Total_Dummy__c = (line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0 || line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null) ? 0 : (line.ASI_CRM_CN_Contract_Total_Dummy__c/line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                    }
                }
            }
        }

        return contractDetailLines;
    }

    public Decimal GeneratingIncentive(Map<String, ASI_CRM_Sub_Brand_Grade__c> SBGradeMap ,String SubBrandGradeName,String TypeName , ASI_TH_CRM_Contract__c ContractSelected){
        
        
        Decimal Incentive=0.0;
        String ExternalKey=SubBrandGradeName;
        
        ExternalKey+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c:'';
        ExternalKey+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
        
        String CityTierExternalKey = ExternalKey;
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c!=null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
            CityTierExternalKey+= ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
        }
        
        if(TypeName =='BRSFDefault'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
            }else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
            }else if(SBGradeMap.containsKey(SubBrandGradeName)){Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_CN_Incentive__c;
            }            
        }
        
        
        
        if(TypeName =='BRSFMax'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;
            }
            else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
            }
            else if(SBGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
            }            
        }
        
        if(TypeName =='PSFMax'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;                                                          
            }
            else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }
            else if(SBGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive_for_PSF__c;
            }
        }

        //3.18新增
        if(TypeName =='FCMax'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;                                                          
            }
            else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
            }
            else if(SBGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
            }
        }
        
        
        if(Incentive==null){ Incentive=0;
        }
        return Incentive;
    }

    //GeneratingIncentive2nd
    public static Decimal GeneratingIncentive(Map<String, ASI_CRM_CM_GS__c> gsMap ,String subBrand,Date setDate,String TypeName,String acCode){
        
        
        Decimal Incentive=null;
        String CityTierExternalKey=subBrand;

        if(TypeName =='BRSFDefault'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive_BRSF__c;
            }
        }
        
        
        
        if(TypeName =='BRSFMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_BRSF__c;
            }
        }
        
        if(TypeName =='PSFMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_PSF__c;
            }
        }

        if(TypeName =='PSFDefault'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive_PSF__c;
            }
        }

        if(TypeName =='VECDefault'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive_VEC__c;
            } else {
                Incentive = 0.00;
            }
        }


        if(TypeName =='VECMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_VEC__c;
            } else {
                Incentive = 99999;
            }
        }


        //3.18新增
        if(TypeName =='FCMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                ASI_CRM_CM_GS__c gs = gsMap.get(CityTierExternalKey);
                for (ASI_CRM_Actual_CM_GS_Line__c gsline : gs.Actual_CM_GS_Lines__r) {
                    if (String.isNotBlank(acCode) && gsline.ASI_CRM_CN_Activity_Code__c == acCode) {
                        Incentive = gsline.ASI_CRM_CN_Max_Incentive__c;
                    }
                }
            }
            if (Incentive == null) {
                Incentive = 99999;
            }
        }

        if (TypeName =='FCDefault') {
            if(gsMap.containsKey(CityTierExternalKey)){ 
                ASI_CRM_CM_GS__c gs = gsMap.get(CityTierExternalKey);
                for (ASI_CRM_Actual_CM_GS_Line__c gsline : gs.Actual_CM_GS_Lines__r) {
                    if (String.isNotBlank(acCode) && gsline.ASI_CRM_CN_Activity_Code__c == acCode) {
                        Incentive = gsline.ASI_CRM_CN_Incentive__c;
                    }
                }
            }
            if (Incentive == null) {
                Incentive = 0;
            }
        }
        
        
        return Incentive;
    }

    // ******************PO Modification Process ******************
    Public void POModificationProcess1(ASI_TH_CRM_Contract__c Contract){
        
        // Date TempStartDate=ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
        //Date TempEndDate=ContractSelected.ASI_CRM_CN_PO_End_Date__c;
        
        //ContractSelected.ASI_CRM_CN_PO_Start_Date__c=StartDate;
        //ContractSelected.ASI_CRM_CN_PO_End_Date__c=EndDate;
        
        
        ASI_TH_CRM_Contract__c ContractCloned  = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        
        Contract.ASI_CRM_CN_Last_PO_version__c=ContractCloned.id;
        //ContractSelected.ASI_CRM_CN_PO_Start_Date__c=TempStartDate;
        //ContractSelected.ASI_CRM_CN_PO_End_Date__c=TempEndDate;
        
        Contract.ASI_CRM_CN_Status__c = 'Draft';
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_CN_Contract_Upload__c=true;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c=null;
        Contract.ASI_CRM_Auto_PO_Modification__c=false;
        //update Contract;
        
        
        Contract.ASI_CRM_CN_PO_Modification__c = true;
        
        if(Contract.ASI_CRM_CN_PO_Version__c=='0.0'){
            Contract.ASI_CRM_CN_V0_0_PO_version__c=ContractCloned.id;
        }
        
        List<String> poVersionSplit = contract.ASI_CRM_CN_PO_Version__c.split('\\.',0);
        if(poVersionSplit != null && poVersionSplit.size() ==2){
            Contract.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1])+1);
        }
        Contract.ASI_CRM_Copied_From__c=ContractCloned.Id; // Previous Contract
        system.debug('********************update Contract**********************');
        
        update Contract;
        
        system.debug('IsClon  :'+Contract.ASI_CRM_CN_IsClone__c);
        system.debug('Start_Date :'+Contract.ASI_CRM_CN_PO_Start_Date__c);
        system.debug('End_Date : '+Contract.ASI_CRM_CN_PO_End_Date__c);
        
        ASI_TH_CRM_Contract__c SelectContract= [select Id,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,ASI_CRM_Copied_From__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Contract_Upload__c,ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grand_Estimate_Total__c
                                                from ASI_TH_CRM_Contract__c WHERE id =:pageId ];
        
        // if changing the 'start date' and 'end date', system will re-calculate the amount
        if( (StartDate!=Contract.ASI_CRM_CN_PO_Start_Date__c || EndDate != ContractSelected.ASI_CRM_CN_PO_End_Date__c)&& NoOfMonths !=integer.valueOf(SelectContract.ASI_CRM_CN_No_of_Months__c ) ){
            
            
            
            Boolean VECIsBySubBrand=false;
            //****Calculate v0.0 amount
            Decimal V0BRSFContractAmount=0;
            Decimal V0PSFContractAmount=0;
            Decimal V0PSFContractAmount_noSB=0;
            Decimal V0PSFEstimateAmount_noSB=0;
            Decimal V0VECContractAmount=0;
            
            Decimal V0BRSFEstimateAmount=0;
            Decimal V0PSFEstimateAmount=0;
            Decimal V0VECEstimateAmount=0;
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> V0ContractDetailLines =[SELECT Id,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                                WHERE ASI_CRM_CN_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c] ;
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:V0ContractDetailLines){
                if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){
                        if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                            V0BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            V0BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                        if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                            V0PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            V0PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                        if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                            VECIsBySubBrand=true;
                            V0VECContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            
                        }
                    }
                }else{
                    if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                        V0PSFContractAmount_noSB+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                        V0PSFEstimateAmount_noSB+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }
                if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                    V0VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
            }
            
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpdatedDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            //current version Contract Line
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines =[SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                              WHERE ASI_CRM_CN_Contract__c = :PageId] ;
            
            map<String, ASI_CRM_CN_EditHeavyContractDetailCtrl.interimData> ContractLineItem_Map = new map<String, ASI_CRM_CN_EditHeavyContractDetailCtrl.interimData> ();
            
            String BRSFModuleId= '';
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractDetailLines){
                system.debug(ContractLine.ID+ 'Key Map : '+ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c );
                if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                    BRSFModuleId = ContractLine.ASI_CRM_Module__c;
                }
                //by Line Type(BRSF/PSF/VEC) + Module Id
                if(ContractLineItem_Map.containsKey(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c)){
                    ContractLineItem_Map.get(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                }else{//New 
                    ASI_CRM_Module__c TempModule= new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c=ContractLine.ASI_CRM_Volume_Base__c,ASI_CRM_Line_Type__c=ContractLine.ASI_CRM_Type__c);
                    ASI_CRM_CN_EditHeavyContractDetailCtrl.interimData TempData= new ASI_CRM_CN_EditHeavyContractDetailCtrl.interimData(TempModule);
                    TempData.DetailLineMap.put(ContractLine.Id,ContractLine);
                    ContractLineItem_Map.put(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c, TempData);
                    
                }
            }
            
            
            Decimal BRSFPreviousEstimateAmount=0;
            Decimal PSFPreviousEstimateAmount=0;
            Decimal VECPreviousEstimateAmount=0;
            
            Decimal BRSFContractAmount=0;
            Decimal PSFContractAmount=0;
            Decimal VECContractAmount=0;
            
            Decimal BRSFEstimateAmount=0;
            Decimal PSFEstimateAmount=0;
            Decimal VECEstimateAmount=0;
            Decimal DiffMonth = SelectContract.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c-SelectContract.ASI_CRM_CN_No_of_Months__c;
            Id subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1].id;
            Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
            
            for(String HeaderKey:ContractLineItem_Map.keySet()){
                ASI_CRM_CN_Contract_BRSF_Line_Item__c AjustmentLine =new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=pageId,ASI_CRM_Module__c=BRSFModuleId,
                    ASI_CRM_Adjustment_Line__c=true,
                    recordTypeId=BRSFLineRtId, ASI_CRM_CN_Sub_Brand__c = subbrand999,
                    ASI_CRM_CN_Est_Monthly_Qty__c = 0,ASI_CRM_CN_Contract_Monthly_Qty__c=0,
                    ASI_CRM_CN_Est_Total_Dummy__c=0,
                    ASI_CRM_CN_Contract_Total_Dummy__c=0,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0);
                String CreatedModuleVersion ='';
                for(String keyline:ContractLineItem_Map.get(HeaderKey).DetailLineMap.keySet()){
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine =ContractLineItem_Map.get(HeaderKey).DetailLineMap.get(keyline);
                    CreatedModuleVersion = ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null ? ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c  : '';
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                        
                        if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                            BRSFPreviousEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                            PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                            VECPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                        
                        
                        AjustmentLine.ASI_CRM_Type__c=ContractLine.ASI_CRM_Type__c!=null? ContractLine.ASI_CRM_Type__c : 'BRSF';
                        if(ContractLine.ASI_CRM_Module__c!=null){
                            AjustmentLine.ASI_CRM_Module__c = ContractLine.ASI_CRM_Module__c ;
                        }
                        
                        //if this contarct line is 999-line, save the id
                        if(ContractLine.ASI_CRM_Adjustment_Line__c || ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c =='999'){
                            AjustmentLine.Id=ContractLine.Id;
                        }else{//if this contarct line is not 999-line, perform calculation
                            ContractLine.ASI_CRM_CN_Est_Total_Dummy__c= ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                            ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                            
                            AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c += (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*DiffMonth: 0;
                            AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c  += (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*DiffMonth: 0;
                            
                            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                                BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                                BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                                
                            }else if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                                PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                                PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                                
                            }else if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                                VECContractAmount+= ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                                VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            }
                            UpdatedDetailLines.add(ContractLine);
                        }
                        
                        
                    }else{ // Not By SubBrand---> By Grade/Category/ Total
                        //ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c == null) ? 0:ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * SelectContract.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c;
                        ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        //ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c == null) ? 0:ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c;
                        ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        
                        UpdatedDetailLines.add(ContractLine);
                        
                        if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                            BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            BRSFPreviousEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                            PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0; 
                            PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                            VECContractAmount+= ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            VECPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                    }
                }// end of looping this Module
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                    AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = BRSFPreviousEstimateAmount-BRSFEstimateAmount; 
                }
                
                //checking if need to create/update 999-Line 
                if(AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c !=0 || AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c!=0){
                    if(CreatedModuleVersion!='0.0'){
                        AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c= 0 ;
                    }
                    
                    if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                        BRSFContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                        BRSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                        
                    }
                    if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='PSF' ){
                        PSFContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                        PSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }
                    
                    if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                        VECContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                        VECEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }
                    System.debug(LoggingLevel.INFO, '*** AjustmentLine: ' + AjustmentLine);
                    system.debug('AjustmentLine: '+AjustmentLine.Id);
                    UpdatedDetailLines.add(AjustmentLine);
                }
                
                
                
                
            }//Ending of Contract Line looping
            
            if(SelectContract.ASI_CRM_CN_PO_Version__c!='0.1' && SelectContract.ASI_CRM_Copied_From__c!=null && SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c !=null){
                PSFPreviousEstimateAmount=SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
            }
            
            
            ///**************************updating record **************************************************************
            if(UpdatedDetailLines.size()>0){
                upsert UpdatedDetailLines;
            }
            
            //BRSF
            SelectContract.ASI_CRM_CN_Expected_BRSF_Est_Total__c=BRSFPreviousEstimateAmount;
            SelectContract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c=V0BRSFEstimateAmount;
            
            //PSF
            
            SelectContract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c=V0PSFEstimateAmount+V0PSFEstimateAmount_noSB;
            SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=PSFPreviousEstimateAmount;
            SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=0;
            SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c=PSFPreviousEstimateAmount;
            
            SelectContract.ASI_CRM_PSF_Grand_Estimate_Total__c=PSFEstimateAmount+V0PSFEstimateAmount_noSB;
            SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c=PSFContractAmount+V0PSFContractAmount_noSB;
            SelectContract.ASI_CRM_PSF_Contract_Adjustment_Amount__c=V0PSFContractAmount-PSFContractAmount;
            SelectContract.ASI_CRM_V0_PSF_Contract_Total__c=V0PSFContractAmount+V0PSFContractAmount_noSB;
            
            
            //VEC
            if(VECIsBySubBrand){
                if(SelectContract.ASI_CRM_CN_PO_Version__c!='0.1' ){
                    SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c= V0VECEstimateAmount;
                }else{
                    SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECPreviousEstimateAmount;
                }
                
            }else{// is not by Sub-Brand
                SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECPreviousEstimateAmount;
                
            }
            
            SelectContract.ASI_CRM_Expected_V0_0_VEC_Est_Total__c =V0VECEstimateAmount;
            
            
            update SelectContract;
            
            
            
            
            
            
            
        }else{
            Decimal BRSFContractAmount=0;
            Decimal PSFContractAmount=0;
            Decimal VECContractAmount=0;
            
            Decimal BRSFEstimateAmount=0;
            Decimal PSFEstimateAmount=0;
            Decimal VECEstimateAmount=0;
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines =[SELECT Id,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :PageId] ;
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractDetailLines){
                
                if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                    BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
                
                if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                    PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
                
                if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                    VECContractAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
            } 
            
            if(SelectContract.ASI_CRM_CN_PO_Version__c=='0.1' ){
                //BRSF
                SelectContract.ASI_CRM_CN_Expected_BRSF_Est_Total__c=BRSFEstimateAmount;
                SelectContract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c=BRSFEstimateAmount;
                
                //PSF
                SelectContract.ASI_CRM_PSF_Grand_Estimate_Total__c=PSFEstimateAmount;
                SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=PSFEstimateAmount;
                SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=0;
                SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c=PSFEstimateAmount;
                SelectContract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c=PSFEstimateAmount;
                SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c=PSFContractAmount;
                SelectContract.ASI_CRM_V0_PSF_Contract_Total__c=PSFContractAmount;
                
                
                //VEC
                SelectContract.ASI_CRM_Expected_V0_0_VEC_Est_Total__c =VECEstimateAmount;
                SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECEstimateAmount;
                
            }else{
                SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=0;
                SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c; 
            }
            
            
            
            
            update SelectContract;  
        }
        
    }

    // shared function 
    public String newCounterCreatorLine() {
        
        String idNew;
        IF(LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            LINE_ITEM_NEWRECORD_COUNTER+=1;
        }
        
        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;
        
        if(LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    // ******************PO Modification Process ******************
    Public void POModificationProcess12nd(ASI_TH_CRM_Contract__c Contract){
        
        // Date TempStartDate=ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
        //Date TempEndDate=ContractSelected.ASI_CRM_CN_PO_End_Date__c;
        
        //ContractSelected.ASI_CRM_CN_PO_Start_Date__c=StartDate;
        //ContractSelected.ASI_CRM_CN_PO_End_Date__c=EndDate;
        ASI_TH_CRM_Contract__c ContractCloned = new ASI_TH_CRM_Contract__c();

        ContractCloned = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        
        Contract.ASI_CRM_CN_Last_PO_version__c=ContractCloned.id;
        //ContractSelected.ASI_CRM_CN_PO_Start_Date__c=TempStartDate;
        //ContractSelected.ASI_CRM_CN_PO_End_Date__c=TempEndDate;
        
        Contract.ASI_CRM_CN_Status__c = 'Draft';
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_CN_Contract_Upload__c=true;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c=null;
        Contract.ASI_CRM_Auto_PO_Modification__c=false;
        //update Contract;
        
        Date CutOffDay = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Date v0TillEndPOM = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, contract.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        Integer mothNo = Contract.ASI_CRM_CN_PO_Start_Date__c.monthsBetween(v0TillEndPOM.addDays(1));
        Contract.ASI_CRM_CN_PO_Modification__c = true;
        
        if(Contract.ASI_CRM_CN_PO_Version__c=='0.0'){
            Contract.ASI_CRM_CN_V0_0_PO_version__c=ContractCloned.id;
        }
        
        List<String> poVersionSplit = contract.ASI_CRM_CN_PO_Version__c.split('\\.',0);
        if(poVersionSplit != null && poVersionSplit.size() ==2){
            Contract.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1])+1);
        }
        Contract.ASI_CRM_Copied_From__c=ContractCloned.Id; // Previous Contract
        system.debug('********************update Contract**********************');
        
        update Contract;
        
        system.debug('IsClon  :'+Contract.ASI_CRM_CN_IsClone__c);
        system.debug('Start_Date :'+Contract.ASI_CRM_CN_PO_Start_Date__c);
        system.debug('End_Date : '+Contract.ASI_CRM_CN_PO_End_Date__c);

        ASI_TH_CRM_Contract__c SelectContract= [select Id,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,ASI_CRM_Copied_From__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_Start_Date__c,
        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_PO_End_Date__c,
        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c,
        
        ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Contract_Upload__c,ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grand_Estimate_Total__c
                                                from ASI_TH_CRM_Contract__c WHERE id =:pageId ];
        

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> V0ContractDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lastvisonlines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        String detailsql = 'SELECT Id,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ';
        if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != ContractSelected.ASI_CRM_Copied_From__c) {
            String v00DetailSql = detailsql + 'ASI_CRM_CN_Contract__c =\'' + ContractSelected.ASI_CRM_CN_V0_0_PO_version__c + '\'';
            String preDetailSql = detailsql + 'ASI_CRM_CN_Contract__c =\'' + ContractSelected.ASI_CRM_Copied_From__c + '\'';
            V0ContractDetailLines = Database.query(v00DetailSql);
            lastvisonlines = Database.query(preDetailSql);
        } else {
            String v00DetailSql = detailsql + 'ASI_CRM_CN_Contract__c =\'' + ContractSelected.ASI_CRM_CN_V0_0_PO_version__c + '\'';
            V0ContractDetailLines = Database.query(v00DetailSql);
            lastvisonlines.addAll(V0ContractDetailLines);
        }

        // if changing the 'start date' and 'end date', system will re-calculate the amount
        if( (StartDate!=Contract.ASI_CRM_CN_PO_Start_Date__c || EndDate != ContractSelected.ASI_CRM_CN_PO_End_Date__c)&& NoOfMonths !=integer.valueOf(SelectContract.ASI_CRM_CN_No_of_Months__c ) ){

            Boolean VECIsBySubBrand=false;
            //****Calculate v0.0 amount
            Decimal V0BRSFContractAmount=0;
            Decimal V0PSFContractAmount=0;
            Decimal V0PSFContractAmount_noSB=0;
            Decimal V0PSFEstimateAmount_noSB=0;
            Decimal V0VECContractAmount=0;
            
            Decimal V0BRSFEstimateAmount=0;
            Decimal V0PSFEstimateAmount=0;
            Decimal V0VECEstimateAmount=0;

            Map<Id,Decimal> v0FCEstimateTotalAmount = new Map<Id,Decimal>();
            Map<Id,Decimal> v0FCConAmount = new Map<Id,Decimal> ();
            Map<Id,Decimal> v0FCPerEstimateAmount = new Map<Id,Decimal> ();
            // Map<Id,Decimal> v0FCadjustEstimateAmount = new Map<Id,Decimal> ();
            // Map<Id,Decimal> v0FCadjustEstimateAmount = new Map<Id,Decimal> ();
            // 
            Decimal perivousESTTotal = 0.00;
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:lastvisonlines){
                if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){

                        //计算上个版本的固定费用单独module的预计总金额
                        if(ContractLine.ASI_CRM_Type__c== 'Fixed'){
                            if (v0FCPerEstimateAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                                Decimal amount = v0FCPerEstimateAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                                amount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                                v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                            } else {
                                v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Est_Total_Dummy__c);
                            }
                        }

                        if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                            perivousESTTotal += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                        }
                    }
                }else{
                    if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                        perivousESTTotal += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'Fixed') {
                        // if (ContractLine.ASI_CRM_Volume_Base__c != 'By Sub-Brand') {
                        if (v0FCPerEstimateAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                            Decimal amount = v0FCPerEstimateAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                            amount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                            v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                        } else {
                            v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Est_Total_Dummy__c);
                        }
                    }
                }
            }
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:V0ContractDetailLines){
                if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){
                        if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                            V0BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            V0BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                        if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                            V0PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            V0PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                        if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                            VECIsBySubBrand=true;
                            V0VECContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            
                        }

                        //计算上个版本的固定费用单独module的预计总金额
                        if(ContractLine.ASI_CRM_Type__c== 'Fixed'){
                            if (v0FCEstimateTotalAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                                Decimal amount = v0FCEstimateTotalAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                                amount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                                v0FCEstimateTotalAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                            } else {
                                v0FCEstimateTotalAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Est_Total_Dummy__c);
                            }
                            if (v0FCConAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                                Decimal amount = v0FCConAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                                amount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                                v0FCConAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                            } else {
                                v0FCConAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c);
                            }
                        }
                    }
                }else{
                    if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                        V0PSFContractAmount_noSB+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                        V0PSFEstimateAmount_noSB+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'Fixed') {
                        // if (ContractLine.ASI_CRM_Volume_Base__c != 'By Sub-Brand') {
                        if (v0FCEstimateTotalAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                            Decimal amount = v0FCEstimateTotalAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                            amount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                            v0FCEstimateTotalAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, amount);
                        } else {
                            v0FCEstimateTotalAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,ContractLine.ASI_CRM_CN_Est_Total_Dummy__c);
                        }
                        if (v0FCConAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                            Decimal amount = v0FCConAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                            amount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                            v0FCConAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                        } else {
                            v0FCConAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c);
                        }
                    }
                }
                if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                    V0VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
            }
            
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpdatedDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

            // Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c> toupdatelines = new Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines = updateLineData(SelectContract);
            
            // for (Integer i = ContractDetailLines.size() - 1; i >= 0; i--) {
            //     ASI_CRM_CN_Contract_BRSF_Line_Item__c item = ContractDetailLines.get(i);
            //     if (String.isBlank(item.Id)) {
            //         UpdatedDetailLines.add(item);
            //         ContractDetailLines.remove(i);
            //     } else {
            //         toupdatelines.put(item.Id, item);
            //     }
            // }
            if (ContractCloned.ASI_CRM_CN_PO_Version__c=='0.0') {
                List<ASI_CRM_CN_FixedMappingSetting__c> settingList = new List<ASI_CRM_CN_FixedMappingSetting__c>();
                for (String key : v0FCPerEstimateAmount.keySet()) {
                    ASI_CRM_CN_FixedMappingSetting__c setting = ASI_CRM_CN_FixedMappingSetting__c.getInstance(key);
                    settingList.add(setting);
                }
                // SObject obj = ContractCloned;
                for (ASI_CRM_CN_FixedMappingSetting__c setting : settingList) {
                    SelectContract.put(setting.ASI_CRM_CN_Contract_Mapping_Field__c, v0FCPerEstimateAmount.get(setting.ASI_CRM_CN_Activity_CodeId__c));
                }
                updateFCModuleAmount(PageId,v0FCConAmount,v0FCEstimateTotalAmount,v0FCPerEstimateAmount);
            }

            
            
            map<String, interimData> ContractLineItem_Map = new map<String, interimData> ();

            Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c> Line999Map = new Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

            List<Id> deleteItemIds = new List<Id>();

            String BRSFModuleId= '';
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractDetailLines){
                system.debug(ContractLine.ID+ 'Key Map : '+ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c );
                if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                    BRSFModuleId = ContractLine.ASI_CRM_Module__c;
                }
                //by Line Type(BRSF/PSF/VEC) + Module Id
                if(ContractLineItem_Map.containsKey(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c)){
                    ContractLineItem_Map.get(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c).DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), ContractLine);
                }else{//New 
                    ASI_CRM_Module__c TempModule= new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c=ContractLine.ASI_CRM_Volume_Base__c,ASI_CRM_Line_Type__c=ContractLine.ASI_CRM_Type__c);
                    interimData TempData= new interimData(TempModule);
                    TempData.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), ContractLine);
                    ContractLineItem_Map.put(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c, TempData);
                    
                }
            }
            
            
            Decimal BRSFPreviousEstimateAmount=0;
            Decimal PSFPreviousEstimateAmount=0;
            Decimal VECPreviousEstimateAmount=0;
            
            Decimal BRSFContractAmount=0;
            Decimal PSFContractAmount=0;
            Decimal VECContractAmount=0;
            
            Decimal BRSFEstimateAmount=0;
            Decimal PSFEstimateAmount=0;
            Decimal VECEstimateAmount=0;
            Decimal DiffMonth = SelectContract.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c-SelectContract.ASI_CRM_CN_No_of_Months__c;

            Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
            
            for(String HeaderKey:ContractLineItem_Map.keySet()){
                ASI_CRM_CN_Contract_BRSF_Line_Item__c AjustmentLine =new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=pageId,ASI_CRM_Module__c=BRSFModuleId,
                    ASI_CRM_Adjustment_Line__c=true,
                    recordTypeId=BRSFLineRtId, ASI_CRM_CN_Sub_Brand__c = subbrand999,
                    ASI_CRM_CN_Est_Monthly_Qty__c = 0,ASI_CRM_CN_Contract_Monthly_Qty__c=0,
                    ASI_CRM_CN_Est_Total_Dummy__c=0,
                    ASI_CRM_CN_Contract_Total_Dummy__c=0,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0);
                String CreatedModuleVersion ='';
                for(String keyline:ContractLineItem_Map.get(HeaderKey).DetailLineMap.keySet()){
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine =ContractLineItem_Map.get(HeaderKey).DetailLineMap.get(keyline);
                    if (String.isBlank(CreatedModuleVersion)) {
                        CreatedModuleVersion = ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null ? ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c  : '';
                    }
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                        
                        if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                            BRSFPreviousEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                            PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                            System.debug(LoggingLevel.INFO, '*** ContractLine: ' + ContractLine);
                            VECPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                        
                        
                        AjustmentLine.ASI_CRM_Type__c=ContractLine.ASI_CRM_Type__c!=null? ContractLine.ASI_CRM_Type__c : 'BRSF';

                        AjustmentLine.ASI_CRM_CN_Activity_Code__c = ContractLine.ASI_CRM_CN_Activity_Code__c!=null? ContractLine.ASI_CRM_CN_Activity_Code__c : null;
                        if(ContractLine.ASI_CRM_Module__c!=null){
                            AjustmentLine.ASI_CRM_Module__c = ContractLine.ASI_CRM_Module__c ;
                        }
                        //if this contarct line is 999-line, save the id
                        if(ContractLine.ASI_CRM_Adjustment_Line__c || ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c =='999'){
                            AjustmentLine.Id=ContractLine.Id;
                        }else{//if this contarct line is not 999-line, perform calculation
                            System.debug(LoggingLevel.INFO, '*** DiffMonth: ' + DiffMonth);
                            AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c += (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*DiffMonth: 0;
                            AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c  += (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*DiffMonth: 0;
                            
                            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                                BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                                BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                                
                            }else if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                                PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                                PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                                
                            }else if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                                VECContractAmount+= ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                                VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            }
                        }
                        
                        
                    }else{ // Not By SubBrand---> By Grade/Category/ Total
                        if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                            BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            BRSFPreviousEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                            PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0; 
                            PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }else if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                            VECContractAmount+= ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            VECPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                    }
                }// end of looping this Module
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                    AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = BRSFPreviousEstimateAmount-BRSFEstimateAmount; 
                    // AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = 0;
                }
                
                //checking if need to create/update 999-Line 
                if(AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c !=0 || AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c!=0){
                    System.debug(LoggingLevel.INFO, '*** CreatedModuleVersion: ' + CreatedModuleVersion);
                    if(CreatedModuleVersion!='0.0'){
                        AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c= 0 ;
                    }
                    
                    if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                        BRSFContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                        // BRSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                        
                    }
                    if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='PSF' ){
                        PSFContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                        // PSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }
                    
                    if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                        VECContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                        VECEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }
                    AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = 0.00;
                    system.debug('AjustmentLine: '+AjustmentLine);
                    if (AjustmentLine.Id != null) {
                        Line999Map.put(AjustmentLine.Id, AjustmentLine);
                    } else {
                        ContractDetailLines.add(AjustmentLine);
                    }
                } else {
                    if (AjustmentLine.Id != null) {
                        deleteItemIds.add(AjustmentLine.Id);
                    }
                }
                
                
                
                
            }//Ending of Contract Line looping
            
            if(SelectContract.ASI_CRM_CN_PO_Version__c!='0.1' && SelectContract.ASI_CRM_Copied_From__c!=null && SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c !=null){
                PSFPreviousEstimateAmount=SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
            }
            
            
            ///**************************updating record **************************************************************
            System.debug(LoggingLevel.INFO, '*** Line999Map: ' + Line999Map);
            if(ContractDetailLines.size()>0){
                for (Integer i = ContractDetailLines.size() - 1;i >= 0 ; i--) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c line = ContractDetailLines.get(i);
                    if (Line999Map.containsKey(line.Id)) {
                        ContractDetailLines.remove(i);
                        contractDetailLines.add(Line999Map.get(line.Id));
                    }
                }
                upsert ContractDetailLines;
            }
            
            //BRSF
            SelectContract.ASI_CRM_CN_Expected_BRSF_Est_Total__c=BRSFEstimateAmount;
            SelectContract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c=V0BRSFEstimateAmount;
            
            //PSF
            
            SelectContract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c=V0PSFEstimateAmount+V0PSFEstimateAmount_noSB;
            if (SelectContract.ASI_CRM_CN_PO_Version__c == '0.1') {
                SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=perivousESTTotal;
            } else {
                SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c = SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
            }
            // SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=perivousESTTotal;
            SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=PSFEstimateAmount-SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c;
            SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c=PSFEstimateAmount;
            
            SelectContract.ASI_CRM_PSF_Grand_Estimate_Total__c=PSFEstimateAmount+V0PSFEstimateAmount_noSB;
            SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c=PSFContractAmount+V0PSFContractAmount_noSB;
            SelectContract.ASI_CRM_PSF_Contract_Adjustment_Amount__c=V0PSFContractAmount-PSFContractAmount;
            SelectContract.ASI_CRM_V0_PSF_Contract_Total__c=V0PSFContractAmount+V0PSFContractAmount_noSB;
            
            
            //VEC
            if(VECIsBySubBrand){
                if(SelectContract.ASI_CRM_CN_PO_Version__c!='0.1' ){
                    SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c= V0VECEstimateAmount;
                }else{
                    SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECPreviousEstimateAmount;
                }
                
            }else{// is not by Sub-Brand
                SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECPreviousEstimateAmount;
                
            }
            
            SelectContract.ASI_CRM_Expected_V0_0_VEC_Est_Total__c =V0VECEstimateAmount;
            
            
            if (mothNo >= (SelectContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c!= null ?SelectContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c:6)) {
                SelectContract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = Date.today();
            } else {
                SelectContract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = null;
            }

            update SelectContract;
            Database.delete(deleteItemIds);
            
            
            
            
            
            
        }else{

            Decimal perivousESTTotal = 0.00;
            Map<Id,Decimal> v0FCEstimateTotalAmount = new Map<Id,Decimal>();
            Map<Id,Decimal> v0FCConAmount = new Map<Id,Decimal> ();
            Map<Id,Decimal> v0FCPerEstimateAmount = new Map<Id,Decimal> ();
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:lastvisonlines){
                if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){

                        //计算上个版本的固定费用单独module的预计总金额
                        if(ContractLine.ASI_CRM_Type__c== 'Fixed'){
                            if (v0FCPerEstimateAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                                Decimal amount = v0FCPerEstimateAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                                amount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                                v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                            } else {
                                v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Est_Total_Dummy__c);
                            }
                        }

                        if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                            perivousESTTotal += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                        }
                    }
                }else{
                    if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                        perivousESTTotal += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'Fixed') {
                        // if (ContractLine.ASI_CRM_Volume_Base__c != 'By Sub-Brand') {
                        if (v0FCPerEstimateAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                            Decimal amount = v0FCPerEstimateAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                            amount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                            v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                        } else {
                            v0FCPerEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Est_Total_Dummy__c);
                        }
                    }
                }
            }

            Decimal v00ContractPsf = 0.00;
            Decimal v00estpsf = 0.00;

            Decimal v00estbrsf = 0.00;

            Decimal v00estvec = 0.00;

            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:V0ContractDetailLines){
                if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){
                        if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                            v00ContractPsf+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                            v00estpsf+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }

                        if(ContractLine.ASI_CRM_Type__c== 'BRSF' ){
                            v00estbrsf+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }

                        if (ContractLine.ASI_CRM_Type__c == 'Variable Event Cost') {
                            v00estvec+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        }
                    }
                }else{
                    if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                        v00ContractPsf+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                        v00estpsf+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }

                    if(ContractLine.ASI_CRM_Type__c== 'BRSF' ){
                        v00estbrsf+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }

                    if (ContractLine.ASI_CRM_Type__c == 'Variable Event Cost') {
                        v00estvec+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }
            }
            Decimal BRSFContractAmount=0;
            Decimal PSFContractAmount=0;
            Decimal VECContractAmount=0;
            
            Decimal BRSFEstimateAmount=0;
            Decimal PSFEstimateAmount=0;
            Decimal VECEstimateAmount=0;

            
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpdatedDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

            Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c> toupdatelines = new Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines = updateLineData(SelectContract);
            // for (Integer i = ContractDetailLines.size() - 1; i >= 0; i--) {
            //     ASI_CRM_CN_Contract_BRSF_Line_Item__c item = ContractDetailLines.get(i);
            //     if (String.isBlank(item.Id)) {
            //         UpdatedDetailLines.add(item);
            //         ContractDetailLines.remove(i);
            //     } else {
            //         toupdatelines.put(item.Id, item);
            //     }
            // }
            if (ContractCloned.ASI_CRM_CN_PO_Version__c=='0.0') {
                List<ASI_CRM_CN_FixedMappingSetting__c> settingList = new List<ASI_CRM_CN_FixedMappingSetting__c>();
                for (String key : v0FCPerEstimateAmount.keySet()) {
                    ASI_CRM_CN_FixedMappingSetting__c setting = ASI_CRM_CN_FixedMappingSetting__c.getInstance(key);
                    settingList.add(setting);
                }
                // SObject obj = ContractCloned;
                for (ASI_CRM_CN_FixedMappingSetting__c setting : settingList) {
                    if (v0FCPerEstimateAmount.containsKey(setting.ASI_CRM_CN_Activity_CodeId__c)) {
                        SelectContract.put(setting.ASI_CRM_CN_Contract_Mapping_Field__c, v0FCPerEstimateAmount.get(setting.ASI_CRM_CN_Activity_CodeId__c));
                    }
                }
            }
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractDetailLines){
                
                if (ContractLine.ASI_CRM_Type__c == 'Fixed') {
                    if (v0FCEstimateTotalAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                        Decimal amount = v0FCEstimateTotalAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                        amount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                        v0FCEstimateTotalAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                    } else {
                        v0FCEstimateTotalAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Est_Total_Dummy__c);
                    }
                    if (v0FCConAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                        Decimal amount = v0FCConAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                        amount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                        v0FCConAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,amount);
                    } else {
                        v0FCConAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c, ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c);
                    }
                }
                if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                    BRSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    BRSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
                
                if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                    PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
                
                if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                    VECContractAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    VECEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
            } 
            
            if(SelectContract.ASI_CRM_CN_PO_Version__c=='0.1' || Test.isRunningTest() ){
                //BRSF
                SelectContract.ASI_CRM_CN_Expected_BRSF_Est_Total__c=BRSFEstimateAmount;
                SelectContract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c=v00estbrsf;
                
                //PSF
                SelectContract.ASI_CRM_PSF_Grand_Estimate_Total__c=PSFEstimateAmount;
                SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=perivousESTTotal;
                SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=PSFEstimateAmount-perivousESTTotal;
                SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c=PSFEstimateAmount;
                if (SelectContract.ASI_CRM_CN_V0_0_PO_version__c == SelectContract.ASI_CRM_CN_Last_PO_version__c) {
                    SelectContract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c;
                } else {
                    SelectContract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = v00estpsf;
                }
                SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c=v00ContractPsf;
                SelectContract.ASI_CRM_V0_PSF_Contract_Total__c=v00ContractPsf;
                //VEC
                SelectContract.ASI_CRM_Expected_V0_0_VEC_Est_Total__c =v00estvec;
                SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECEstimateAmount;
                
            }else{
                SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=0;
                SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c; 
            }
            if (ContractCloned.ASI_CRM_CN_PO_Version__c=='0.0') {
                updateFCModuleAmount(PageId,v0FCConAmount,v0FCEstimateTotalAmount,v0FCPerEstimateAmount);
            }
            
            if(ContractDetailLines.size()>0){
                upsert ContractDetailLines;
            }
            

            if (mothNo >= (SelectContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c!= null ?SelectContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c:6)) {
                SelectContract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = Date.today();
            } else {
                SelectContract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = null;
            }
            update SelectContract;  
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    //Cancel the record 
    public PageReference CancelProcess(){
        PageReference pageRef = null;
        pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef; 
    }

    public Class interimData{
        public ASI_CRM_Module__c Module {set;get;} 
        public boolean HaveRefresh  {set;get;} 
        public String MethodologyValue  {set;get;} {MethodologyValue='';}
        public String MethodologyDisplay  {set;get;} {MethodologyDisplay='';}
        
        
        public map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}

        
        public interimData( ASI_CRM_Module__c ModuleInput){
            this.Module=ModuleInput;
            this.DetailLineMap= new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.HaveRefresh=true;
        }

    }
    
}