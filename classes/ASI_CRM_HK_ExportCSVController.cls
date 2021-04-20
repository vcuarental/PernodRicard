/*********************************************************************************
 * Name:ASI_CRM_HK_ExportCSVController
 * Description: 
 * Test Class: ASI_HK_CRM_priceSet_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-11-26                     Add PDF data export function
 * 2016-01-18                     Add logic of SKU.Name = Item Group.Name
 * 2017-08-08       Wilken Lee          [WL 1.0] Change Advance Pricing by Item Group CSV Factor Value to remove % sign
*********************************************************************************/
public without sharing class ASI_CRM_HK_ExportCSVController {

    public static Id PSLId {set;get;} 
    public static Boolean BPbySKU {set;get;} 
    public static Boolean BPbyItemGP {set;get;} 
    public static Boolean APbySKU {set;get;} 
    public static Boolean APbyItemGP {set;get;} 
    public static Boolean PDFSummary {get {if (PDFSummary != true) {PDFSummary = PSSummaryByPAF();} return PDFSummary;} set;}

    public static List<ASI_CRM_Price_Set_Generation_Log_Detail__c> PSLItems {get; set;} 
    public static List<PAFHeader> PAFSetHeader {get;set;}
    
    public static Integer No_BPbySKU {get;set;}
    public static Integer No_BPbyItemGP{get;set;}
    public static Integer No_APbySKU{get;set;}
    public static Integer No_APbyItemGP{get;set;}
    
    public static Set<id> PAFSet {get;set;}
    public static List<ASI_HK_CRM_Pre_Approval_Form_Item__c> PAFItems {get; set;}
    public static Map<id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>> PAFCustomerMap {get; set;}
    //public static List<ExcelColObj> ExcelColsPDFSummary {get;set;} {ExcelColsPDFSummary = new List<ExcelColObj> ();}
    public static List<ExcelColObj> ExcelColsBPbySKU {get;set;}// {ExcelColsBPbySKU = new List<ExcelColObj> ();}
    public static List<ExcelColObj> ExcelColsBPbyItemGP {get;set;} //{ExcelColsBPbyItemGP = new List<ExcelColObj> ();}
    public static List<ExcelColObj> ExcelColsAPbySKU {get;set;} //{ExcelColsAPbySKU = new List<ExcelColObj> ();}
    public static List<ExcelColObj> ExcelColsAPbyItemGP {get;set;} //{ExcelColsAPbyItemGP = new List<ExcelColObj> ();}
    public ASI_CRM_HK_ExportCSVController() {

    }
        
    
    public class ExcelColObj {
        public String ColA {get;Set;}
        public String ColB {get;Set;}
        public String ColC {get;Set;}
        public String ColD {get;Set;}
        public String ColE {get;Set;}
        public String ColF {get;Set;}
        public String ColG {get;Set;}
        public String ColH {get;Set;}
        public String ColI {get;Set;}
        public String ColJ {get;Set;}
        public String ColK {get;Set;}
        public String ColL {get;Set;}
        public String ColM {get;Set;}
        public String ColN {get;Set;}
        public String ColO {get;Set;}
        public String ColP {get;Set;}
        public String ColQ {get;Set;}
        public String ColR {get;Set;}
        public String ColS {get;Set;}
        public String ColT {get;Set;}
        public String ColU {get;Set;}
        public String ColV {get;Set;}
        public String ColW {get;Set;}
        public String ColX {get;Set;}
        public String ColY {get;Set;}
        public String ColZ {get;Set;}
    }
    
    public class PAFHeader{
        public String PAFNo {get;Set;}
        public date StartDate {get;Set;}
        public date EndDate {get;Set;}
    }
    
    public static boolean BasePriceBySKU() {
        //DateTime tmpDate = new DateTime();
        ExcelColsBPbySKU = new List<ExcelColObj> ();
        PSLItems = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
        PAFSet = new Set<id>();
        Date psSubDate; //20160628, added by Leo
        PSLItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c = :PSLId ORDER By id ASC];
        //20160628, added by Leo, add price set submittion date
        for (ASI_CRM_Price_Set_Generation_Log_Detail__c Item: PSLItems) {
            PAFSet.add(Item.ASI_CRM_Pre_Approval_Form__c);
        }
        psSubDate = PSLItems[0].ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c; //20160628, added by Leo
        if (PAFSet.size() > 0) {
            PAFItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            PAFItems = [SELECT 
                        id,
                        ASI_HK_CRM_Price__c, 
                        ASI_HK_CRM_SKU_Lookup__c, 
                        ASI_HK_CRM_SKU_Lookup__r.Name,
                        ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c,
                        ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Description__c, 
                        ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c,
                        ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.Name,
                        ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c,
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__c,
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name,
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c, 
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode, 
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name,
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c, 
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c,
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c, 
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name,
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c
                        FROM
                        ASI_HK_CRM_Pre_Approval_Form_Item__c
                        WHERE
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__c IN:PAFSet
                        AND ASI_CRM_HK_All_Product__c = FALSE //20160321, edited by Leo
                        Order by ASI_HK_CRM_SKU_Lookup__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c //20161026, add back ordering
                        //AND ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.Name =: ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Description__c
                        //AND ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c = NULL
                        //Group by ASI_HK_CRM_SKU_Lookup__c
                       ];
            
            Set<id> CusSet = new Set<id>(); 
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c PAFItem: PAFItems) {
                CusSet.add(PAFItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
            }
            // Get pricing channel
            Map<id, string> pricingChannelMap = new Map<id, string>();
            Map<id, string> channelAdminMap = new Map<id, string>();
            List<Account> acctSet = [SELECT Id, ASI_HK_CRM_Customer_Number__c, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Channel__c,ASI_HK_CRM_Customer_Type__c 
                                     //, ASI_CRM_AccountAdditionalField__pr.ASI_CRM_Pricing_Channel__c
                                     FROM Account WHERE Id IN :CusSet];
            for (Account CustAcc: acctSet) {
                string accChannel = CustAcc.ASI_HK_CRM_Channel__c.substring(0,3) + '%';
                ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannelMapObj = [SELECT ASI_HK_CRM_Channel__c
                                                                                , ASI_HK_CRM_Pricing_Channel__c 
                                                                                , ASI_CRM_Channel_Admin1__r.Name
                                                                                From ASI_HK_CRM_Channel_Local_Channel_Map__c
                                                                                Where ASI_HK_CRM_Channel__c Like: accChannel
                                                                                Limit 1];
                pricingChannelMap.put(CustAcc.Id, PricingChannelMapObj.ASI_HK_CRM_Pricing_Channel__c);
                channelAdminMap.put(CustAcc.Id, PricingChannelMapObj.ASI_CRM_Channel_Admin1__r.Name);
            }
            /*List<ASI_CRM_AccountsAdditionalField__c> Addedfields = [SELECT id, ASI_CRM_Account__c, ASI_CRM_Pricing_Channel__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN : CusSet];
        for (ASI_CRM_AccountsAdditionalField__c AddedField: Addedfields) {
                pricingChannelMap.put(AddedField.ASI_CRM_Account__c, AddedField.ASI_CRM_Pricing_Channel__c);
                }*/
            // Get the customer list when customer specific = true
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustomers = [SELECT id, ASI_CRM_Generate_Price_Set__c, ASI_CRM_HK_Customer__r.Name, 
                                                                           ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c
                                                                           , ASI_CRM_HK_Pre_Approval_Form__c//20151230 Ben @ Elufa Systems fix the soql error
                                                                           , ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Number__c //20161107,Leo@Elufa
                                                                           FROM 
                                                                           ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                                                                           WHERE 
                                                                           ASI_CRM_HK_Pre_Approval_Form__c IN : PAFSet AND ASI_CRM_Generate_Price_Set__c = true
                                                                          ];
            PAFCustomerMap = new Map<id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>>();
            if (PAFCustomers.size() > 0){
                for (ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFCustomer: PAFCustomers) {
                    if(!PAFCustomerMap.containsKey(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c)) {
                        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> tmpPAFCust = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
                        tmpPAFCust.add(PAFCustomer);
                        PAFCustomerMap.put(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c, tmpPAFCust);
                    } else {
                        PAFCustomerMap.get(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c).add(PAFCustomer);
                    }
                }
            }
            decimal count=1;
            String prev = '';
            String current = '';
            if (PAFItems.size() > 0) {
                for (ASI_HK_CRM_Pre_Approval_Form_Item__c rows: PAFItems) {
                    // Modified 20160118
                    if (rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c == rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c)
                        if (PAFCustomerMap.containsKey(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c)){
                            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustList = PAFCustomerMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
                            for (ASI_CRM_HK_Pre_Approval_Form_Customer__c Cust: PAFCustList){
                                prev = current;
                                //current = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                                current = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c + rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c + rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name; //20161026, add back criteria
                                if (prev != current){
                                    ExcelColObj row = new ExcelColObj();
                                    row.ColA = String.valueOf(count);
                                    row.ColB = '';
                                    row.ColC = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name;
                                    row.ColD = '="'+rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c+'"';
                                    row.ColE = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Description__c;
                                    row.ColF = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name;
                                    //row.ColG = '    394DPKHK';
                                    row.ColG = '';
                                    row.ColH = Cust.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c;
                                    row.ColI = Cust.ASI_CRM_HK_Customer__r.Name.replace('('+row.ColH+')','').trim();
                                    row.ColJ = '';
                                    row.ColK = '';
                                    row.ColL = '';
                                    row.ColM = '';
                                    row.ColN = '';
                                    row.ColO = '';
                                    row.ColP = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode;
                                    row.ColQ = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c;
                                    row.ColR = String.ValueOf(rows.ASI_HK_CRM_Price__c);
                                    Date tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c;
                                    if(psSubDate < tmpdate)//20160628, edited by Leo
                                        row.ColS = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                                    else//20160628, edited by Leo
                                        row.ColS = psSubDate.month() +'/' + psSubDate.day() + '/' + psSubDate.year();//20160628, edited by Leo
                                    tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c;
                                    //if(!rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c)//20160628, edited by Leo
                                    if(!(Cust.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Number__c.startsWith('9')
                                     &&Cust.ASI_CRM_HK_Customer__r.Name.startsWith('OUTLET_')))//20161107,Leo@Elufa //20161205,Leo@Elufa
                                    { //20161026, edited by Leo
                                        if(tmpdate != null)
                                          row.ColT = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                                        else
                                            row.ColT = '';
                                    } //20161026, edited by Leo
                                    else//20160628, edited by Leo
                                        row.ColT = '12/31/2050';//20160628, edited by Leo
                                    row.ColU = channelAdminMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                                    ExcelColsBPbySKU.add(row);
                                    count++;
                                }  
                            }
                            
                        }
                    else{
                        prev = current;
                        //current = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                        current = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c + rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c; //20161026, add back criteria
                        if (prev != current){
                            ExcelColObj row = new ExcelColObj();
                            row.ColA = String.valueOf(count);
                            row.ColB = '';
                            row.ColC = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name;
                            row.ColD = '="'+rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c+'"';
                            row.ColE = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Description__c;
                            row.ColF = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name;
                            //row.ColG = '    394DPKHK';
                            row.ColG = '';
                            if (rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.startsWith('OUTLET_')) {
                                row.ColH = '';
                                row.ColI = '';
                                List<String> tmpString = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.split('_');
                                row.ColJ = tmpString[0];
                                //row.ColK = tmpString[1].replaceAll('\\(.*?\\)','').trim();
                                row.ColK = pricingChannelMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                            } else {
                                row.ColH = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c;
                                row.ColI = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.replace('('+row.ColH+')','').trim();
                                row.ColJ = '';
                                row.ColK = '';
                            }  
                            row.ColL = '';
                            row.ColM = '';
                            row.ColN = '';
                            row.ColO = '';
                            row.ColP = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode;
                            row.ColQ = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c;
                            row.ColR = String.ValueOf(rows.ASI_HK_CRM_Price__c);
                            Date tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c;
                            if(psSubDate < tmpdate)//20160628, edited by Leo
                                row.ColS = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                            else//20160628, edited by Leo
                                row.ColS = psSubDate.month() +'/' + psSubDate.day() + '/' + psSubDate.year();//20160628, edited by Leo
                            tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c;
                            if(!rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c)//20160628, edited by Leo
                            {
                                if(tmpdate != null)
                                    row.ColT = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                                else
                                    row.ColT = '';
                            }
                            else//20160628, edited by Leo
                                row.ColT = '12/31/2050';//20160628, edited by Leo
                            row.ColU = channelAdminMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                            ExcelColsBPbySKU.add(row);       
                            count++;
                        }
                    }
                }
            }       
        }
        No_BPbySKU = ExcelColsBPbySKU.size();
        return true;
    }
    
    public static boolean BasePriceByItemGP() {
        system.debug('PSLId'+PSLId);
       // PSLId = 'aDgM0000000CaZLKA0';
        ExcelColsBPbyItemGP = new List<ExcelColObj> ();
        PSLItems = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
        PAFSet = new Set<id>();
        Date psSubDate; //20160628, added by Leo
        PSLItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c = :PSLId ORDER By id ASC];
        //20160628, edited by Leo, add price set submittion date
        for (ASI_CRM_Price_Set_Generation_Log_Detail__c Item: PSLItems) {
            PAFSet.add(Item.ASI_CRM_Pre_Approval_Form__c);
        }
        psSubDate = PSLItems[0].ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c; //20160628, added by Leo
        if (PAFSet.size() > 0) {
            PAFItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            PAFItems = [SELECT id, ASI_HK_CRM_Price__c
                        , ASI_CRM_HK_Pricing_Item__c
                        , ASI_HK_CRM_SKU_Lookup__c
                        , ASI_HK_CRM_SKU_Lookup__r.Name
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.Name
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_CRM_HK_Pricing_Category__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Short_Term_Promotion__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c
                        FROM
                        ASI_HK_CRM_Pre_Approval_Form_Item__c
                        WHERE
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__c IN:PAFSet
                        AND ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c != NULL
                        AND ASI_CRM_HK_All_Product__c = FALSE //20160321, edited by Leo
                        Order by ASI_CRM_HK_Pricing_Item__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c //20161026, add back ordering
                       ];
            
            Map<id, string> pricingChannelMap = new Map<id, string>();
            Map<id, string> channelAdminMap = new Map<id, string>();
            Set<id> CusSet = new Set<id>(); 
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c PAFItem: PAFItems) {
                CusSet.add(PAFItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
            }
            // Get Pricing Channel & Sales Admin from ASI_HK_CRM_Channel_Local_Channel_Map__c Object
            List<Account> acctSet = [SELECT Id, ASI_HK_CRM_Customer_Number__c, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Channel__c,ASI_HK_CRM_Customer_Type__c 
                            //, ASI_CRM_AccountAdditionalField__pr.ASI_CRM_Pricing_Channel__c
                            FROM Account WHERE Id IN :CusSet];
            for (Account CustAcc: acctSet) {
                string accChannel = CustAcc.ASI_HK_CRM_Channel__c.substring(0,3) + '%';
                ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannelMapObj = [SELECT ASI_HK_CRM_Channel__c
                                                                                , ASI_HK_CRM_Pricing_Channel__c
                                                                                , ASI_CRM_Channel_Admin1__r.Name
                                                                                From ASI_HK_CRM_Channel_Local_Channel_Map__c
                                                                                Where ASI_HK_CRM_Channel__c Like: accChannel
                                                                                Limit 1];
                pricingChannelMap.put(CustAcc.Id, PricingChannelMapObj.ASI_HK_CRM_Pricing_Channel__c);
                channelAdminMap.put(CustAcc.Id, PricingChannelMapObj.ASI_CRM_Channel_Admin1__r.Name);
            }
            /* backup20150105
            List<ASI_CRM_AccountsAdditionalField__c> Addedfields = [SELECT id, ASI_CRM_Account__c, ASI_CRM_Pricing_Channel__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN : CusSet];
            for (ASI_CRM_AccountsAdditionalField__c AddedField: Addedfields) {
                pricingChannelMap.put(AddedField.ASI_CRM_Account__c, AddedField.ASI_CRM_Pricing_Channel__c);
            }
            */
            // Get the customer list when customer specific = true
            PAFCustomerMap = new Map<id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>>();
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustomers = [SELECT id, ASI_CRM_Generate_Price_Set__c, ASI_CRM_HK_Customer__r.Name, 
                            ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c
                            , ASI_CRM_HK_Pre_Approval_Form__c//20151230 Ben @ Elufa Systems fix the soql error
                            , ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Number__c //20161107,Leo@Elufa
                            FROM 
                            ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                            WHERE 
                            ASI_CRM_HK_Pre_Approval_Form__c IN : PAFSet AND ASI_CRM_Generate_Price_Set__c = true
                           ];
            
            if (PAFCustomers.size() > 0 && PAFCustomers != null){
                for (ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFCustomer: PAFCustomers) {
                    if(!PAFCustomerMap.containsKey(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c)) {
                        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> tmpPAFCust = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
                        tmpPAFCust.add(PAFCustomer);
                        PAFCustomerMap.put(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c, tmpPAFCust);
                    } else {
                        PAFCustomerMap.get(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c).add(PAFCustomer);
                    }
              }
            }
            decimal count=1;
            string prev = '';
            string current = '';
            if (PAFItems.size() > 0) {
                for (ASI_HK_CRM_Pre_Approval_Form_Item__c rows: PAFItems) {
                    prev = current;
                    //current = rows.ASI_CRM_HK_Pricing_Item__c;
                    current = rows.ASI_CRM_HK_Pricing_Item__c + rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c; //20161026, add back criteria
                    // Modified 20160118
                    if (rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c != rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c)
                    if (Current != prev){
                      //Check if customer specific
                        if (PAFCustomerMap.containsKey(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c)){
                            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustList = PAFCustomerMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
                            for (ASI_CRM_HK_Pre_Approval_Form_Customer__c Cust: PAFCustList){
                                ExcelColObj row = new ExcelColObj();
                                row.ColA = String.ValueOf(count++);
                                row.ColB = '';
                                row.ColC = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name;
                                row.ColD = '';
                                row.ColE = '';
                                row.ColF = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name;
                                //row.ColG = '    394DPKHK';
                                row.ColG = '';
                                row.ColH = Cust.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c;
                                row.ColI = Cust.ASI_CRM_HK_Customer__r.Name.replace('('+row.ColH+')','').trim();
                                row.ColJ = '';
                                row.ColK = '';
                                row.ColL = '';
                                row.ColM = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_CRM_HK_Pricing_Category__c;
                                row.ColN = '="'+rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c+'"';
                                row.ColO = '';
                                row.ColP = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode;
                                row.ColQ = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c;
                                row.ColR = String.ValueOf(rows.ASI_HK_CRM_Price__c);
                                Date tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c; //20160418, edited by Leo
                                if(psSubDate < tmpdate)//20160628, edited by Leo
                                    row.ColS = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year(); //20160418, edited by Leo
                                else//20160628, edited by Leo
                                    row.ColS = psSubDate.month() +'/' + psSubDate.day() + '/' + psSubDate.year();//20160628, edited by Leo
                                tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c; //20160418, edited by Leo
                                //if(!rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c)//20160628, edited by Leo
                                if(!(Cust.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Number__c.startsWith('9')
                                     &&Cust.ASI_CRM_HK_Customer__r.Name.startsWith('OUTLET_')))//20161107,Leo@Elufa //20161205,Leo@Elufa
                                {
                                    if(tmpdate!=null)
                                        row.ColT = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year(); //20160418, edited by Leo
                                    else
                                        row.ColT = '';
                                }
                                else//20160628, edited by Leo
                                    row.ColT = '12/31/2050';//20160628, edited by Leo
                                row.ColU = channelAdminMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                                ExcelColsBPbyItemGP.add(row);
                            }
                        }
                        else if (PAFCustomerMap.size() == 0 && rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Short_Term_Promotion__c ){
                        //TO-DO: Error Handling of missing "Generate Price Set?"
                        system.debug('Wrong Condition');
                      }
                        else{
                            ExcelColObj row = new ExcelColObj();
                            row.ColA = String.ValueOf(count++);
                            row.ColB = '';
                            row.ColC = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name;
                            row.ColD = '';
                            row.ColE = '';
                            row.ColF = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name;
                            //row.ColG = '    394DPKHK';
                            row.ColG = '';
                            if (rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.startsWith('OUTLET_')) {
                                row.ColH = '';
                                row.ColI = '';
                                List<String> tmpString = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.split('_');
                                row.ColJ = tmpString[0];
                                //row.ColK = tmpString[1].replaceAll('\\(.*?\\)','').trim();
                                row.ColK = pricingChannelMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                            } else {
                                row.ColH = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c != Null? 
                                    rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c: rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c;
                                row.ColI = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.replace('('+row.ColH+')','').trim();
                                row.ColJ = '';
                                row.ColK = '';
                            }  
                            row.ColL = '';
                            row.ColM = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_CRM_HK_Pricing_Category__c;
                            row.ColN = '="'+rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c+'"';
                            row.ColO = '';
                            row.ColP = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode;
                            row.ColQ = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c;
                            row.ColR = String.ValueOf(rows.ASI_HK_CRM_Price__c);
                            Date tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c; //20160418, edited by Leo
                            if(psSubDate < tmpdate) //20160628, edited by Leo
                                row.ColS = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year(); //20160418, edited by Leo
                            else//20160628, edited by Leo
                                row.ColS = psSubDate.month() +'/' + psSubDate.day() + '/' + psSubDate.year();//20160628, edited by Leo
                            tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c; //20160418, edited by Leo
                            if(!rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c)//20160628, edited by Leo
                            {
                                if(tmpdate != null)
                                    row.ColT = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year(); //20160418, edited by Leo
                                else
                                    row.ColT = '';
                            }
                            else//20160628, edited by Leo
                                row.ColT = '12/31/2050';//20160628, edited by Leo
                            row.ColU = channelAdminMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                            ExcelColsBPbyItemGP.add(row);
                        }
                    }
                    
                }
            }
        }        
        No_BPbyItemGP = ExcelColsBPbyItemGP.size();
        return true;
    }
    
    public static boolean AdvPriceBySKU() {
        ExcelColsAPbySKU = new List<ExcelColObj> ();
        PSLItems = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
        PAFSet = new Set<id>();
        Date psSubDate; //20160628, added by Leo
        PSLItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c,ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c = :PSLId ORDER By id ASC];
        //20160628, edited by Leo, add price set submittion date
        for (ASI_CRM_Price_Set_Generation_Log_Detail__c Item: PSLItems) {
            PAFSet.add(Item.ASI_CRM_Pre_Approval_Form__c);
        }
        psSubDate = PSLItems[0].ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c; //20160628, added by Leo
        if (PAFSet.size() > 0) {
            PAFItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            PAFItems = [SELECT id, ASI_HK_CRM_Price__c
                        , ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c
                        , ASI_HK_CRM_SKU_Lookup__c
                        , ASI_HK_CRM_SKU_Lookup__r.Name
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.Name
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_Packaging_Size__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Description__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Chann_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Cust_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Chan_PAF__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c //20160412, added by Leo
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c //20160412, added by Leo
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c
                        , ASI_HK_CRM_Target_Volume_Qty__c
                        , ASI_HK_CRM_Rebate_Disc_Percent__c
                        , ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c
                        , ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c
                        , ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c
                        , ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c
                        , ASI_HK_CRM_FOC_Free_Bottle_Option_1__c
                        , ASI_HK_CRM_FOC_Free_Bottle_Option_2__c
                        , ASI_HK_CRM_FOC_Free_Bottle_Option_3__c
                        , ASI_HK_CRM_FOC_Free_Bottle_Option_4__c
                        , ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name
            , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name
                        , ASI_CRM_HK_All_Product__c //20160321, added by Leo
                        FROM
                        ASI_HK_CRM_Pre_Approval_Form_Item__c
                        WHERE
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__c IN:PAFSet
                        //AND ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c = NULL
                        AND (ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c != ''
                            OR ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Chann_PAF__c != '')
                        
                       ];

            Set<id> CusSet = new Set<id>(); 
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c PAFItem: PAFItems) {
                CusSet.add(PAFItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
            }
            // Get Pricing Channel from ASI_HK_CRM_Channel_Local_Channel_Map__c Object
      Map<id, string> pricingChannelMap = new Map<id, string>();
            Map<id, string> channelAdminMap = new Map<id, string>();
            List<Account> acctSet = [SELECT Id, ASI_HK_CRM_Customer_Number__c, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Channel__c,ASI_HK_CRM_Customer_Type__c 
                            //, ASI_CRM_AccountAdditionalField__pr.ASI_CRM_Pricing_Channel__c
                            FROM Account WHERE Id IN :CusSet];
            for (Account CustAcc: acctSet) {
                string accChannel = CustAcc.ASI_HK_CRM_Channel__c.substring(0,3) + '%';
                ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannelMapObj = [SELECT ASI_HK_CRM_Channel__c, ASI_HK_CRM_Pricing_Channel__c 
                                                                             ,ASI_CRM_Channel_Admin1__r.Name
                                                                                From ASI_HK_CRM_Channel_Local_Channel_Map__c
                                                                             Where ASI_HK_CRM_Channel__c Like: accChannel
                                                                             Limit 1];
                pricingChannelMap.put(CustAcc.Id, PricingChannelMapObj.ASI_HK_CRM_Pricing_Channel__c);
                channelAdminMap.put(CustAcc.Id, PricingChannelMapObj.ASI_CRM_Channel_Admin1__r.Name);
            }
            /*
            List<ASI_CRM_AccountsAdditionalField__c> Addedfields = [SELECT id, ASI_CRM_Account__c, ASI_CRM_Pricing_Channel__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN : CusSet];
            for (ASI_CRM_AccountsAdditionalField__c AddedField: Addedfields) {
                pricingChannelMap.put(AddedField.ASI_CRM_Account__c, AddedField.ASI_CRM_Pricing_Channel__c);
            }*/
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustomers = [SELECT id, ASI_CRM_Generate_Price_Set__c, ASI_CRM_HK_Customer__r.Name, 
                                                                           ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c
                                                                           , ASI_CRM_HK_Pre_Approval_Form__c//20151230 Ben @ Elufa Systems fix the soql error
                                                                           FROM 
                                                                           ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                                                                           WHERE 
                                                                           ASI_CRM_HK_Pre_Approval_Form__c IN : PAFSet AND ASI_CRM_Generate_Price_Set__c = true
                                                                          ];
            PAFCustomerMap = new Map<id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>>();
            if (PAFCustomers.size() > 0){
                for (ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFCustomer: PAFCustomers) {
                    if(!PAFCustomerMap.containsKey(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c)) {
                        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> tmpPAFCust = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
                        tmpPAFCust.add(PAFCustomer);
                        PAFCustomerMap.put(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c, tmpPAFCust);
                    } else {
                        PAFCustomerMap.get(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c).add(PAFCustomer);
                    }
                }
            }
            decimal count=1;
            if (PAFItems.size() > 0) {
                for (ASI_HK_CRM_Pre_Approval_Form_Item__c rows: PAFItems) {
                    // Modified 20160118
                    if (rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c == rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c){
                        ExcelColObj row = new ExcelColObj();
                        row.ColA = String.valueOf(count);
                        row.ColC = '="'+rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c+'"';
                        row.ColD = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Description__c;
                        row.ColE = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name;
                        row.ColH = '';
                        row.ColL = '';
                        row.ColM = '';
                        row.ColN = '';
                        row.ColO = '';
                        row.ColP = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode;
                        if (rows.ASI_HK_CRM_Rebate_Disc_Percent__c != null && rows.ASI_HK_CRM_Rebate_Disc_Percent__c != 0) {
                            row.ColQ = '2'; // mark ng @2020-06-22 from 1
              /*[WL 1.0 BEGIN]*/
                            //row.ColR = '-' + rows.ASI_HK_CRM_Rebate_Disc_Percent__c + '%';
              row.ColR = '-' + rows.ASI_HK_CRM_Rebate_Disc_Percent__c;
              /*[WL 1.0 END]*/
                        }
                        else if (rows.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c!= 0 && rows.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null) {
                            row.ColQ = '5';
                            row.ColR = '-' + rows.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                        }
                        else {
                            row.ColQ = '';
                            row.ColR = '0';
                        }
                        row.ColS = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c;
                        //row.ColT = String.ValueOf(rows.ASI_HK_CRM_Target_Volume_Qty__c);
                        Date tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c; //20160212, edited by Leo
                        if(psSubDate < tmpdate) //20160628, edited by Leo
                            row.ColU = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                        else //20160628, edited by Leo
                            row.ColU = psSubDate.month() +'/' + psSubDate.day() + '/' + psSubDate.year(); //20160628, edited by Leo
                        tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c; //20160212, edited by Leo
                        if(tmpdate != null)
                          row.ColV = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                        else
                            row.ColV = '';
                        if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null) {
                            row.ColT = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c);
                            row.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c);
                            row.ColX = '="'+rows.ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c+'"';
                        }
                        row.ColY = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.Name;
                        row.ColZ = channelAdminMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                        if (PAFCustomerMap.containsKey(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c)){
                            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustList = PAFCustomerMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
                            for (ASI_CRM_HK_Pre_Approval_Form_Customer__c Cust: PAFCustList){
                                ExcelColObj rowC = new ExcelColObj();
                                rowC.ColA = String.valueOf(count++);
                                rowC.ColB = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c;
                                rowC.ColC = row.ColC;
                                rowC.ColD = row.ColD;
                                rowC.ColE = row.ColE;
                                rowC.ColF = Cust.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c;
                                rowC.ColG = Cust.ASI_CRM_HK_Customer__r.Name.replace('('+rowC.ColF+')','').trim();
                                rowC.ColH = row.ColH;
                                rowC.ColI = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Cust_PAF__c;
                                rowC.ColJ = '';
                                rowC.ColK = '';
                                rowC.ColL = row.ColL;
                                rowC.ColM = row.ColM;
                                rowC.ColN = row.ColN;
                                rowC.ColO = row.ColO;
                                rowC.ColP = row.ColP;
                                rowC.ColQ = row.ColQ;
                                rowC.ColR = row.ColR;
                                rowC.ColS = row.ColS;
                                rowC.ColT = row.ColT;
                                rowC.ColU = row.ColU;
                                rowC.ColV = row.ColV;
                                rowC.ColW = row.ColW;
                                rowC.ColX = row.ColX;
                                rowC.ColY = row.ColY;
                                rowC.ColZ = row.ColZ;
                                ExcelColsAPbySKU.add(rowC);
                                //if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null && math.mod(Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c),Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c)) == 0) {
                                if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null ) {
                                        ExcelColObj row2 = new ExcelColObj();
                                        row2.ColA = String.valueOf(count++);
                                        row2.ColB = rowC.ColB;
                                        row2.ColC = rowC.ColC;
                                        row2.ColD = rowC.ColD;
                                        row2.ColE = rowC.ColE;
                                        row2.ColF = rowC.ColF;
                                        row2.ColG = rowC.ColG;
                                        row2.ColH = rowC.ColH;
                                        row2.ColI = rowC.ColI;
                                        row2.ColJ = rowC.ColJ;
                                        row2.ColK = rowC.ColK;
                                        row2.ColL = rowC.ColL;
                                        row2.ColM = rowC.ColM;
                                        row2.ColN = rowC.ColN;
                                        row2.ColO = rowC.ColO;
                                        row2.ColP = rowC.ColP;
                                        row2.ColQ = rowC.ColQ;
                                        row2.ColR = rowC.ColR;
                                        row2.ColS = rowC.ColS;
                                        row2.ColT = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c);
                                        row2.ColU = rowC.ColU;
                                        row2.ColV = rowC.ColV;
                                        row2.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c - (((rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c / rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).round(System.RoundingMode.DOWN)) * rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c));
                                        row2.ColX = '="'+rows.ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c+'"';
                                        row2.ColY = row.ColY;
                                        row2.ColZ = row.ColZ;
                                        ExcelColsAPbySKU.add(row2);
                                    }
                            }
                        }
                        else{
                            if (rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.startsWith('OUTLET_')) {
                                row.ColB = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Chann_PAF__c;
                                row.ColF = '';
                                row.ColG = '';
                                row.ColI = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Chan_PAF__c;
                                List<String> tmpString = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.split('_');
                                row.ColJ = tmpString[0];
                                //row.ColK = tmpString[1].replaceAll('\\(.*?\\)','').trim();
                                row.ColK = pricingChannelMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                              ExcelColsAPbySKU.add(row);
                                count++;
                            } 
                            else {
                                row.ColB = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c;
                                row.ColF = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c;
                                row.ColG = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.replaceAll('\\(.*?\\)','').trim();
                                row.ColI = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Cust_PAF__c;
                                row.ColJ = '';
                                row.ColK = '';
                                ExcelColsAPbySKU.add(row);
                                count++;
                            }
                            //if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null && math.mod(Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c),Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c)) == 0) {
                            if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null ) {
                                    ExcelColObj row2 = new ExcelColObj();
                                    row2.ColA = String.valueOf(count);
                                    row2.ColB = row.ColB;
                                    row2.ColC = row.ColC;
                                    row2.ColD = row.ColD;
                                    row2.ColE = row.ColE;
                                    row2.ColF = row.ColF;
                                    row2.ColG = row.ColG;
                                    row2.ColH = row.ColH;
                                    row2.ColI = row.ColI;
                                    row2.ColJ = row.ColJ;
                                    row2.ColK = row.ColK;
                                    row2.ColL = row.ColL;
                                    row2.ColM = row.ColM;
                                    row2.ColN = row.ColN;
                                    row2.ColO = row.ColO;
                                    row2.ColP = row.ColP;
                                    row2.ColQ = row.ColQ;
                                    row2.ColR = row.ColR;
                                    row2.ColS = row.ColS;
                                    row2.ColT = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c);
                                    row2.ColU = row.ColU;
                                    row2.ColV = row.ColV;
                                    row2.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c - (((rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c / rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).round(System.RoundingMode.DOWN)) * rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c));
                                    row2.ColX = '="'+rows.ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c+'"';
                                    row2.ColY = row.ColY;
                                    row2.ColZ = row.ColZ;
                                    ExcelColsAPbySKU.add(row2);
                                    count++;
                                }
                        }
                    }
                }
            }
        } 
        No_APbySKU = ExcelColsAPbySKU.size();
        return true;
    }
    
    public static boolean AdvPriceByItemGP() {
        ExcelColsAPbyItemGP = new List<ExcelColObj> ();
        PSLItems = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
        PAFSet = new Set<id>();
        Date psSubDate; //20160628, added by Leo
        PSLItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c,ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c = :PSLId ORDER By id ASC];
        //20160628, edited by Leo, add price set submittion date
        for (ASI_CRM_Price_Set_Generation_Log_Detail__c Item: PSLItems) {
            PAFSet.add(Item.ASI_CRM_Pre_Approval_Form__c);
        }
        psSubDate = PSLItems[0].ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c; //20160628, added by Leo
        if (PAFSet.size() > 0) {
            PAFItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            PAFItems = [SELECT id, ASI_HK_CRM_Price__c
                        , ASI_CRM_HK_Pricing_Item__c
                        , ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c
                        , ASI_HK_CRM_SKU_Lookup__c
                        , ASI_HK_CRM_SKU_Lookup__r.Name
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_CRM_HK_Pricing_Category__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Description__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.Name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Short_Term_Promotion__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c //20160412, added by Leo
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c //20160412, added by Leo
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c
                        , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c
                        , ASI_HK_CRM_Target_Volume_Qty__c
                        , ASI_HK_CRM_Rebate_Disc_Percent__c
                        , ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c
                        , ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c, ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c
                        , ASI_HK_CRM_FOC_Free_Bottle_Option_1__c, ASI_HK_CRM_FOC_Free_Bottle_Option_2__c
                        , ASI_HK_CRM_FOC_Free_Bottle_Option_3__c, ASI_HK_CRM_FOC_Free_Bottle_Option_4__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Chann_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name2_Cust_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name2_Chann_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Cust_PAF__c
                        , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Chan_PAF__c
                        , ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c
                        , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c
                        , ASI_CRM_HK_All_Product__c
                        FROM
                        ASI_HK_CRM_Pre_Approval_Form_Item__c
                        WHERE
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__c IN:PAFSet
                        AND ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c != NULL
                        AND (ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c != ''
                             OR ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Chann_PAF__c != '')
                       ];
            Map<id, string> pricingChannelMap = new Map<id, string>();
            Map<id, string> channelAdminMap = new Map<id, string>();
            Set<id> CusSet = new Set<id>(); 
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c PAFItem: PAFItems) {
                CusSet.add(PAFItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
            }
            List<Account> acctSet = [SELECT Id, ASI_HK_CRM_Customer_Number__c, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Channel__c,ASI_HK_CRM_Customer_Type__c 
                                     //, ASI_CRM_AccountAdditionalField__pr.ASI_CRM_Pricing_Channel__c
                                     FROM Account WHERE Id IN :CusSet];
            for (Account CustAcc: acctSet) {
                string accChannel = CustAcc.ASI_HK_CRM_Channel__c.substring(0,3) + '%';
                ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannelMapObj = [SELECT ASI_HK_CRM_Channel__c, ASI_HK_CRM_Pricing_Channel__c 
                                                                             , ASI_CRM_Channel_Admin1__r.Name
                                                                                From ASI_HK_CRM_Channel_Local_Channel_Map__c
                                                                             Where ASI_HK_CRM_Channel__c Like: accChannel
                                                                             Limit 1];
                pricingChannelMap.put(CustAcc.Id, PricingChannelMapObj.ASI_HK_CRM_Pricing_Channel__c);
                channelAdminMap.put(CustAcc.Id, PricingChannelMapObj.ASI_CRM_Channel_Admin1__r.Name);
            }
            /*
            List<ASI_CRM_AccountsAdditionalField__c> Addedfields = [SELECT id, ASI_CRM_Account__c, ASI_CRM_Pricing_Channel__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN : CusSet];
            for (ASI_CRM_AccountsAdditionalField__c AddedField: Addedfields) {
                pricingChannelMap.put(AddedField.ASI_CRM_Account__c, AddedField.ASI_CRM_Pricing_Channel__c);
            }*/
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustomers = [SELECT id, ASI_CRM_Generate_Price_Set__c, ASI_CRM_HK_Customer__r.Name, 
                                                                           ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c
                                                                           , ASI_CRM_HK_Pre_Approval_Form__c//20151230 Ben @ Elufa Systems fix the soql error
                                                                           FROM 
                                                                           ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                                                                           WHERE 
                                                                           ASI_CRM_HK_Pre_Approval_Form__c IN : PAFSet AND ASI_CRM_Generate_Price_Set__c = true
                                                                          ];
            PAFCustomerMap = new Map<id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>>();
            if (PAFCustomers.size() > 0){
                for (ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFCustomer: PAFCustomers) {
                    if(!PAFCustomerMap.containsKey(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c)) {
                        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> tmpPAFCust = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
                        tmpPAFCust.add(PAFCustomer);
                        PAFCustomerMap.put(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c, tmpPAFCust);
                    } else {
                        PAFCustomerMap.get(PAFCustomer.ASI_CRM_HK_Pre_Approval_Form__c).add(PAFCustomer);
                    }
                }
            }
            decimal count=1;
            if (PAFItems.size() > 0) {
                for (ASI_HK_CRM_Pre_Approval_Form_Item__c rows: PAFItems) {
                    // Modified 20160118
                    if (rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c != rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c){
                        ExcelColObj row = new ExcelColObj();
                        row.ColC = '';
                        row.ColD = '';
                        row.ColE = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name;
                        row.ColH = '';
                        row.ColL = '';
                        if(!rows.ASI_CRM_HK_All_Product__c) //20160321, edited by Leo
                        { //20160321, edited by Leo
                          row.ColM = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_CRM_HK_Pricing_Category__c;
                          row.ColN = '="'+rows.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c+'"';
                        } //20160321, edited by Leo
                        else //20160321, edited by Leo
                        { //20160321, edited by Leo
                            row.ColM = ''; //20160321, edited by Leo
                          row.ColN = ''; //20160321, edited by Leo
                        } //20160321, edited by Leo
                        row.ColO = '';
                        row.ColP = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.CurrencyIsoCode;
                        if (rows.ASI_HK_CRM_Rebate_Disc_Percent__c != null && rows.ASI_HK_CRM_Rebate_Disc_Percent__c != 0) {
                            row.ColQ = '2'; // mark ng @2020-06-22 from 1
              /*[WL 1.0 BEGIN]*/
                            //row.ColR = '-' + rows.ASI_HK_CRM_Rebate_Disc_Percent__c + '%';
              row.ColR = '-' + rows.ASI_HK_CRM_Rebate_Disc_Percent__c;
              /*[WL 1.0 END]*/
                        }
                        else if (rows.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c!= 0 && rows.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null) {
                            row.ColQ = '5';
                            row.ColR = '-' + rows.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                        }
                        else {
                            row.ColQ = '';
                            row.ColR = '0';
                        }
                        row.ColS = rows.ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_UOM1__c;
                        //row.ColT = String.ValueOf(rows.ASI_HK_CRM_Target_Volume_Qty__c);
                        Date tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c; //20160212, edited by Leo;
                        if(psSubDate < tmpdate) //20160628, edited by Leo
                            row.ColU = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                        else //20160628, edited by Leo
                            row.ColU = psSubDate.month() +'/' + psSubDate.day() + '/' + psSubDate.year(); //20160628, edited by Leo
                        tmpdate = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c; //20160212, edited by Leo
                        if(tmpdate != null)
                          row.ColV = tmpdate.month() +'/' + tmpdate.day() + '/' + tmpdate.year();
                        else
                            row.ColV = '';
                        if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null) {
                            row.ColT = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c);
                            row.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c);
                            row.ColX = '="'+rows.ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c+'"';
                            //row.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c);
                            //row.ColX = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c);
                        }
                        else //20160324, added by Leo
                            row.ColT = '1'; //20160324, added by Leo
                        row.ColY = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Owner.Name;
                        row.ColZ = channelAdminMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                        if (PAFCustomerMap.containsKey(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c)){
                            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustList = PAFCustomerMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
                            for (ASI_CRM_HK_Pre_Approval_Form_Customer__c Cust: PAFCustList){
                                ExcelColObj rowC = new ExcelColObj();
                                rowC.ColA = String.valueOf(count++);
                                rowC.ColB = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c;
                                rowC.ColC = row.ColC;
                                rowC.ColD = row.ColD;
                                rowC.ColE = row.ColE;
                                rowC.ColF = Cust.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Customer_Code__c;
                                rowC.ColG = Cust.ASI_CRM_HK_Customer__r.Name.replace('('+rowC.ColF+')','').trim();
                                rowC.ColH = row.ColH;
                                rowC.ColI = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Cust_PAF__c;
                                rowC.ColJ = '';
                                rowC.ColK = '';
                                rowC.ColL = row.ColL;
                                rowC.ColM = row.ColM;
                                rowC.ColN = row.ColN;
                                rowC.ColO = row.ColO;
                                rowC.ColP = row.ColP;
                                rowC.ColQ = row.ColQ;
                                rowC.ColR = row.ColR;
                                rowC.ColS = row.ColS;
                                rowC.ColT = row.ColT;
                                rowC.ColU = row.ColU;
                                rowC.ColV = row.ColV;
                                rowC.ColW = row.ColW;
                                rowC.ColX = row.ColX;
                                rowC.ColY = row.ColY;
                                rowC.ColZ = row.ColZ;
                                ExcelColsAPbyItemGP.add(rowC);
                                //if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null && math.mod(Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c),Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c)) == 0) {
                                if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null ) {
                                        ExcelColObj row2 = new ExcelColObj();
                                        row2.ColA = String.valueOf(count++);
                                        row2.ColB = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name2_Cust_PAF__c;
                                        row2.ColC = rowC.ColC;
                                        row2.ColD = rowC.ColD;
                                        row2.ColE = rowC.ColE;
                                        row2.ColF = rowC.ColF;
                                        row2.ColG = rowC.ColG;
                                        row2.ColH = rowC.ColH;
                                        row2.ColI = rowC.ColI;
                                        row2.ColJ = rowC.ColJ;
                                        row2.ColK = rowC.ColK;
                                        row2.ColL = rowC.ColL;
                                        row2.ColM = rowC.ColM;
                                        row2.ColN = rowC.ColN;
                                        row2.ColO = rowC.ColO;
                                        row2.ColP = rowC.ColP;
                                        row2.ColQ = rowC.ColQ;
                                        row2.ColR = rowC.ColR;
                                        row2.ColS = rowC.ColS;
                                        //row2.ColT = rowC.ColT;
                                        row2.ColT = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c);
                                        row2.ColU = rowC.ColU;
                                        row2.ColV = rowC.ColV;
                                        row2.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c - (((rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c / rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).round(System.RoundingMode.DOWN)) * rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c));
                                        row2.ColX = '="'+rows.ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c+'"';
                                        //row2.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c);
                                        //row2.ColX = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c - (((rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c / rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).round(System.RoundingMode.DOWN)) * rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c));
                                        row2.ColY = row.ColY;
                                        row2.ColZ = row.ColZ;
                                        ExcelColsAPbyItemGP.add(row2);
                                    }
                            }
                        }
                        else if (PAFCustomerMap.size() == 0 && rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Short_Term_Promotion__c ){
                            //TO-DO: Error Handling of missing "Generate Price Set?"
                        }
                        else{
                            row.ColA = String.valueOf(count++);
                            if (rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.startsWith('OUTLET_')) {
                                row.ColB = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Chann_PAF__c;
                                row.ColF = '';
                                row.ColG = '';
                                row.ColI = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Chan_PAF__c;
                                List<String> tmpString = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.split('_');
                                row.ColJ = tmpString[0];
                                //row.ColK = tmpString[1].replaceAll('\\(.*?\\)','').trim();
                                row.ColK = pricingChannelMap.get(rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c);
                                ExcelColsAPbyItemGP.add(row);
                            } 
                            else {
                                row.ColB = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c;
                                row.ColF = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c != Null?
                                    rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c:rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c;
                                row.ColG = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.replaceAll('\\(.*?\\)','').trim();
                                row.ColI = rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Preference_for_Cust_PAF__c;
                                row.ColJ = '';
                                row.ColK = '';
                                ExcelColsAPbyItemGP.add(row);
                            }
                            //if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null && math.mod(Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c),Integer.Valueof(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c)) == 0) {
                            if (rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null ) {
                                    ExcelColObj row2 = new ExcelColObj();
                                    row2.ColA = String.valueOf(count++);
                                    row2.ColB = rows.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name.startsWith('OUTLET_')? 
                                        rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name2_Chann_PAF__c : rows.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Adjustment_Name2_Cust_PAF__c;
                                    row2.ColC = row.ColC;
                                    row2.ColD = row.ColD;
                                    row2.ColE = row.ColE;
                                    row2.ColF = row.ColF;
                                    row2.ColG = row.ColG;
                                    row2.ColH = row.ColH;
                                    row2.ColI = row.ColI;
                                    row2.ColJ = row.ColJ;
                                    row2.ColK = row.ColK;
                                    row2.ColL = row.ColL;
                                    row2.ColM = row.ColM;
                                    row2.ColN = row.ColN;
                                    row2.ColO = row.ColO;
                                    row2.ColP = row.ColP;
                                    row2.ColQ = row.ColQ;
                                    row2.ColR = row.ColR;
                                    row2.ColS = row.ColS;
                                    row2.ColT = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c);
                                    //row.ColT;
                                    row2.ColU = row.ColU;
                                    row2.ColV = row.ColV;
                                    row2.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c - (((rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c / rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).round(System.RoundingMode.DOWN)) * rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c));
                                    row2.ColX = '="'+rows.ASI_CRM_HK_Free_SKU__r.ASI_MFM_SKU_Code__c+'"';
                                    //row2.ColW = String.ValueOf(rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c);
                                    //row2.ColX = String.ValueOf(rows.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c - (((rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c / rows.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).round(System.RoundingMode.DOWN)) * rows.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c));
                                    row2.ColY = row.ColY;
                                    row2.ColZ = row.ColZ;
                                    ExcelColsAPbyItemGP.add(row2);
                                }
                        }
                    }
                }
            }
        }        
        No_APbyItemGP = ExcelColsAPbyItemGP.size();
        return true;
    }
    
    public static boolean PSSummaryByPAF(){
    
        return (BasePriceBySKU() && BasePriceByItemGP() && AdvPriceBySKU() && AdvPriceByItemGP());
    }
}