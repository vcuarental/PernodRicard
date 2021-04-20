/*********************************************************************************
 * Name:ASI_CRM_SG_TBCN_PDF_Controller
 * Description: Controller to handle the data of TBCN Request PDF Attachement.
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016/06/01       Laputa: Hugo Cheung     Created
 * 2016-07-19       Laputa: Vincent Lam     [VL 1.0] Show delivery address in PDF (if alternate address filled in, use alternate address, else use Ship To address)
 * 2017-07-05       Wilken Lee				[WL 1.0] CHM115161419 Add SKU Packing Size
 * 2018-02-26       Wilken Lee				[WL 2.0] Change PDF to display SKU Name
*********************************************************************************/

public with sharing class ASI_CRM_SG_TBCN_PDF_Controller {

    public Id currentTBCNHeaderId {get; set;}
    public String approverName {get; set;}
    
    /* [VL 1.0] BEGIN */
    public String address1 {get; set;}
    public String address2 {get; set;}
    public String address3 {get; set;}
    public String address4 {get; set;}
    /* [VL 1.0] END */

    public ASI_KOR_Sales_Order_Request__c header;
    public List<TBCNLineItemWrapper> details;

    public ASI_KOR_Sales_Order_Request__c getHeader() {

        ASI_KOR_Sales_Order_Request__c headerTemp = [SELECT Id,
                                                     Name,
                                                     ASI_CRM_SG_Customer__c,
                                                     Owner.Name,
                                                     ASI_CRM_SG_Country__c,
                                                     ASI_KOR_Customer_PO_No__c,
                                                     ASI_CRM_SG_Order_Date__c,
                                                     ASI_KOR_Order_Status__c,
                                                     ASI_CRM_Return_Date__c,
                                                     ASI_CRM_Reason_For_Return__c
                                                     /* [VL 1.0] BEGIN */
                                                     , ASI_CRM_Alternate_Address_Line_1__c
                                                     , ASI_CRM_Alternate_Address_Line_2__c
                                                     , ASI_CRM_Alternate_Address_Line_3__c
                                                     , ASI_CRM_Alternate_Address_Line_4__c
                                                     , ASI_CRM_SG_Ship_To__r.ASI_CRM_JP_City_Ward__c
                                                     , ASI_CRM_SG_Ship_To__r.ASI_CRM_JP_Town__c
                                                     , ASI_CRM_SG_Ship_To__r.ASI_CRM_Street_Number__c
                                                     , ASI_CRM_SG_Ship_To__r.ASI_CRM_Building_Floor_Number__c
                                                     /* [VL 1.0] END */
                                                     FROM ASI_KOR_Sales_Order_Request__c
                                                     WHERE Id = :currentTBCNHeaderId
                                                     ];

        if(headerTemp != null) {
            List<ProcessInstance> approvalProcessList = [SELECT ID, 
                                                         TargetObjectId, 
                                                         Status, 
                                                         LastActorId, 
                                                         LastActor.name
                                                         FROM ProcessInstance
                                                         WHERE TargetObjectId = :headerTemp.id
                                                         AND Status = :'Approved'];
            
            if(approvalProcessList.size() > 0) {
                this.approverName = approvalProcessList.get(0).LastActor.name;
            }

            System.debug('approvalProcessList ' + approvalProcessList);
            
            /* [VL 1.0] BEGIN */
            boolean useAlternateAddress = (headerTemp.ASI_CRM_Alternate_Address_Line_1__c != null ||
                                           headerTemp.ASI_CRM_Alternate_Address_Line_2__c != null ||
                                           headerTemp.ASI_CRM_Alternate_Address_Line_3__c != null ||
                                           headerTemp.ASI_CRM_Alternate_Address_Line_4__c != null
                                           ) ? true : false;
            this.address1 = useAlternateAddress ? headerTemp.ASI_CRM_Alternate_Address_Line_1__c : headerTemp.ASI_CRM_SG_Ship_To__r.ASI_CRM_JP_City_Ward__c;
            this.address2 = useAlternateAddress ? headerTemp.ASI_CRM_Alternate_Address_Line_2__c : headerTemp.ASI_CRM_SG_Ship_To__r.ASI_CRM_JP_Town__c;
            this.address3 = useAlternateAddress ? headerTemp.ASI_CRM_Alternate_Address_Line_3__c : headerTemp.ASI_CRM_SG_Ship_To__r.ASI_CRM_Street_Number__c;
            this.address4 = useAlternateAddress ? headerTemp.ASI_CRM_Alternate_Address_Line_4__c : headerTemp.ASI_CRM_SG_Ship_To__r.ASI_CRM_Building_Floor_Number__c;
            /* [VL 1.0] END */
            
        }

        return headerTemp;
    }

    public List<TBCNLineItemWrapper> getDetails() {
        List<TBCNLineItemWrapper> tbcnLineItemWrapperList = new List<TBCNLineItemWrapper>();

        List<ASI_KOR_Sales_Order_Transaction__c> detailTempList = [SELECT Id,
                                                                    Name,
                                                                    ASI_CRM_SG_SKU__c,
																	/*[WL 2.0] BEGIN*/
																	ASI_CRM_SG_SKU__r.Name,
																	/*[WL 2.0] END*/
                                                                    ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c,
                                                                    ASI_CRM_SG_SKU__r.ASI_CRM_Short_Description__c,
																	/*[WL 1.0 BEGIN]*/
																	ASI_CRM_Pack_Factor__c,
																	ASI_CRM_English_Name__c,
																	/*[WL 1.0 END]*/
                                                                    ASI_CRM_Sales_Order_History_Detail__c,
                                                                    ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__c,
                                                                    ASI_CRM_SG_Request_Quantity_Bottle__c
                                                                    FROM ASI_KOR_Sales_Order_Transaction__c
                                                                    WHERE ASI_KOR_Sales_Order_Request__c = :currentTBCNHeaderId
                                                                    ];

        List<String> salesOrderHisotryIdList = new List<String>();  
        List<String> salesOrderHistoryDetailIdList = new List<String>();                                                            
        for(ASI_KOR_Sales_Order_Transaction__c detailTemp : detailTempList) {

            salesOrderHisotryIdList.add(detailTemp.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__c);
            salesOrderHistoryDetailIdList.add(detailTemp.ASI_CRM_Sales_Order_History_Detail__c);

        }                                                            

        /*
        Map<Id, ASI_HK_CRM_Sales_Order_History__c> salesOrderHistoryIdMap = new Map<Id, ASI_HK_CRM_Sales_Order_History__c>([SELECT Id,
                                                                                                                            ASI_HK_CRM_Order_No__c,
                                                                                                                            ASI_HK_CRM_JDE_Invoice_No__c
                                                                                                                            FROM ASI_HK_CRM_Sales_Order_History__c
                                                                                                                            WHERE Id in :salesOrderHisotryIdList
                                                                                                                           ]);
        */

        Map<Id, ASI_HK_CRM_Sales_Order_History_Detail__c> salesOrderHistoryDetailIdMap = new Map<Id, ASI_HK_CRM_Sales_Order_History_Detail__c>([SELECT Id,
                                                                                                                            ASI_HK_CRM_Sales_Order_History__c,
                                                                                                                            ASI_CRM_Lot_Number__c,
                                                                                                                            ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c,
                                                                                                                            ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c
                                                                                                                            FROM ASI_HK_CRM_Sales_Order_History_Detail__c
                                                                                                                            WHERE Id in :salesOrderHistoryDetailIdList
                                                                                                                           ]);

        for(ASI_KOR_Sales_Order_Transaction__c detailTemp : detailTempList) {

            /*
            if(salesOrderHistoryIdMap.containsKey(detailTemp.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__c)) {

                ASI_HK_CRM_Sales_Order_History__c tempSalesOrderHistory = salesOrderHistoryIdMap.get(detailTemp.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__c);
                String orderNo = tempSalesOrderHistory.ASI_HK_CRM_Order_No__c;
                String jdeInvoiceNo = tempSalesOrderHistory.ASI_HK_CRM_JDE_Invoice_No__c;

                tbcnLineItemWrapperList.add(new TBCNLineItemWrapper(detailTemp, orderNo, jdeInvoiceNo));

            } else {
                tbcnLineItemWrapperList.add(new TBCNLineItemWrapper(detailTemp));
            }
            */
            if(salesOrderHistoryDetailIdMap.containsKey(detailTemp.ASI_CRM_Sales_Order_History_Detail__c)) {

                ASI_HK_CRM_Sales_Order_History_Detail__c tempSalesOrderHistoryDetail = salesOrderHistoryDetailIdMap.get(detailTemp.ASI_CRM_Sales_Order_History_Detail__c);
                String orderNo = tempSalesOrderHistoryDetail.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c;
                String jdeInvoiceNo = tempSalesOrderHistoryDetail.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c;
                String lotNo = tempSalesOrderHistoryDetail.ASI_CRM_Lot_Number__c;

                tbcnLineItemWrapperList.add(new TBCNLineItemWrapper(detailTemp, orderNo, jdeInvoiceNo, lotNo));

            } else {
                tbcnLineItemWrapperList.add(new TBCNLineItemWrapper(detailTemp));
            }

        }

        return tbcnLineItemWrapperList;
    }

    public class TBCNLineItemWrapper {

        public ASI_KOR_Sales_Order_Transaction__c tbcnLineItem {get; set;}
        public String orderNo {get; set;}
        public String jdeInvoiceNo {get; set;}
        public String lotNo {get; set;}

        public TBCNLineItemWrapper(ASI_KOR_Sales_Order_Transaction__c tbcnLineItem) {
            this.tbcnLineItem = tbcnLineItem;

            orderNo = '';
            jdeInvoiceNo = '';
        }

        public TBCNLineItemWrapper(ASI_KOR_Sales_Order_Transaction__c tbcnLineItem, String orderNo, String jdeInvoiceNo, String lotNo) {
            this.tbcnLineItem = tbcnLineItem;
            this.orderNo = orderNo;
            this.jdeInvoiceNo = jdeInvoiceNo;
            this.lotNo = lotNo;
        }

    }

}