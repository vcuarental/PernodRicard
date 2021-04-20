/*********************************************************************************
 * Name: ASI_CRM_JP_EncodingConverterHelper
 * Description: Converter for jp text encoding(Clone some logic from ASI_CRM_JP_EncodingConverter)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/02/2017       Hugo Cheung             Created          
*/
public with sharing class ASI_CRM_JP_EncodingConverterHelper extends ASI_CRM_JP_TriggerAbstract {

	private Set<String> convertFieldSet;

	public ASI_CRM_JP_EncodingConverterHelper(Set<String> convertFieldSet) {
		super('ASI_CRM_JP_EncodingConverterHelper');

		this.convertFieldSet = convertFieldSet;
	}

	public override void executeTriggerAction(
        TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        performConversion(sObjList);
    }

    public void performConversion(List<sObject> sObjList) {
        ASI_CRM_JP_FullWidthToHalfWidth widthConverter = ASI_CRM_JP_FullWidthToHalfWidth.GetInstance();
        for(sObject sObj : sObjList) {
        	for(String convertField : convertFieldSet) {
        		Object fieldValue = sObj.get(convertField);
        		if(fieldValue instanceof String) {
        			ASI_CRM_JP_AsciiToHexConverter encodingConverter = new ASI_CRM_JP_AsciiToHexConverter((String) fieldValue);
	        		List<String> lstPlaceHolder = encodingConverter.convert();

	        		if(validateInput(lstPlaceHolder) == true) {
	        			sObj.put(convertField, widthConverter.replace(widthConverter.UnicodeToString(lstPlaceHolder)));
	        		}
        		}
        	}
        }
    }

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