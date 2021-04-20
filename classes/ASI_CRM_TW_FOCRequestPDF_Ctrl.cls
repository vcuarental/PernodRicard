/*Filename:    ASI_CRM_TW_FOCApplicationPDF_Ctrl.cls
* Modified By: Twinkle LI (Introv Limited)
* Date:        Nov 11 2016
* Purpose:     Controller Class for FOC Request PDF - TW CRM
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_FOCRequestPDF_Ctrl{
    public id FOCRequestId {set; get;}
    public ASI_FOC_Free_Goods_Request__c objFOCRequest {set; get;}
    public List<ASI_FOC_Request_Item__c> listFOCRequestLine {set; get;}
    public List<requestLineClass> rqlClassList {get;set;}
    public Map<Id, SKUSummaryWrapper> mapSKUSummary {set; get;}
    public Decimal decTotal {set; get;}
    
    public String userLanguage {set; get;}
    public Boolean noData {set; get;}
    
    public class SKUSummaryWrapper{
        public String strSKUCode {set; get;}
        public String strSKUName {set; get;}
        public Decimal decQty {set; get;}
    }
    
    public ASI_CRM_TW_FOCRequestPDF_Ctrl(ApexPages.StandardController controller) {
        FOCRequestId = ApexPages.currentPage().getParameters().get('id');
        init();
    }
    
    public void init(){
        Map<Id, ASI_MFM_SKU_Code__c> mapSKU = new Map<Id, ASI_MFM_SKU_Code__c>();
        Set<Id> setSKUId = new Set<Id>();

        rqlClassList = new List<requestLineClass>();
        
        mapSKUSummary = new Map<Id, SKUSummaryWrapper>();
        noData = TRUE;
        decTotal = 0;
        
        userLanguage = UserInfo.getLanguage();
        
        objFOCRequest = [SELECT Id, Name, ASI_CRM_SG_Order_Date__c, ASI_CRM_Requester__r.Name, ASI_CRM_Target_Outlet__r.Name, 
                         ASI_CRM_Target_Outlet__r.ASI_HK_CRM_JDE_Account_Number__c, ASI_CRM_Requester_Contact_No__c, 
                         ASI_FOC_Date_of_Delivery__c, ASI_CRM_Purpose__c, ASI_FOC_Delivery_Remarks__c, ASI_CRM_Plan__r.Name, 
                         ASI_CRM_Plan__r.ASI_MFM_Plan_Description__c, ASI_CRM_Delivery_To__r.Name, 
                         ASI_CRM_Delivery_To__r.ASI_HK_CRM_JDE_Account_Number__c, ASI_CRM_SG_Delivery_Address__c, 
                         ASI_CRM_Delivery_Tel__c, ASI_CRM_Receiver__c, ASI_CRM_Reference_No__c, ASI_CRM_Payment_No__c, ASI_CRM_Payment_No__r.Name,
                         ASI_FOC_Not_for_Sales__c, ASI_FOC_Customer_Receipt__c, ASI_CRM_SG_Delivery_Instructions__c,ASI_CRM_Request_Delivery_Date__c
                         FROM ASI_FOC_Free_Goods_Request__c WHERE id =: FOCRequestId LIMIT 1];        
        
        listFOCRequestLine = [SELECT Id, ASI_FOC_SKU__c, ASI_CRM_SKU_Code__c, ASI_FOC_SKU_Description__c, 
                              ASI_FOC_Request_Quantity_Bottle__c, ASI_CRM_Plan_Line_Item__r.ASI_MFM_Sub_Brand_Code_Only__c, 
                              ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.Name, ASI_FOC_G_H_Request__r.name, 
                              ASI_CRM_Plan_Line_Item__r.ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c, 
                              ASI_CRM_Plan_Line_Item__r.ASI_MFM_List_Item_Description__c, ASI_CRM_Target_Outlet__r.Name, 
                              ASI_CRM_Delivery_To__r.Name, ASI_CRM_Reimbursement__c, ASI_CRM_Delivery_Address__c, 
                              ASI_CRM_Delivery_Tel__c, ASI_CRM_Receiver__c, ASI_FOC_Remark__c, ASI_CRM_Delivery_Instruction__c
                              FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c =: FOCRequestId];   
        
        //get SKU Name for SKU Summary table
        for(ASI_FOC_Request_Item__c itm : listFOCRequestLine){
            setSKUId.add(itm.ASI_FOC_SKU__c);
        }   
        for(ASI_MFM_SKU_Code__c sku : [SELECT ASI_MFM_SKU_Code__c, ASI_MFM_SKU_Description__c FROM ASI_MFM_SKU_Code__c WHERE Id IN:setSKUId]){
            mapSKU.put(sku.Id, sku);
        }
                              
        if(listFOCRequestLine != NULL){
            noData = FALSE;
            for(ASI_FOC_Request_Item__c itm : listFOCRequestLine){
                requestLineClass rqlClass = new requestLineClass();
                rqlClass.requestItem = itm;
                rqlClass.skuDescription = spacingForChineseCharacters(itm.ASI_FOC_SKU_Description__c, 8);
                rqlClassList.add(rqlClass);
                if(itm.ASI_FOC_SKU__c != NULL){
                    //String strTempSKUName = mapSKU.get(itm.ASI_FOC_SKU__c).ASI_MFM_SKU_Code__c+' '+mapSKU.get(itm.ASI_FOC_SKU__c).ASI_MFM_SKU_Description__c;
                    SKUSummaryWrapper skuSummary = new SKUSummaryWrapper();
                    skuSummary.strSKUCode = mapSKU.get(itm.ASI_FOC_SKU__c).ASI_MFM_SKU_Code__c;
                    skuSummary.strSKUName = mapSKU.get(itm.ASI_FOC_SKU__c).ASI_MFM_SKU_Description__c;
                    
                    if(itm.ASI_FOC_Request_Quantity_Bottle__c != NULL){
                        if(mapSKUSummary != NULL && mapSKUSummary.get(itm.ASI_FOC_SKU__c) != NULL){
                            skuSummary.decQty = mapSKUSummary.get(itm.ASI_FOC_SKU__c).decQty+itm.ASI_FOC_Request_Quantity_Bottle__c;
                            mapSKUSummary.put(itm.ASI_FOC_SKU__c, skuSummary);
                        }
                        else{
                            skuSummary.decQty = itm.ASI_FOC_Request_Quantity_Bottle__c;
                            mapSKUSummary.put(itm.ASI_FOC_SKU__c, skuSummary);
                        }
                    }
                }
                
                if(itm.ASI_FOC_Request_Quantity_Bottle__c != null)
                    decTotal += itm.ASI_FOC_Request_Quantity_Bottle__c;
            }
            system.debug('SKU Summary: '+mapSKUSummary);
        }
        
        //define downloaded pdf file name
        String fileName = objFOCRequest.Name+'.pdf' ;
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
    }

    public class requestLineClass{
        public String skuDescription {get;set;}
        public ASI_FOC_Request_Item__c requestItem {get;set;}
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