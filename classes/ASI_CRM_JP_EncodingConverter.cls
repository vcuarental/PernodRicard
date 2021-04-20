/**********************************************************************************
 * Name : ASI_CRM_JP_EncodingConverter
 * Created : DC @03/14/2016 11:32 AM
 * Revision History:
 * 1. 03/14/2016 - [DC 1.0] Created
 * 1. 03/15/2016 - [DC 1.1] Moved conversion logic to separate method
 * 1. 03/16/2016 - [DC 1.2] Marked "triggerNew" list as public class level list
 * 1. 03/22/2016 - [DC 1.3] Removed "Postal Code" from conversion
 **********************************************************************************/

public with sharing class ASI_CRM_JP_EncodingConverter extends ASI_CRM_JP_TriggerAbstract {

    /* [DC 1.1] START */
    public List<ASI_CRM_AccountsAdditionalField__c> triggerNew;
    /* [DC 1.1] END */

    public ASI_CRM_JP_EncodingConverter() {
        super('ASI_CRM_JP_EncodingConverter');
    }
    
    public override void executeTriggerAction(
        TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        // Data received from trigger
        triggerNew = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;

        performConversion(triggerNew);

    }

    /* [DC 1.1] START */
    public void performConversion(List<ASI_CRM_AccountsAdditionalField__c> pTriggerNew) {
        
        triggerNew = pTriggerNew;

        ASI_CRM_JP_AsciiToHexConverter encodingConverter;
        // Initializing character width converter
        ASI_CRM_JP_FullWidthToHalfWidth widthConverter = ASI_CRM_JP_FullWidthToHalfWidth.GetInstance();

        // Temporary list for holding unicodes for validation
        List<String> lstPlaceHolder;
        
        for(ASI_CRM_AccountsAdditionalField__c customerIterator : triggerNew) {

            // Initializing decimal to hex converter with "Name" field.
            encodingConverter = new ASI_CRM_JP_AsciiToHexConverter(customerIterator.Name);
            lstPlaceHolder = encodingConverter.convert();

            if(validateInput(lstPlaceHolder) == true) {
                customerIterator.Name = widthConverter.replace(widthConverter.UnicodeToString(lstPlaceHolder));
            }

            // Initializing decimal to hex converter with "Customer Name (Katakana)" field.
            encodingConverter = new ASI_CRM_JP_AsciiToHexConverter(customerIterator.ASI_CRM_Customer_Name_Katakana__c);
            lstPlaceHolder = encodingConverter.convert();

            if(validateInput(lstPlaceHolder) == true) {
                customerIterator.ASI_CRM_Customer_Name_Katakana__c = widthConverter.replace(widthConverter.UnicodeToString(lstPlaceHolder));
            }

            // Initializing decimal to hex converter with "Phone Number" field.
            encodingConverter = new ASI_CRM_JP_AsciiToHexConverter(customerIterator.ASI_CRM_CN_Phone_Number__c);
            lstPlaceHolder = encodingConverter.convert();

            if(validateInput(lstPlaceHolder) == true) {
                customerIterator.ASI_CRM_CN_Phone_Number__c = widthConverter.replace(widthConverter.UnicodeToString(lstPlaceHolder));
            }

            /*
            [DC 1.3] BEGIN
            // Initializing decimal to hex converter with "Postal Code" field.
            encodingConverter = new ASI_CRM_JP_AsciiToHexConverter(customerIterator.ASI_CRM_PostalCode__c);
            lstPlaceHolder = encodingConverter.convert();

            if(validateInput(lstPlaceHolder) == true) {
                customerIterator.ASI_CRM_PostalCode__c = widthConverter.replace(widthConverter.UnicodeToString(lstPlaceHolder));
            }
            [DC 1.3] END
            */

            // Initializing decimal to hex converter with "Address Line 3" field.
            encodingConverter = new ASI_CRM_JP_AsciiToHexConverter(customerIterator.ASI_CRM_Street_Number__c);
            lstPlaceHolder = encodingConverter.convert();

            if(validateInput(lstPlaceHolder) == true) {
                customerIterator.ASI_CRM_Street_Number__c = widthConverter.replace(widthConverter.UnicodeToString(lstPlaceHolder));
            }

            // Initializing decimal to hex converter with "Address Line 4" field.
            encodingConverter = new ASI_CRM_JP_AsciiToHexConverter(customerIterator.ASI_CRM_Building_Floor_Number__c);
            lstPlaceHolder = encodingConverter.convert();

            if(validateInput(lstPlaceHolder) == true) {
                customerIterator.ASI_CRM_Building_Floor_Number__c = widthConverter.replace(widthConverter.UnicodeToString(lstPlaceHolder));
            }

        }
    }
    /* [DC 1.1] END */

    // Checking if the input provided is valid.
    private Boolean validateInput(List<String> pLstPlaceHolder) {

        if(pLstPlaceHolder.size() == 1 && pLstPlaceHolder[0] == ASI_CRM_JP_AsciiToHexConverter.ERROR_STRING) {
            return false;
        } else if(!pLstPlaceHolder.isEmpty()) {
            return true;
        }

        return false;
    }
    
}