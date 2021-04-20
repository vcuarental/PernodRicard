public with sharing class ASI_CN_NPL_RequestSavePDFController {
    public ASI_CN_NPL_NPL_Request__c npl {get; set;}        
    public ASI_CN_NPL_ATL_Plan__c[] ATLs {get; set;}        
    public ASI_CN_NPL_BTL_Plan__c[] BTLs {get; set;}
    public ASI_CN_NPL_VIP_Plan__c[] VIPs {get; set;}
    
    public Boolean showProfitAndLoss {get; set;}
    public Boolean showProfitAndLossSave {get; set;}
            
    ASI_CN_NPL_ATL_Plan__c[] thisATLs;
    ASI_CN_NPL_BTL_Plan__c[] thisBTLs;
    ASI_CN_NPL_VIP_Plan__c[] thisVIPs;
    
    public string onTradeChannel1 {get; set;}
    public string onTradeChannel2 {get; set;}
    public string onTradeChannel3 {get; set;}
    
    public string offTradeChannel {get; set;}
    public string offTradeChannel1 {get; set;}
    public string offTradeChannel2 {get; set;}
    public string offTradeChannel3 {get; set;}
            
    public ASI_CN_NPL_RequestSavePDFController (ApexPages.StandardController stdController){
        System.debug('ASI_CN_NPL_RequestSavePDFController start');
        parentId = stdController.getId();   
        npl = [select OwnerId, ASI_CN_NPL_Profit_Loss__c, 
               //On Trade
               ASI_CN_NPL_Chinese_Bar_Priority__c, ASI_CN_NPL_FKTV_Priority__c, ASI_CN_NPL_Western_Bar_Priority__c, ASI_CN_NPL_CR_Priority__c,  ASI_CN_NPL_KTV_Priority__c, ASI_CN_NPL_IHBR_Priority__c, 
               //Off Trade
               ASI_CN_NPL_Hypermarket_Priority__c, ASI_CN_NPL_Wine_Shop_Priority__c, ASI_CN_NPL_Cash_Carry_Priority__c, ASI_CN_NPL_Tobacco_Store_Priority__c, ASI_CN_NPL_Supermarket_Priority__c, ASI_CN_NPL_Grocery_Priority__c, ASI_CN_NPL_Convenience_Store_Priority__c, ASI_CN_NPL_E_Commerce_Priority__c, ASI_CN_NPL_Department_Store_Priority__c, ASI_CN_NPL_Wholesaler_Store_Priority__c
               //20170814 Introv
               , ASI_NPL_Commercial_Team__c, ASI_NPL_Bar_Priority__c, ASI_NPL_Night_Club_Priority__c, ASI_NPL_Restaurant_Priority__c, ASI_NPL_Hotel_Priority__c, ASI_NPL_BulkPurchase_Priority__c, ASI_NPL_VIP_Priority__c, ASI_NPL_Convenience_Store_Chain_Priority__c
               , ASI_NPL_Liquor_Store_WS_Store_Priority__c
               from ASI_CN_NPL_NPL_Request__c where id = :parentId limit 1];
                    
        System.debug('Start query sObject');
        
        thisATLs = [Select 
            a.New_Product_Launch_Request__c, a.Name, a.LastModifiedDate, a.LastModifiedById,a.CurrencyIsoCode,a.ASI_CN_NPL_Title__c, 
            a.ASI_CN_NPL_TV_Start_Date__c, a.ASI_CN_NPL_TV_End_Date__c, a.ASI_CN_NPL_Sample_Requirement__c, a.ASI_CN_NPL_Outdoor_Start_Date__c, a.ASI_CN_NPL_Outdoor_End_Date__c, a.ASI_CN_NPL_Other_Format__c, a.ASI_CN_NPL_Number__c, 
            a.ASI_CN_NPL_Media_Format__c, a.ASI_CN_NPL_Markets__c, a.ASI_CN_NPL_Market_Location__c, a.ASI_CN_NPL_Insertion_Date__c, a.ASI_CN_NPL_DigitalMedia_Number__c, a.ASI_CN_NPL_DigitalMedia_Markets__c, a.ASI_CN_NPL_DigitalMedia_End_Date__c, a.ASI_CN_NPL_DigitalMedia_Start_Date__c 
            From ASI_CN_NPL_ATL_Plan__c a Where New_Product_Launch_Request__c = :parentId];
            
        thisBTLs = [Select a.SystemModstamp, a.New_Product_Launch_Request__c, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, 
            a.Id, a.CurrencyIsoCode, a.CreatedDate, a.CreatedById, 
            a.ASI_CN_NPL_Sample_Requirement__c, 
            a.ASI_CN_NPL_Responsible_By__c, a.ASI_CN_NPL_Remark__c, a.ASI_CN_NPL_Project_Name__c, a.ASI_CN_NPL_Mechanics__c, a.ASI_CN_NPL_City_Converage__c, a.ASI_CN_NPL_Channel__c, a.ASI_CN_NPL_Activity_Format__c 
            From ASI_CN_NPL_BTL_Plan__c a Where New_Product_Launch_Request__c = :parentId];
        
        thisVIPs = [Select a.SystemModstamp, a.New_Product_Launch_Request__c, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted,  
            a.Id, a.CurrencyIsoCode, a.CreatedDate, a.CreatedById, 
            a.ASI_CN_NPL_Sample_Requirement__c, a.ASI_CN_NPL_Description__c From ASI_CN_NPL_VIP_Plan__c a Where New_Product_Launch_Request__c = :parentId];
        
        //Grouping of Channel Priority
        //On trade
        onTradeChannel1 = '';
        onTradeChannel2 = '';
        onTradeChannel3 = '';
        offTradeChannel1 = '';
        offTradeChannel2 = '';
        offTradeChannel3 = '';
        
        //20170814 Introv
        if(npl.ASI_NPL_Bar_Priority__c == '1')
            onTradeChannel1 += 'Bar';
        else if (npl.ASI_NPL_Bar_Priority__c == '2')
            onTradeChannel2 += 'Bar;';
        else if (npl.ASI_NPL_Bar_Priority__c == '3')
            onTradeChannel3 += 'Bar;';
        
        if(npl.ASI_NPL_Night_Club_Priority__c == '1')
            onTradeChannel1 += 'Night Club;';
        else if (npl.ASI_NPL_Night_Club_Priority__c == '2')
            onTradeChannel2 += 'Night Club;';
        else if (npl.ASI_NPL_Night_Club_Priority__c == '3')
            onTradeChannel3 += 'Night Club;';
        
        if (npl.ASI_CN_NPL_Chinese_Bar_Priority__c == '1')
            onTradeChannel1 += 'Chinese Bar;';
        else if (npl.ASI_CN_NPL_Chinese_Bar_Priority__c == '2')
            onTradeChannel2 += 'Chinese Bar;';
        else if (npl.ASI_CN_NPL_Chinese_Bar_Priority__c == '3')
            onTradeChannel3 += 'Chinese Bar;';
        
        if (npl.ASI_CN_NPL_KTV_Priority__c == '1')
            onTradeChannel1 += 'KTV;';
        else if (npl.ASI_CN_NPL_KTV_Priority__c == '2')
            onTradeChannel2 += 'KTV;';
        else if (npl.ASI_CN_NPL_KTV_Priority__c == '3')
            onTradeChannel3 += 'KTV;';
        
        if (npl.ASI_CN_NPL_FKTV_Priority__c == '1')
            onTradeChannel1 +='FKTV;';
        else if (npl.ASI_CN_NPL_FKTV_Priority__c == '2')
            onTradeChannel2 +='FKTV;';
        else if (npl.ASI_CN_NPL_FKTV_Priority__c == '3')
            onTradeChannel3 +='FKTV;';
        
        if (npl.ASI_CN_NPL_Western_Bar_Priority__c == '1')
            onTradeChannel1 += 'Western Bar;';
        else if (npl.ASI_CN_NPL_Western_Bar_Priority__c == '2')
            onTradeChannel2 += 'Western Bar;';
        else if (npl.ASI_CN_NPL_Western_Bar_Priority__c == '3')
            onTradeChannel3 += 'Western Bar;';
            
        if (npl.ASI_CN_NPL_CR_Priority__c == '1')
            onTradeChannel1 += 'Chinese Restaurant;';
        else if (npl.ASI_CN_NPL_CR_Priority__c == '2')
            onTradeChannel2 += 'Chinese Restaurant;';
        else if (npl.ASI_CN_NPL_CR_Priority__c == '3')
            onTradeChannel3 += 'Chinese Restaurant;';
            
        if (npl.ASI_CN_NPL_IHBR_Priority__c == '1')
            onTradeChannel1 += 'IHBR;';
        else if (npl.ASI_CN_NPL_IHBR_Priority__c == '2')
            onTradeChannel2 += 'IHBR;';
        else if (npl.ASI_CN_NPL_IHBR_Priority__c == '3')
            onTradeChannel3 += 'IHBR;';
        
        if (npl.ASI_NPL_Restaurant_Priority__c == '1')
            onTradeChannel1 += 'Restaurant;';
        else if (npl.ASI_NPL_Restaurant_Priority__c == '2')
            onTradeChannel2 += 'Restaurant;';
        else if (npl.ASI_NPL_Restaurant_Priority__c == '3')
            onTradeChannel3 += 'Restaurant;';
        
        if (npl.ASI_NPL_Hotel_Priority__c == '1')
            onTradeChannel1 += 'Hotel;';
        else if (npl.ASI_NPL_Hotel_Priority__c == '2')
            onTradeChannel2 += 'Hotel;';
        else if (npl.ASI_NPL_Hotel_Priority__c == '3')
            onTradeChannel3 += 'Hotel;';
        
        //Off trade 
        
        //20170814 Introv
        
        if (npl.ASI_NPL_BulkPurchase_Priority__c == '1')
            offTradeChannel1 += 'BulkPurchase - BP;';
        else if (npl.ASI_NPL_BulkPurchase_Priority__c == '2')
            offTradeChannel2 += 'BulkPurchase - BP;';
        else if (npl.ASI_NPL_BulkPurchase_Priority__c == '3')
            offTradeChannel3 += 'BulkPurchase - BP;';
        
        if (npl.ASI_NPL_VIP_Priority__c == '1')
            offTradeChannel1 += 'VIP - BP;';
        else if (npl.ASI_NPL_VIP_Priority__c == '2')
            offTradeChannel2 += 'VIP - BP;';
        else if (npl.ASI_NPL_VIP_Priority__c == '3')
            offTradeChannel3 += 'VIP - BP;';
        
        if (npl.ASI_CN_NPL_Hypermarket_Priority__c == '1')
            offTradeChannel1 += 'Hypermarket - MOT;';
        else if (npl.ASI_CN_NPL_Hypermarket_Priority__c == '2')
            offTradeChannel2 += 'Hypermarket - MOT;';
        else if (npl.ASI_CN_NPL_Hypermarket_Priority__c == '3')
            offTradeChannel3 += 'Hypermarket - MOT;';
        
        if (npl.ASI_CN_NPL_Cash_Carry_Priority__c == '1')
            offTradeChannel1 += 'Cash and Carry - MOT;';
        else if (npl.ASI_CN_NPL_Cash_Carry_Priority__c == '2')
            offTradeChannel2 += 'Cash and Carry - MOT;';
        else if (npl.ASI_CN_NPL_Cash_Carry_Priority__c == '3')
            offTradeChannel3 += 'Cash and Carry - MOT;';
            
        if (npl.ASI_CN_NPL_Supermarket_Priority__c == '1')
            offTradeChannel1 += 'Supermarket - MOT;';
        else if (npl.ASI_CN_NPL_Supermarket_Priority__c == '2')
            offTradeChannel2 += 'Supermarket - MOT;';
        else if (npl.ASI_CN_NPL_Supermarket_Priority__c == '3')
            offTradeChannel3 += 'Supermarket - MOT;';
            
        if (npl.ASI_NPL_Convenience_Store_Chain_Priority__c =='1')
            offTradeChannel1 += 'Convenience Store Chain - MOT;';
        else if (npl.ASI_NPL_Convenience_Store_Chain_Priority__c =='2')
            offTradeChannel2 += 'Convenience Store Chain - MOT;';
        else if (npl.ASI_NPL_Convenience_Store_Chain_Priority__c =='3')
            offTradeChannel3 += 'Convenience Store Chain - MOT;';
            
        if (npl.ASI_CN_NPL_Department_Store_Priority__c == '1')
            offTradeChannel1 += 'Department Store - TOT;';
        else if (npl.ASI_CN_NPL_Department_Store_Priority__c == '2')
            offTradeChannel2 += 'Department Store - TOT;';
        else if (npl.ASI_CN_NPL_Department_Store_Priority__c == '3')
            offTradeChannel3 += 'Department Store - TOT;';
            
        if (npl.ASI_NPL_Liquor_Store_WS_Store_Priority__c == '1')
            offTradeChannel1 += 'Liquor Store (WS Store) - TOT;';
        else if (npl.ASI_NPL_Liquor_Store_WS_Store_Priority__c == '2')
            offTradeChannel2 += 'Liquor Store (WS Store) - TOT;';
        else if (npl.ASI_NPL_Liquor_Store_WS_Store_Priority__c == '3')
            offTradeChannel3 += 'Liquor Store (WS Store) - TOT;';
        
        if (npl.ASI_CN_NPL_Wine_Shop_Priority__c == '1')
            offTradeChannel1 += 'Wine Shop - TOT;';
        else if (npl.ASI_CN_NPL_Wine_Shop_Priority__c == '2')
            offTradeChannel2 += 'Wine Shop - TOT;';
        else if (npl.ASI_CN_NPL_Wine_Shop_Priority__c == '3')
            offTradeChannel3 += 'Wine Shop - TOT;';           
            
        if (npl.ASI_CN_NPL_Tobacco_Store_Priority__c == '1')
            offTradeChannel1 += 'Tobacco Store;';
        else if (npl.ASI_CN_NPL_Tobacco_Store_Priority__c == '2')
            offTradeChannel2 += 'Tobacco Store;';
        else if (npl.ASI_CN_NPL_Tobacco_Store_Priority__c == '3')
            offTradeChannel3 += 'Tobacco Store;';
            
        if (npl.ASI_CN_NPL_Grocery_Priority__c == '1')
            offTradeChannel1 += 'Geocery - TOT;';
        else if (npl.ASI_CN_NPL_Grocery_Priority__c == '2')
            offTradeChannel2 += 'Geocery - TOT;';
        else if (npl.ASI_CN_NPL_Grocery_Priority__c == '3')
            offTradeChannel3 += 'Geocery - TOT;';
            
        if (npl.ASI_CN_NPL_Convenience_Store_Priority__c =='1')
            offTradeChannel1 += 'Convenience Store;';
        else if (npl.ASI_CN_NPL_Convenience_Store_Priority__c =='2')
            offTradeChannel2 += 'Convenience Store;';
        else if (npl.ASI_CN_NPL_Convenience_Store_Priority__c =='3')
            offTradeChannel3 += 'Convenience Store;';
            
        if (npl.ASI_CN_NPL_E_Commerce_Priority__c == '1')
            offTradeChannel1 += 'E-Commerce - EC;';
        else if (npl.ASI_CN_NPL_E_Commerce_Priority__c == '2')
            offTradeChannel2 += 'E-Commerce - EC;';
        else if (npl.ASI_CN_NPL_E_Commerce_Priority__c == '3')
            offTradeChannel3 += 'E-Commerce - EC;';
            
        if (npl.ASI_CN_NPL_Wholesaler_Store_Priority__c == '1')
            offTradeChannel1 += 'Wholesaler Store;';
        else if (npl.ASI_CN_NPL_Wholesaler_Store_Priority__c == '2')
            offTradeChannel2 += 'Wholesaler Store;';
        else if (npl.ASI_CN_NPL_Wholesaler_Store_Priority__c == '3')
            offTradeChannel3 += 'Wholesaler Store;';
            
        System.debug('Start assign sObject');
        
        if (thisATLs.size() > 0)
                ATLs = thisATLs;
                
        if (thisBTLs.size() > 0)
                BTLs = thisBTLs;
                
        if (thisVIPs.size() > 0)
                VIPs = thisVIPs;
        
        //Added by Wilken on 20140321, check if P&L section should be displayed
        Map<id, PermissionSet> nplPermissionSet = new Map<id, PermissionSet>([select id, Name from PermissionSet where name like 'ASI_CN_NPL%']);
        List<PermissionSetAssignment> nplPermissionAssign = [select PermissionSetId from PermissionSetAssignment where AssigneeId = :UserInfo.getUserId() and PermissionSetId in :nplPermissionSet.values()];
        
        string userPermissionName;
        
        if (nplPermissionAssign.size() > 0)
            userPermissionName = nplPermissionSet.get(nplPermissionAssign.get(0).PermissionSetId).Name;
        else
            userPermissionName = '';
        
        if (UserInfo.getUserId() == npl.OwnerId){
            showProfitAndLoss = true;
            showProfitAndLossSave = false;
        }
        else {
            if (userPermissionName == 'ASI_CN_NPL_BA_User'){
                showProfitAndLoss = true;
                showProfitAndLossSave = true;
            }
            else if (userPermissionName == 'ASI_CN_NPL_Approvers' || userPermissionName == 'ASI_CN_NPL_Logistics_User'){
                    showProfitAndLoss = true;
                    showProfitAndLossSave = false;
            }
            else {
                showProfitAndLoss = false;
                showProfitAndLossSave = false;
            }
        }
        System.debug('ASI_CN_NPL_RequestSavePDFController end');
    }
    
    public PageReference savePnL (){
        update npl;
        return null;
    }
    
    public PageReference popUp() {
        return new pageReference('/apex/ASI_CN_NPL_PnLPage?id=' + npl.id);
    }
    
    public ID parentId {get;set;}
    public String pdfName {get;set;}

}