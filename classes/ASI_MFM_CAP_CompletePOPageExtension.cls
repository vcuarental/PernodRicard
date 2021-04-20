/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_CompletePOPageExtension
 * Description: Extension Class to Complete PO 
 * Test Class: ASI_MFM_CAP_CompletePOPageExtensionTest
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-24       Laputa (Hector)         Created
 * 2019-05-03       Wilken Lee              [WL 1.0] Validate no Draft or Submitted Payment before allowing user to Complete PO
 * 2019-06-03       Wilken Lee              [WL 2.0] PO with Final Payment cannot be completed
 * 2019-06-05       Wilken Lee              [WL 3.0] Add Generate Accrual PO function
 ****************************************************************************************************************************/

public without sharing class ASI_MFM_CAP_CompletePOPageExtension {
    
    private ASI_MFM_PO__c po;
	private final Id poId;
    public Boolean showError {get;set;}{showError = false;}
    public String ErrorMessage {get;set;}
    
    public ASI_MFM_CAP_CompletePOPageExtension(ApexPages.StandardController controller){
        this.po = (ASI_MFM_PO__c)controller.getRecord();
		
		this.po	= [SELECT Id, Name, ASI_MFM_Status__c, ASI_MFM_PO_Balance__c, ASI_MFM_Plan__c,ASI_MFM_PO_Type__c, OwnerId, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c FROM ASI_MFM_PO__c WHERE Id = :po.Id LIMIT 1]; //WL 1.0				
    }
    
    public PageReference CompletePO(){
        try{
            /*[WL 1.0] BEGIN*/
            List<ASI_MFM_Payment__c> paymentList = [SELECT Name, ASI_MFM_Status__c FROM ASI_MFM_Payment__c WHERE ASI_MFM_CAP_PO__c = :po.Id];
            
            for (ASI_MFM_Payment__c payment:paymentList){
                if (payment.ASI_MFM_Status__c == 'Draft' || payment.ASI_MFM_Status__c == 'Submitted' || payment.ASI_MFM_Status__c == 'Pending Goods/Service Receipt'
                    || payment.ASI_MFM_Status__c == 'Final'){//WL 2.0
                    showError = true;
                    ErrorMessage = 'Payment ' + payment.Name + ' is still in ' + payment.ASI_MFM_Status__c + ' status. Please approve the Payment before completing PO.';
                }                   
            }
            /*[WL 1.0] END*/
            
            if (!showError){    //WL 1.0
                //Get PO Line Item
                List<ASI_MFM_PO_Line_Item__c> POLineItemList =  [SELECT Id, ASI_MFM_Amount__c, ASI_MFM_Paid_Amount__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c = :po.Id];
                //Set PO Line Item plan amount to payment amount
                List<ASI_MFM_PO_Line_Item__c> updatePOLineItemList = new List<ASI_MFM_PO_Line_Item__c>();
                
                for(ASI_MFM_PO_Line_Item__c POLineItem : POLineItemList){
                    if (POLineItem.ASI_MFM_Amount__c > POLineItem.ASI_MFM_Paid_Amount__c){
                        POLineItem.ASI_MFM_Amount__c = POLineItem.ASI_MFM_Paid_Amount__c;
                        updatePOLineItemList.add(POLineItem);
                    }
                }
                update updatePOLineItemList;
                
                this.po.ASI_MFM_Status__c = 'Complete';
                update this.po;
            }
        } catch (Exception e){
            showError = true;
            ErrorMessage = e.getMessage();
        }
        
        
        if (!showError){
            return new PageReference('/' + po.Id);
        } 
        return null;
    }
	
	/*[WL 3.0] BEGIN*/
	public PageReference generateAccrualPO(){
        List<ASI_MFM_PO_Line_Item__c> POLineItemList =  [SELECT Id, Name, ASI_MFM_Amount__c, ASI_MFM_Paid_Amount__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__c, ASI_MFM_G_L_Date__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c = :po.Id];
		
		//Insert Accrual PO Line as well as Negative Amount of PO Line Balance
		List<ASI_MFM_PO_Line_Item__c> insertPOLineItemList = new List<ASI_MFM_PO_Line_Item__c>();
		ID rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('CAP PO Line Item').getRecordTypeId();    
		String description;
		
		if (po.ASI_MFM_PO_Balance__c <= 0){
			showError = true;
            ErrorMessage = 'PO Does not have balance to generate accrual PO.';
		}
			
		List<ASI_MFM_Prefix__c> prefixList = [SELECT Id, Name, ASI_MFM_Next_Number__c FROM ASI_MFM_Prefix__c WHERE ASI_MFM_Module__c = 'PO' AND ASI_MFM_country_name__c = 'HK' AND Name LIKE '34%' AND ASI_MFM_Inactive__c = false AND recordTypeId = :Global_recordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix') ORDER BY ASI_MFM_Fiscal_year__c DESC];
		ASI_MFM_Prefix__c prefix;
		
		if (prefixList.size() != 1){
			showError = true;
			ErrorMessage = 'Incorrect setup of Accrual PO Prefix. Please contact system administrator';
		}
		else {
			prefix = prefixList.get(0);
		}
		
		//Query AP Code and A/C Code for Accrual PO
		List<ASI_MFM_AP_Code__c> apCodeList = [SELECT Id, ASI_MFM_A_C_Code__c, ASI_MFM_OPEX__c FROM ASI_MFM_AP_Code__c WHERE recordTypeId = :Global_recordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code') AND ASI_MFM_Inactive__c = false AND ASI_MFM_AP_Code__c like '2%'];
		
		ASI_MFM_AP_Code__c accrualAPCode;
		
		if (apCodeList.size() != 2){
			showError = true;
			ErrorMessage = 'Cannot find CAPEX and OPEX Accrual Account Code setup. Please contact system administrator';
		}
		
		for (ASI_MFM_AP_Code__c apCode:apCodeList){
			if (po.ASI_MFM_PO_Type__c == 'CAPEX' && !apCode.ASI_MFM_OPEX__c){
				accrualAPCode = apCode;
			}
			else if (po.ASI_MFM_PO_Type__c == 'OPEX' && apCode.ASI_MFM_OPEX__c){
				accrualAPCode = apCode;
			}
		}
		
		//Query BU Code for Accrual PO
		List<ASI_MFM_BU__c> buCodeList = [SELECT Id, ASI_MFM_OPEX__c FROM ASI_MFM_BU__c WHERE recordTypeId = :Global_recordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU') AND ASI_MFM_Inactive__c = false AND ((ASI_MFM_OPEX__c = true AND Name = 'OPEX - SUSPENSE - 3319000001') OR (ASI_MFM_OPEX__c = false AND ASI_MFM_BU_Code__c like '331%'))];
		
		ASI_MFM_BU__c accrualBUCode;
		
		if (buCodeList.size() != 2){
			showError = true;
			ErrorMessage = 'Cannot find CAPEX and OPEX Accrual BU Code setup. Please contact system administrator';
		}
		
		for (ASI_MFM_BU__c buCode:buCodeList){
			if (po.ASI_MFM_PO_Type__c == 'CAPEX' && !buCode.ASI_MFM_OPEX__c){
				accrualBUCode = buCode;
			}
			else if (po.ASI_MFM_PO_Type__c == 'OPEX' && buCode.ASI_MFM_OPEX__c){
				accrualBUCode = buCode;
			}
		}
				
		//Validate there is no outstanding payment on the PO
		//Flexibility to allow generate accrual PO while PM haven't submit Draft payment, remove this validation
		/*List<ASI_MFM_Payment__c> paymentList = [SELECT ID, Name FROM ASI_MFM_Payment__c WHERE ASI_MFM_CAP_PO__c = :po.Id AND ASI_MFM_Status__c IN ('Draft','Submitted','Final','Pending Goods/Service Receipt')];
		
		if (paymentList.size() > 0){
			showError = true;
			ErrorMessage = 'Please make sure all related Payments are completed before generating Accrual PO';
		}*/
		
		ASI_MFM_PO__c newPO;
		
		User currentUser = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId() Limit 1];
		
		if (!showError || currentUser.BypassTriggers__c.contains('ASI_MFM_HK_BypassTrigger')){
			try{
				String poNumber = '000' + String.ValueOf(prefix.ASI_MFM_Next_Number__c);
				poNumber = poNumber.right(4);
				poNumber = prefix.Name + poNumber;
				
				//Insert new accrual PO
				newPO = new ASI_MFM_PO__c(Name = poNumber, recordTypeId = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_Accrual_PO_Read_Only'), ASI_MFM_Plan__c = po.ASI_MFM_Plan__c, ASI_MFM_PO_Type__c = po.ASI_MFM_PO_Type__c, OwnerID = po.OwnerId, 
														ASI_MFM_Supplier_Name__c = po.ASI_MFM_Supplier_Name__c, ASI_MFM_Status__c = 'Final', ASI_MFM_Currency__c = po.ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c = po.ASI_MFM_Exchange_Rate__c, ASI_MFM_Prefix__c = prefix.Id);
				insert newPO;

				//Increase prefix running number
				prefix.ASI_MFM_Next_Number__c = prefix.ASI_MFM_Next_Number__c + 1;
				update prefix;
				
				for(ASI_MFM_PO_Line_Item__c poLineItem : POLineItemList){
					if (poLineItem.ASI_MFM_Remaining_Balance__c > 0){
						
						description = 'Accrual PO Adjustment: ' + po.Name + '-' + poLineItem.Name + '- Paid Amount: ' + (poLineItem.ASI_MFM_Amount__c - poLineItem.ASI_MFM_Remaining_Balance__c) + '; Remaining Amount: ' + poLineItem.ASI_MFM_Remaining_Balance__c;
									
						//Add Negative Amount Line to existing PO
						ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = description, ASI_MFM_Amount__c = 0-poLineItem.ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c = poLineItem.ASI_MFM_PO__c ,
									ASI_MFM_A_C_Code__c = poLineItem.ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c = poLineItem.ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__c = poLineItem.ASI_MFM_BU_Code__c, 
									recordTypeId = rectypeid, ASI_MFM_G_L_Date__c = poLineItem.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
									
						insertPOLineItemList.add(poline);
									
						//Add Accrual PO Line
						ASI_MFM_PO_Line_Item__c accrualPOLine = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = description, ASI_MFM_Amount__c = poLineItem.ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c = newPO.Id ,
									ASI_MFM_A_C_Code__c = accrualAPCode.ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c = accrualAPCode.Id, ASI_MFM_BU_Code__c = accrualBUCode.Id, 
									recordTypeId = rectypeid, ASI_MFM_G_L_Date__c = poLineItem.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
						
						insertPOLineItemList.add(accrualPOLine);
					}
				}			

				insert insertPOLineItemList;
			} 
			catch (Exception e){
				showError = true;
				ErrorMessage = e.getMessage();
			}
		}
        
        if (!showError){
            return new PageReference('/' + newPO.Id);
        } 
        return null;
    }
	/*[WL 3.0] END*/
}