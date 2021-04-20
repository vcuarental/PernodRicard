/*****************************************************************************************************************
 * Name:        ASI_CRM_CN_VA_CreateVendorFormByRT       
 * Test Class:  ASI_CRM_CN_VA_CreateVendorFormByRTTest
 * Description: CN Vendor Form Detail Page Buttons
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-02-24       Sera Liao               Create
 *****************************************************************************************************************/
global class ASI_CRM_CN_VA_CreateVendorFormByRT {
    webService static String CreateVendorFormByRT(String recordId, String recordName, String rtName) {
    	try {
        String sql = 'SELECT id FROM ASI_eForm_Vendor_Form__c WHERE ASI_CRM_CN_VA_Related_Vendor_Form__r.id =\''+recordId+'\'';
        if(rtName == 'ASI_CRM_CN_VA_Vendor_Form_Revise'){
          sql+=' AND ASI_eForm_Status__c in (\'Draft\',\'Submitted\',\'Rejected\')';
        }
        sql+=' AND RecordType.DeveloperName=\''+rtName+'\'';
        List<ASI_eForm_Vendor_Form__c> vendorFormList = Database.query(sql);
        if(vendorFormList!=null&&vendorFormList.size()>0){
          return JSON.serialize(new Result(true,URL.getSalesforceBaseUrl().toExternalForm()+'/'+vendorFormList[0].id));
        }else{
          Set<String> fieldDeveloperNames = new Set<String>{
          'ASI_CRM_CN_VA_Related_Vendor_Form'
          };
          ASI_eForm_Vendor_Form__c vendorForm = new ASI_eForm_Vendor_Form__c();
          if(rtName == 'ASI_CRM_CN_VA_Vendor_Form_Revise'){
            Set<String> fieldNames = new Set<String>{
              'ASI_CRM_CN_VA_Vendor_Code',
              'ASI_CRM_CN_VA_Effective',
              'ASI_CRM_CN_VA_Company_Name',
              'ASI_CRM_CN_VA_Address',
              'ASI_CRM_CN_VA_Contact_Person',
              'ASI_CRM_CN_VA_Payment_Term',
              'ASI_CRM_CN_VA_Postal_Code',
              'ASI_CRM_CN_VA_Phone_Number',
              'ASI_CRM_CN_VA_Vendor_Form_A1',
              'ASI_CRM_CN_VA_Trans_Bank_Name',
              'ASI_CRM_CN_VA_Trans_Bank_Account',
              'ASI_CRM_CN_VA_Expense_Type'};
            System.debug(LoggingLevel.INFO, '*** fieldNames: ' + fieldNames);
            fieldDeveloperNames.addAll(fieldNames);
            String soqlStr = 'SELECT ';
            for(String fieldName : fieldNames){
              if(!fieldName.contains('ASI_CRM_CN_VA_Ori_')){
                soqlStr += fieldName + '__c, ';
              }
            }
            soqlStr = soqlStr.removeEnd(', ');
            soqlStr += ' FROM ASI_eForm_Vendor_Form__c WHERE Id =\'' + recordId + '\'';
            System.debug(LoggingLevel.INFO, '*** soqlStr: ' + soqlStr);
            List<ASI_eForm_Vendor_Form__c> vendorForms = Database.query(soqlStr);
            vendorForm = vendorForms[0]; 
            System.debug(LoggingLevel.INFO, '*** vendorForm: ' + vendorForm);
          }

          String rtId = Schema.SObjectType.ASI_eForm_Vendor_Form__c.getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();
          String prefix = ASI_eForm_Vendor_Form__c.SobjectType.getDescribe().getKeyPrefix();

          String url = '/' + prefix + '/e?retURL=' + recordId + '&RecordType=' + rtId;

          String relatedFieldId = '';
          List<EntityDefinition> entitys = [SELECT DeveloperName,
                              (SELECT Id, DeveloperName, DurableId 
                              FROM Fields 
                              WHERE DeveloperName IN: fieldDeveloperNames) 
                            FROM EntityDefinition 
                            WHERE DeveloperName = 'ASI_eForm_Vendor_Form'];
          if(entitys.size() > 0 && entitys[0].Fields.size() > 0){
            for(FieldDefinition field : entitys[0].Fields){
              if(field.DeveloperName == 'ASI_CRM_CN_VA_Related_Vendor_Form'){
                url += '&CF' + field.DurableId.substringAfter('.') + '=' + recordName + '&CF' + field.DurableId.substringAfter('.') + '_lkid=' + recordId;
              }else if(field.DeveloperName == 'ASI_CRM_CN_VA_Effective' 
                && null != vendorForm.get(field.DeveloperName + '__c')){
                url += '&CF' + field.DurableId.substringAfter('.') + '=' + vendorForm.get(field.DeveloperName + '__c');
              }else if(field.DeveloperName == 'ASI_CRM_CN_VA_Expense_Type'
                && null != vendorForm.get(field.DeveloperName + '__c')){
                url += '&CF' + field.DurableId.substringAfter('.') + '=' + vendorForm.get(field.DeveloperName + '__c');
              }else if(null != vendorForm.get(field.DeveloperName + '__c')){
                url += '&' + field.DurableId.substringAfter('.') + '=' + vendorForm.get(field.DeveloperName + '__c');
              }
            }
          }
          System.debug(LoggingLevel.INFO, '*** url: ' + url);
          return JSON.serialize(new Result(true, url));
        }
      } catch (Exception e) {
              String message = new CustomerException(e, TRUE).getMessage();
              return JSON.serialize(new Result(false, message));
      }
    }

    private class Result {
		private Boolean isSuccess;
		private String returnMsg;

		private Result(Boolean isSuccess, String returnMsg) {
			this.isSuccess = isSuccess;
			this.returnMsg = returnMsg;
		}
	}

	public class CustomerException extends Exception {

	    public CustomerException (Exception e, Boolean needCustomization) {
	        System.debug(LoggingLevel.INFO, '*** e.getTypeName(): ' + e.getTypeName());
	        System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
	        String message = e.getMessage();

	        if (!needCustomization) {
	            this.setMessage(message);
	        } else {
	            String type = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,';
	            this.setMessage(message);
	        }
	    }
	}
}