public class ASI_eForm_KR_Vendor_Form_TriggerClass {
    public static final string DEFAULT_COUNTRY_CODE = 'KR-KOREA';
	
	public static void routineBeforeUpsert(List<ASI_eForm_Vendor_Form__c> triggerNew, Map<Id, ASI_eForm_Vendor_Form__c> triggerOldMap) {
        Set<Id> OwnerIdSet = New Set<Id>();
        Map<String,ASI_eForm_HR_MDM__c> MDMMap= new Map<String,ASI_eForm_HR_MDM__c> ();
        Map<Id,User> UserMap = new Map<Id,User>();
        Set<Id> SupplierIdSet = new Set<Id>();
        Map<ID, Account> SupplierMap   = new Map<ID,Account> ();
        List<ASI_CRM_Field_Mapping__mdt> FieldMappingList  = new List<ASI_CRM_Field_Mapping__mdt>();
        
        
        for(ASI_eForm_Vendor_Form__c obj : triggerNew){
            OwnerIdSet.add(obj.OwnerId);
            if(obj.ASI_eForm_Supplier__c!=null ){
                SupplierIdSet.add(obj.ASI_eForm_Supplier__c);
            }
        }
        
        if(OwnerIdSet.size()>0){
            Set<String> UserEmailSet = new Set<String>();
            List<User> UserList= [select Id,Email,username,ASI_MFM_Team__c,managerId from User where Id in : OwnerIdSet and ASI_MFM_Team__c!=null ];
            for(User u : UserList){
                UserMap.put(u.Id,u);
                UserEmailSet.add(u.username);
            }
            List<ASI_eForm_HR_MDM__c> ListOfMDM = [select id,ASI_eForm_Employee_Work_Email__c,ASI_eForm_Employee_Job_Title__c,ASI_eForm_Employee_Branch_Code__c 
                                                   from ASI_eForm_HR_MDM__c 
                                                   where ASI_eForm_Employee_Work_Email__c in : UserEmailSet and ASI_eForm_Employee_Work_Email__c!=null ];
            
            for(ASI_eForm_HR_MDM__c mdm :ListOfMDM ){
                MDMMap.put(mdm.ASI_eForm_Employee_Work_Email__c, mdm);
            }
            
        }
        
        
        if(SupplierIdSet.size()>0){
            SupplierMap= new Map<ID,Account>([SELECT ID, Name,ASI_MFM_Customer_Supplier_Name__c,CurrencyIsoCode,ASI_MFM_Address_Line_1__c,ASI_MFM_Zip_Code__c,ASI_LUX_Email_Business__c, ASI_MFM_Customer_Supplier_Number__c, 
                                              ASI_KOR_Venue_Business_License_Number__c,ASI_KOR_Venue_Owner_1__c,ASI_MFM_Address_Line_4__c,ASI_MFM_Address_Line_3__c,ASI_KOR_Wholesaler_Bank__c,Phone,
                                              ASI_KOR_Wholesaler_Bank_Account_Num__c, Bank_account_type_JDE__c,ASI_MFM_Site_Code__c,ASI_MFM_Payment_Terms__c, ASI_HK_CRM_Payment_Term_Code__c, ASI_MFM_Country_Code__c
                                              FROM Account WHERE Id in : SupplierIdSet]);
            FieldMappingList = [select id,ASI_CRM_To_Field_Name__c,ASI_CRM_From_Field_Name__c  from ASI_CRM_Field_Mapping__mdt where ACI_CRM_Application__c='KR_Vendor_Forms'];
            
            
            
        }
        
		Map<String, String> map_countryCode = getPickListValuesIntoMap();
        for(ASI_eForm_Vendor_Form__c obj : triggerNew){
            if(obj.ASI_eForm_Supplier__c!=null){
                if(SupplierMap.containsKey(obj.ASI_eForm_Supplier__c)){
                    
                    obj= FieldAssignment(obj, FieldMappingList , SupplierMap.get(obj.ASI_eForm_Supplier__c));
                    if(SupplierMap.get(obj.ASI_eForm_Supplier__c).get('ASI_KOR_Venue_Business_License_Number__c')!=null){
                        String BusinessLicenseNumber= String.valueOf(SupplierMap.get(obj.ASI_eForm_Supplier__c).get('ASI_KOR_Venue_Business_License_Number__c')) ;
                        if(BusinessLicenseNumber.length() == 10){
                            obj.ASI_eForm_Individual_Corporate__c ='Corporate';
                        }else
						if(BusinessLicenseNumber.length() == 7 && BusinessLicenseNumber.startsWith('690')){
                            obj.ASI_eForm_Individual_Corporate__c ='Intercompany';
                        }else
						if(BusinessLicenseNumber.length() == 7 && BusinessLicenseNumber.startsWith('680')){
                            obj.ASI_eForm_Individual_Corporate__c ='Foreign';
                        }else
						if(BusinessLicenseNumber.length() == 6){
                            obj.ASI_eForm_Individual_Corporate__c ='Individual';
                        }else{
                            obj.ASI_eForm_Individual_Corporate__c ='';
                        }
                    }
                    if(SupplierMap.get(obj.ASI_eForm_Supplier__c).get('ASI_MFM_Country_Code__c')!=null){
                        String countryCode= String.valueOf(SupplierMap.get(obj.ASI_eForm_Supplier__c).get('ASI_MFM_Country_Code__c')) ;
                        if(map_countryCode.containsKey(countryCode)){
                            obj.ASI_eForm_Country__c =map_countryCode.get(countryCode);
                        }else{
							obj.ASI_eForm_Country__c = DEFAULT_COUNTRY_CODE;
						}
                    }else{
						obj.ASI_eForm_Country__c = DEFAULT_COUNTRY_CODE;
					}
                }
            }
            
            if(UserMap.containsKey(obj.OwnerId) ){
                if(MDMMap.containsKey(UserMap.get(obj.OwnerId).username)){
                    obj.ASI_eForm_Job_Title__c = MDMMap.get(UserMap.get(obj.OwnerId).username).ASI_eForm_Employee_Job_Title__c;
                    obj.ASI_eForm_Branch_Code__c = MDMMap.get(UserMap.get(obj.OwnerId).username).ASI_eForm_Employee_Branch_Code__c;
                }
                obj.ASI_eForm_Sys_Approver_1__c = UserMap.get(obj.OwnerId).managerId;
            }
        }
        
        
    }
    
    
    Public static ASI_eForm_Vendor_Form__c FieldAssignment(ASI_eForm_Vendor_Form__c InputVendorForm, List<ASI_CRM_Field_Mapping__mdt> FieldMappingLists, Account Supplier){
        for(ASI_CRM_Field_Mapping__mdt FieldMapping:FieldMappingLists ){
            InputVendorForm.put(FieldMapping.ASI_CRM_To_Field_Name__c , Supplier.get(FieldMapping.ASI_CRM_From_Field_Name__c));
        }
        
        return InputVendorForm;
    }
    
    public static Map<String, String> getPickListValuesIntoMap(){
       Map<String, String> pickListValuesMap= new Map<String, String>();
		Schema.DescribeFieldResult fieldResult = ASI_eForm_Vendor_Form__c.ASI_eForm_Country__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			string full = pickListVal.getLabel();
			string code = full.substring(0,1);
			pickListValuesMap.put(code,full);
		}     
		return pickListValuesMap;
    }
}