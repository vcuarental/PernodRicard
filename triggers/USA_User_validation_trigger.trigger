trigger USA_User_validation_trigger on User(before insert,before update) {
   	Map<String,Map<String,String>> resultMap = new Map<String,Map<String,String>>();
   	Map<String,USA_Data_validation_Utils.Data_validation_Obj> fieldMap = new Map<String,USA_Data_validation_Utils.Data_validation_Obj>();
   	private static List<String> profileName = new List<String>{
          'PRUSA Briefcase Delegated Admin',
          'PRUSA Briefcase Distributor Executive',
          'PRUSA Briefcase External Sales Rep',
          'PRUSA Briefcase Internal Sales Rep',
          'PRUSA Briefcase Super User',
          'PRUSA Briefcase Super User-Manage Content',
          'PRUSA Briefcase Wines External Sales Rep',
          'PRUSA Briefcase Wines Internal Sales Rep',
          'PRUSA Data Integration Profile'
    };

    Map<Id,Profile> proMap = new Map<Id,Profile>([select id from Profile where name in: profileName]);
    USA_Data_validation_Utils.Data_validation_Obj USA_CHATTER = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_CHATTER.fieldName = 'USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C';
   	USA_CHATTER.hasId = true;
   	USA_CHATTER.formatType = 3;
   	USA_CHATTER.IdFormat = '0F9Dxxxxxxxxxxx';
   	USA_CHATTER.subListSize = 2;
   	USA_CHATTER.IdIndex = 2;
    USA_CHATTER.canfix = false;
   	fieldMap.put('USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C', USA_CHATTER);

   	USA_Data_validation_Utils.Data_validation_Obj USA_ASSIGNED_MARKETS = new USA_Data_validation_Utils.Data_validation_Obj();
   	USA_ASSIGNED_MARKETS.fieldName = 'USA_ASSIGNED_MARKETS__C';
   	USA_ASSIGNED_MARKETS.hasId = false;
   	USA_ASSIGNED_MARKETS.formatType = 4;
   	USA_ASSIGNED_MARKETS.IdFormat = '';
   	USA_ASSIGNED_MARKETS.subListSize = 2;
   	USA_ASSIGNED_MARKETS.IdIndex = 0;
    USA_ASSIGNED_MARKETS.canfix = false;
   	fieldMap.put('USA_ASSIGNED_MARKETS__C', USA_ASSIGNED_MARKETS);

    for(User u: trigger.new){
      
    	try{
        if(proMap.containsKey(u.ProfileId)){
          resultMap = USA_Data_validation_Utils.dataMapCreate(u,fieldMap);
          for(String str : resultMap.keySet()){
            USA_Data_validation_Utils.data_handle(u,str,resultMap);
          }
        }
    	}catch(Exception e){
    		u.addError('Exception Message:'+e.getMessage());
    	}
    	
    }

}