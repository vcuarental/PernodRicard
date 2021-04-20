/*********************************************************************************
* Name: ASI_CRM_HK_SOClonebtnController
* Description:  clone SO for HK Sales Order
* Test class : ASI_HK_CRM_exchOrder_Test
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 16/11/2020       PRA COE                 [COE 1.0] add 'Reason for Payment Method Change' field
*/
public without sharing class ASI_CRM_HK_SOClonebtnController {
    public Id soId {get;set;}
    
    public ASI_CRM_HK_SOClonebtnController (ApexPages.StandardController stdCon) {
        ASI_HK_CRM_Sales_Order__c so = new ASI_HK_CRM_Sales_Order__c();        
    }
    
    public PageReference cloneSO(){
        soId = apexpages.currentPage().getParameters().get('id');        
        ASI_HK_CRM_Sales_Order__c newSO = new ASI_HK_CRM_Sales_Order__c();
        List<ASI_HK_CRM_Sales_Order_Item__c> soNewDetailList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        ASI_HK_CRM_Sales_Order_Item__c soDetailTemp;
        ASI_HK_CRM_Sales_Order__c oldSO = [SELECT ASI_HK_CRM_SO_External_ID__c , ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_Payment_Term_Code__c,ASI_HK_CRM_Account_PA__c , ASI_HK_CRM_Customer_DA__c , ASI_HK_CRM_JDE_Order_No__c , ASI_HK_CRM_JDE_Order_Type_Code__c , ASI_HK_CRM_JDE_Order_Type_name__c , ASI_HK_CRM_Cust_PO__c , ASI_HK_CRM_Reason_For_Change__c , ASI_HK_CRM_Alternate_Delivery_Address_1__c , ASI_HK_CRM_Alternate_Delivery_Address_2__c , ASI_HK_CRM_Alternate_Delivery_Address_3__c , ASI_HK_CRM_Alternate_Delivery_Address_4__c , ASI_HK_CRM_Has_Cancelled_Line_Item__c , OwnerId , ASI_HK_CRM_Order_Date__c , ASI_HK_CRM_Delivery_Date__c , ASI_HK_CRM_Order_Type__c , CurrencyIsoCode , ASI_HK_CRM_Urgent_Order__c , ASI_HK_CRM_Urgent_Order_Confirmed__c , ASI_HK_CRM_Phone_Number__c , ASI_HK_CRM_Fax__c , ASI_HK_CRM_Delivery_Window_Instruction__c , ASI_HK_CRM_Delivery_Time_1__c , ASI_HK_CRM_Delivery_Time_2__c , ASI_HK_CRM_Payment_Method__c , ASI_HK_CRM_Instruction_txt__c , ASI_HK_CRM_Attention__c , ASI_HK_CRM_Delivery_Remarks__c , ASI_HK_CRM_User_D_O__c , ASI_HK_CRM_Order_Status_Name__c , ASI_HK_CRM_Credit_Limit__c , ASI_HK_CRM_Payment_Term_Code__c , ASI_HK_CRM_Payment_Term_Description__c , ASI_HK_CRM_Current_Amount__c , ASI_HK_CRM_X1_30__c,ASI_HK_CRM_Reason_PaymentMethodChange__c , ASI_HK_CRM_X31_60__c , ASI_HK_CRM_X61_90__c , ASI_HK_CRM_Over_91__c , ASI_HK_CRM_No_comments_from_SSC__c , ASI_HK_CRM_Money_Report_Remarks__c , ASI_HK_CRM_Total_Exposure__c , ASI_HK_CRM_Overdue_30_days__c , ASI_HK_CRM_AR_Info_Last_Updated_By__c , ASI_HK_CRM_Payment_Amt_1__c , ASI_HK_CRM_Payment_Amt_2__c , ASI_HK_CRM_Payment_Amt_3__c , ASI_HK_CRM_Payment_Amt_4__c , ASI_HK_CRM_Payment_Amt_5__c , ASI_HK_CRM_Payment_Date_1__c , ASI_HK_CRM_Payment_Date_2__c , ASI_HK_CRM_Payment_Date_3__c , ASI_HK_CRM_Payment_Date_4__c , ASI_HK_CRM_Payment_Date_5__c , ASI_HK_CRM_Cheque_Amt_1__c , ASI_HK_CRM_Cheque_Amt_2__c , ASI_HK_CRM_Cheque_Amt_3__c , ASI_HK_CRM_Cheque_Amt_4__c , ASI_HK_CRM_Cheque_Amt_5__c , ASI_HK_CRM_Cheque_Date_1__c , ASI_HK_CRM_Cheque_Date_2__c , ASI_HK_CRM_Cheque_Date_3__c , ASI_HK_CRM_Cheque_Date_4__c , ASI_HK_CRM_Cheque_Date_5__c , ASI_HK_CRM_Salesman_Comments_PreSubmit__c , ASI_HK_CRM_Comments_SSC__c , ASI_HK_CRM_Comments_Salesman__c , ASI_HK_CRM_Comment_SSM_HS__c , recordTypeID FROM ASI_HK_CRM_Sales_Order__c 
                                           WHERE id =: soId];
        
        //Assign values from old SO header to new SO header
        newSO.ASI_HK_CRM_Account_PA__c = oldSO.ASI_HK_CRM_Account_PA__c;
        newSO.ASI_HK_CRM_Customer_DA__c = oldSO.ASI_HK_CRM_Customer_DA__c;
        newSO.ASI_HK_CRM_Cust_PO__c = oldSO.ASI_HK_CRM_Cust_PO__c;
        newSO.ASI_HK_CRM_Reason_For_Change__c = oldSO.ASI_HK_CRM_Reason_For_Change__c;
        newSO.ASI_HK_CRM_Alternate_Delivery_Address_1__c = oldSO.ASI_HK_CRM_Alternate_Delivery_Address_1__c;
        newSO.ASI_HK_CRM_Alternate_Delivery_Address_2__c = oldSO.ASI_HK_CRM_Alternate_Delivery_Address_2__c;
        newSO.ASI_HK_CRM_Alternate_Delivery_Address_3__c = oldSO.ASI_HK_CRM_Alternate_Delivery_Address_3__c;
        newSO.ASI_HK_CRM_Alternate_Delivery_Address_4__c = oldSO.ASI_HK_CRM_Alternate_Delivery_Address_4__c;
        newSO.ASI_HK_CRM_Has_Cancelled_Line_Item__c = oldSO.ASI_HK_CRM_Has_Cancelled_Line_Item__c;
        newSO.ASI_HK_CRM_Order_Date__c = Date.Today();
        newSO.ASI_HK_CRM_Delivery_Date__c = Date.Today().addDays(1);
        newSO.ASI_HK_CRM_Order_Type__c = oldSO.ASI_HK_CRM_Order_Type__c;
        newSO.CurrencyIsoCode = oldSO.CurrencyIsoCode; 
        newSO.ASI_HK_CRM_Phone_Number__c = oldSO.ASI_HK_CRM_Phone_Number__c;
        newSO.ASI_HK_CRM_Fax__c = oldSO.ASI_HK_CRM_Fax__c;
        newSO.ASI_HK_CRM_Delivery_Window_Instruction__c = oldSO.ASI_HK_CRM_Delivery_Window_Instruction__c;
        newSO.ASI_HK_CRM_Delivery_Time_1__c = oldSO.ASI_HK_CRM_Delivery_Time_1__c;
        newSO.ASI_HK_CRM_Delivery_Time_2__c = oldSO.ASI_HK_CRM_Delivery_Time_2__c;
        
        if(oldSO.ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_Payment_Term_Code__c=='COD' ){
            newSO.ASI_HK_CRM_Payment_Method__c = 'CASH' ;
        }else{
            newSO.ASI_HK_CRM_Payment_Method__c = oldSO.ASI_HK_CRM_Payment_Method__c;
        }
        
        
        newSO.ASI_HK_CRM_Reason_PaymentMethodChange__c = oldSO.ASI_HK_CRM_Reason_PaymentMethodChange__c!=null?oldSO.ASI_HK_CRM_Reason_PaymentMethodChange__c:'N/A';
        newSO.ASI_HK_CRM_Instruction_txt__c = oldSO.ASI_HK_CRM_Instruction_txt__c;
        newSO.ASI_HK_CRM_Attention__c = oldSO.ASI_HK_CRM_Attention__c;
        newSO.ASI_HK_CRM_Delivery_Remarks__c = oldSO.ASI_HK_CRM_Delivery_Remarks__c;
        newSO.ASI_HK_CRM_User_D_O__c = oldSO.ASI_HK_CRM_User_D_O__c; 
        newSO.ASI_HK_CRM_Credit_Limit__c = oldSO.ASI_HK_CRM_Credit_Limit__c;
        newSO.ASI_HK_CRM_Payment_Term_Code__c = oldSO.ASI_HK_CRM_Payment_Term_Code__c;
        newSO.ASI_HK_CRM_Payment_Term_Description__c = oldSO.ASI_HK_CRM_Payment_Term_Description__c;
        newSO.ASI_HK_CRM_Current_Amount__c = oldSO.ASI_HK_CRM_Current_Amount__c;
        newSO.ASI_HK_CRM_X1_30__c = oldSO.ASI_HK_CRM_X1_30__c;
        newSO.ASI_HK_CRM_X31_60__c = oldSO.ASI_HK_CRM_X31_60__c;
        newSO.ASI_HK_CRM_X61_90__c = oldSO.ASI_HK_CRM_X61_90__c;
        newSO.ASI_HK_CRM_Over_91__c = oldSO.ASI_HK_CRM_Over_91__c;
        newSO.ASI_HK_CRM_No_comments_from_SSC__c = oldSO.ASI_HK_CRM_No_comments_from_SSC__c;
        newSO.ASI_HK_CRM_Money_Report_Remarks__c = oldSO.ASI_HK_CRM_Money_Report_Remarks__c;
        newSO.ASI_HK_CRM_Total_Exposure__c = oldSO.ASI_HK_CRM_Total_Exposure__c;
        newSO.ASI_HK_CRM_Overdue_30_days__c = oldSO.ASI_HK_CRM_Overdue_30_days__c;
        newSO.ASI_HK_CRM_AR_Info_Last_Updated_By__c = oldSO.ASI_HK_CRM_AR_Info_Last_Updated_By__c;
        newSO.ASI_HK_CRM_Payment_Amt_1__c = oldSO.ASI_HK_CRM_Payment_Amt_1__c;
        newSO.ASI_HK_CRM_Payment_Amt_2__c = oldSO.ASI_HK_CRM_Payment_Amt_2__c;
        newSO.ASI_HK_CRM_Payment_Amt_3__c = oldSO.ASI_HK_CRM_Payment_Amt_3__c;
        newSO.ASI_HK_CRM_Payment_Amt_4__c = oldSO.ASI_HK_CRM_Payment_Amt_4__c;
        newSO.ASI_HK_CRM_Payment_Amt_5__c = oldSO.ASI_HK_CRM_Payment_Amt_5__c;
        newSO.ASI_HK_CRM_Payment_Date_1__c = oldSO.ASI_HK_CRM_Payment_Date_1__c;
        newSO.ASI_HK_CRM_Payment_Date_2__c = oldSO.ASI_HK_CRM_Payment_Date_2__c;
        newSO.ASI_HK_CRM_Payment_Date_3__c = oldSO.ASI_HK_CRM_Payment_Date_3__c;
        newSO.ASI_HK_CRM_Payment_Date_4__c = oldSO.ASI_HK_CRM_Payment_Date_4__c;
        newSO.ASI_HK_CRM_Payment_Date_5__c = oldSO.ASI_HK_CRM_Payment_Date_5__c;
        newSO.ASI_HK_CRM_Cheque_Amt_1__c = oldSO.ASI_HK_CRM_Cheque_Amt_1__c;
        newSO.ASI_HK_CRM_Cheque_Amt_2__c = oldSO.ASI_HK_CRM_Cheque_Amt_2__c;
        newSO.ASI_HK_CRM_Cheque_Amt_3__c = oldSO.ASI_HK_CRM_Cheque_Amt_3__c;
        newSO.ASI_HK_CRM_Cheque_Amt_4__c = oldSO.ASI_HK_CRM_Cheque_Amt_4__c;
        newSO.ASI_HK_CRM_Cheque_Amt_5__c = oldSO.ASI_HK_CRM_Cheque_Amt_5__c;
        newSO.ASI_HK_CRM_Cheque_Date_1__c = oldSO.ASI_HK_CRM_Cheque_Date_1__c;
        newSO.ASI_HK_CRM_Cheque_Date_2__c = oldSO.ASI_HK_CRM_Cheque_Date_2__c;
        newSO.ASI_HK_CRM_Cheque_Date_3__c = oldSO.ASI_HK_CRM_Cheque_Date_3__c;
        newSO.ASI_HK_CRM_Cheque_Date_4__c = oldSO.ASI_HK_CRM_Cheque_Date_4__c;
        newSO.ASI_HK_CRM_Cheque_Date_5__c = oldSO.ASI_HK_CRM_Cheque_Date_5__c;
        newSO.ASI_HK_CRM_Salesman_Comments_PreSubmit__c = oldSO.ASI_HK_CRM_Salesman_Comments_PreSubmit__c;
        newSO.ASI_HK_CRM_Comments_SSC__c = oldSO.ASI_HK_CRM_Comments_SSC__c;
        newSO.ASI_HK_CRM_Comments_Salesman__c = oldSO.ASI_HK_CRM_Comments_Salesman__c;
        newSO.ASI_HK_CRM_Comment_SSM_HS__c = oldSO.ASI_HK_CRM_Comment_SSM_HS__c;
        insert newSO;
        
        List<ASI_HK_CRM_Sales_Order_Item__c> oldSODetailList = [SELECT  ASI_HK_CRM_SKU__c , ASI_HK_CRM_Quantity__c, ASI_HK_CRM_UOM__c, ASI_HK_CRM_Price__c, ASI_HK_CRM_Cancel_Qty__c , ASI_HK_CRM_Free_Issue__c , ASI_HK_CRM_Original_Price__c  , CurrencyIsoCode , recordTypeID , ASI_HK_CRM_Doc_Line_Num__c , ASI_HK_CRM_SYS_StatusCodeLast__c , ASI_HK_CRM_SYS_StatusCodeNext__c
                                                                FROM ASI_HK_CRM_Sales_Order_Item__c
                                                                WHERE ASI_HK_CRM_Sales_Order__c =: soId 
                                                                AND (NOT ASI_HK_CRM_Free_Issue__c LIKE 'STK%')]; //20160505, edited by Leo
        
        //Assign values from old SO Detail to new SO Detail
        for(ASI_HK_CRM_Sales_Order_Item__c oldDetail: oldSODetailList){
            soDetailTemp = new ASI_HK_CRM_Sales_Order_Item__c();
            soDetailTemp.ASI_HK_CRM_Sales_Order__c = newSO.Id;
            soDetailTemp.ASI_HK_CRM_SKU__c = oldDetail.ASI_HK_CRM_SKU__c;
            soDetailTemp.ASI_HK_CRM_Quantity__c = oldDetail.ASI_HK_CRM_Quantity__c;
            soDetailTemp.ASI_HK_CRM_UOM__c = oldDetail.ASI_HK_CRM_UOM__c;
            soDetailTemp.ASI_HK_CRM_Price__c = oldDetail.ASI_HK_CRM_Price__c;
            soDetailTemp.ASI_HK_CRM_Cancel_Qty__c = oldDetail.ASI_HK_CRM_Cancel_Qty__c;
            soDetailTemp.ASI_HK_CRM_Free_Issue__c = oldDetail.ASI_HK_CRM_Free_Issue__c;
            soDetailTemp.ASI_HK_CRM_Original_Price__c = oldDetail.ASI_HK_CRM_Original_Price__c;
            soDetailTemp.ASI_HK_CRM_Doc_Line_Num__c = oldDetail.ASI_HK_CRM_Doc_Line_Num__c;
            soDetailTemp.ASI_HK_CRM_SYS_StatusCodeLast__c = oldDetail.ASI_HK_CRM_SYS_StatusCodeLast__c;
            soDetailTemp.ASI_HK_CRM_SYS_StatusCodeNext__c = oldDetail.ASI_HK_CRM_SYS_StatusCodeNext__c;
            soNewDetailList.add(soDetailTemp);
        }
        
        insert soNewDetailList;
        
        return new PageReference('/' + newSO.id + '/e?retURL=' + '%2F' + newSO.id);
    }
}