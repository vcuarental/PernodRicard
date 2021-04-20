/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_HK_PaymentGeneration
 * Description: Extension Class to manually generate Payment in Detail button 
 * Test Class: ASI_MFM_CAP_GeneratePaymentExtensionTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-18       Laputa:Hector           Created
 * 2019-03-07       Wilken Lee           	[WL 1.0] Use PO Remaining Balance as Payment Amount
 * 2019-08-15       Wilken Lee           	[WL 2.0] Remove PO Receipt 3-way match logic
 ****************************************************************************************************************************/

public class ASI_MFM_CAP_HK_PaymentGeneration {
    
    public static ASI_MFM_Payment__c GeneratePaymentFromPO(ASI_MFM_PO__c po){
    	List<ASI_MFM_PO__c> poList = new List<ASI_MFM_PO__c>();
    	poList.add(po);
    	return GeneratePaymentFromPO(poList);
    }
    
    public static ASI_MFM_Payment__c GeneratePaymentFromPO(List<ASI_MFM_PO__c> poListInput){
    	//Map of PO ID to Payment 
    	Map<id, ASI_MFM_Payment__c> newPOPaymentMap = new Map<id, ASI_MFM_Payment__c>();
    	List<ASI_MFM_Payment_Line_Item__c> newPaymentLineItemList = new List<ASI_MFM_Payment_Line_Item__c>();
    	
    	Set<Id> poIDSet = new Set<Id>();
    	for (ASI_MFM_PO__c po:poListInput){
    		poIDSet.add(po.Id);
    	}
    	
    	//Get PO Detail
    	List<ASI_MFM_PO__c> poList = [SELECT Id,
    										ASI_MFM_Dummy_PO__c,
											ASI_MFM_Exchange_Rate__c,
											ASI_MFM_Plan__c,
											ASI_MFM_PO_Type__c,
											ASI_MFM_Prefix__c,
											ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,
											ASI_MFM_Supplier_Name__c,
											CurrencyIsoCode
    									FROM ASI_MFM_PO__c
    									WHERE Id in :poIDSet];
		
		//For PO Generate Payment, only Dummy PO will need to generate payment lines
    	if (poList.size() > 0){
    		//Get PO Line Item
	    	List<ASI_MFM_PO_Line_Item__c> poLineItemList = [SELECT Id,
														    	ASI_MFM_Amount__c,
																ASI_MFM_Remaining_Balance__c,	//[WL 1.0]
														    	ASI_MFM_AP_Code__c,
														    	ASI_MFM_BU_Code__c,
														    	ASI_MFM_G_L_Date__c,
														    	ASI_MFM_List_Item_Description__c,
	                                                        	ASI_MFM_PO__c,
	                                                        	ASI_MFM_PO__r.ASI_MFM_Dummy_PO__c
	    													FROM ASI_MFM_PO_Line_Item__c
	    													WHERE ASI_MFM_PO__c in :poIDSet];
	    	
	    	
	    	//Retrieve MFM Prefix
	    	List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixRelationshipList = getRolePrefixRelationship('Payment', 'HK', 'ASI_MFM_CAP_Prefix');
	    	
	    	//PO (ASI_MFM_PO__c) generate Payment (ASI_MFM_Payment__c)
	    	for (ASI_MFM_PO__c po : poList){
	            String mfmPrefix = '';
	            for (ASI_MFM_Role_Prefix_Relationship__c rolePrefixRelationship : rolePrefixRelationshipList){
	            	if (rolePrefixRelationship.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c == po.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c){
	            		mfmPrefix = rolePrefixRelationship.ASI_MFM_Prefix__c;
	            	}
	            }
	    		ASI_MFM_Payment__c newPayment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Type__c = po.ASI_MFM_PO_Type__c,
		    															ASI_MFM_Plan__c = po.ASI_MFM_Plan__c,
		    															ASI_MFM_Invoice_Date__c = Date.today(),
		    															ASI_MFM_Supplier_Name__c = po.ASI_MFM_Supplier_Name__c,
		    															ASI_MFM_Status__c = 'Draft',
		    															ASI_MFM_CAP_PO__c = po.Id,
		    															ASI_MFM_Prefix__c = mfmPrefix,
		    															CurrencyIsoCode = po.CurrencyIsoCode,
		    															ASI_MFM_Exchange_Rate__c = po.ASI_MFM_Exchange_Rate__c,
		    															ASI_MFM_Payment_Date__c = Date.today(),
		    															ASI_MFM_Cashflow_Date__c = Date.today(),
		    															ASI_MFM_G_L_Date__c = Date.today(),
		    															//ASI_MFM_Invoice_Number__c = 'AUTO' + DateTime.Now().format('YYYYMMddhhmmss'),
		    															recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__c'+'ASI_MFM_CAP_Payment'));
		    	newPOPaymentMap.put(po.Id, newPayment);               
	    	}
	    	insert newPOPaymentMap.values();
	    	system.debug(newPOPaymentMap.values());
	    	
	    	//PO Line (ASI_MFM_PO_Line_Item__c) generate Payment Line (ASI_MFM_Payment_Line_Item__c)
	    	for (ASI_MFM_PO_Line_Item__c poLine : poLineItemList){
	    		//if (poLine.ASI_MFM_PO__r.ASI_MFM_Dummy_PO__c){ //[WL 2.0] Generate Payment Line for all PO, regardless is Dummy PO or not
	    			ASI_MFM_Payment_Line_Item__c newPaymentLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_AP_Code__c = poLine.ASI_MFM_AP_Code__c,
																									ASI_MFM_BU__c = poLine.ASI_MFM_BU_Code__c,
																									/*[WL 1.0] BEGIN*/
																									//ASI_MFM_Payment_Amount__c = poLine.ASI_MFM_Amount__c,
																									ASI_MFM_Payment_Amount__c = poLine.ASI_MFM_Remaining_Balance__c,
																									/*[WL 1.0] END*/
																									ASI_MFM_Payment_List_Item_Description__c = poLine.ASI_MFM_List_Item_Description__c,
		                                                                                            ASI_MFM_PO__c = poLine.ASI_MFM_PO__c,
		                                                                                            ASI_MFM_PO_Line_Item__c = poLine.Id,
																									recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__c'+'ASI_MFM_CAP_Payment_Line_Item'));
					newPaymentLine.ASI_MFM_Payment__c = newPOPaymentMap.get(poLine.ASI_MFM_PO__c).Id;
					newPaymentLineItemList.add(newPaymentLine);
	    		//} //[WL 2.0]
			}
			if (newPaymentLineItemList.size() > 0){
				insert newPaymentLineItemList;
				system.debug(newPaymentLineItemList);
			}
    	}
    	if (newPOPaymentMap.size() > 0){
    		//Get first payment of the map
    		for (ASI_MFM_Payment__c payment : newPOPaymentMap.values()){
    			return payment;
    			break;
    		}
    	} 
    	return null;
    }
    
