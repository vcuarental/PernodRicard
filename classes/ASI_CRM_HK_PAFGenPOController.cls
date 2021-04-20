/*********************************************************************************
 * Name: ASI_CRM_HK_PAFGenPOController
 * Description: 
 * Test Class:  ASI_HK_CRM_PAF_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 *	2015-12-16  							Add start date and End Date
 *			 								Remove mechanic type = Variable
 *	2017-01-25  		Wilken 				Use PAF Customer as PO Customer if it is JDE Account, prompt error if none of the child outlet is JDE Account
 *	2019-02-27  		Wilken				[WL 1.0] Add "PAF Item - Fix Bottle" mechanic type to create PO line, to handle STK4 changes
 *	2019-03-01  		Wilken				[WL 2.0] Change PAF PO Line Customer assignment logic
 */


public with sharing class ASI_CRM_HK_PAFGenPOController {
    public List <SAPHeaderObj> LSAPHeader {set;get;}
    public List <SAPLineObj> SAPL_Item {set;get;}
    public map<integer, SAPLineObj> SAPL_Item_Map {set;get;}
    public List <SAPLineObj> Del_SAPL_Item {set;get;}
    public List <ASI_MFM_PO_Line_Item__c> Save_SAPL_POItem {set;get;}    
    public Integer indexSAPL {set;get;}
    public Integer rowidSAPL {set;get;}
    public String recordtypeSelected {set;get;}
    public asi_mfm_prefix__c po_prefixes;
    public boolean showEdit {set;get;}    
    public ASI_MFM_PO__c create_po;
    public List<CustomSKUMechanicDetail> CustomSKUMechanicDetailsList{ get; set; }
    public CustomSKUMechanicDetail cmd;
    public boolean hasFOC = false;
    public boolean haveValue {get;set;}
    public String PAF_Number;
    public list<selectOption> available_prefixes {get; private set;}
    map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>();   
    public string selected_prefix {get; set;}
    public ASI_HK_CRM_Pre_Approval_Form__c Orginal_PAF {get; set;}
    public ApexPages.StandardController standardController;  
    public String Msg {get;set;}
    public Boolean havePO {get;set;}
    public Boolean haveError {get;set;}
    public string ExistingPO {get;set;}
    
    private static Set<String> requiredLineFields() {
        return new Set<String> {
            'Id'
            , 'ASI_HK_CRM_SKU_Lookup__r.Name'
            , 'ASI_HK_CRM_SKU_Lookup__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_FOC_Packing_Description__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c'
            , 'ASI_CRM_HK_Pricing_Item__c'
            , 'ASI_HK_CRM_Target_Volume_Qty__c'
            , 'ASI_HK_CRM_Price__c'
            , 'ASI_HK_CRM_Pouring__c'
            , 'ASI_HK_CRM_SKU_Value__c'
            , 'ASI_HK_CRM_Conditions_for_Payment__c'
            , 'ASI_HK_CRM_mechanic__r.Name'
            , 'ASI_HK_CRM_Investment_Value__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_4__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_4__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_4__c'
            , 'ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c'
            //, 'ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Category__c'    
            , 'ASI_HK_CRM_Rebate_Disc_Percent__c'
            , 'ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c'
            , 'CurrencyIsoCode'
            , 'ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c'
            , 'ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_JDE_Account__c'
        };
    }
    
    public class CustomSKUMechanicDetail{
        public ASI_HK_CRM_Pre_Approval_Form_Item__c paf_displaySKU{ get; set; }
        public String mechanic_name{ get; set; }
        public String sku_name{ get; set; }
        public String sku_code{ get; set; }
        public String Adj_Name{ get; set; }
        public String pricing_item { get;set;}
        public Decimal buy_bottle{ get; set; }
        public Decimal sell_bottle{ get; set; }
        public Decimal investmentValue{ get; set; }
        public boolean investValueShowDollarSign{ get; set; }
        public boolean perBtShowDollarSign{ get; set; }
        public Boolean checked {get;set;}
        public Boolean Spread{ get; set; }
        
    }
    
    public ASI_CRM_HK_PAFGenPOController(ApexPages.StandardController controller) {
        standardController = controller;
        List<string> fields = new List<string>();
        fields.add('Name');
        fields.add('ASI_HK_CRM_Adjusted_End_Date__c');
        fields.add('ASI_HK_CRM_PAF_End_Date__c');
        fields.add('ASI_HK_CRM_PAF_Customer__c');
        fields.add('ASI_HK_CRM_PAF_Customer__r.Name');
        fields.add('ASI_HK_CRM_PAF_Nature_of_Promotion__c');
        fields.add('ASI_HK_CRM_PAF_Contract_Requirement__c');
        fields.add('ASI_CRM_Short_Term_Promotion__c');
        fields.add('ASI_CRM_Promotion_Category__r.ASI_CRM_Description__c');
        if(!Test.isRunningTest())
        	controller.addFields(fields);        
        Orginal_PAF = (ASI_HK_CRM_Pre_Approval_Form__c)controller.getRecord();
        havePO = false;
        init();
        getMechanic();
    }
    
    public void init(){
        haveValue = true;
        showEdit  = true;
        LSAPHeader = new List<SAPHeaderObj>();
        SAPHeaderObj smp = new SAPHeaderObj();
        smp.id = '1';
        smp.po = new ASI_MFM_PO__c (ASI_MFM_PAF_Number__c = Orginal_PAF.id);
        smp.po.ASI_MFM_PO_Start_Date__c = date.today();
        smp.po.ASI_MFM_PO_End_Date__c = Orginal_PAF.ASI_HK_CRM_Adjusted_End_Date__c;
        smp.po.ASI_MFM_Currency__c = 'HKD';
        smp.pay = new ASI_MFM_Payment__c();
        LSAPHeader.add(smp);
        Del_SAPL_Item = new List<SAPLineObj>();
        SAPL_Item_Map = new Map<Integer, SAPLineObj>();
        indexSAPL = 0;            
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
        for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name from asi_mfm_role_prefix_relationship__c
                                                     where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'PO' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) {
                                                         px_map.put(px.asi_mfm_prefix__c, px);
                                                         px_list.add(px);    
                                                     }                       
        if (px_list.size() > 0) {
            if (px_list.size() == 1)
            {
                selected_prefix = px_list[0].asi_mfm_prefix__c;
                available_prefixes = new list<selectOption>();
                available_prefixes.add(new selectOption(px_list[0].asi_mfm_prefix__c, px_list[0].asi_mfm_prefix__r.name));
            } else { 
                available_prefixes = new list<selectOption>();
                available_prefixes.add(new selectOption('', '-- None --'));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                }
            }
        }
        ExistingPO = '';
        List<ASI_MFM_PO__c> POs = [SELECT id, name from ASI_MFM_PO__c WHERE ASI_MFM_PAF_Number__c = :Orginal_PAF.id];
        if (POs.size() > 0) {
            for (ASI_MFM_PO__c po: POs) {
                ExistingPO += po.Name + ', ';
            }
            havePO = true;
        }
        //Testing
        /*id tmpCust;
        if (Orginal_PAF.ASI_CRM_Short_Term_Promotion__c){
            ASI_CRM_HK_Pre_Approval_Form_Customer__c tmpDA = [select id, name,ASI_CRM_PA_DA__c, ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.Name
                     //, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Local_Channel__c, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Credit_Limit__c 
                     , ASI_CRM_HK_Customer__r.ASI_HK_CRM_Address__c 
                     from ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                     where ASI_CRM_HK_Pre_Approval_Form__c=:Orginal_PAF.Name
                     and ASI_CRM_PA_DA__c = 'DA'
                     Limit 1];
            tmpCust = tmpDA.ASI_CRM_HK_Customer__c;
        }else{
            List<Account> accList = [Select id, Name
                                     from Account
                                     where ParentId =: Orginal_PAF.ASI_HK_CRM_PAF_Customer__c
                                     ];
            if (accList.size() > 0) {
                tmpCust = accList[0].id;
            }
            else{
            	tmpCust = Orginal_PAF.ASI_HK_CRM_PAF_Customer__c;
            }
        }
        system.debug('tmpCust:::::::::' +tmpCust);*/
    }
    //***** Wapper Class **********
    public Class SAPHeaderObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
            } 
            set; }
        public ASI_MFM_PO__c po {get; set;}
        public ASI_MFM_Payment__c pay {get; set;}
    }
    public Class SAPLineObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
            } 
            set; }
        public ASI_MFM_PO_Line_Item__c pol {get; set;}
        public ASI_MFM_Payment_Line_Item__c pl {get; set;}
    }
    //******End Wapper Class***********
    //
    public void getMechanic() 
    {
        haveValue = false;
        //ASI_HK_CRM_Pre_Approval_Form__c tmp
        system.debug('enter get Mechanic:::');   
        PAF_Number = Apexpages.currentPage().getParameters().get('PAF_Number');
        system.debug('PAF_Number3:::' + PAF_Number);
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> MechanicList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        if (PAF_Number == null || PAF_Number == '') {
           	PAF_Number = ApexPages.CurrentPage().getparameters().get('id');
            MechanicList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
                requiredLineFields()
                , 'ASI_HK_CRM_Pre_Approval_Form_Item__c'
                , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__c = :PAF_Number'
                , 'ORDER BY ASI_HK_CRM_Mechanic__r.name'
            )); 
        }
        else {
            MechanicList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
                requiredLineFields()
                , 'ASI_HK_CRM_Pre_Approval_Form_Item__c'
                , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name =: PAF_Number'
                , 'ORDER BY ASI_HK_CRM_Mechanic__r.name'
            ));
        }
        System.debug('MechanicList:::' + LSAPHeader[0].po.ASI_MFM_PAF_Number__c);
        CustomSKUMechanicDetailsList = new List<CustomSKUMechanicDetail>();
        
        if(MechanicList.size() > 0){
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c paf_detail: MechanicList){ 
                Decimal targetVolume = paf_detail.ASI_HK_CRM_Target_Volume_Qty__c;
                Decimal price = paf_detail.ASI_HK_CRM_Price__c;
                //START - Remove machanics type = Varible
                /*[WL 1.0] BEGIN*/
				/*if(//paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - Variable' ||
                    paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - Fixed Amount'){*/
				if(paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - Fixed Amount' || paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - Fixed Bottle'){
				/*[WL 1.0] END*/
                       cmd = new CustomSKUMechanicDetail();
                       cmd.paf_displaySKU = paf_detail;
                       cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                       cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                       cmd.sku_code = paf_detail.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                       cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                       cmd.pricing_item = paf_detail.ASI_CRM_HK_Pricing_Item__c;
                       cmd.buy_bottle = null;
                       cmd.sell_bottle = null;
                       cmd.investmentValue = paf_detail.ASI_HK_CRM_Investment_Value__c;
                       if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;  
                       if(paf_detail.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null) cmd.perBtShowDollarSign = true;              
                       CustomSKUMechanicDetailsList.add(cmd);       
			   }
                //FOC and bulk FOC
                 /*         
                else if(paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - FOC'  
                        || paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - FOC Bulk'){
                            cmd = new CustomSKUMechanicDetail();
                            cmd.paf_displaySKU = paf_detail;
                            
                            if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null){
                                cmd = new CustomSKUMechanicDetail();
                                cmd.paf_displaySKU = paf_detail;
                                cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                                cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                                cmd.sku_code = paf_detail.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                                cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                                cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c;
                                cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c;
                                cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c,
                                                                         paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c,
                                                                         targetVolume, price);
                                if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                              //  hasFOC = true;
                                CustomSKUMechanicDetailsList.add(cmd);
                            }
                            if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null){
                                cmd = new CustomSKUMechanicDetail();
                                cmd.paf_displaySKU = paf_detail;
                               // if(!hasFOC){
                                    cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                                    cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                                    cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                                cmd.sku_code = paf_detail.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                               // }
                                cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c;
                                cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c;
                                cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c,
                                                                         paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c,
                                                                         targetVolume, price);
                                if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                                CustomSKUMechanicDetailsList.add(cmd);
                            }
                            if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c != null){
                                cmd = new CustomSKUMechanicDetail();
                                cmd.paf_displaySKU = paf_detail;
                             //   if(!hasFOC){
                                    cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                                    cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                                    cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                                cmd.sku_code = paf_detail.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                             //   }
                                cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c;
                                cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c;
                                cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c,
                                                                         paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c,
                                                                         targetVolume, price);
                                if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                                CustomSKUMechanicDetailsList.add(cmd);
                            }
                            if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c != null){
                                cmd = new CustomSKUMechanicDetail();
                                cmd.paf_displaySKU = paf_detail;
                           //     if(!hasFOC){
                                    cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                                    cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                                    cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                                cmd.sku_code = paf_detail.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                           //     }
                                cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c;
                                cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c;
                                cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c,
                                                                         paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c,
                                                                         targetVolume, price);
                                if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                                CustomSKUMechanicDetailsList.add(cmd);
                            }                                   
                        }
                */
                //End - Remove machanics type = Varible
            }
        }
        if (CustomSKUMechanicDetailsList.size() > 0){
            haveValue = true;
        }
        
    }
    
    public PageReference SaveRecord() 
    {
        //System.assertEquals(null, LSAPHeader[0].po.ASI_MFM_PO_End_Date__c);
        ASI_MFM_PO__c newPO = new ASI_MFM_PO__c();
        List<ASI_MFM_PO_Line_Item__c> newPOLines = new List<ASI_MFM_PO_Line_Item__c>();
        Msg = '';
        haveError = false;
        if (LSAPHeader[0].po.ASI_MFM_PAF_Number__c == null) {
            Msg += 'Please select PAF No. <br />';
            haveError = true;
        }
        if (LSAPHeader[0].po.ASI_MFM_Plan__c == null) {
            Msg += 'Please select Plan No. <br />';
            haveError = true;
        }
        if (LSAPHeader[0].po.ASI_MFM_Supplier_Name__c == null) {
            Msg += 'Please select Supplier. <br />';
            haveError = true;
        }
        if (LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c == null) {
            Msg += 'Please select Start Date. <br />';
            haveError = true;
        }
        if (LSAPHeader[0].po.ASI_MFM_PO_End_Date__c == null) {
            Msg += 'Please select End Date. <br />';
            haveError = true;
        }
        if (LSAPHeader[0].po.ASI_MFM_PO_End_Date__c < LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c) {
            Msg += 'Error: End Date < Start Date. <br />';
            haveError = true;
        }
        if (selected_prefix == null) {
            Msg += 'No prefix is selected';
            haveError = true;
        }
        //get DA
        id tmpCust;
        string tmpCustName;
        if (Orginal_PAF.ASI_CRM_Short_Term_Promotion__c){
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> tmpDA = [select id, name,ASI_CRM_PA_DA__c, ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.Name
                     //, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Local_Channel__c, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Credit_Limit__c 
                     , ASI_CRM_HK_Customer__r.ASI_HK_CRM_Address__c 
                     from ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                     where ASI_CRM_HK_Pre_Approval_Form__c=:Orginal_PAF.id
                     and ASI_CRM_PA_DA__c = 'DA'
                     ];
            if(tmpDA.size() > 0 && tmpDA[0].ASI_CRM_HK_Customer__c != null)
            {
                tmpCust = tmpDA[0].ASI_CRM_HK_Customer__c;
            	tmpCustName = tmpDA[0].ASI_CRM_HK_Customer__r.Name;
            }//end if //20160412, added by Leo, add check null
        }
		else{
			/*[WL 3.0] BEGIN*/
			Account pafCustomer = [Select recordType.DeveloperName, ASI_HK_CRM_IsDeliveryAccount__c from Account where Id = :Orginal_PAF.ASI_HK_CRM_PAF_Customer__c Limit 1];
			
			system.debug('PAF Customer Record Type: ' + pafCustomer.recordType.DeveloperName);
			
			if (pafCustomer.recordType.DeveloperName == 'ASI_HK_CRM_Outlet' && pafCustomer.ASI_HK_CRM_IsDeliveryAccount__c){	//Use PAF Customer if it is DA				
				system.debug('Use PAF Customer, ID: ' + Orginal_PAF.Id);
				tmpCust = Orginal_PAF.ASI_HK_CRM_PAF_Customer__c;
				tmpCustName = Orginal_PAF.ASI_HK_CRM_PAF_Customer__r.Name;
			}
			else {	//Else, Look for Active Child DA
				List<Account> accList = [SELECT id, Name FROM Account WHERE ParentId =: Orginal_PAF.ASI_HK_CRM_PAF_Customer__c 
																			AND recordtype.developerName = 'ASI_HK_CRM_Outlet' 
																			AND ASI_HK_CRM_IsDeliveryAccount__c = TRUE
																			AND ASI_HK_CRM_Status__c = 'Active'
																			AND (NOT Name LIKE '%CONSIG%')
																			ORDER BY ASI_HK_CRM_Customer_Code__c ASC];
				if (accList.size() > 0) {
					system.debug('Use first child outlet of PAF Customer, ID: ' + accList[0].id);
					tmpCust = accList[0].id;
					tmpCustName = accList[0].Name;
				}
				else {
					Msg += 'Invalid Customer. <br />';
					haveError = true;
				}
			}
			/*[WL 3.0] END*/
        }
        system.debug('tmpCust:::::::::' +tmpCust);
        newPO.ASI_MFM_PAF_Number__c = LSAPHeader[0].po.ASI_MFM_PAF_Number__c;
        newPO.ASI_MFM_Plan__c = LSAPHeader[0].po.ASI_MFM_Plan__c;
        newPO.ASI_MFM_Supplier_Name__c = LSAPHeader[0].po.ASI_MFM_Supplier_Name__c;
        newPO.ASI_MFM_Currency__c = LSAPHeader[0].po.ASI_MFM_Currency__c;
        newPO.ASI_MFM_Prefix__c = selected_prefix;
        newPO.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO');
        newPO.ASI_MFM_Status__c = 'Draft';
        newPO.ASI_MFM_Remarks__c = 'Contract Requirement: '+Orginal_PAF.ASI_HK_CRM_PAF_Contract_Requirement__c;
        //START - remove getting the dates from PAF
        /*newPO.ASI_MFM_PO_Start_Date__c = date.today();
        if (Orginal_PAF.ASI_HK_CRM_Adjusted_End_Date__c != null) {
            newPO.ASI_MFM_PO_End_Date__c = Orginal_PAF.ASI_HK_CRM_Adjusted_End_Date__c;
        } else {
            newPO.ASI_MFM_PO_End_Date__c = Orginal_PAF.ASI_HK_CRM_PAF_End_Date__c;
        }*/
        //END - remove
        newPO.ASI_MFM_PO_Start_Date__c = LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c;
        newPO.ASI_MFM_PO_End_Date__c = LSAPHeader[0].po.ASI_MFM_PO_End_Date__c;
        newPO.ASI_MFM_PO_Raised_Date__c = date.today();
        Map<String, Id> ACMap = new Map<String, Id>();
        List<ASI_MFM_A_C_Code__c> accodes = [SELECT id, Name, ASI_MFM_A_C_Code__c FROM ASI_MFM_A_C_Code__c WHERE RecordType.DeveloperName = 'ASI_MFM_HK_A_C_Code'];
        for (ASI_MFM_A_C_Code__c ac: accodes) {
            ACMap.put(ac.ASI_MFM_A_C_Code__c, ac.id);
        }
        id polrt = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item');
        for (CustomSKUMechanicDetail CustSKU :CustomSKUMechanicDetailsList){
            if (CustSKU.checked) {
                system.debug('CustSKU:::' + CustSKU);
                ASI_MFM_PO_Line_Item__c tmpPOL = new ASI_MFM_PO_Line_Item__c();
                tmpPOL.ASI_MFM_Spread_by_Months__c = CustSKU.Spread;
                tmpPOL.ASI_MFM_G_L_Date__c = newPO.ASI_MFM_PO_Start_Date__c;
                tmpPOL.ASI_MFM_Sub_brand_Code__c = CustSKU.paf_displaySKU.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c;
                tmpPOL.ASI_MFM_Customer_Name__c = tmpCust;//Orginal_PAF.ASI_HK_CRM_PAF_Customer__c;
                tmpPOL.ASI_MFM_Amount__c = CustSKU.investmentValue;
                if (Orginal_PAF.ASI_HK_CRM_PAF_Nature_of_Promotion__c == null) {
                    Orginal_PAF.ASI_HK_CRM_PAF_Nature_of_Promotion__c = '';
                }
                tmpPOL.ASI_MFM_List_Item_Description__c = Orginal_PAF.Name + ' ' + tmpCustName + ' ' + Orginal_PAF.ASI_CRM_Promotion_Category__r.ASI_CRM_Description__c + ' - ' + CustSKU.paf_displaySKU.ASI_HK_CRM_Mechanic__r.Name;
                if (!ACMap.containsKey(CustSKU.paf_displaySKU.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_JDE_Account__c)) {
                    haveError = true;
                    Msg += 'A/C Code not Found: '+ CustSKU.paf_displaySKU.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_JDE_Account__c;
                }
                tmpPOL.ASI_MFM_A_C_Code__c = ACMap.get(CustSKU.paf_displaySKU.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_JDE_Account__c);
                tmpPOL.RecordTypeId = polrt;
                newPOLines.add(tmpPOL);
            }
        }
        if (newPOLines.isEmpty()) {
            haveError = true;
            Msg += 'Please Select Mechanic Lines';
        }
        if (!haveError) {
            try{
                insert newPO;    
                for (ASI_MFM_PO_Line_Item__c newPOL: newPOLines) {
                    newPOL.ASI_MFM_PO__c = newPO.id;
                }
                insert newPOLines;
            }
            catch (Exception e) 
            {
                Msg = e.getMessage();
                haveError = true;
            }
        }
        if (haveError) {
            return null;
        } else {
            //PageReference redirect = new PageReference('/a7qM000000016ozIAA'thisrecord.id); 
            PageReference redirect = new PageReference('/'+newPO.id); 
            return redirect;
        }
    }
    public PageReference Cancel() 
    {
        PageReference redirect = new PageReference('/' + Orginal_PAF.id); 
        return redirect;
    }
    
    //****** SAPL Line Item - functions - (end) ******
    
    @RemoteAction
    public static String[] findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            System.debug('sot is null' );
            
            return null;
        }
        String filter = '';
        if (obj == 'ASI_MFM_Plan__c') {
            //filter = ' WHERE ASI_MFM_Status__c Like \'Final\' ';
            filter = '';
        }
        String soql = 'select Name from ' + obj  +filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
                String tmp = String.valueOf(sobj.get('Name'));
                results.add(String.escapeSingleQuotes(tmp)); 
            }
            System.debug('results:' + results);
        }
        catch (QueryException e) {
            return null;
        }
        return results;
    }
    @RemoteAction
    public static String[] findCustSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            return null;
        }
        Map<String, id> MRecType = ASI_MFM_Function.getRecordTypeId('account');
        string recTypeID = MRecType.get(qry);
        String filter;
        filter = ' WHERE recordtypeid = \'' + String.escapeSingleQuotes(recTypeID) + '\' ';
  
        String soql = 'select Name from ' + obj + filter +' order by Name';
                
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
                results.add(String.valueOf(sobj.get('Name'))); 
            }
            System.debug('results:' + results);
        }
        catch (QueryException e) {
            return null;
        }
        return results;
    }
    
    //****** End Other Method ****//
     public Decimal getInvestmentValue(Decimal buyBt, Decimal freeBt, Decimal volume, Decimal price){
        Decimal result; 
        Integer totalFreeBt;
        
        if(buyBt == null){
            return null;
        }
        else if(volume == null){
            return null;
        }
        else if(freeBt == null){
            return null;
        }
        else if(Price == null){
            return null;
        }
        
        totalFreeBt = Integer.valueOf(volume)/Integer.valueOf(buyBt);
        totalFreeBt = totalFreeBt * Integer.valueOf(freeBt);
        result = totalFreeBt * price;
        return result;
    }
    
}