public class ASI_eForm_KR_LE_settingExternalID
{
    private final String externalIDField = 'ASI_eForm_externalID__c';
    private final String yearField = 'ASI_eform_Year__c';
    private final String employeeIDField = 'ASI_eForm_Employee_Record__c';
    private String yearFieldValue;
    private String employeeIDFieldValue;
    private String fieldValue;
	public void setExternalID(list<ASI_eForm_KR_Leave_EE__c> Trigger_New)
    {
        Map<ID,ASI_eForm_HR_MDM__c> mapID = new Map<ID,ASI_eForm_HR_MDM__c>([SELECT ID,Name From ASI_eForm_HR_MDM__c]);
        
        for(ASI_eForm_KR_Leave_EE__c entitlementForm : Trigger_New){
            //getting year value and change it to string
            yearFieldValue = String.valueOf(entitlementForm.get(yearField));
            //getting local employee id and change it to string
            employeeIDFieldValue = mapID.get(entitlementForm.ASI_eForm_Employee_Record__c).Name;
            if(!yearFieldValue.equalsIgnoreCase('null'))
            {
            	//add two string together and let it be a external id
            	fieldValue = yearFieldValue + employeeIDFieldValue;
            	//put the value to the external id field
            	entitlementForm.put(externalIDField, fieldValue);
            }
            else
                if(!Test.isRunningTest())
                	entitlementForm.addError('Please enter the Year.');
        }//end for loop
    }
}