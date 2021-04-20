/*********************************************************************************
 * Name: ASI_CRM_HK_EDISO_To_Invoice_Batch
 * Description: 
 * Test Class:  ASI_CRM_HK_EDISO_To_Invoice_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-27       Wilken Lee             [WL 1.0] Additional handling to cater Watson's Wine cellar uses same GLN as ParkNShop
 * 2018-10-11       Wilken Lee             [WL 2.0] Add record type to EDI Invoice
 * 2018-10-12       Wilken Lee             [WL 3.0] Add "Has Error" checkbox in order to filter in list view
 * 2019-02-26       Wilken Lee             [WL 4.0] EDI Invoice Buyer GLN should be from EDI SO Buyer ID
 * 2019-02-27       Wilken Lee             [WL 5.0] Add Product EAN Code to Invoice Item
 * 2019-04-01       Wilken Lee             [WL 6.0] Skip invoice generation for item that is Not Fulfilled
 * 2019-04-01       Wilken Lee             [WL 7.0] Format Delivery Date to string for comparison
 * 2019-04-01       Wilken Lee             [WL 8.0] Skip requirement to have CRM SO & Trigger Processed in order to generate invoice, skip Voided EDI SO as well
 * 2019-04-12       Wilken Lee             [WL 9.0] Separate Buyer GLN and Sender Identification into two fields
 * 2019-04-24       Wilken Lee             [WL 10.0] Allow entering SO Invoice # in Credit Order and system still able to link it for EDI Invoice generation
 * 2019-05-06       Wilken Lee             [WL 11.0] Include Document Type "SO" to invoice generation
 * 2019-05-28       Wilken Lee             [WL 12.0] Add Custom Setting to control default interface EDI Invoice to ezTrade
 */
