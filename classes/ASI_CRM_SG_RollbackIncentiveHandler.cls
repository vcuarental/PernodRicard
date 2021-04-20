/*********************************************************************************
 * Name: ASI_CRM_SG_RollbackIncentiveHandler
 * Description: Handler rollback incentive after delete Payment Request / FOC Request / Voucher
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/04/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_SG_RollbackIncentiveHandler extends ASI_CRM_SG_TriggerAbstract {
    
    public static final String PAYMENT_REQUEST = 'PaymentRequest';
    public static final String FOC_REQUEST     = 'FOCRequest';
    public static final String VOUCHER_REQUEST = 'VoucherRequest';
	public static final String SG_PROMOTION_REMARK = 'SG Promotion';
	public static final String SG_PROMOTION_REMARK_TOBEDELETED = 'SG Promotion (To Be Deleted)';
	public static final String SG_PROMOTION_DELETEERROR = 'Please remove / re-generate the promotion incentive in Automated Request page.';
    
    private String objType {get; set;}
    
    public ASI_CRM_SG_RollbackIncentiveHandler() {
        super('ASI_CRM_SG_RollbackIncentiveHandler');
    }
    
    public ASI_CRM_SG_RollbackIncentiveHandler(String objType) {
        super('ASI_CRM_SG_RollbackIncentiveHandler');
    	this.objType = objType;
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
       	Map<Id, Date> promotionDetilIdDateMap = new Map<Id, Date>();
  		Set<Integer> monthSet = new Set<Integer>();
        Set<Integer> yearSet = new Set<Integer>();
        
        if(objType == PAYMENT_REQUEST) {
            list<ASI_TH_CRM_PaymentRequest__c> list_p = (list<ASI_TH_CRM_PaymentRequest__c>) sObjList;
			Map<Id, ASI_TH_CRM_PaymentRequest__c> paymentRequestMap = new Map<Id, ASI_TH_CRM_PaymentRequest__c>();
			for(ASI_TH_CRM_PaymentRequest__c p : list_p){
				if(p.ASI_CRM_System_Remark__c == SG_PROMOTION_REMARK){
					p.addError(SG_PROMOTION_DELETEERROR);
				}else
				if(p.ASI_CRM_System_Remark__c == SG_PROMOTION_REMARK_TOBEDELETED){
					paymentRequestMap.put(p.id, p);
				}
			}
			
			//Map<Id, ASI_TH_CRM_PaymentRequest__c> paymentRequestMap = (Map<Id, ASI_TH_CRM_PaymentRequest__c>) oldMap;
			
            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItem : retrievePaymentRequestLineList(paymentRequestMap.keySet())) {
                ASI_TH_CRM_PaymentRequest__c paymentRequest = paymentRequestMap.get(lineItem.ASI_TH_CRM_Payment_Request__c);
                if(paymentRequest.ASI_CRM_Generation_From_Date__c != null) {
                    promotionDetilIdDateMap.put(lineItem.ASI_CRM_Promotion_Detail__c, paymentRequest.ASI_CRM_Generation_From_Date__c);
                    monthSet.add(paymentRequest.ASI_CRM_Generation_From_Date__c.month());
                    yearSet.add(paymentRequest.ASI_CRM_Generation_From_Date__c.year());
                }
            }
            
        } else if(objType == FOC_REQUEST) {
            list<ASI_FOC_Free_Goods_Request__c> list_p = (list<ASI_FOC_Free_Goods_Request__c>) sObjList;
			Map<Id, ASI_FOC_Free_Goods_Request__c> requestMap = new Map<Id, ASI_FOC_Free_Goods_Request__c>();
			for(ASI_FOC_Free_Goods_Request__c p : list_p){
				if(p.ASI_CRM_System_Remark__c == SG_PROMOTION_REMARK){
					p.addError(SG_PROMOTION_DELETEERROR);
				}else
				if(p.ASI_CRM_System_Remark__c == SG_PROMOTION_REMARK_TOBEDELETED){
					requestMap.put(p.id, p);
				}
			}
			
        	//Map<Id, ASI_FOC_Free_Goods_Request__c> requestMap = (Map<Id, ASI_FOC_Free_Goods_Request__c>) oldMap;

            for(ASI_FOC_Request_Item__c lineItem : retrieveFOCLineList(requestMap.keySet())) {
                ASI_FOC_Free_Goods_Request__c request = requestMap.get(lineItem.ASI_FOC_Request_Order__c);
                if(request.ASI_CRM_SG_Year__c != null && request.ASI_CRM_SG_Month__c != null) {
                    promotionDetilIdDateMap.put(lineItem.ASI_CRM_Promotion_Detail__c, Date.newInstance(Integer.valueOf(request.ASI_CRM_SG_Year__c), Integer.valueOf(request.ASI_CRM_SG_Month__c), 1));
                    monthSet.add(Integer.valueOf(request.ASI_CRM_SG_Month__c));
                    yearSet.add(Integer.valueOf(request.ASI_CRM_SG_Year__c));
                }
            }
        } else if(objType == VOUCHER_REQUEST) {
            list<ASI_CRM_Voucher__c> list_p = (list<ASI_CRM_Voucher__c>) sObjList;
			Map<Id, ASI_CRM_Voucher__c> voucherMap = new Map<Id, ASI_CRM_Voucher__c>();
			for(ASI_CRM_Voucher__c p : list_p){
				if(p.ASI_CRM_System_Generated_Msg__c == SG_PROMOTION_REMARK){
					p.addError(SG_PROMOTION_DELETEERROR);
				}else
				if(p.ASI_CRM_System_Generated_Msg__c == SG_PROMOTION_REMARK_TOBEDELETED){
					voucherMap.put(p.id, p);
				}
			}
			
        	//Map<Id, ASI_CRM_Voucher__c> voucherMap = (Map<Id, ASI_CRM_Voucher__c>) oldMap;
			
            for(ASI_CRM_Voucher_Detail__c voucherDetail : retrieveVoucherDetailList(voucherMap.keySet())) {
                ASI_CRM_Voucher__c voucher = voucherMap.get(voucherDetail.ASI_CRM_Voucher_Header__c);
                if(voucher.ASI_CRM_Generation_Reference_Date__c != null) {
                    promotionDetilIdDateMap.put(voucherDetail.ASI_CRM_Promotion_Detail__c, voucher.ASI_CRM_Generation_Reference_Date__c);
                    monthSet.add(voucher.ASI_CRM_Generation_Reference_Date__c.month());
                    yearSet.add(voucher.ASI_CRM_Generation_Reference_Date__c.year());
                }
            }
        }
        
        if(promotionDetilIdDateMap.size() > 0) {
            List<ASI_CRM_Promotion_Detail_Achievement__c> promotionDetailAchievementList = 
                ASI_CRM_SG_PromotionDetailAchieveHandler.resetAchievementList(promotionDetilIdDateMap, monthSet, yearSet);
            
            update promotionDetailAchievementList;
        }
    }
    
    
    
    /***************
    Data Retrievement Function
    ***************/
    private static List<ASI_TH_CRM_PaymentRequestLineItem__c> retrievePaymentRequestLineList(Set<Id> paymentRequestIdSet) {
        String query = 'SELECT Id, ASI_CRM_Promotion_Detail__c, ASI_TH_CRM_Payment_Request__c '
                     + 'FROM ASI_TH_CRM_PaymentRequestLineItem__c '
                     + 'WHERE ASI_TH_CRM_Payment_Request__c in :paymentRequestIdSet '
                     + 'AND ASI_CRM_Promotion_Detail__c != null ';
        
        return (List<ASI_TH_CRM_PaymentRequestLineItem__c>) Database.query(query);
    }
    
    private static List<ASI_FOC_Request_Item__c> retrieveFOCLineList(Set<Id> requestIdSet) {
        String query = 'SELECT Id, ASI_CRM_Promotion_Detail__c, ASI_FOC_Request_Order__c '
                     + 'FROM ASI_FOC_Request_Item__c '
                     + 'WHERE ASI_FOC_Request_Order__c in :requestIdSet '
                     + 'AND ASI_CRM_Promotion_Detail__c != null ';
        
        return (List<ASI_FOC_Request_Item__c>) Database.query(query);
    }
    
    private static List<ASI_CRM_Voucher_Detail__c> retrieveVoucherDetailList(Set<Id> voucherIdSet) {
        String query = 'SELECT Id, ASI_CRM_Promotion_Detail__c, ASI_CRM_Voucher_Header__c '
                     + 'FROM ASI_CRM_Voucher_Detail__c '
                     + 'WHERE ASI_CRM_Voucher_Header__c in :voucherIdSet '
                     + 'AND ASI_CRM_Promotion_Detail__c != null ';
        
        return (List<ASI_CRM_Voucher_Detail__c>) Database.query(query);
    }
}