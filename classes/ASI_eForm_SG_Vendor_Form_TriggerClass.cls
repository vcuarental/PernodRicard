/*********************************************************************************
 * Name:ASI_eForm_SG_Vendor_Form_TriggerClass 
 * Test Class: ASI_eForm_SG_VendorForm_TriggerTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-28       Wilken Lee              Created
*********************************************************************************/

public class ASI_eForm_SG_Vendor_Form_TriggerClass{
    public static void duplicateBRNumberCheck(List<ASI_eForm_Vendor_Form__c> vFormList , Map<ID, ASI_eForm_Vendor_Form__c> oldMap) {
		List<ASI_eForm_Vendor_Form__c> vFormToCheck = new List<ASI_eForm_Vendor_Form__c>();
		Set<String> bizRegNumSet = new Set<String>();
		
		for (ASI_eForm_Vendor_Form__c vForm : vFormList ){
			if (((oldMap != null && vForm.ASI_eForm_Biz_Registration_No__c != oldMap.get(vForm.Id).ASI_eForm_Biz_Registration_No__c) 
				|| oldMap == null) && Global_RecordTypeCache.getRt(vForm.recordTypeID).DeveloperName.contains('ASI_eForm_SG_Vendor_Form_New')
			){
				vFormToCheck.add(vForm);
				bizRegNumSet.add(vForm.ASI_eForm_Biz_Registration_No__c);
			}
		}
		
		if (vFormToCheck.size() > 0){
			List<ASI_eForm_Vendor_Form__c> existingvFormList = [select Id, Name, ASI_eForm_Status__c, ASI_eForm_Biz_Registration_No_Latest__c, ASI_eForm_Biz_Registration_No__c from  ASI_eForm_Vendor_Form__c 
				where (ASI_eForm_Biz_Registration_No_Latest__c in :bizRegNumSet or ASI_eForm_Biz_Registration_No__c in :bizRegNumSet) and recordType.DeveloperName like 'ASI_eForm_SG_Vendor_Form_New%'];
			
			for (ASI_eForm_Vendor_Form__c v:vFormToCheck){
				for (ASI_eForm_Vendor_Form__c existForm:existingvFormList){
					if (
						(
							(existForm.ASI_eForm_Status__c == 'Completed' && v.ASI_eForm_Biz_Registration_No__c == existForm.ASI_eForm_Biz_Registration_No_Latest__c)
							||
							(existForm.ASI_eForm_Status__c != 'Completed' && v.ASI_eForm_Biz_Registration_No__c == existForm.ASI_eForm_Biz_Registration_No__c)
						) 
						&& v.Id != existForm.Id
					)
						v.addError('Duplicated Business Registration Number ' + v.ASI_eForm_Biz_Registration_No__c + ' with Vendor Form ' + existForm.Name);
				}
			}
		}
	}
	
