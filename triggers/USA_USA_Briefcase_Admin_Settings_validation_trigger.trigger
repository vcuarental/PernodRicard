trigger USA_USA_Briefcase_Admin_Settings_validation_trigger on USA_Briefcase_Admin_Settings__c(before insert,before update) {
    Map<String,Map<String,String>> resultMap = new Map<String,Map<String,String>>();
     Map<String,USA_Data_validation_Utils.Data_validation_Obj> fieldMap = new Map<String,USA_Data_validation_Utils.Data_validation_Obj>();
    USA_Data_validation_Utils.Data_validation_Obj MAP_SUBTIER_FILTERS = new USA_Data_validation_Utils.Data_validation_Obj();
   	MAP_SUBTIER_FILTERS.fieldName = 'MAP_SUBTIER_FILTERS__C';
   	MAP_SUBTIER_FILTERS.hasId = false;
   	MAP_SUBTIER_FILTERS.formatType = 1;
   	MAP_SUBTIER_FILTERS.IdFormat = '';
   	MAP_SUBTIER_FILTERS.subListSize = 1;
   	MAP_SUBTIER_FILTERS.IdIndex = 0;
      MAP_SUBTIER_FILTERS.canfix = true;
   	fieldMap.put('MAP_SUBTIER_FILTERS__C', MAP_SUBTIER_FILTERS);

   	USA_Data_validation_Utils.Data_validation_Obj MAP_TIER_FILTERS = new USA_Data_validation_Utils.Data_validation_Obj();
   	MAP_TIER_FILTERS.fieldName = 'MAP_TIER_FILTERS__C';
   	MAP_TIER_FILTERS.hasId = false;
   	MAP_TIER_FILTERS.formatType = 1;
   	MAP_TIER_FILTERS.IdFormat = '';
   	MAP_TIER_FILTERS.subListSize = 1;
   	MAP_TIER_FILTERS.IdIndex = 0;
      MAP_TIER_FILTERS.canfix = true;
   	fieldMap.put('MAP_TIER_FILTERS__C', MAP_TIER_FILTERS);

   	USA_Data_validation_Utils.Data_validation_Obj MAP_WINES_SUBTIER_FILTERS = new USA_Data_validation_Utils.Data_validation_Obj();
   	MAP_WINES_SUBTIER_FILTERS.fieldName = 'MAP_WINES_SUBTIER_FILTERS__C';
   	MAP_WINES_SUBTIER_FILTERS.hasId = false;
   	MAP_WINES_SUBTIER_FILTERS.formatType = 1;
   	MAP_WINES_SUBTIER_FILTERS.IdFormat = '';
   	MAP_WINES_SUBTIER_FILTERS.subListSize = 1;
      MAP_WINES_SUBTIER_FILTERS.IdIndex = 0;
   	MAP_WINES_SUBTIER_FILTERS.canfix = true;
   	fieldMap.put('MAP_WINES_SUBTIER_FILTERS__C', MAP_WINES_SUBTIER_FILTERS);

   	USA_Data_validation_Utils.Data_validation_Obj GLOBAL_CHATTER_GROUPS = new USA_Data_validation_Utils.Data_validation_Obj();
   	GLOBAL_CHATTER_GROUPS.fieldName = 'GLOBAL_CHATTER_GROUPS__C';
   	GLOBAL_CHATTER_GROUPS.hasId = true;
   	GLOBAL_CHATTER_GROUPS.formatType = 3;
   	GLOBAL_CHATTER_GROUPS.IdFormat = '0F9Dxxxxxxxxxxx';
   	GLOBAL_CHATTER_GROUPS.subListSize = 2;
      GLOBAL_CHATTER_GROUPS.IdIndex = 2;
   	GLOBAL_CHATTER_GROUPS.canfix = false;

   	fieldMap.put('GLOBAL_CHATTER_GROUPS__C', GLOBAL_CHATTER_GROUPS);

   	USA_Data_validation_Utils.Data_validation_Obj MAP_REP_FILTERS = new USA_Data_validation_Utils.Data_validation_Obj();
   	MAP_REP_FILTERS.fieldName = 'MAP_REP_FILTERS__C';
   	MAP_REP_FILTERS.hasId = true;
   	MAP_REP_FILTERS.formatType = 4;
   	MAP_REP_FILTERS.IdFormat = '005Dxxxxxxxxxxxxxx';
   	MAP_REP_FILTERS.subListSize = 2;
      MAP_REP_FILTERS.IdIndex = 2;
   	MAP_REP_FILTERS.canfix = false;
   	fieldMap.put('MAP_REP_FILTERS__C', MAP_REP_FILTERS);

    //   USA_Data_validation_Utils.Data_validation_Obj REPORT_IDS = new USA_Data_validation_Utils.Data_validation_Obj();
    //   REPORT_IDS.fieldName = 'REPORT_IDS__C';
    //   REPORT_IDS.hasId = true;
    //   REPORT_IDS.formatType = 1;
    //   REPORT_IDS.IdFormat = '00ODxxxxxxxxxxx';
    //   REPORT_IDS.subListSize = 1;
    //   REPORT_IDS.IdIndex = 1;
    //   REPORT_IDS.canfix = false;
    //   fieldMap.put('REPORT_IDS__C', REPORT_IDS);


    //   //cause formula Field 'REPORT_IDS__C' has a reference to Field 'GLOBAL_REPORT_IDS__C' 
   	// USA_Data_validation_Utils.Data_validation_Obj GLOBAL_REPORT_IDS = new USA_Data_validation_Utils.Data_validation_Obj();
   	// GLOBAL_REPORT_IDS.fieldName = 'GLOBAL_REPORT_IDS__C';
   	// GLOBAL_REPORT_IDS.hasId = true;
   	// GLOBAL_REPORT_IDS.formatType = 1;
   	// GLOBAL_REPORT_IDS.IdFormat = '00ODxxxxxxxxxxx';
   	// GLOBAL_REPORT_IDS.subListSize = 1;
    //   GLOBAL_REPORT_IDS.IdIndex = 1;
   	// GLOBAL_REPORT_IDS.canfix = false;
   	// fieldMap.put('GLOBAL_REPORT_IDS__C', GLOBAL_REPORT_IDS);

   	

   	USA_Data_validation_Utils.Data_validation_Obj TO_DO_CATEGORIES = new USA_Data_validation_Utils.Data_validation_Obj();
   	TO_DO_CATEGORIES.fieldName = 'TO_DO_CATEGORIES__C';
   	TO_DO_CATEGORIES.hasId = false;
   	TO_DO_CATEGORIES.formatType = 1;
   	TO_DO_CATEGORIES.IdFormat = '';
   	TO_DO_CATEGORIES.subListSize = 1;
      TO_DO_CATEGORIES.IdIndex = 0;
   	TO_DO_CATEGORIES.canfix = true;
   	fieldMap.put('TO_DO_CATEGORIES__C', TO_DO_CATEGORIES);

   	USA_Data_validation_Utils.Data_validation_Obj CHAIN_NAMES = new USA_Data_validation_Utils.Data_validation_Obj();
   	CHAIN_NAMES.fieldName = 'CHAIN_NAMES__C';
   	CHAIN_NAMES.hasId = false;
   	CHAIN_NAMES.formatType = 1;
   	CHAIN_NAMES.IdFormat = '';
   	CHAIN_NAMES.subListSize = 1;
      CHAIN_NAMES.IdIndex = 0;
   	CHAIN_NAMES.canfix = true;
   	fieldMap.put('CHAIN_NAMES__C', CHAIN_NAMES);

   	USA_Data_validation_Utils.Data_validation_Obj MANAGERS = new USA_Data_validation_Utils.Data_validation_Obj();
   	MANAGERS.fieldName = 'MANAGERS__C';
   	MANAGERS.hasId = true;
   	MANAGERS.formatType = 4;
   	MANAGERS.IdFormat = '005Dxxxxxxxxxxxxxx';
   	MANAGERS.subListSize = 2;
      MANAGERS.IdIndex = 2;
   	MANAGERS.canfix = false;
   	fieldMap.put('MANAGERS__C', MANAGERS);

   	USA_Data_validation_Utils.Data_validation_Obj MAP_WINES_TIER_FILTERS = new USA_Data_validation_Utils.Data_validation_Obj();
   	MAP_WINES_TIER_FILTERS.fieldName = 'MAP_WINES_TIER_FILTERS__C';
   	MAP_WINES_TIER_FILTERS.hasId = false;
   	MAP_WINES_TIER_FILTERS.formatType = 1;
   	MAP_WINES_TIER_FILTERS.IdFormat = '';
   	MAP_WINES_TIER_FILTERS.subListSize = 1;
      MAP_WINES_TIER_FILTERS.IdIndex = 0;
   	MAP_WINES_TIER_FILTERS.canfix = true;
   	fieldMap.put('MAP_WINES_TIER_FILTERS__C', MAP_WINES_TIER_FILTERS);

   	USA_Data_validation_Utils.Data_validation_Obj REPORT_NAMES = new USA_Data_validation_Utils.Data_validation_Obj();
   	REPORT_NAMES.fieldName = 'REPORT_NAMES__C';
   	REPORT_NAMES.hasId = false;
   	REPORT_NAMES.formatType = 1;
   	REPORT_NAMES.IdFormat = '';
   	REPORT_NAMES.subListSize = 1;
      REPORT_NAMES.IdIndex = 0;
   	REPORT_NAMES.canfix = true;
   	fieldMap.put('REPORT_NAMES__C', REPORT_NAMES);

      System.debug('trigger.old:'+trigger.old);
      System.debug('trigger.new:'+trigger.new);
   	for(USA_Briefcase_Admin_Settings__c us: trigger.new){


      try{
      	resultMap = USA_Data_validation_Utils.dataMapCreate(us,fieldMap);
      	for(String str : resultMap.keySet()){
      		USA_Data_validation_Utils.data_handle(us,str,resultMap);
      	}
      }catch(Exception e){
          us.addError('Exception Message:'+e.getMessage()+'\n'+e.getStackTraceString());
      }
    }
}