global class ASI_CRM_HK_EDISO_To_Invoice_Batch implements Database.Batchable<sObject>, Database.Stateful
{   
    //public Id customerRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
    //public Id customerRecTypeID2 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
    //public Id headerRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader');
    //public Id itemRecTypeID = Global_RecordTypeCache.getRtId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP');
    public String log;
    public static final String DEFAULT_CURRENCYISOCODE = 'HKD';
    public static final List<String> SO_HISTORY_ORDER_TYPE = new List<String>{'S1', 'CR', 'SO'};    //WL 11.0
    public static final String CUST_MAPPING_PICKLIST_UOM_BOTTLE = 'Bottle';
    public static final String CUST_MAPPING_PICKLIST_UOM_CASE = 'Case';
    public static final String CUST_MAPPING_PICKLIST_UOM_UOM_FACTOR = 'UOM Factor';
                                            
    private Boolean autoSyncInv = false;    //WL 12.0
                                                                            
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Datetime dFiveDaysAgo = Datetime.now().addDays(-5);     //[WL 7.0]
        
        String dFiveDaysAgoStr = dFiveDaysAgo.format('yyyy-MM-dd'); //[WL 7.0]
        
        string query = 'select '
                        + 'Id, Name, ASI_CRM_Customer_PO__c, ASI_CRM_Buyer_ID__c, ASI_CRM_Buyer_Name__c, '
                        + 'ASI_CRM_Buyer_Name_2__c, ASI_CRM_Order_Date__c, ASI_CRM_Delivery_Date__c, '
                        + 'ASI_CRM_Delivery_Party__c, ASI_CRM_ETL_Complete__c, ASI_HK_Generated_SO__c, '
                        + 'ASI_CRM_Sender_Identification__c, ASI_CRM_SO_Generation_Error__c, ASI_CRM_Trigger_Processed__c, '
                        + 'ASI_CRM_Address_Line_1__c, ASI_CRM_Address_Line_2__c, ASI_CRM_Address_Line_3__c, ASI_CRM_Address_Line_4__c, '
                        + 'ASI_HK_CRM_EDI_Invoice__c, CurrencyIsoCode '
                        + 'from ASI_CRM_EDI_SO_Header__c '
                        + 'where ASI_CRM_ETL_Complete__c = true '
                        //+ 'and ASI_CRM_Trigger_Processed__c = true '  //WL 8.0
                        + 'and ASI_HK_CRM_EDI_Invoice__c = null '
                        + 'and ASI_CRM_Voided__c = false '  //WL 8.0
                        //+ 'and ASI_HK_Generated_SO__c != null ' //WL 8.0
                        //+ 'and ASI_CRM_Delivery_Date__c != null'; //For Testing Purpose
                        + 'and ASI_CRM_Delivery_Date__c <= :dFiveDaysAgoStr'; //For Actual  //[WL 7.0]
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_CRM_EDI_SO_Header__c> scope)
    {
        try
        {
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Start');
            
            /*[WL 12.0] BEGIN*/
            ASI_HK_CRM_ThresholdValues__c setting = [select id , ASI_CRM_Enable_EDI_Invoice_Auto_Sync__c from ASI_HK_CRM_ThresholdValues__c LIMIT 1];
            if (setting != null)
                autoSyncInv = setting.ASI_CRM_Enable_EDI_Invoice_Auto_Sync__c;
            /*[WL 12.0] END*/
            
            Set<Id> ediSOIDs = new Set<Id>();
            Set<String> custPOIDs = new Set<String>();
            Set<String> buyerIDs = new Set<String>();
            Set<Id> histIDs = new Set<Id>();
            Set<Id> skuIDs = new Set<Id>();

            for (ASI_CRM_EDI_SO_Header__c s : scope)
            {
                ediSOIDs.add(s.Id);
                custPOIDs.add(s.ASI_CRM_Customer_PO__c);
                buyerIDs.add(s.ASI_CRM_Buyer_ID__c);
            }
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting EDI SO, Cust PO, Buyer ID');

            List<ASI_HK_CRM_Sales_Order_History__c> histList = [
                SELECT Id, 
                ASI_HK_CRM_Account_PA__c,
                ASI_CRM_AccountAdditionalField__c,
                ASI_HK_CRM_Customer_PO__c,
                ASI_HK_CRM_EDI_Invoice__c,
                ASI_HK_CRM_JDE_Invoice_No__c,
                ASI_CRM_Invoice_Date__c,
                ASI_HK_CRM_Order_Type__c
                FROM ASI_HK_CRM_Sales_Order_History__c
                WHERE ASI_HK_CRM_Customer_PO__c in :custPOIDs
                AND ASI_HK_CRM_EDI_Invoice__c = NULL
                AND ASI_HK_CRM_Order_Type__c IN :SO_HISTORY_ORDER_TYPE
                ORDER BY ASI_HK_CRM_Customer_PO__c ASC, ASI_HK_CRM_Order_Type__c DESC, ASI_HK_CRM_JDE_Invoice_No__c ASC
            ];
            
            /*[WL 10.0] BEGIN*/
            for (ASI_HK_CRM_Sales_Order_History__c hist : histList)
            {
                custPOIDs.add(hist.ASI_HK_CRM_JDE_Invoice_No__c);
            }
            
            histList = [
                    SELECT Id, 
                    ASI_HK_CRM_Account_PA__c,
                    ASI_CRM_AccountAdditionalField__c,
                    ASI_HK_CRM_Customer_PO__c,
                    ASI_HK_CRM_EDI_Invoice__c,
                    ASI_HK_CRM_JDE_Invoice_No__c,
                    ASI_CRM_Invoice_Date__c,
                    ASI_HK_CRM_Order_Type__c
                    FROM ASI_HK_CRM_Sales_Order_History__c
                    WHERE ASI_HK_CRM_Customer_PO__c in :custPOIDs
                    AND ASI_HK_CRM_EDI_Invoice__c = NULL
                    AND ASI_HK_CRM_Order_Type__c IN :SO_HISTORY_ORDER_TYPE
                    ORDER BY ASI_HK_CRM_Customer_PO__c ASC, ASI_HK_CRM_Order_Type__c DESC, ASI_HK_CRM_JDE_Invoice_No__c ASC
            ];
            /*[WL 10.0] END*/
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting SO History');

            for (ASI_HK_CRM_Sales_Order_History__c hist : histList)
            {
                histIDs.add(hist.Id);
            }
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting SO History ID | histIDs.size() : ' + histIDs.size());

            List<ASI_HK_CRM_Sales_Order_History_Detail__c> histDetailList = [
                select Id,
                ASI_HK_CRM_Sales_Order_History__c,
                ASI_HK_CRM_Product_SKU__c,
                ASI_HK_CRM_Product_SKU__r.Name, 
                ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_Packaging_Size__c,
                ASI_HK_CRM_Quantity_in_Bottles__c,
                ASI_HK_CRM_Total_Amount__c
                from
                ASI_HK_CRM_Sales_Order_History_Detail__c
                where ASI_HK_CRM_Sales_Order_History__c in :histIDs
                order by ASI_HK_CRM_Sales_Order_History__c asc, ASI_HK_CRM_Product_SKU__c
            ];
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting SO History Items');

            for (ASI_HK_CRM_Sales_Order_History_Detail__c detail : histDetailList)
            {
                skuIDs.add(detail.ASI_HK_CRM_Product_SKU__c);
            }
                        
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting SO History Item SKU ID | skuIDs.size() : ' + skuIDs.size());

            List<ASI_CRM_Customer_Mapping__c> custList = [
                select ASI_CRM_Buyer_ID__c, ASI_CRM_Account__c, ASI_CRM_Account__r.ParentId, ASI_CRM_UOM__c 
                from ASI_CRM_Customer_Mapping__c
                where ASI_CRM_Buyer_ID__c in :buyerIDs
                AND recordType.DeveloperName = 'ASI_CRM_HK_EDI_Customer_Mapping'//[WL 3.0]
                AND ASI_CRM_Account__c != NULL
            ];
            
            /*[WL 1.0] BEGIN*/
            List<ASI_CRM_Customer_Mapping__c> additionalCustList = [
                select ASI_CRM_Delivery_Party_Keyword__c, ASI_CRM_Account__c, ASI_CRM_Account__r.OwnerId, ASI_CRM_Account__r.ParentId, ASI_CRM_UOM__c 
                from ASI_CRM_Customer_Mapping__c
                where recordType.DeveloperName = 'ASI_CRM_HK_EDI_Additional_Customer_Mapping'
            ];
            /*[WL 1.0] END*/

            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting Customer Mapping | custList.size() : ' + custList.size());
            
            List<ASI_CRM_EDI_SO_Item__c> itemList = [
                select 
                Id, Name, ASI_CRM_EDI_Sales_Order_Header__c, ASI_CRM_Product_EAN_Code__c,
                ASI_CRM_Order_Quantity__c, ASI_CRM_Price__c, ASI_CRM_SKU_Code__c, 
                ASI_CRM_SKU_Description__c, ASI_CRM_SKU_Description_2__c, ASI_CRM_Item_Line_Number__c,
                ASI_CRM_UOM_Factor__c, ASI_CRM_Not_Fulfilled__c 
                from ASI_CRM_EDI_SO_Item__c
                where ASI_CRM_EDI_Sales_Order_Header__c in :ediSOIDs
                order by ASI_CRM_EDI_Sales_Order_Header__c asc, ASI_CRM_Item_Line_Number__c asc
            ];
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting EDI SO Items | itemList.size() : ' + itemList.size());

            /*List<ASI_CRM_SKU_Mapping__c> skuList = [
                select ASI_CRM_SKU__c, ASI_CRM_Customer_Number__c, ASI_CRM_Item_Number__c
                from ASI_CRM_SKU_Mapping__c
                where ASI_CRM_SKU__c in :skuIDs
                and ASI_CRM_Inactive__c = false
                order by ASI_CRM_SKU__c asc
            ];*/
            List<ASI_CRM_SKU_Mapping__c> skuList = [
                select ASI_CRM_SKU__c, ASI_CRM_Account__c, ASI_CRM_Item_Number__c, ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c,
                ASI_CRM_Preferred__c, ASI_CRM_Item_Group_Mapping__r.ASI_CRM_Preferred__c, ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c,
                ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c
                from ASI_CRM_SKU_Mapping__c
                where ASI_CRM_SKU__c in :skuIDs
                and RecordType.DeveloperName = 'ASI_CRM_HK_EDI_SKU_Mapping'                
                order by ASI_CRM_SKU__c asc
            ];
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting SKU Mapping | skuList.size() : ' + skuList.size());

            List<ASI_CRM_EDI_Invoice_Header__c> insertHeader = new List<ASI_CRM_EDI_Invoice_Header__c>();
            List<ASI_CRM_EDI_Invoice_Item__c> insertItem = new List<ASI_CRM_EDI_Invoice_Item__c>();
            List<ASI_CRM_EDI_SO_Header__c> updateSO = new List<ASI_CRM_EDI_SO_Header__c>();
            List<ASI_HK_CRM_Sales_Order_History__c> updateHistory = new List<ASI_HK_CRM_Sales_Order_History__c>();
            
            // handle
            for (ASI_CRM_EDI_SO_Header__c header : scope)
            {
                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | In loop on EDI SO Header : ' + header.Name);
                
                List<ASI_CRM_EDI_SO_Item__c> items = getItems(itemList, header.Id);
                ASI_CRM_Customer_Mapping__c cust = getCustMapping(custList, header.ASI_CRM_Buyer_ID__c);
                List<ASI_HK_CRM_Sales_Order_History__c> hList = getHistory(histList, header.ASI_CRM_Customer_PO__c);
                
                /*[WL 1.0] BEGIN*/
                for (ASI_CRM_Customer_Mapping__c addCust: additionalCustList){
                    if (header.ASI_CRM_Delivery_Party__c != null && header.ASI_CRM_Delivery_Party__c.contains(addCust.ASI_CRM_Delivery_Party_Keyword__c))
                        cust = addCust;
                }
                /*[WL 1.0] END*/
            
                if(items.size() > 0 && cust != NULL && hList.size() > 0){
                    Date deliveryDate;
                    List<String> deliveryDateList = header.ASI_CRM_Delivery_Date__c.split('-');
                    
                    System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | header.ASI_CRM_Delivery_Date__c : ' + header.ASI_CRM_Delivery_Date__c);
                    
                    if (deliveryDateList.size() == 3){
                        deliveryDate = Date.newInstance(
                            Integer.valueOf(deliveryDateList.get(0)), 
                            Integer.valueOf(deliveryDateList.get(1)), 
                            Integer.valueOf(deliveryDateList.get(2))
                        );
                    }
                    
                    System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | deliveryDate : ' + deliveryDate);
                    String companyName = (String.isBlank(header.ASI_CRM_Buyer_Name__c) ? '' : header.ASI_CRM_Buyer_Name__c);
                    companyName += (String.isBlank(header.ASI_CRM_Buyer_Name_2__c) ? '' : ' ' + header.ASI_CRM_Buyer_Name_2__c);
                    ASI_CRM_EDI_Invoice_Header__c iHeader = new ASI_CRM_EDI_Invoice_Header__c(
                        ASI_CRM_Buyer_Company_Name__c = companyName,
                        ASI_CRM_Buyer_GLN__c = header.ASI_CRM_Buyer_ID__c, //[WL 4.0] //[WL 9.0]
                        ASI_CRM_Sender_Identification__c = header.ASI_CRM_Sender_Identification__c, //[WL 9.0]
                        ASI_CRM_Delivery_Date__c = deliveryDate,
                        ASI_CRM_Ready_For_Interface__c = FALSE,
                        ASI_CRM_EDI_Completed__c = FALSE,
                        ASI_CRM_Invoice_Date__c = hList[0].ASI_CRM_Invoice_Date__c,
                        ASI_CRM_Invoice_Number__c = hList[0].ASI_HK_CRM_JDE_Invoice_No__c,
                        CurrencyIsoCode = DEFAULT_CURRENCYISOCODE, //header.CurrencyIsoCode
                        ASI_CRM_Cust_PO__c = header.ASI_CRM_Customer_PO__c,
                        ASI_CRM_Invoice_Generation_Error__c = '',
                        ASI_CRM_Has_Error__c = false, //[WL 3.0]
                        recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_EDI_Invoice_Header__cASI_CRM_HK_EDI_Invoice_Header') //[WL 2.0]
                    );
                    
                    /*[WL 12.0] BEGIN*/
                    if (autoSyncInv)
                        iHeader.ASI_CRM_Ready_For_Interface__c = true;
                    /*[WL 12.0] END*/
            
                    insertHeader.add(iHeader);
                    
                    System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | New Header Insert');
                    
                    header.ASI_HK_CRM_EDI_Invoice__r = iHeader;
                    updateSO.add(header);
                    
                    Map<String, ASI_CRM_EDI_Invoice_Item__c> itemMap = new Map<String, ASI_CRM_EDI_Invoice_Item__c>();
                    for (ASI_HK_CRM_Sales_Order_History__c hist : hList)
                    {
                        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Looping SO History on Cust PO : ' + hist.ASI_HK_CRM_Customer_PO__c);
                        hist.ASI_HK_CRM_EDI_Invoice__r = iHeader;
                        updateHistory.add(hist);
                        List<ASI_HK_CRM_Sales_Order_History_Detail__c> dList = getHistoryDetail(histDetailList, hist.Id);
                        
                        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting History Details | dList.size() : ' + dList.size());
                        
                        for (ASI_HK_CRM_Sales_Order_History_Detail__c d : dList)
                        {
                            List<ASI_CRM_SKU_Mapping__c> skuMap = getSkuMapping(skuList, cust.ASI_CRM_Account__c, d.ASI_HK_CRM_Product_SKU__c);
                            
                            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting SKU Mapping from Customer | Customer Id : ' + cust.ASI_CRM_Account__c + ' | skuMap.size() : ' + skuMap.size());
                            
                            //If no SKU Mapping was found for the Customer and Customer is under a Parent Account, should look for SKU Mapping by Parent Account's Customer Code as well
                            if(skuMap.size() == 0 && cust.ASI_CRM_Account__r.ParentId != NULL){
                                skuMap = getSkuMapping(skuList, cust.ASI_CRM_Account__r.ParentId, d.ASI_HK_CRM_Product_SKU__c);
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting SKU Mapping from Parent Customer |  Parent Id : ' + cust.ASI_CRM_Account__r.ParentId + ' | skuMap.size() : ' + skuMap.size());
                            }
                            
                            ASI_CRM_EDI_SO_Item__c soItem;
                            String skuCode = '';
                            for (ASI_CRM_SKU_Mapping__c sMap : skuMap)
                            {
                                soItem = getItem(items, sMap.ASI_CRM_Item_Number__c);
                                
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting Item | soItem != null : ' + (soItem != null));
                                
                                if (soItem != null)
                                {
                                    skuCode = sMap.ASI_CRM_Item_Number__c;
                                    break;
                                }
                            }
                            
                            //If there is one SKU could not be mapped, the Header will be marked as not ready. PR IT should look into it and handle this EDI Invoice
                            system.debug('SO History Detail SKU: ' + d.ASI_HK_CRM_Product_SKU__c + ' Mapping skuCode: ' + skuCode);
                            if(skuCode == ''){
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Item not mapped. EDI Invoice not ready for interfacing.');
                                iHeader.ASI_CRM_Ready_For_Interface__c = FALSE;
                                iHeader.ASI_CRM_Invoice_Generation_Error__c += 'Item (' + d.ASI_HK_CRM_Product_SKU__r.Name + ') not mapped. please confirm\n';
                                iHeader.ASI_CRM_Has_Error__c = true; //[WL 3.0]
                            }
                            
                            ASI_CRM_EDI_Invoice_Item__c item = itemMap.get(skuCode);
                            
                            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After getting EDI Invoice Item | item == null : ' + (item == null));
                            
                            if (item == null)
                            {
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Create new EDI Invoice Item');
                                
                                item = new ASI_CRM_EDI_Invoice_Item__c(
                                    ASI_CRM_EDI_Invoice_Header__r = iHeader,
                                    ASI_CRM_Invoiced_Net_Price__c = soItem == NULL ? 0 : Decimal.valueOf(soItem.ASI_CRM_Price__c),
                                    ASI_CRM_Invoice_Quantity__c = getActualItemAmount(cust.ASI_CRM_UOM__c, d, soItem, iHeader), //d.ASI_HK_CRM_Quantity_in_Bottles__c,
                                    ASI_CRM_Item_Description__c = soItem == NULL ? '' : soItem.ASI_CRM_SKU_Description__c + ' ' + soItem.ASI_CRM_SKU_Description_2__c,
                                    ASI_CRM_Product_EAN_Code__c = soItem == NULL ? '' : soItem.ASI_CRM_Product_EAN_Code__c, //[WL 5.0]
                                    ASI_CRM_SKU_Code__c = skuCode,
                                    CurrencyIsoCode = DEFAULT_CURRENCYISOCODE, //header.CurrencyIsoCode
                                    recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_EDI_Invoice_Item__cASI_CRM_HK_EDI_Invoice_Item'),
                                    ASI_CRM_Line_Number__c= soItem == NULL ? 0: decimal.valueOf(soItem.ASI_CRM_Item_Line_Number__c)
                                );
                                
                                /*[WL 6.0] BEGIN*/
                                if (soItem != null && soItem.ASI_CRM_Not_Fulfilled__c == false) 
                                    itemMap.put(skuCode, item);
                                else if (soItem != null && soItem.ASI_CRM_Not_Fulfilled__c == true){
                                    System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Item Not Fulfilled, Need CS Confirm.');
                                    iHeader.ASI_CRM_Ready_For_Interface__c = FALSE;
                                    iHeader.ASI_CRM_Invoice_Generation_Error__c += 'Item (' + d.ASI_HK_CRM_Product_SKU__r.Name + ') not fulfilled. Please confirm\n';
                                    iHeader.ASI_CRM_Has_Error__c = true;
                                }
                                /*[WL 6.0] END*/
                                
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After putting SKU Code and Invoice Item into itemMap');
                            }
                            else
                            {
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Added existing item quantity instead');                                                             
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | d.ASI_HK_CRM_Quantity_in_Bottles__c : ' + d.ASI_HK_CRM_Quantity_in_Bottles__c);
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | BEFORE item.ASI_CRM_Invoice_Quantity__c : ' + item.ASI_CRM_Invoice_Quantity__c);
                                
                                item.ASI_CRM_Invoice_Quantity__c += getActualItemAmount(cust.ASI_CRM_UOM__c, d, soItem, iHeader);// d.ASI_HK_CRM_Quantity_in_Bottles__c; 
                                
                                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | AFTER item.ASI_CRM_Invoice_Quantity__c : ' + item.ASI_CRM_Invoice_Quantity__c);
                            }
                        }
                    }
                    System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Finished looping on SO History');
                    
                    for (String key : itemMap.keySet())
                    {
                        ASI_CRM_EDI_Invoice_Item__c item = itemMap.get(key);
                        insertItem.add(item);
                    }                    
                }
                
                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | Leaving loop on EDI SO Header : ' + header.Name);
            }
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After looping EDI SO Header');

            if (insertHeader.size() > 0)
            {
                //insert insertHeader;
                
                Database.SaveResult[] srList = database.insert(insertHeader, false);
                for (Integer i = 0; i < srList.size(); i++)
                {
                    if (!srList[i].isSuccess())
                    {
                        this.log += '\n Error in new EDI Invoice Header: ' + insertHeader[i].ASI_CRM_Invoice_Number__c + '. Error msg=' + srList[i].getErrors()[0].getMessage();
                    }
                }
            }
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After Insert new EDI Invoice Header');

            if (insertItem.size() > 0)
            {
                for(ASI_CRM_EDI_Invoice_Item__c item : insertItem){
                    item.ASI_CRM_EDI_Invoice_Header__c = item.ASI_CRM_EDI_Invoice_Header__r.Id;
                }
                
                //insert insertItem;
                
                Database.SaveResult[] srList = database.insert(insertItem, false);
                for (Integer i = 0; i < srList.size(); i++)
                {
                    if (!srList[i].isSuccess())
                    {
                        this.log += '\n Error in new EDI Invoice Details: ' + insertItem[i].ASI_CRM_SKU_Code__c + '. Error msg=' + srList[i].getErrors()[0].getMessage();
                    }
                }
            }
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After Insert new EDI Invoice Details');

            if (updateSO.size() > 0)
            {
                for(ASI_CRM_EDI_SO_Header__c so : updateSO){
                    so.ASI_HK_CRM_EDI_Invoice__c = so.ASI_HK_CRM_EDI_Invoice__r.Id;
                }
                
                //update updateSO;
                
                Database.SaveResult[] srList = database.update(updateSO, false);
                for (Integer i = 0; i < srList.size(); i++)
                {
                    if (!srList[i].isSuccess())
                    {
                        this.log += '\n Error in updating EDI SO Header: ' + updateSO[i].Name + '. Error msg=' + srList[i].getErrors()[0].getMessage();
                    }
                }
            }
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After update existing EDI SO Header');

            if (updateHistory.size() > 0)
            {
                for(ASI_HK_CRM_Sales_Order_History__c his : updateHistory){
                    his.ASI_HK_CRM_EDI_Invoice__c = his.ASI_HK_CRM_EDI_Invoice__r.Id;
                }
                
                update updateHistory;
                
                Database.SaveResult[] srList = database.update(updateHistory, false);
                for (Integer i = 0; i < srList.size(); i++)
                {
                    if (!srList[i].isSuccess())
                    {
                        this.log += '\n Error in updating SO History: ' + updateHistory[i].Name + '. Error msg=' + srList[i].getErrors()[0].getMessage();
                    }
                }
            }
            
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | After update SO History');
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | execute | End');
        }
        catch (exception e)
        {
            System.debug(e.getMessage());
        }
    }

    public List<ASI_HK_CRM_Sales_Order_History__c> getHistory(List<ASI_HK_CRM_Sales_Order_History__c> histList, string custPO)
    {
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getHistory | Start');
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getHistory | histList.size() :' + histList.size());
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getHistory | custPO :' + custPO);
        
        List<ASI_HK_CRM_Sales_Order_History__c> hList = new List<ASI_HK_CRM_Sales_Order_History__c>();

        Set<String> jdeInvNumSet = new Set<String>(); //WL 10.0
        
        for (ASI_HK_CRM_Sales_Order_History__c hist : histList)
        {
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getHistory | hist.ASI_HK_CRM_Customer_PO__c :' + hist.ASI_HK_CRM_Customer_PO__c);
            if (hist.ASI_HK_CRM_Customer_PO__c == custPO)
            {
                hList.add(hist);
                jdeInvNumSet.add(hist.ASI_HK_CRM_JDE_Invoice_No__c);    //WL 10.0
            }
        }
        /*[WL 10.0] BEGIN*/
        for (ASI_HK_CRM_Sales_Order_History__c hist : histList)
        {
            if (jdeInvNumSet.contains(hist.ASI_HK_CRM_Customer_PO__c) && !hList.contains(hist))
            {
                hList.add(hist);
            }
        }
        /*[WL 10.0] END*/
        
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getHistory | End');

        return hList;
    }

    public List<ASI_HK_CRM_Sales_Order_History_Detail__c> getHistoryDetail(List<ASI_HK_CRM_Sales_Order_History_Detail__c> histDetailList, Id histID)
    {
        List<ASI_HK_CRM_Sales_Order_History_Detail__c> hdList = new List<ASI_HK_CRM_Sales_Order_History_Detail__c>();

        for (ASI_HK_CRM_Sales_Order_History_Detail__c hd : histDetailList)
        {
            if (hd.ASI_HK_CRM_Sales_Order_History__c == histID)
            {
                hdList.add(hd);
            }
        }

        return hdList;
    }

    public ASI_CRM_Customer_Mapping__c getCustMapping(List<ASI_CRM_Customer_Mapping__c> custList, String buyerID)
    {
        ASI_CRM_Customer_Mapping__c custMap;

        for (ASI_CRM_Customer_Mapping__c cust : custList)
        {
            if (cust.ASI_CRM_Buyer_ID__c == buyerID)
            {
                custMap = cust;
                break;
            }
        }

        return custMap;
    }
    
    public List<ASI_CRM_EDI_SO_Item__c> getItems(List<ASI_CRM_EDI_SO_Item__c> itemList, Id headerID)
    {
        List<ASI_CRM_EDI_SO_Item__c> retList = new List<ASI_CRM_EDI_SO_Item__c>();

        for (ASI_CRM_EDI_SO_Item__c item : itemList)
        {
            if (item.ASI_CRM_EDI_Sales_Order_Header__c == headerID)
            {
                retList.add(item);
            }
        }

        return retList;
    }

    public ASI_CRM_EDI_SO_Item__c getItem(List<ASI_CRM_EDI_SO_Item__c> itemList, String skuCode)
    {
        ASI_CRM_EDI_SO_Item__c ret;

        for (ASI_CRM_EDI_SO_Item__c item : itemList)
        {
            if (item.ASI_CRM_SKU_Code__c == skuCode)
            {
                ret = item;
                break;
            }
        }

        return ret;
    }
    
    public List<ASI_CRM_SKU_Mapping__c> getSkuMapping(List<ASI_CRM_SKU_Mapping__c> skuList, Id custId, Id skuId)
    {
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getSkuMapping | Start');
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getSkuMapping | custId : ' + custId);
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getSkuMapping | skuId : ' + skuId);
        List<ASI_CRM_SKU_Mapping__c> skuMap = new List<ASI_CRM_SKU_Mapping__c>();

        for (ASI_CRM_SKU_Mapping__c skuMapObj : skuList)
        {
            //System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getSkuMapping | skuMapObj.ASI_CRM_Account__c : ' + skuMapObj.ASI_CRM_Account__c);           
            //System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getSkuMapping | skuMapObj.ASI_CRM_SKU__c : ' + skuMapObj.ASI_CRM_SKU__c);
            if (skuMapObj.ASI_CRM_Account__c == custId && skuMapObj.ASI_CRM_SKU__c == skuId)
            {
                skuMap.add(skuMapObj);
            }
        }
        
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getSkuMapping | End');
        return skuMap;
    }
    
    private decimal getActualItemAmount(String UOM, ASI_HK_CRM_Sales_Order_History_Detail__c d, ASI_CRM_EDI_SO_Item__c soItem, ASI_CRM_EDI_Invoice_Header__c iHeader){
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getActualItemAmount | Start');
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getActualItemAmount | UOM : ' + UOM);
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getActualItemAmount | Quantity in Bottles : ' + d.ASI_HK_CRM_Quantity_in_Bottles__c);
        decimal amount = 0;
        
        if(UOM == CUST_MAPPING_PICKLIST_UOM_BOTTLE){
            amount = d.ASI_HK_CRM_Quantity_in_Bottles__c;
        }else if(UOM == CUST_MAPPING_PICKLIST_UOM_CASE){
            System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getActualItemAmount | Packaging Size : ' + d.ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            amount = d.ASI_HK_CRM_Quantity_in_Bottles__c / d.ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_Packaging_Size__c;
        }else if(UOM == CUST_MAPPING_PICKLIST_UOM_UOM_FACTOR && soItem != NULL){
            if(soItem.ASI_CRM_UOM_Factor__c != NULL && soItem.ASI_CRM_UOM_Factor__c > 0){
                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getActualItemAmount | UOM Factor : ' + soItem.ASI_CRM_UOM_Factor__c);
                amount = d.ASI_HK_CRM_Quantity_in_Bottles__c / soItem.ASI_CRM_UOM_Factor__c;
            }else{
                System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getActualItemAmount | UOM Factor is NULL or Zero');
                iHeader.ASI_CRM_Ready_For_Interface__c = FALSE;
                iHeader.ASI_CRM_Invoice_Generation_Error__c += 'Item (' + d.ASI_HK_CRM_Product_SKU__c + ') not mapped. \n';
                iHeader.ASI_CRM_Has_Error__c = true; //[WL 3.0]
            }
        }
        
        System.debug('ASI_CRM_HK_EDISO_To_Invoice_Batch | getActualItemAmount | amount : ' + amount);
        return amount;
    }

    global void finish(Database.BatchableContext BC)
    {
        if (!String.isEmpty(this.log))
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(UserInfo.getUserId());
            email.setSaveAsActivity(false);
            email.setSenderDisplayName('Salesforce Support');
            email.setSubject('Error in Convert EDI SO To Invoice batch process!');
            email.setPlainTextBody(this.log);    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}