	public static void prefillReviseInformation(List<ASI_eForm_Vendor_Form__c> vFormList , Map<ID, ASI_eForm_Vendor_Form__c> oldMap) {
		Set<Id> reviseFromID = new Set<Id>();
		Map<Id, ASI_eForm_Vendor_Form__c> originalFormMap = new Map<Id, ASI_eForm_Vendor_Form__c>();
		
		for (ASI_eForm_Vendor_Form__c vForm : vFormList ){
			reviseFromID.add(vForm.ASI_eForm_Original_Vendor_Form__c);
		}
		
		if (reviseFromID != null){
			for (ASI_eForm_Vendor_Form__c vForm:[select Id, 
												ASI_eForm_Vendor_Account_Number__c,
												
												ASI_eForm_Company_Name_Latest__c, 
												ASI_eForm_Biz_Registration_No_Latest__c,
												ASI_eForm_Contact_Person_Latest__c, 
												ASI_eForm_Tel_Number_Latest__c, 
												ASI_eForm_Fax_Number_Latest__c, 
												
												ASI_eForm_Bank_Branch_1_Latest__c,
												ASI_eForm_Bank_Account_Number_1_Latest__c,
												ASI_eForm_SWIFT_Code_1_Latest__c,
												
												ASI_eForm_Address_Line_1__c,
												ASI_eForm_Address_Line_2__c,
												ASI_eForm_Address_Line_3__c,
												ASI_eForm_Market_Created_For__c,
												
												ASI_eForm_Payee_Name__c,
												ASI_eForm_Bankers_1__c, 
												ASI_eForm_Email__c, 
												ASI_eForm_Business_Type__c 
													FROM ASI_eForm_Vendor_Form__c where Id in :reviseFromID]){
				originalFormMap.put(vForm.Id, vForm);
			}
		}
			
		for (ASI_eForm_Vendor_Form__c vForm : vFormList ){
            if (Global_RecordTypeCache.getRt(oldMap.get(vForm.Id).recordTypeId).DeveloperName == 'ASI_eForm_SG_Vendor_Form_Revise' &&
				Global_RecordTypeCache.getRt(vForm.recordTypeId).DeveloperName == 'ASI_eForm_SG_Vendor_Form_Revise_All'){
				if (originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c) != null){				
					//Latst Field from JDE
					vForm.ASI_eForm_Company_Name_Text__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Company_Name_Latest__c;
					vForm.ASI_eForm_Biz_Registration_No__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Biz_Registration_No_Latest__c;
					
					vForm.ASI_eForm_Contact_Person__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Contact_Person_Latest__c;
					vForm.ASI_eForm_Fax_Number__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Fax_Number_Latest__c;
					vForm.ASI_eForm_Tel_Number__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Tel_Number_Latest__c;
					
					vForm.ASI_eForm_Bank_Branch_1__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Bank_Branch_1_Latest__c;
					vForm.ASI_eForm_Bank_Account_Number_1__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Bank_Account_Number_1_Latest__c;
					vForm.ASI_eForm_SWIFT_Code_1__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_SWIFT_Code_1_Latest__c;
					
					vForm.ASI_eForm_Address_Line_1__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Address_Line_1__c;
					vForm.ASI_eForm_Address_Line_2__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Address_Line_2__c;
					vForm.ASI_eForm_Address_Line_3__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Address_Line_3__c;
					vForm.ASI_eForm_Market_Created_For__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Market_Created_For__c;
					
					//Non-Latest field from Original Vendor Form
					vForm.ASI_eForm_Vendor_Account_Number__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Vendor_Account_Number__c;
					vForm.ASI_eForm_Payee_Name__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Payee_Name__c;
					vForm.ASI_eForm_Business_Type__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Business_Type__c;
					vForm.ASI_eForm_Email__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Email__c;
					vForm.ASI_eForm_Bankers_1__c = originalFormMap.get(vForm.ASI_eForm_Original_Vendor_Form__c).ASI_eForm_Bankers_1__c;
				}
			}			
        }
	}
	
    public static void retrieveExchangeRate(List<ASI_eForm_Vendor_Form__c> vFormList , Map<ID, ASI_eForm_Vendor_Form__c> oldMap) {
        List<String> currencyList = new List<String>();
        
        for (ASI_eForm_Vendor_Form__c vForm : vFormList ){
            currencyList.add(vForm.ASI_eForm_Currency__c);                        
        }
        
        List<ASI_MFM_Exchange_Rate__c> exRateList = [select id, ASI_MFM_Exchange_Rate__c, ASI_MFM_Counter_Currency__c from ASI_MFM_Exchange_Rate__c 
                                                    where ASI_MFM_Country__c = 'SG' and ASI_MFM_Effective_Date__c <= :System.Today() and ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c = 'SGD'
                                                    and ASI_MFM_Counter_Currency__c in :currencyList order by ASI_MFM_Effective_Date__c desc];
        
        for (ASI_eForm_Vendor_Form__c vForm : vFormList ){
            if (oldMap == null || vForm.ASI_eForm_Currency__c != oldMap.get(vForm.Id).ASI_eForm_Currency__c)
                for (ASI_MFM_Exchange_Rate__c exRate:exRateList){
                    if (exRate.ASI_MFM_Counter_Currency__c == vForm.ASI_eForm_Currency__c){
                        vForm.ASI_eForm_Exchange_Rate__c = exRate.ASI_MFM_Exchange_Rate__c;
                        break;
                    }                   
                }
        }       
    }
    
    public static void validationBeforeDelete(List<ASI_eForm_Vendor_Form__c> vFormList) {
        for (ASI_eForm_Vendor_Form__c vForm : vFormList ){
            if (vForm.ASI_eForm_Status__c != 'Draft' && vForm.ASI_eForm_Status__c != 'Rejected')
                vForm.addError('Only Draft or Rejected Vendor Form can be deleted');
        }
    }
    
    public static void assignHODApproval(List<ASI_eForm_Vendor_Form__c> vFormList , Map<ID, ASI_eForm_Vendor_Form__c> oldMap) {
        String environment;
        if (UserInfo.getUserName().substringAfterLast('.com')!= null)
            environment = UserInfo.getUserName().substringAfterLast('.');
        else
            environment = 'Production';     

        List<ASI_eForm_SG_HOD_Approver__mdt> approverList = [Select Label, ASI_CRM_HOD_Username__c From ASI_eForm_SG_HOD_Approver__mdt];
        Map<String, String> deptUsernameMap = new Map<String, String>(); 
        Set<String> userNameSet = new Set<String>();
        
        for (ASI_eForm_SG_HOD_Approver__mdt approver:approverList){
            if (environment == 'Production'){
                deptUsernameMap.put(approver.Label, approver.ASI_CRM_HOD_Username__c);
                userNameSet.add(approver.ASI_CRM_HOD_Username__c);
            }
            else { 
                deptUsernameMap.put(approver.Label, approver.ASI_CRM_HOD_Username__c + '.' + environment);
                userNameSet.add(approver.ASI_CRM_HOD_Username__c + '.' + environment);
            }
        }
        
        Map<String, Id> userIdMap = new Map<String, Id>(); 
        for(User u : [Select userName, Id From User Where userName in :userNameSet])
            userIdMap.put(u.userName, u.Id);
        
        for (ASI_eForm_Vendor_Form__c vForm : vFormList ){
            System.debug('vForm.ASI_eForm_Owner_Department__c: '+ vForm.ASI_eForm_Owner_Department__c+',deptUsernameMap.get(vForm.ASI_eForm_Owner_Department__c): '+ deptUsernameMap.get(vForm.ASI_eForm_Owner_Department__c));
            System.debug('userIdMap.get(deptUsernameMap.get(vForm.ASI_eForm_Owner_Department__c))'+ userIdMap.get(deptUsernameMap.get(vForm.ASI_eForm_Owner_Department__c)));
			if (approverList.size() > 0){
				if (deptUsernameMap.get(vForm.ASI_eForm_Owner_Department__c) != null && userIdMap.get(deptUsernameMap.get(vForm.ASI_eForm_Owner_Department__c)) != null)
					vForm.ASI_eForm_Head_of_Department__c = userIdMap.get(deptUsernameMap.get(vForm.ASI_eForm_Owner_Department__c));
				else 
					vForm.addError('Cannot obtain Head of Department approver, please contact system administrator');
            }
			 
            if (oldMap.get(vForm.Id).ASI_eForm_Requires_HOD_Approval__c == false){
                if ((vForm.ASI_eForm_Type_Of_Goods__c == 'Marketing' || vForm.ASI_eForm_Type_Of_Goods__c == 'Sales')
                    && vForm.ASI_eForm_SGD_Equiviaent_Value__c > 16000 && vForm.ASI_eForm_Number_of_Quotation__c < 3)
                    vForm.ASI_eForm_Requires_HOD_Approval__c = true;
                else if (vForm.ASI_eForm_Type_Of_Goods__c == 'Admin' && vForm.ASI_eForm_SGD_Equiviaent_Value__c > 7000 && vForm.ASI_eForm_Number_of_Quotation__c < 3)
                    vForm.ASI_eForm_Requires_HOD_Approval__c = true;
            }
            else {
				User u = [select Department from User where Id = :UserInfo.getUserId() limit 1];
				Boolean isFinanceUser =  false;
				
				if (u.Department != null && u.Department.contains('Finance'))
					isFinanceUser = true;
				
				system.debug('isFinanceUser: ' + isFinanceUser);
				
                if ((vForm.ASI_eForm_Type_Of_Goods__c == 'Marketing' || vForm.ASI_eForm_Type_Of_Goods__c == 'Sales')
                    && vForm.ASI_eForm_SGD_Equiviaent_Value__c <= 16000 || vForm.ASI_eForm_Number_of_Quotation__c >= 3)
                    vForm.ASI_eForm_Requires_HOD_Approval__c = false;
                else if (vForm.ASI_eForm_Type_Of_Goods__c == 'Admin' && (vForm.ASI_eForm_SGD_Equiviaent_Value__c <= 7000 || vForm.ASI_eForm_Number_of_Quotation__c >= 3))
                    vForm.ASI_eForm_Requires_HOD_Approval__c = false;
				else if (vForm.ASI_eForm_Requires_HOD_Approval__c == false && !isFinanceUser)
					vForm.addError('Please contact Finance team to skip Head of Department approval');
            }
			
			//Check Overseas Vendor Form Vendor Account Number
			if (oldMap != null && oldMap.get(vForm.Id).ASI_eForm_Status__c == 'Submitted' && vForm.ASI_eForm_Status__c == 'Final' &&
				vForm.ASI_eForm_Supplier_Country_of_Operation__c == 'B' && vForm.ASI_eForm_Vendor_Account_Number__c == null)
					vForm.addError('Please assign Vendor Address Number for Overseas Supplier');
        }       
    }
}