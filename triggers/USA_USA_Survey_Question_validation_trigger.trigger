trigger USA_USA_Survey_Question_validation_trigger on USA_Survey_Question__c(before insert,before update) {
    Map<String,Map<String,String>> resultMap = new Map<String,Map<String,String>>();
    Map<String,USA_Data_validation_Utils.Data_validation_Obj> fieldMap = new Map<String,USA_Data_validation_Utils.Data_validation_Obj>();
    USA_Data_validation_Utils.Data_validation_Obj USA_POSSIBLE_VALUES = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_POSSIBLE_VALUES.fieldName = 'USA_POSSIBLE_VALUES__C';
   	USA_POSSIBLE_VALUES.hasId = false;
   	USA_POSSIBLE_VALUES.formatType = 2;
   	USA_POSSIBLE_VALUES.IdFormat = '';
   	USA_POSSIBLE_VALUES.subListSize = 1;
   	USA_POSSIBLE_VALUES.IdIndex = 0;
    USA_POSSIBLE_VALUES.canfix = true;
   	fieldMap.put('USA_POSSIBLE_VALUES__C', USA_POSSIBLE_VALUES);

   	for(USA_Survey_Question__c us: trigger.new){
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