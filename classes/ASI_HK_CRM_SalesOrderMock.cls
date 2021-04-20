@isTest
global with sharing class ASI_HK_CRM_SalesOrderMock implements WebServiceMock{
    global static String HOLD_CODE_RETURN_CODE = 'M0';
    global static ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder expectedShowSalesOrder = null;
    
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        
        if (endpoint.contains('/SalesOrderManager')) {
            if (request instanceof ASI_HK_CRM_SalesOrderManagerTypes.ProcessSalesOrder) {
                ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSalesOrder responseObj = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSalesOrder();
                ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeader soHeader = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeader();
                responseObj.header = soHeader;
                soHeader.customerPO = '11111111';
                ASI_HK_CRM_SalesOrderManagerTypes.SalesOrderKey soKey = new ASI_HK_CRM_SalesOrderManagerTypes.SalesOrderKey();
                soHeader.salesOrderKey = soKey;
                soKey.documentNumber = 22222222;
                soKey.documentCompany = '33333';
                soKey.documentTypeCode = 'S1';
                
                soHeader.detail = new List<ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail>();
                for (Integer i = 0; i < 1; i++) {
                    ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail soDetail = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail();
                    soDetail.documentLineNumber = i;
                    ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailDates sd = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailDates();
                    soDetail.dates = sd;
                    ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailProduct pd = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailProduct();
                    soDetail.product = pd;
                    ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailFinancial financial = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailFinancial();
                    soDetail.financial = financial;
                    financial.priceUnitDomestic = 100;
                    ASI_HK_CRM_SalesOrderManagerTypes.Quantity quantity = new ASI_HK_CRM_SalesOrderManagerTypes.Quantity();
                    soDetail.quantity = quantity;
                    quantity.unitOfMeasureCodeTransaction = 'BT';
                    soHeader.detail.add(soDetail);
                }
      
                response.put('response_x', responseObj);
                
            } else if (request instanceof ASI_HK_CRM_SalesOrderManagerTypes.GetSalesOrder) {
                response.put('response_x', expectedShowSalesOrder);
            }
        } else if (endpoint.contains('/CRMSOManager')) {
            if (request instanceof ASI_HK_CRM_SalesOrderHoldCodeWSTypes.N56HOLD_Input) {
                ASI_HK_CRM_SalesOrderHoldCodeWSTypes.N56HOLD_Output responseObj = new ASI_HK_CRM_SalesOrderHoldCodeWSTypes.N56HOLD_Output();
                responseObj.documentOrderNoInvoiceetc = 1111111;
                responseObj.orderCompanyOrderNumber = '22222222';
                responseObj.orderType = 'Sales Order - HK';
                responseObj.holdOrdersCode = HOLD_CODE_RETURN_CODE ;
                ASI_HK_CRM_SalesOrderHoldCodeWSTypes.E1Message eMessageTemp = new ASI_HK_CRM_SalesOrderHoldCodeWSTypes.E1Message();
                eMessageTemp.message = 'testing';
                eMessageTemp.messagePrefix = 'e';
                //ASI_HK_CRM_SalesOrderHoldCodeWSTypes.E1MessageList eMessageListTemp = new ASI_HK_CRM_SalesOrderHoldCodeWSTypes.E1MessageList();
                responseObj.e1MessageList.e1Messages.add(eMessageTemp);
                response.put('response_x', responseObj);
            }
        }
    }
    
    public static ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder sampleShowSalesOrder() {
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder responseObj = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder();
        List<ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader> header = new List<ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader>();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader header1 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesShipTo st = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesShipTo();
        header1.shipTo = st;
        header.add(header1);
        responseObj.header = header;
        
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetail showSalesDetail = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetail();
        header1.detail = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetail[] {showSalesDetail};
        showSalesDetail.documentLineNumber = 1;
        showSalesDetail.quantityOrdered = 100;
        showSalesDetail.unitOfMeasureCodeTransaction = 'BT';
        
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailProduct product = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailProduct();
        showSalesDetail.product = product;
        ASI_HK_CRM_SalesOrderManagerTypes.ShowDetailItem item = new ASI_HK_CRM_SalesOrderManagerTypes.ShowDetailItem();
        product.item = item;
        item.itemId = null;
        
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLineBilling lineBilling = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLineBilling();
        showSalesDetail.lineBilling = lineBilling;
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLinePricing linePricing = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLinePricing();
        lineBilling.linePricing = linePricing;
        linePricing.priceUnitDomestic = 150;
        
        return responseObj;
    }
}