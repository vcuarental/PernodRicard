public with sharing class LAT_OpportunityHandlerJSON {

	public Header header {get;set;} 
	public List<Detail> detail {get;set;} 

	public LAT_OpportunityHandlerJSON() {
		header = new Header();
		detail = new List<Detail>{new Detail()};
	}

	public LAT_OpportunityHandlerJSON(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'header') {
						header = new Header(parser);
					} else if (text == 'detail') {
						detail = arrayOfDetail(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'LAT_OpportunityHandlerJSON consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Header {
		public String id {get;set;} 
		public String owner {get;set;} 
		public String name {get;set;} 
		public String account {get;set;} 
		public String customerOrderNr {get;set;} 
		public String accountAN8 {get;set;} 
		public String businessUnit {get;set;} 
		public String freighpetTy {get;set;} 
		public String message1 {get;set;} 
		public String message2 {get;set;} 
		public String lastItemModifiedDate {get;set;} 
		public String creationDateTime {get;set;} 
		public String jdeOrderNumber {get;set;} 
		public String source {get;set;} 
		public String type_Z {get;set;} // in json: type
		public String stage {get;set;} 
		public String closeDate {get;set;} 
		public String deliveryDate {get;set;} 
		public String sugestedDeliveryDate {get;set;} 
		public Decimal totalAmmount {get;set;} 
		public Decimal totalBoxes {get;set;} 
		public String recordType {get;set;} 
		public Boolean hasBackorder {get;set;} 
		public Decimal creditLimitBalance {get;set;} 
		public String parentAccount {get;set;} 
		public String actionCode {get;set;} 
		public Datetime LastModifiedDate {get;set;} 
		public String mxPaymentCondition {get;set;} 
		public String mxPurchaseOrderSince {get;set;} 
		public String mxPurchaseOrderUntil {get;set;} 
		public String mxCreditCollectionsStatus {get;set;} 
		public String mxLogisticsStatus {get;set;} 
		public String pCurrency {get;set;} 
		public Decimal totalFreightPercent {get;set;} 
		public Decimal totalPalletQuantity {get;set;} 
		public Boolean isFlex {get;set;} 
		public Boolean flexApproveManager {get;set;} 
		public Boolean flexApproveAreaManager {get;set;} 
		public Boolean flexApproveRegionalManager {get;set;} 
		public Boolean flexApproveCommercialDirector {get;set;}
		public String flexJustification {get;set;} 
		public String needsToBeBlocked {get;set;}
		public String agreementId {get;set;}
		public String fundingType {get;set;} 
		public String aquilaId {get;set;} 


		public Header(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'owner') {
							owner = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'account') {
							account = parser.getText();
						} else if (text == 'customerOrderNr') {
							customerOrderNr = parser.getText();
						} else if (text == 'accountAN8') {
							accountAN8 = parser.getText();
						} else if (text == 'businessUnit') {
							businessUnit = parser.getText();
						} else if (text == 'freighpetTy') {
							freighpetTy = parser.getText();
						} else if (text == 'message1') {
							message1 = parser.getText();
						} else if (text == 'message2') {
							message2 = parser.getText();
						} else if (text == 'lastItemModifiedDate') {
							lastItemModifiedDate = parser.getText();
						} else if (text == 'creationDateTime') {
							creationDateTime = parser.getText();
						} else if (text == 'jdeOrderNumber') {
							jdeOrderNumber = parser.getText();
						} else if (text == 'source') {
							source = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'stage') {
							stage = parser.getText();
						} else if (text == 'closeDate') {
							closeDate = parser.getText();
						} else if (text == 'deliveryDate') {
							deliveryDate = parser.getText();
						} else if (text == 'sugestedDeliveryDate') {
							sugestedDeliveryDate = parser.getText();
						} else if (text == 'totalAmmount') {
							totalAmmount = parser.getDoubleValue();
						} else if (text == 'totalBoxes') {
							totalBoxes = parser.getDecimalValue();
						} else if (text == 'recordType') {
							recordType = parser.getText();
						} else if (text == 'hasBackorder') {
							hasBackorder = parser.getBooleanValue();
						} else if (text == 'creditLimitBalance') {
							creditLimitBalance = parser.getDecimalValue();
						} else if (text == 'parentAccount') {
							parentAccount = parser.getText();
						} else if (text == 'actionCode') {
							actionCode = parser.getText();
						} else if (text == 'LastModifiedDate') {
							LastModifiedDate = parser.getDateTimeValue();
						} else if (text == 'mxPaymentCondition') {
							mxPaymentCondition = parser.getText();
						} else if (text == 'mxPurchaseOrderSince') {
							mxPurchaseOrderSince = parser.getText();
						} else if (text == 'mxPurchaseOrderUntil') {
							mxPurchaseOrderUntil = parser.getText();
						} else if (text == 'mxCreditCollectionsStatus') {
							mxCreditCollectionsStatus = parser.getText();
						} else if (text == 'mxLogisticsStatus') {
							mxLogisticsStatus = parser.getText();
						} else if (text == 'pCurrency') {
							pCurrency = parser.getText();
						} else if (text == 'totalFreightPercent') {
							totalFreightPercent = parser.getDoubleValue();
						} else if (text == 'totalPalletQuantity') {
							totalPalletQuantity = parser.getDoubleValue();
						} else if (text == 'agreementId') {
							agreementId = parser.getText();
						} else if (text == 'fundingType') {
							fundingType = parser.getText();
						}else if (text == 'aquilaId') {
							aquilaId = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Header consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}

		public Header(){
		}
	}
	
	public class Detail {
		public String id {get;set;} 
		public String compassId {get;set;} 
		public String product {get;set;} 
		public String productSKU {get;set;} 
		public String PriceBookEntryId {get;set;} 
		public String paymentCondition {get;set;} 
		public String measurementUnit {get;set;} 
		public Decimal maxDiscount {get;set;} 
		public Double quantity {get;set;} 
		public Double discount {get;set;} 
		public Double finalFlexDiscount {get;set;} 
		public Boolean sendDicountToApproval {get;set;} 
		public Double unitPrice {get;set;} 
		public Double totalPrice {get;set;} 
		public String bottlesPerBox {get;set;} 
		public String lineStatus {get;set;} 
		public String statusDescription {get;set;} 
		public String retentionCode {get;set;} 
		public Double backorder {get;set;} 
		public Double quantityBonus {get;set;} 
		public Decimal percentualBonus {get;set;} 
		public Double totalQuantity {get;set;} 
		public Double totalPriceBR {get;set;} 
		public Double bottlePrice {get;set;} 
		public String actionCode {get;set;} 
		public Double skuFreightPercentIndividual {get;set;} 
		public Double skuFreightPercent {get;set;} 
		public Double skuPalletQuantity {get;set;} 
		public String detailAmmountSummaryType {get;set;} 
		public String detailAmmountSummaryType_ID {get;set;} 
		public Boolean isFlex {get;set;} 
		public Decimal flexAmount {get;set;} 
		public Decimal originalFlexAmount {get;set;} 
		public Decimal baseNISAmount {get;set;} 
		public String idImm {get;set;} 
		public Boolean isOkEDI {get;set;} 
		public String lineNumberJDE {get;set;} 

		public Detail(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'product') {
							product = parser.getText();
						} else if (text == 'productSKU') {
							productSKU = parser.getText();
						} else if (text == 'PriceBookEntryId') {
							PriceBookEntryId = parser.getText();
						} else if (text == 'paymentCondition') {
							paymentCondition = parser.getText();
						} else if (text == 'measurementUnit') {
							measurementUnit = parser.getText();
						} else if (text == 'maxDiscount') {
							maxDiscount = parser.getDecimalValue();
						} else if (text == 'quantity') {
							quantity = parser.getDoubleValue();
						} else if (text == 'discount') {
							discount = parser.getDoubleValue();
						} else if (text == 'finalFlexDiscount') {
							finalFlexDiscount = parser.getDoubleValue();
						} else if (text == 'sendDicountToApproval') {
							sendDicountToApproval = parser.getBooleanValue();
						} else if (text == 'unitPrice') {
							unitPrice = parser.getDoubleValue();
						} else if (text == 'totalPrice') {
							totalPrice = parser.getDoubleValue();
						} else if (text == 'bottlesPerBox') {
							bottlesPerBox = parser.getText();
						} else if (text == 'lineStatus') {
							lineStatus = parser.getText();
						} else if (text == 'statusDescription') {
							statusDescription = parser.getText();
						} else if (text == 'retentionCode') {
							retentionCode = parser.getText();
						} else if (text == 'backorder') {
							backorder = parser.getDoubleValue();
						} else if (text == 'quantityBonus') {
							quantityBonus =  parser.getDecimalValue();
						} else if (text == 'percentualBonus') {
							percentualBonus = parser.getDecimalValue();
						} else if (text == 'totalQuantity') {
							totalQuantity = parser.getDoubleValue();
						} else if (text == 'totalPriceBR') {
							totalPriceBR = parser.getDoubleValue();
						} else if (text == 'bottlePrice') {
							bottlePrice = parser.getDecimalValue();
						} else if (text == 'actionCode') {
							actionCode = parser.getText();
						} else if (text == 'skuFreightPercentIndividual') {
							skuFreightPercentIndividual = parser.getDoubleValue();
						} else if (text == 'skuFreightPercent') {
							skuFreightPercent = parser.getDoubleValue();
						} else if (text == 'skuPalletQuantity') {
							skuPalletQuantity = parser.getDoubleValue();
						} else if (text == 'detailAmmountSummaryType') {
							detailAmmountSummaryType = parser.getText();
						} else if (text == 'detailAmmountSummaryType_ID') {
							detailAmmountSummaryType_ID = parser.getText();
						} else if (text == 'isOkEDI') {
							isOkEDI = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Detail consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}

		public Detail(){

		}
	}
	
	
	public static LAT_OpportunityHandlerJSON parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new LAT_OpportunityHandlerJSON(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

    private static List<Detail> arrayOfDetail(System.JSONParser p) {
        List<Detail> res = new List<Detail>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Detail(p));
        }
        return res;
    }
}