trigger USA_BriefcaseSurvey_validation_trigger on USA_Survey__c(before insert,before update) {
	Map<String,Map<String,String>> resultMap = new Map<String,Map<String,String>>();
	Map<String,USA_Data_validation_Utils.Data_validation_Obj> fieldMap = new Map<String,USA_Data_validation_Utils.Data_validation_Obj>();
    USA_Data_validation_Utils.Data_validation_Obj USA_MARKET = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_MARKET.fieldName = 'USA_MARKET__C';
   	USA_MARKET.hasId = false;
   	USA_MARKET.formatType = 1;
   	USA_MARKET.IdFormat = '';
   	USA_MARKET.subListSize = 1;
      USA_MARKET.IdIndex = 0;
   	USA_MARKET.canfix = true;
   	fieldMap.put('USA_MARKET__C', USA_MARKET);

   	USA_Data_validation_Utils.Data_validation_Obj USA_NATIONAL_ID = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_NATIONAL_ID.fieldName = 'USA_NATIONAL_ID__C';
   	USA_NATIONAL_ID.hasId = false;
   	USA_NATIONAL_ID.formatType = 1;
   	USA_NATIONAL_ID.IdFormat = '';
   	USA_NATIONAL_ID.subListSize = 1;
      USA_NATIONAL_ID.IdIndex = 0;
   	USA_NATIONAL_ID.canfix = true;
   	fieldMap.put('USA_NATIONAL_ID__C', USA_NATIONAL_ID);

   	USA_Data_validation_Utils.Data_validation_Obj USA_SUB_TIER = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_SUB_TIER.fieldName = 'USA_SUB_TIER__C';
   	USA_SUB_TIER.hasId = false;
   	USA_SUB_TIER.formatType = 1;
   	USA_SUB_TIER.IdFormat = '';
   	USA_SUB_TIER.subListSize = 1;
      USA_SUB_TIER.IdIndex = 0;
   	USA_SUB_TIER.canfix = true;
   	fieldMap.put('USA_SUB_TIER__C', USA_SUB_TIER);

   	USA_Data_validation_Utils.Data_validation_Obj USA_TD_LINX_ID = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_TD_LINX_ID.fieldName = 'USA_TD_LINX_ID__C';
   	USA_TD_LINX_ID.hasId = false;
   	USA_TD_LINX_ID.formatType = 1;
   	USA_TD_LINX_ID.IdFormat = '';
   	USA_TD_LINX_ID.subListSize = 1;
      USA_TD_LINX_ID.IdIndex = 0;
   	USA_TD_LINX_ID.canfix = true;
   	fieldMap.put('USA_TD_LINX_ID__C', USA_TD_LINX_ID);

   	USA_Data_validation_Utils.Data_validation_Obj USA_TIER = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_TIER.fieldName = 'USA_TIER__C';
   	USA_TIER.hasId = false;
   	USA_TIER.formatType = 1;
   	USA_TIER.IdFormat = '';
   	USA_TIER.subListSize = 1;
      USA_TIER.IdIndex = 0;
   	USA_TIER.canfix = true;
   	fieldMap.put('USA_TIER__C', USA_TIER);

   	for(USA_Survey__c us: trigger.new){
   		try{
   			resultMap = USA_Data_validation_Utils.dataMapCreate(us,fieldMap);
	    	for(String str : resultMap.keySet()){
	    		USA_Data_validation_Utils.data_handle(us,str,resultMap);
	    	}
   		}catch(Exception e){
   			us.addError('Exception Message:'+e.getMessage());
   		}
    	

    }

}