    //Generate Payment Line and trigger Payment turns Final when PO Receipt turns Final
    public static void GeneratePaymentLineFromPOReceipt(List<Id> paymentHeaderIdList){
    	List<ASI_MFM_Payment__c> paymentHeaderList = [SELECT Id, 
    														ASI_MFM_CAP_PO__c,
    														ASI_MFM_Status__c
    													FROM ASI_MFM_Payment__c
    													WHERE Id in :paymentHeaderIdList];
    													
    	GeneratePaymentLineFromPOReceipt(paymentHeaderList);
    }
    
    public static void GeneratePaymentLineFromPOReceipt(List<ASI_MFM_Payment__c> paymentHeaderList){
    	Map<Id, Id> paymentPOMap = new Map<Id, Id>();
    	for (ASI_MFM_Payment__c payment:paymentHeaderList){
    		paymentPOMap.put(payment.Id, payment.ASI_MFM_CAP_PO__c);
    		payment.ASI_MFM_Status__c = 'Final';
    	}
    	//Get PO Receipt
    	Map<Id, ASI_MFM_PO_Receipt__c> POReceiptMap = new Map<Id, ASI_MFM_PO_Receipt__c>([SELECT Id
																	    					FROM ASI_MFM_PO_Receipt__c
																	    					WHERE ASI_MFM_Payment__c in :paymentPOMap.KeySet()]);
    	
    					
    	//Get PO Receipt Line
    	Map<Id, ASI_MFM_PO_Receipt_Item__c> POReceiptItemMap = new Map<Id, ASI_MFM_PO_Receipt_Item__c>([SELECT Id,
    																										ASI_MFM_Amount__c,
    																										ASI_MFM_PO_Line_Item__c,
    																										ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,
																											ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Inactive__c,
    																										ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__c,
    																										ASI_MFM_PO_Line_Item__r.ASI_MFM_Distributor_Amount__c,
    																										ASI_MFM_PO_Receipt__r.ASI_MFM_Payment__c
																					    					FROM ASI_MFM_PO_Receipt_Item__c
																					    					WHERE ASI_MFM_PO_Receipt__c in :POReceiptMap.KeySet()]);
																					    	
    	
    	//Generate Payment Line from PO Receipt Line
    	List<ASI_MFM_Payment_Line_Item__c> newPaymentLineItemList = new List<ASI_MFM_Payment_Line_Item__c>();
    	for (ASI_MFM_PO_Receipt_Item__c poReceiptItem : POReceiptItemMap.values()){
    		ASI_MFM_Payment_Line_Item__c newPaymentLine = new ASI_MFM_Payment_Line_Item__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__c' + 'ASI_MFM_CAP_Payment_Line_Item'), 
																							ASI_MFM_AP_Code__c = poReceiptItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,
																							ASI_MFM_BU__c = poReceiptItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__c,
																							ASI_MFM_Payment_Amount__c = poReceiptItem.ASI_MFM_Amount__c, 
																							ASI_MFM_Payment_Amount_Distributor__c = poReceiptItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_Distributor_Amount__c, 
																							ASI_MFM_Payment__c = poReceiptItem.ASI_MFM_PO_Receipt__r.ASI_MFM_Payment__c, 
																							ASI_MFM_PO_Line_Item__c = poReceiptItem.ASI_MFM_PO_Line_Item__c);
			newPaymentLineItemList.add(newPaymentLine);									
			
			system.debug('Payment Line AP Code: ' + newPaymentLine.ASI_MFM_AP_Code__c + ' AP Code Inactive: ' + poReceiptItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Inactive__c);
    	}
    	insert newPaymentLineItemList;
    	update paymentHeaderList;
    }
    @testVisible
    private static List<ASI_MFM_Role_Prefix_Relationship__c> getRolePrefixRelationship(String ModuleName, String CountryName, String RecordTypeName){
    	Id userId = userinfo.getUserId();
    	User userDetails = [SELECT Id, UserRole.DeveloperName FROM User where Id=:userId LIMIT 1];
    	String userRoleName = userDetails.UserRole.DeveloperName;
    	
    	List<ASI_MFM_Role_Prefix_Relationship__c> result = [SELECT Id, 
														    	ASI_MFM_Prefix__c, 
														    	ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c
											   				FROM ASI_MFM_Role_Prefix_Relationship__c 
											  				WHERE ASI_MFM_Prefix__r.ASI_MFM_Inactive__c = false
											 				AND ASI_MFM_Prefix__r.ASI_MFM_Module__c = :ModuleName
											    			AND ASI_MFM_Prefix__r.ASI_MFM_country_name__c = :CountryName
											    			AND ASI_MFM_Prefix__r.recordType.DeveloperName = :RecordTypeName
											    			AND ASI_MFM_Role_Name__c = :userRoleName];
											    						
    	return result;
    }
}