/*Filename:        ASI_CRM_TW_DeliverySummaryPDF_Ctrl.cls
* Author:          Twinkle LI (Introv Limited)
* Purpose:         Controller Class for FOC Delivery Summary PDF
* Created Date:    2017/02/15
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_DeliverySummaryPDF_Ctrl{
    public String userLanguage {set; get;}
    public Boolean noData {set; get;}
    
    public String selectedType {set; get;}
    public Date orderDate {set; get;}
    // public String refNoFrom {set; get;}
    // public String refNoTo {set; get;}
    public String orderName {set; get;}
    
    public Map<String, Map<Id, Decimal>> mapSummuryQty {set; get;} //map by Delivery To + Address & SKU
    public Map<Id, ASI_MFM_SKU_Code__c> mapSKU {set; get;}
    public Map<String, RowCls> mapAccountAddress {set; get;}
    public Map<Id, Decimal> mapSKUTotalQty {set; get;}
    
    public Map<String, Map<String, Map<String, Map<Id, LineCls>>>> mapLineByRow {set; get;} //map by Delivery To + Address + Receiver & Header & Ref. No. & SKU
    public Map<Id, ASI_FOC_Free_Goods_Request__c> mapHeader {set; get;}
    public Map<Id, ASI_FOC_Request_Item__c> mapLine {set; get;}
    
    public Map<String, Integer> mapSize1 {set; get;}
    public Map<String, Integer> mapSize2 {set; get;}
    public Map<String, Integer> mapSize3 {set; get;}
    
    public List<SelectOption> getTypeOptions() {
        List<SelectOption> typeOptions = new List<SelectOption>();
        typeOptions.add(new SelectOption('FOC','FOC'));
        typeOptions.add(new SelectOption('POSM','POSM'));
 
        return typeOptions;
    }
    
    public class RowCls{
        public String DeliveryTo {set; get;}
        public String DeliveryLegalName {set;get;}  // [SH] 2019-03-26
        public String Receiver {set; get;}
        public String DeliveryTel {set; get;}
        public String DeliveryAddress {set; get;}
        public Decimal TotalQty {set; get;}
    }
    
    public class LineCls{
        public String SKU_Code {set; get;}
        public String SKU_Description {set; get;}
        public String Remark {set; get;}
        public Decimal Qty {set; get;}
        public String JDE_OrderType {get;set;}
        public String JDE_OrderNo {get;set;}
    }
    
    public ASI_CRM_TW_DeliverySummaryPDF_Ctrl(ApexPages.StandardController controller){
        search();
    }
    
    public void search(){
        userLanguage = UserInfo.getLanguage();
        noData = true;
        
        mapSummuryQty = new Map<String, Map<Id, Decimal>>();
        mapSKU = new Map<Id, ASI_MFM_SKU_Code__c>();
        mapAccountAddress = new Map<String, RowCls>();
        mapSKUTotalQty = new Map<Id, Decimal>();
        
        mapLineByRow = new Map<String, Map<String, Map<String, Map<Id, LineCls>>>>();
        mapHeader = new Map<Id, ASI_FOC_Free_Goods_Request__c>();
        
        mapSize1 = new Map<String, Integer>();
        mapSize2 = new Map<String, Integer>();
        mapSize3 = new Map<String, Integer>();
        
        if(ApexPages.currentPage().getParameters().get('type') != null)
            selectedType = String.valueOf(ApexPages.currentPage().getParameters().get('type'));
        if(ApexPages.currentPage().getParameters().get('date') != null)
            orderDate = Date.valueOf(ApexPages.currentPage().getParameters().get('date'));  
        // if(ApexPages.currentPage().getParameters().get('rnF') != null)
        //     refNoFrom = ApexPages.currentPage().getParameters().get('rnF');  
        // if(ApexPages.currentPage().getParameters().get('rnT') != null)
        //     refNoTo = ApexPages.currentPage().getParameters().get('rnT'); 
        if(ApexPages.currentPage().getParameters().get('orderName') != null)
            orderName = ApexPages.currentPage().getParameters().get('orderName');     
        
        Set<String> orderList = new Set<String>();
        if(orderName != null)orderList.addAll(orderName.split(','));
        
        Id lineRecordTypeId;
        if(selectedType == 'FOC')
            lineRecordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_FOC_Request_Item');
        else   
            lineRecordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_POSM_Request_Item');
        
        if(orderDate != null){
            List<ASI_CRM_Order_Status__c> listOrderStatus = new List<ASI_CRM_Order_Status__c>();
            
            Set<Id> setSKUId = new Set<Id>();
            Set<Id> setHeaderId = new Set<Id>();
            
            String soqlQuery = 'SELECT Id, ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_Request_Order__c, ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_To__c,'+
                                'ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_To__r.Name, ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Receiver__c,'+
                                'ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_To__r.ASI_KOR_Legal_Name__c,'+ 
                                'ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_Tel__c, ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_Address__c,'+ 
                                'ASI_CRM_FOC_POSM_Line_No__c, ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_SKU__c, ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_SKU_Description__c,'+ 
                                'ASI_CRM_Reference_No__c, ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_Remark__c, ASI_CRM_Shipped_Qty__c, ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_SKU_Code__c, ASI_CRM_Order_Date__c, '+ 
                                'ASI_CRM_JDE_Order_Type__c, ASI_CRM_JDE_Order_No__c ' +
                                'FROM ASI_CRM_Order_Status__c '+
                                'WHERE ASI_CRM_Shipped_Qty__c != 0 AND ASI_CRM_Shipped_Qty__c != null AND ASI_CRM_Reference_No__c != null '+
                                //' and ASI_CRM_JDE_Status__c = ' + '\'' + 'Complete' + '\'' + 
                                'and ASI_CRM_FOC_POSM_Line_No__r.RecordTypeId =\''+lineRecordTypeId+'\' '+
                                'AND ASI_CRM_Order_Date__c='+string.valueof(orderDate).substring(0,10);
                                
                                // if(!String.isBlank(refNoFrom))
                                //     soqlQuery+=' and ASI_CRM_Reference_No__c>=\''+refNoFrom+'\' ';                                                              
                                // if(!String.isBlank(refNoTo))
                                //     soqlQuery+=' and ASI_CRM_Reference_No__c<=\''+refNoTo+'\' ';
                                    
                                // if(!String.isBlank(orderName))
                                    // soqlQuery+=' and ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_Request_Order__r.name=\''+orderName+'\' ';   

                                if(orderList.size()>0)
                                {
                                    soqlQuery+=' and ASI_CRM_Reference_No__c in: orderList' ;
                                } 
                                                            
                                soqlQuery+=' ORDER BY ASI_CRM_Reference_No__c';
                                
            System.debug(soqlQuery);
            
            List<ASI_CRM_Order_Status__c> resultList = database.query(soqlQuery);
            
            for(ASI_CRM_Order_Status__c os : resultList){                                     
            
                listOrderStatus.add(os);
                                  
                setSKUId.add(os.ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_SKU__c);
                setHeaderId.add(os.ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_Request_Order__c);
            }
            
            mapSKU = new Map<Id, ASI_MFM_SKU_Code__c>([SELECT Id, ASI_MFM_SKU_Code__c, ASI_MFM_SKU_Description__c FROM ASI_MFM_SKU_Code__c WHERE Id IN: setSKUId]);
            mapHeader = new Map<Id, ASI_FOC_Free_Goods_Request__c>([SELECT id, Name, ASI_CRM_Reference_No__c, ASI_CRM_Purpose__c, ASI_FOC_JDE_Order_Type_Code__c, ASI_FOC_JDE_Order_Number__c FROM ASI_FOC_Free_Goods_Request__c WHERE Id IN: setHeaderId]);

            for(Id mapid : mapHeader.keyset())
            {
                ASI_FOC_Free_Goods_Request__c tempFGR = mapHeader.get(mapid);
                tempFGR.ASI_CRM_Purpose__c = spacingForChineseCharacters(tempFGR.ASI_CRM_Purpose__c, 12);
                mapHeader.put(mapid, tempFGR);
            }
            
            
            for(ASI_CRM_Order_Status__c os : listOrderStatus){
                Map<Id, Map<Id, Decimal>> tempByDeliveryTo = new Map<Id, Map<Id, Decimal>>();
                Map<Id, Decimal> tempMapSKUbyShippedQty = new Map<Id, Decimal>();
                
                String strHeaderKey = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_To__c+os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_Address__c+os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Receiver__c;
                String strSKUKey = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_SKU__c;
                
                if(mapAccountAddress == null || mapAccountAddress.get(strHeaderKey) == null){
                    RowCls tempRow = new RowCls();
                    tempRow.DeliveryTo = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_To__r.Name;
                    tempRow.DeliveryLegalName = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_To__r.ASI_KOR_Legal_Name__c;        // [SH] 2019-03-26
                    tempRow.Receiver = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Receiver__c;
                    tempRow.DeliveryTel = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_Tel__c;
                    tempRow.DeliveryAddress = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_Address__c;
                    
                    mapAccountAddress.put(strHeaderKey, tempRow);
                }
                
                if(mapSummuryQty != null && mapSummuryQty.get(strHeaderKey) != null){
                    tempMapSKUbyShippedQty = mapSummuryQty.get(strHeaderKey);
                    
                    if(mapSummuryQty.get(strHeaderKey).get(strSKUKey) != null){
                        Decimal tempQty = mapSummuryQty.get(strHeaderKey).get(strSKUKey);
                        tempQty += os.ASI_CRM_Shipped_Qty__c;
                        
                        tempMapSKUbyShippedQty.put(strSKUKey, tempQty);
                    }
                    else{
                        tempMapSKUbyShippedQty.put(strSKUKey, os.ASI_CRM_Shipped_Qty__c);                   
                    }
                }
                else{
                    tempMapSKUbyShippedQty.put(strSKUKey, os.ASI_CRM_Shipped_Qty__c);
                }
                
                mapSummuryQty.put(strHeaderKey, tempMapSKUbyShippedQty);
            }
            system.debug('Summary map 1: '+mapSummuryQty);
            
            //put null to those row with no such SKU
            if(mapSummuryQty != null){
                for(String key1 : mapSummuryQty.KeySet()){
                    Map<Id, Decimal> tempMap = mapSummuryQty.get(key1);
                    
                    for(Id skuId : mapSKU.KeySet()){
                        if(!mapSummuryQty.get(key1).KeySet().contains(skuId)){
                            tempMap.put(skuId, 0);
                        }
                    }
                    mapSummuryQty.put(key1, tempMap);
                    
                    Decimal totalQty = 0;
                    for(Id key2 : mapSummuryQty.get(key1).KeySet()){
                        //calculate total qty by row
                        Decimal tempQty = mapSummuryQty.get(key1).get(key2);
                        totalQty += tempQty;
                        
                        //calculate total qty by SKU
                        if(mapSKUTotalQty != null && mapSKUTotalQty.get(key2) != null){
                            Decimal tempQtySKU = mapSKUTotalQty.get(key2)+mapSummuryQty.get(key1).get(key2);
                            mapSKUTotalQty.put(key2, tempQtySKU);
                        }
                        else{
                            mapSKUTotalQty.put(key2, mapSummuryQty.get(key1).get(key2));
                        }
                    }
                    
                    if(mapAccountAddress != null && mapAccountAddress.get(key1) != null){
                        RowCls tempRowCls = mapAccountAddress.get(key1);
                        tempRowCls.TotalQty = totalQty;
                        mapAccountAddress.put(key1, tempRowCls);
                    }
                }
            }
            
            if(mapSummuryQty != null && mapSummuryQty.size() > 0)
                noData = false;
            
            system.debug('No Data: '+noData);
            system.debug('Account/Address map: '+mapAccountAddress);
            system.debug('SKU map: '+mapSKU);
            system.debug('Total Qty by SKU: '+mapSKUTotalQty);
            system.debug('Summary map 2: '+mapSummuryQty);
            
            //Page break down by Row
            for(ASI_CRM_Order_Status__c os : listOrderStatus){
                Map<String, Map<String, Map<Id, LineCls>>> tempByHeader = new Map<String, Map<String, Map<Id, LineCls>>>();
                Map<String, Map<Id, LineCls>> tempByRefNo = new Map<String, Map<Id, LineCls>>();
                Map<Id, LineCls> tempByLine = new Map<Id, LineCls>();
                
                String strHeaderKey = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_To__c+os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Delivery_Address__c+os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_Receiver__c;
                String strFOCKey = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_Request_Order__c;
                String strRefNoKey = os.ASI_CRM_Reference_No__c;
                String strSKUKey = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_SKU__c;
                
                LineCls tempLine = new LineCls();
                tempLine.SKU_Code = os.ASI_CRM_FOC_POSM_Line_No__r.ASI_CRM_SKU_Code__c;
                tempLine.SKU_Description = spacingForChineseCharacters(os.ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_SKU_Description__c, 12);
                tempLine.Remark = spacingForChineseCharacters(os.ASI_CRM_FOC_POSM_Line_No__r.ASI_FOC_Remark__c, 12);
                tempLine.Qty = os.ASI_CRM_Shipped_Qty__c;
                tempLine.JDE_OrderType = os.ASI_CRM_JDE_Order_Type__c;
                tempLine.JDE_OrderNo = os.ASI_CRM_JDE_Order_No__c;
                    
                if(mapLineByRow != null && mapLineByRow.get(strHeaderKey) != null){
                    tempByHeader = mapLineByRow.get(strHeaderKey);
                    
                    if(mapLineByRow.get(strHeaderKey).get(strFOCKey) != null){
                        tempByRefNo = mapLineByRow.get(strHeaderKey).get(strFOCKey);
                        
                        if(mapLineByRow.get(strHeaderKey).get(strFOCKey).get(strRefNoKey) != null){
                            tempByLine = mapLineByRow.get(strHeaderKey).get(strFOCKey).get(strRefNoKey);
                        
                            if(mapLineByRow.get(strHeaderKey).get(strFOCKey).get(strRefNoKey).get(strSKUKey) != null){
                                LineCls tempLineCls = mapLineByRow.get(strHeaderKey).get(strFOCKey).get(strRefNoKey).get(strSKUKey);
                                tempLine.Qty += tempLineCls.Qty;      
                            }
                        }
                    } 
                }
                
                tempByLine.put(strSKUKey, tempLine);
                tempByRefNo.put(strRefNoKey, tempByLine);
                tempByHeader.put(strFOCKey, tempByRefNo);
                
                mapLineByRow.put(strHeaderKey, tempByHeader);
                system.debug(mapLineByRow);
            }
            
            //get maps size
            if(mapLineByRow != null){
                for(String key1 : mapLineByRow.KeySet()){
                    Integer sizeIndex = 0;
                    
                    for(String key2 : mapLineByRow.get(key1).KeySet()){
                        Map<String, Map<Id, LineCls>> tempMap1 = mapLineByRow.get(key1).get(key2);
                        Integer sizeIndex1 = 0;
                        
                        for(String key3 : mapLineByRow.get(key1).get(key2).KeySet()){
                            Map<Id, LineCls> tempMap2 = mapLineByRow.get(key1).get(key2).get(key3);
                            mapSize3.put(key1+key2+key3, tempMap2.size());
                            
                            for(Id key4 : mapLineByRow.get(key1).get(key2).get(key3).KeySet()){
                                sizeIndex++;
                                sizeIndex1++;
                            }
                            sizeIndex++;
                            // sizeIndex1++;
                        }
                        sizeIndex++;
                        sizeIndex1++;
                        mapSize2.put(key1+key2, sizeIndex1);
                    }
                    mapSize1.put(key1, sizeIndex);
                }
            }
            
            system.debug('Line map : '+mapLineByRow);
            system.debug('Map Size 1: '+mapSize1);
            system.debug('Map Size 2: '+mapSize2);
            system.debug('Map Size 3: '+mapSize3);
        }
    }

    public static String spacingForChineseCharacters(String InputString, Integer characterLimit){
        if(String.isBlank(InputString)) return '';
        if(containsChineseCharacters(InputString)){
            List<String> splitInput = new List<String>();
            splitInput = InputString.split(' ');
            String returnString = '';
            for(String str: splitInput)
            {
                if(containsChineseCharacters(str)){
                    String tmpStr = str;
                    do{
                        if(tmpStr.length()<=characterLimit){
                            returnString += tmpStr;
                            tmpStr = '';
                        }else{
                            returnString += tmpStr.substring(0, characterLimit) + ' ';
                            tmpStr = tmpStr.substring(characterLimit);
                        }
                    }while(tmpStr.length() != 0);
                }
                else{
                    returnString += str + ' ';
                }
            }
            return returnString;
        }
        else{
            return InputString;
        }
    }
    public static Boolean containsChineseCharacters(String InputString){
        Pattern p = Pattern.compile('\\p{IsHan}');
        Matcher m = p.matcher( InputString );
        return m.find();
    }
}