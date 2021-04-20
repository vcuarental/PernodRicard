/* Filename:    ASI_CN_NPL_ChannelMgmtCompCtrl.cls
 * Author:      [Laputa]Kevin Choi
 * Purpose:     Controller to retrieve and update channel strategy fro each channel and sub channel
 * History
 * -----------------------------------------------------------------------------
 * 2019-01-14	[Laputa]Kevin		Created
 */

global class ASI_CN_NPL_ChannelMgmtCompCtrl {
  //MT@202004 START
  //get the multi-select pick list values
  public static List<String> regionOptions {
    get {
        List<String> options = new List<String>();
        for( Schema.PicklistEntry obj : ASI_MFM_Sub_Channel__c.ASI_MFM_Region__c.getDescribe().getPicklistValues()) {
            options.add(obj.getLabel());
        } 
        return options;
    }  
    set;
  }
  //MT@202004 END
  
  public String recordId {set;get;}
  public String ObjectType {set;get;}
  public boolean email {set;get;} 
  public String channelStrategyId {set;get;}
  public ASI_CRM_CN_Channel_Strategy__c channelStrategy {set;get;}
  
  public List<ASI_CRM_CN_Channel_Group__c> retrievedChannelGroupList {set;get;}
  public List<ASI_CRM_CN_Channel__c> retrievedChannelList {set;get;}
  public List<ASI_MFM_Sub_Channel__c> retrievedSubChannelList {set;get;}
  
  public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelStrategyLineItemList {set;get;}
  public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelStrategyLastLineItemList {set;get;}
  public string channelStrategyLastLineItemListJSON {set;get;}
  
  public Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelPercentageLineItemMap {set;get;}
  public Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> subChannelEntitleLineItemMap {set;get;}
  public String channelPercentageLineItemMapJSON {set;get;}
  public String subChannelEntitleLineItemMapJSON {set;get;}
  public String channelPercentageLastVersionMapJSON {set;get;}
  public String subChannelEntitleLastVersionMapJSON {set;get;}
  public String subChannelGroupedMapJSON {set;get;}//MT@202004
  
  public Map<String,channelPercentageWrapper> channelPercentageWrapperMap {set;get;}
  public Map<String,channelEntitledWrapper> subChannelEntitleWrapperMap {set;get;}
  public Map<String,channelPercentageWrapper> channelPercentageLastVersionMap {set;get;}
  public Map<String,channelEntitledWrapper> subChannelEntitleLastVersionMap {set;get;}
  public String channelPercentageWrapperMapJSON {set;get;}
  public String subChannelEntitleWrapperMapJSON {set;get;}
  
  public Map<String,List<ASI_CRM_CN_Channel__c>> channelGroupedMap {set;get;}
  public Map<String,List<ASI_MFM_Sub_Channel__c>> subChannelGroupedMap {set;get;}
  
  private static final string darftStatus = 'Draft';
  private static final string finalStatus = 'Final';
  private static final string submittedStatus = 'Submitted';
  private static final string finalApproved = 'Final Approved';
  
  
  public boolean isEdit {set;get;}
  public boolean isRevise {set;get;}
  public boolean isSubmitted {set;get;}
  public boolean isNPLApproved {set;get;}
  public boolean canEditSubmit {set;get;}
  public boolean channelStrategyExists {set;get;}
  public string editOption {set;get;}
  public string status {set;get;}
  
  public Boolean initialised {
      get {
          if (initialised != true) {
              initialised = init();
          }
          return initialised;
      }
      set;}
  
  
  global class channelPercentageWrapper{
      global string channelType{ set;get;}
      global decimal percentage{ set;get;}
      global id  channel{ set;get;}
  }
  
  global class channelEntitledWrapper{
      global string channelType{ set;get;}
      global string entitled{ set;get;}
      global id subChannel{ set;get;}
      global id channel{ set;get;}
      //MT@202004 START
      global Map<String, Boolean> mb{ set;get;}
      private String listToStr (List<String> l_str){
          String str = '';
          if(l_str == null)
				return str;
          for(String s : l_str){
              if(str == '')
                  str += s;
              else
	              str += ', ' + s;
          }
          return str;
      }
      global String avaString{set;get;}      
      //get the multi-select pick list values
      global boolean isAllRegion{ set;get;}
      global List<String> avaRegions{ set;get;}
      global String region_to_rc{ set;get;}
      global String regionsSelected{ set;get;}
      global Boolean notInUse{set;get;}
      global List<String> availableRegions{ 
        set{
          List<String> ret = new List<String>();
          if(this.isAllRegion)
              for( Schema.PicklistEntry obj : ASI_MFM_Sub_Channel__c.ASI_MFM_Region__c.getDescribe().getPicklistValues()) {
                ret.add(obj.getLabel());       
              }
          else{
          	  ret = value;
          }
          this.avaRegions = ret;
          this.avaString = this.listToStr(ret);
        }
        get;
		  }
      //MT@202004 END
  }
  
  public ASI_CN_NPL_ChannelMgmtCompCtrl(){}
  
  public boolean init(){
      system.debug('init');
      system.debug(recordId);
      
      //init all params
      isEdit = false;
       isRevise = false;
      isSubmitted = false;
      editOption = 'none';
      channelGroupedMap = new Map<String,List<ASI_CRM_CN_Channel__c>>();
      subChannelGroupedMap = new Map<String,List<ASI_MFM_Sub_Channel__c>>();
      channelPercentageLineItemMap = new Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
      subChannelEntitleLineItemMap = new Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
      channelPercentageWrapperMap = new Map<String,channelPercentageWrapper>();
      subChannelEntitleWrapperMap = new Map<String,channelEntitledWrapper>();
      channelPercentageLastVersionMap = new Map<String,channelPercentageWrapper>();
      subChannelEntitleLastVersionMap = new Map<String,channelEntitledWrapper>();
      channelStrategyLastLineItemList = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
      Map<Id, ASI_MFM_Sub_Channel__c> subChannelMap = new Map<Id,ASI_MFM_Sub_Channel__c>(); //MT@202004
      
  list<ASI_CRM_CN_Channel_Strategy__c> list_cs;
      
      //get channel strategy record depends on component attribute
      if (ObjectType == 'Item Group'){
          list_cs =  [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c,
                              ASI_NPL_New_Product_Launch_Request__c,ASI_NPL_New_Product_Launch_Request__r.ASI_CN_NPL_Status__c 
                              from ASI_CRM_CN_Channel_Strategy__c 
                              where ASI_NPL_Item_Group__c =: recordId];
      }else if (ObjectType == 'New Product Launch Request'){
          list_cs =  [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c,
                              ASI_NPL_New_Product_Launch_Request__c,ASI_NPL_New_Product_Launch_Request__r.ASI_CN_NPL_Status__c 
                              from ASI_CRM_CN_Channel_Strategy__c 
                              where ASI_NPL_New_Product_Launch_Request__c =: recordId];
      }else if (ObjectType == 'Channel Strategy'){
          list_cs =  [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c,
                              ASI_NPL_New_Product_Launch_Request__c,ASI_NPL_New_Product_Launch_Request__r.ASI_CN_NPL_Status__c 
                              from ASI_CRM_CN_Channel_Strategy__c 
                              where id =: recordId];
      }
      
  if(list_cs.size()>0){
    channelStrategyExists = true;
    channelStrategy = list_cs[0];
    channelStrategyId = channelStrategy.Id;
    status = channelStrategy.ASI_CRM_CN_Status__c;
    if (channelStrategy.ASI_NPL_New_Product_Launch_Request__r.ASI_CN_NPL_Status__c == finalApproved){
      system.debug('is final approved');
      isNPLApproved = true;
      //email = true;
    } else {
      isNPLApproved = false;
    }
    
    List<GroupMember> validateGpMember = [SELECT Id,UserOrGroupId 
                        FROM GroupMember 
                        WHERE Group.DeveloperName='ASI_CN_MFM_User' AND UserOrGroupId =: userInfo.getUserId()];
    String profileName = [Select Name from Profile where Id =:userinfo.getProfileid()].Name;
    if (validateGpMember.size() > 0 || profileName=='ASI_CRM_CN_Logistic_User'){
      system.debug('is ASI_CN_MFM_User or ASI_CRM_CN_Logistic_User');
      canEditSubmit = true;
    }
    
    isEdit = channelStrategy.ASI_CRM_CN_Status__c == darftStatus?true:false;
    isRevise = channelStrategy.ASI_CRM_CN_Status__c == finalStatus?true:false;
    isSubmitted = channelStrategy.ASI_CRM_CN_Status__c == submittedStatus?true:false;
    system.debug(isEdit+' '+isRevise+' '+isSubmitted);
    
    Set<Id> channelGpIdSet = new Set<Id>();
    Set<Id> channelIdSet = new Set<Id>();
    
    //retrieve channel group and from set of channel group id
    retrievedChannelGroupList = [select id,name from ASI_CRM_CN_Channel_Group__c 
                   where recordtype.developerName = 'ASI_NPL_CN_Channel_Group' 
                   order by ASI_CRM_Sequence__c];
    
    for (ASI_CRM_CN_Channel_Group__c channelGp: retrievedChannelGroupList){
      channelGpIdSet.add(channelGp.Id);
    }
    //retrieve channel group and from map of channel name
    retrievedChannelList = [select Id,name, ASI_CRM_CN_Channel_Group__c, ASI_CRM_CN_Channel_Group__r.Name 
                from ASI_CRM_CN_Channel__c 
                where recordtype.developerName = 'ASI_NPL_CN_Channel' 
                AND ASI_CRM_CN_Channel_Group__c = :channelGpIdSet
                order by ASI_CRM_CN_Sequence__c];
    
    for (ASI_CRM_CN_Channel__c channel : retrievedChannelList){
      channelIdSet.add(channel.Id);
      groupChannel(channel);
    }
    
    
          retrievedSubChannelList = [select id, name, ASI_CRM_CN_Channel__c,ASI_CRM_CN_Channel__r.Name
                                     , ASI_MFM_Region__c, ASI_MFM_Is_All_Region__c, ASI_CRM_CN_Not_in_use__c //MT@202004
                   from ASI_MFM_Sub_Channel__c 
                   where recordtype.developerName = 'ASI_NPL_CN_Sub_Channel'
                   AND ASI_CRM_CN_Channel__c = :channelIdSet
                   //AND ASI_CRM_CN_Not_in_use__c = FALSE //MT@202004
                   order by ASI_CRM_CN_Sequence__c];	
    
    for (ASI_MFM_Sub_Channel__c subChannel :retrievedSubChannelList){
      groupSubChannel(subChannel);
      subChannelMap.put(subChannel.Id, subChannel); //MT@202004
    }			 
    
    channelStrategyLineItemList = [select id, Name, ASI_NPL_Version__c, ASI_NPL_Type__c, 
                     ASI_NPL_Percentage__c, ASI_NPL_Channel__c, ASI_NPL_Channel__r.Name, 
                     ASI_NPL_Sub_Channel__c, ASI_NPL_Entitled__c , ASI_NPL_Sub_Channel__r.Name, 
                                         ASI_CRM_CN_Channel_Strategy__c, ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Vision__c 
                                         , ASI_NPL_Region__c //MT@202004
                     from ASI_CRM_CN_Channel_Strategy_Line_Item__c 
                     where ASI_CRM_CN_Channel_Strategy__c =: channelStrategy.Id
                     AND ASI_NPL_Version__c =: channelStrategy.ASI_NPL_Vision__c
                     AND recordtype.developerName = 'ASI_CRM_CN_Channel_Strategy'];
    
    if (channelStrategyLineItemList.size() > 0)	{							
      Integer channelStrategyVersion = (channelStrategyLineItemList[0].ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Vision__c).intValue();
      
      //seperate list of result into 2 map accroding to their type
      for (ASI_CRM_CN_Channel_Strategy_Line_Item__c lineItem: channelStrategyLineItemList){
        if (lineItem.ASI_NPL_Type__c ==  'Channel Percentage'){
          
          channelPercentageWrapper channelPercentage = new channelPercentageWrapper();
          channelPercentage.channelType = lineItem.ASI_NPL_Type__c;
          channelPercentage.percentage = lineItem.ASI_NPL_Percentage__c;
          channelPercentage.channel = lineItem.ASI_NPL_Channel__c;
          //channelPercentage.strategyLineItem = lineItem;
          
          channelPercentageLineItemMap.put(lineItem.ASI_NPL_Channel__r.Name,lineItem);
          channelPercentageWrapperMap.put(lineItem.ASI_NPL_Channel__r.Name, channelPercentage);
          
          
        }else if (lineItem.ASI_NPL_Type__c ==  'Sub-Channel Entitlement'){
          system.debug('found Sub Channel:'+lineItem.ASI_NPL_Channel__r.Name +'-'+lineItem.Name);
          
          string mapkey = lineItem.ASI_NPL_Channel__r.Name+lineItem.ASI_NPL_Sub_Channel__r.Name;
          channelEntitledWrapper channelEntitled = new channelEntitledWrapper();
          channelEntitled.channelType = lineItem.ASI_NPL_Type__c;
          channelEntitled.entitled = lineItem.ASI_NPL_Entitled__c == true? 'Y' : 'N';
          channelEntitled.subChannel = lineItem.ASI_NPL_Sub_Channel__c;
          channelEntitled.channel = lineItem.ASI_NPL_Channel__c;
          //MT@202004 START
          system.debug('name' + lineItem.Name);
          channelEntitled.regionsSelected = lineItem.ASI_NPL_Region__c == null? '' : lineItem.ASI_NPL_Region__c;
          channelEntitled.isAllRegion = subChannelMap.containsKey(lineItem.ASI_NPL_Sub_Channel__c)? subChannelMap.get(lineItem.ASI_NPL_Sub_Channel__c).ASI_MFM_Is_All_Region__c : false;
          channelEntitled.region_to_rc = lineItem.ASI_NPL_Region__c == null? '' : lineItem.ASI_NPL_Region__c;
          channelEntitled.availableRegions = subChannelMap.containsKey(lineItem.ASI_NPL_Sub_Channel__c) && subChannelMap.get(lineItem.ASI_NPL_Sub_Channel__c).ASI_MFM_Region__c != null? subChannelMap.get(lineItem.ASI_NPL_Sub_Channel__c).ASI_MFM_Region__c.split(';') : new List<String>();
          channelEntitled.notInUse = subChannelMap.containsKey(lineItem.ASI_NPL_Sub_Channel__c)? subChannelMap.get(lineItem.ASI_NPL_Sub_Channel__c).ASI_CRM_CN_Not_in_use__c : false;
          //channelEntitled.strategyLineItem = lineItem;
          //MT@202004 END
          subChannelEntitleLineItemMap.put(mapkey,lineItem);
          subChannelEntitleWrapperMap.put(mapkey, channelEntitled);
        }
      }
      system.debug(channelStrategyVersion);	
      if (channelStrategyVersion > 1){
        /*handle last version channel strategy line item*/
        Integer lastVision = channelStrategyVersion - 1;
        channelStrategyLastLineItemList = [select id, Name, ASI_NPL_Version__c, ASI_NPL_Type__c, 
                           ASI_NPL_Percentage__c, ASI_NPL_Channel__c,ASI_NPL_Channel__r.Name,
                           ASI_NPL_Sub_Channel__c, ASI_NPL_Entitled__c ,ASI_NPL_Sub_Channel__r.Name,
                           ASI_CRM_CN_Channel_Strategy__c, ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Vision__c 
                           , ASI_NPL_Region__c //MT@202004
                           from ASI_CRM_CN_Channel_Strategy_Line_Item__c 
                           where ASI_CRM_CN_Channel_Strategy__c =: channelStrategy.Id 
                           AND recordtype.developerName = 'ASI_CRM_CN_Channel_Strategy'
                           AND ASI_NPL_Version__c =: lastVision];
      }
      
    }
    
    //seperate list of result into 2 map accroding to their type
    if (channelStrategyLastLineItemList.size() > 0){
      for (ASI_CRM_CN_Channel_Strategy_Line_Item__c lastVersionItem : channelStrategyLastLineItemList){
        if (lastVersionItem.ASI_NPL_Type__c ==  'Channel Percentage'){
          system.debug('found previous line item:'+lastVersionItem.ASI_NPL_Channel__r.Name);
          channelPercentageWrapper channelPercentage = new channelPercentageWrapper();
          channelPercentage.channelType = lastVersionItem.ASI_NPL_Type__c;
          channelPercentage.percentage = lastVersionItem.ASI_NPL_Percentage__c;
          channelPercentage.channel = lastVersionItem.ASI_NPL_Channel__c;
          
          
          channelPercentageLastVersionMap.put(lastVersionItem.ASI_NPL_Channel__r.Name, channelPercentage);
          
        }else if (lastVersionItem.ASI_NPL_Type__c ==  'Sub-Channel Entitlement'){
          system.debug('found previous line item:'+lastVersionItem.ASI_NPL_Channel__r.Name + lastVersionItem.ASI_NPL_Sub_Channel__r.Name);
          string mapkey = lastVersionItem.ASI_NPL_Channel__r.Name + lastVersionItem.ASI_NPL_Sub_Channel__r.Name;
          
          channelEntitledWrapper channelEntitled = new channelEntitledWrapper();
          channelEntitled.channelType = lastVersionItem.ASI_NPL_Type__c;
          channelEntitled.entitled = lastVersionItem.ASI_NPL_Entitled__c == true? 'Y' : 'N';
          channelEntitled.subChannel = lastVersionItem.ASI_NPL_Sub_Channel__c;
          channelEntitled.channel = lastVersionItem.ASI_NPL_Channel__c;
          //MT@202004 START
          system.debug('name' + lastVersionItem.Name);
          channelEntitled.regionsSelected = lastVersionItem.ASI_NPL_Region__c == null? '' : lastVersionItem.ASI_NPL_Region__c;
          channelEntitled.isAllRegion = subChannelMap.containsKey(lastVersionItem.ASI_NPL_Sub_Channel__c)? subChannelMap.get(lastVersionItem.ASI_NPL_Sub_Channel__c).ASI_MFM_Is_All_Region__c : false;
          channelEntitled.region_to_rc = lastVersionItem.ASI_NPL_Region__c == null? '' : lastVersionItem.ASI_NPL_Region__c;
          channelEntitled.availableRegions = subChannelMap.containsKey(lastVersionItem.ASI_NPL_Sub_Channel__c) && subChannelMap.get(lastVersionItem.ASI_NPL_Sub_Channel__c).ASI_MFM_Region__c != null? subChannelMap.get(lastVersionItem.ASI_NPL_Sub_Channel__c).ASI_MFM_Region__c.split(';') : new List<String>();
          channelEntitled.notInUse = subChannelMap.containsKey(lastVersionItem.ASI_NPL_Sub_Channel__c)? subChannelMap.get(lastVersionItem.ASI_NPL_Sub_Channel__c).ASI_CRM_CN_Not_in_use__c : false;            
          //channelEntitled.strategylastVersionItem = lastVersionItem;
          //MT@202004 END
          
          subChannelEntitleLastVersionMap.put(mapkey, channelEntitled);
        }
        
      }
    }
    
    /*add back channel percentage record into map 
    if any channel master is not found, and init percentage == 0*/
    
    for (ASI_CRM_CN_Channel__c channel : retrievedChannelList){
      if (channelPercentageWrapperMap.get(channel.Name) == null){
        system.debug('Channel:'+channel.Name);
        channelPercentageWrapper channelPercentage = new channelPercentageWrapper();
        channelPercentage.channelType = 'Channel Percentage';
        channelPercentage.percentage = 0;
        channelPercentage.channel = channel.id;
        
        channelPercentageWrapperMap.put(channel.Name, channelPercentage);
        
      }

      //MT@202004 START
      if (channelPercentageLastVersionMap.get(channel.Name) == null){
        system.debug('Channel:'+channel.Name);
        channelPercentageWrapper channelPercentage = new channelPercentageWrapper();
        channelPercentage.channelType = 'Channel Percentage';
        channelPercentage.percentage = 0;
        channelPercentage.channel = channel.id;
        
        channelPercentageLastVersionMap.put(channel.Name, channelPercentage);
        
      }
      //MT@202004 END
      
    }

    
    /*add back sub channel percentage record into map 
    if any sub channel master is not found, init entitled == N*/
    
    for (ASI_MFM_Sub_Channel__c subChannel :retrievedSubChannelList){
      string mapkey = subChannel.ASI_CRM_CN_Channel__r.Name + subChannel.Name;
      if (subChannelEntitleWrapperMap.get(mapkey) == null){
        system.debug('add Sub Channel:'+subChannel.ASI_CRM_CN_Channel__r.Name+'-'+subChannel.Name);
        
        channelEntitledWrapper channelEntitled = new channelEntitledWrapper();
        channelEntitled.channelType = 'Sub-Channel Entitlement';
        channelEntitled.entitled =  'N';
        channelEntitled.subChannel = subChannel.id;
        channelEntitled.channel = subChannel.ASI_CRM_CN_Channel__c;
        //MT@202004 START
        channelEntitled.regionsSelected = '';
        channelEntitled.isAllRegion = subChannel.ASI_MFM_Is_All_Region__c;
        channelEntitled.region_to_rc = '';
        channelEntitled.availableRegions = subChannel.ASI_MFM_Region__c != null? subChannel.ASI_MFM_Region__c.split(';') : new List<String>();
        channelEntitled.notInUse = subChannel.ASI_CRM_CN_Not_in_use__c;  
        //MT@202004 END 
        subChannelEntitleWrapperMap.put(mapkey, channelEntitled);
        
      }

      if (subChannelEntitleLastVersionMap.get(mapkey) == null){
        system.debug('add Sub Channel:'+subChannel.ASI_CRM_CN_Channel__r.Name+'-'+subChannel.Name);
        
        channelEntitledWrapper channelEntitled = new channelEntitledWrapper();
        channelEntitled.channelType = 'Sub-Channel Entitlement';
        channelEntitled.entitled =  'N';
        channelEntitled.subChannel = subChannel.id;
        channelEntitled.channel = subChannel.ASI_CRM_CN_Channel__c;
        //MT@202004 START
        channelEntitled.regionsSelected = '';
        channelEntitled.isAllRegion = subChannel.ASI_MFM_Is_All_Region__c;
        channelEntitled.region_to_rc = '';
        channelEntitled.availableRegions = subChannel.ASI_MFM_Region__c != null? subChannel.ASI_MFM_Region__c.split(';') : new List<String>();
        //MT@202004 END 
        subChannelEntitleLastVersionMap.put(mapkey, channelEntitled);
        
      }
    }
    system.debug(channelStrategyLastLineItemList);	
    system.debug(channelPercentageWrapperMap);
    system.debug(subChannelEntitleWrapperMap);
    system.debug(channelPercentageLastVersionMap);
    system.debug(subChannelEntitleLastVersionMap);
     channelPercentageLineItemMapJSON = JSON.serialize(channelPercentageLineItemMap);
    subChannelEntitleLineItemMapJSON = JSON.serialize(subChannelEntitleLineItemMap);
    channelPercentageWrapperMapJSON = JSON.serialize(channelPercentageWrapperMap);
    subChannelEntitleWrapperMapJSON = JSON.serialize(subChannelEntitleWrapperMap);
    channelStrategyLastLineItemListJSON = JSON.serialize(channelStrategyLastLineItemList);
    channelPercentageLastVersionMapJSON = JSON.serialize(channelPercentageLastVersionMap);
    subChannelEntitleLastVersionMapJSON = JSON.serialize(subChannelEntitleLastVersionMap);
    subChannelGroupedMapJSON = JSON.serialize(subChannelGroupedMap);//MT@202004
    
    system.debug(channelPercentageWrapperMapJSON);
    system.debug(subChannelEntitleWrapperMapJSON);
    system.debug(channelGroupedMap);		
    system.debug(subChannelGroupedMap);	
  } else {
    channelStrategyExists = false;
  }
      
      return true;
      
  }
  
  /*[Start] Page Function*/
  @RemoteAction
  global static boolean reviseChannelStrategy(string percentmapjson,
                          string entitlemapjson, 
                          string channelPercentageLineItemMapString,
                          string subChannelEntitleLineItemMapString,
                          string channelStrategyId){
      system.debug('start revise');       
      ASI_CRM_CN_Channel_Strategy__c channelStrategy =  [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c 
                                                         from ASI_CRM_CN_Channel_Strategy__c 
                                                         where id =: channelStrategyId];
      
      //convert back to apex map
      Map<String,channelPercentageWrapper> channelPercentageMap = (Map<String,channelPercentageWrapper>) JSON.deserialize(percentmapjson, Map<String,channelPercentageWrapper>.class);
      Map<String,channelEntitledWrapper> subChannelEntitleMap = (Map<String,channelEntitledWrapper>) JSON.deserialize(entitlemapjson, Map<String,channelEntitledWrapper>.class);
      Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelPercentageLineItemMap = (Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>) JSON.deserialize(channelPercentageLineItemMapString, Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>.class);
      Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> subChannelEntitleLineItemMap = (Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>) JSON.deserialize(subChannelEntitleLineItemMapString, Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>.class);
      
      decimal revisedVersion = channelStrategy.ASI_NPL_Vision__c + 1;
      try{
          //saveChannelStrategyToDB(channelPercentageMap,subChannelEntitleMap,channelPercentageLineItemMap,subChannelEntitleLineItemMap,channelStrategy, revisedVersion,false);
          //2019/10/30 CanterDuan修改
          saveChannelStrategyToDB(channelPercentageMap,subChannelEntitleMap,channelPercentageLineItemMap,subChannelEntitleLineItemMap,channelStrategy, revisedVersion,false,channelStrategyId);
          channelStrategy.ASI_NPL_Vision__c = revisedVersion;
          channelStrategy.ASI_CRM_CN_Status__c = 'Draft';
          
          update channelStrategy;
      }catch(exception e){
          
          return false;
      }    	
      
      return true;
      
  }
  
  @RemoteAction
  global static boolean saveChannelStrategy(string percentmapjson, 
                        string entitlemapjson, 
                        string channelPercentageLineItemMapString, 
                        string subChannelEntitleLineItemMapString, 
                        string channelStrategyId){
      system.debug('start save');
      ASI_CRM_CN_Channel_Strategy__c channelStrategy =  [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c 
                                                         from ASI_CRM_CN_Channel_Strategy__c 
                                                         where id =: channelStrategyId];
      
      //convert back to apex map
      Map<String,channelPercentageWrapper> channelPercentageMap = (Map<String,channelPercentageWrapper>) JSON.deserialize(percentmapjson, Map<String,channelPercentageWrapper>.class);
      Map<String,channelEntitledWrapper> subChannelEntitleMap = (Map<String,channelEntitledWrapper>) JSON.deserialize(entitlemapjson, Map<String,channelEntitledWrapper>.class);
      Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelPercentageLineItemMap = (Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>) JSON.deserialize(channelPercentageLineItemMapString, Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>.class);
      Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> subChannelEntitleLineItemMap = (Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>) JSON.deserialize(subChannelEntitleLineItemMapString, Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>.class);
      
     
      try{
          //saveChannelStrategyToDB(channelPercentageMap,subChannelEntitleMap,channelPercentageLineItemMap,subChannelEntitleLineItemMap,channelStrategy,channelStrategy.ASI_NPL_Vision__c,true);
          //2019/10/30 CanterDuan修改
          saveChannelStrategyToDB(channelPercentageMap,subChannelEntitleMap,channelPercentageLineItemMap,subChannelEntitleLineItemMap,channelStrategy,channelStrategy.ASI_NPL_Vision__c,true,channelStrategyId);
      }catch (exception e){
          return false;
      }
      
      return true;
  }
  
  @RemoteAction
  global static boolean submitChannelStrategy(string channelStrategyId){
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
  req1.setObjectId(channelStrategyId);
  req1.setSubmitterId(UserInfo.getUserId());
  Approval.ProcessResult result = Approval.process(req1);
      
      return true;
  }
  
  /*public PageReference cancel(){
      system.debug('cancel');
      PageReference pageRef = new PageReference('/'+recordId);
      pageRef.setRedirect(true);
      return pageRef;
  }*/
  /*[End] Page Function*/
  /*[Start] Private Function*/
  
  /**
  group channel by channel group
  Input: ASI_CRM_CN_Channel__c
Output: Map<String,List<ASI_CRM_CN_Channel__c>>
**/
  private void groupChannel(ASI_CRM_CN_Channel__c channel){
      
      if (this.channelGroupedMap.get(channel.ASI_CRM_CN_Channel_Group__r.Name) != null){
          this.channelGroupedMap.get(channel.ASI_CRM_CN_Channel_Group__r.Name).add(channel);
      }else{
          List<ASI_CRM_CN_Channel__c> newChannelList = new List<ASI_CRM_CN_Channel__c>();
          newChannelList.add(channel); 
          this.channelGroupedMap.put(channel.ASI_CRM_CN_Channel_Group__r.Name,newChannelList);
      }
      
  }
  
  /**
  group sub channel by channel
  Input: ASI_MFM_Sub_Channel__c
Output: Map<String,List<ASI_MFM_Sub_Channel__c>>
**/
  
  private void groupSubChannel(ASI_MFM_Sub_Channel__c subChannel){
      
      if (this.subChannelGroupedMap.get(subChannel.ASI_CRM_CN_Channel__r.Name) != null){
          this.subChannelGroupedMap.get(subChannel.ASI_CRM_CN_Channel__r.Name).add(subChannel);
      }else{
          List<ASI_MFM_Sub_Channel__c> newSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
          newSubChannelList.add(subChannel); 
          this.subChannelGroupedMap.put(subChannel.ASI_CRM_CN_Channel__r.Name,newSubChannelList);
      }
      
  }
  
  /**
  save channel strategy to salesforce db
input: Map<String,channelPercentageWrapper> updated channel percentage map from vf 
         Map<String,channelEntitledWrapper> updated sub channel entitlement map from vf 
         Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> retrieved channel percentage reference from salesforce db
         Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> retrieved sub channel entitlement reference from salesforce db
         ASI_CRM_CN_Channel_Strategy__c channel Strategy
         decimal channel strategy version
         boolean distinguish revise/update
**/
  global static void saveChannelStrategyToDB(Map<String,channelPercentageWrapper> channelPercentageMap, 
                                             Map<String,channelEntitledWrapper> subChannelEntitleMap, 
                                             Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelPercentageLineItemMap,
                                             Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> subChannelEntitleLineItemMap,
                                             ASI_CRM_CN_Channel_Strategy__c channelStrategy,
                                             decimal strategyVision, 
                                             boolean isUpdate,Id ChannelStrategyId){
                                                 system.debug('start saveChannelStrategyToDB');
                                                 List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelStrategyUpsertList = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
                                                 Recordtype channelStrategyRt = [select id from recordtype 
                                                                                 where developerName =  'ASI_CRM_CN_Channel_Strategy' limit 1];
                                                 
                                                 if (!isUpdate){
                                                     //2019/10/30 CanterDuan start 将其他标记为最新版本的Item都取消标记
                                                     List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> updateList = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>([SELECT Id,ASI_CRM_CN_Is_Latest__c 
                                                                                                                                                                     FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c
                                                                                                                                                                     WHERE ASI_CRM_CN_Is_Latest__c = true
                                                                                                                                                                     AND ASI_CRM_CN_Channel_Strategy__c =: ChannelStrategyId]);
                                                     if(!updateList.isEmpty()){
                                                         for(ASI_CRM_CN_Channel_Strategy_Line_Item__c item : updateList){
                                                             item.ASI_CRM_CN_Is_Latest__c = false;
                                                         }
                                                         update updateList;
                                                     }
                                                     //2019/10/30 CanterDuan END
                                                     //insert case for revise version
                                                     for (channelPercentageWrapper channelPercentage : channelPercentageMap.values()){
                                                         ASI_CRM_CN_Channel_Strategy_Line_Item__c newChannelStrategyItem = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                                                         newChannelStrategyItem.ASI_CRM_CN_Channel_Strategy__c = channelStrategy.id;
                                                         newChannelStrategyItem.recordtypeid = channelStrategyRt.id;
                                                         newChannelStrategyItem.ASI_NPL_Version__c = strategyVision;
                                                         newChannelStrategyItem.ASI_NPL_Type__c = channelPercentage.channelType;
                                                         newChannelStrategyItem.ASI_NPL_Percentage__c = channelPercentage.percentage;
                                                         newChannelStrategyItem.ASI_NPL_Channel__c = channelPercentage.channel;
                                                         newChannelStrategyItem.ASI_CRM_CN_Is_Latest__c = true; //2019/10/30 CanterDuan
                                                         
                                                         channelStrategyUpsertList.add(newChannelStrategyItem);
                                                     }
                                                     
                                                     
                                                     for (channelEntitledWrapper subChannelEntitle : subChannelEntitleMap.values()){
                                                          //MT@202004 START
                                                            if(subChannelEntitle.notInUse == true)
                                                            continue;
                                                          //MT@202004 END
                                                         ASI_CRM_CN_Channel_Strategy_Line_Item__c newChannelStrategyItem = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                                                         newChannelStrategyItem.ASI_CRM_CN_Channel_Strategy__c = channelStrategy.id;
                                                         newChannelStrategyItem.recordtypeid = channelStrategyRt.id;
                                                         newChannelStrategyItem.ASI_NPL_Version__c = strategyVision;
                                                         newChannelStrategyItem.ASI_NPL_Type__c = subChannelEntitle.channelType;
                                                         newChannelStrategyItem.ASI_NPL_Entitled__c = subChannelEntitle.entitled == 'Y'? true : false;
                                                         newChannelStrategyItem.ASI_NPL_Sub_Channel__c = subChannelEntitle.subChannel;
                                                         newChannelStrategyItem.ASI_NPL_Channel__c = subChannelEntitle.channel;
                                                         newChannelStrategyItem.ASI_CRM_CN_Is_Latest__c = true; //2019/10/30 CanterDuan
                                                         newChannelStrategyItem.ASI_NPL_Region__c = subChannelEntitle.region_to_rc;//MT@202004
                                                         
                                                         channelStrategyUpsertList.add(newChannelStrategyItem);
                                                     }
                                                     
                                                     if (channelStrategyUpsertList.size()>0)
                                                         insert channelStrategyUpsertList;
                                                     
                                                 }else {
                                                     //update case for saving current version
                                                     for (string percentageKey : channelPercentageMap.keyset()){
                                                         channelPercentageWrapper wrapperClass = channelPercentageMap.get(percentageKey);
                                                         ASI_CRM_CN_Channel_Strategy_Line_Item__c tragetClass = channelPercentageLineItemMap.get(percentageKey);
                                                         
                                                         if (tragetClass != null){
                                                             tragetClass.ASI_NPL_Percentage__c = wrapperClass.percentage;
                                                         }else {
                                                             tragetClass =  new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                                                             tragetClass.ASI_CRM_CN_Channel_Strategy__c = channelStrategy.id;
                                                             tragetClass.recordtypeid = channelStrategyRt.id;
                                                             tragetClass.ASI_NPL_Version__c = channelStrategy.ASI_NPL_Vision__c;
                                                             tragetClass.ASI_NPL_Type__c = wrapperClass.channelType;
                                                             tragetClass.ASI_NPL_Percentage__c = wrapperClass.percentage;
                                                             tragetClass.ASI_NPL_Channel__c = wrapperClass.channel;
                                                         }
                                                         
                                                         channelStrategyUpsertList.add(tragetClass);
                                                     }
                                                     
                                                     for (string entitlekey : subChannelEntitleMap.keyset()){
                                                         channelEntitledWrapper entitlewrapper = subChannelEntitleMap.get(entitlekey);
                                                         //MT@202004 START
                                                         if(entitlewrapper.notInUse == true)
                                                            continue;
                                                          //MT@202004 END
                                                         ASI_CRM_CN_Channel_Strategy_Line_Item__c entitleTargetClass = subChannelEntitleLineItemMap.get(entitlekey);
                                                         
                                                         if (entitleTargetClass != null){
                                                             entitleTargetClass.ASI_NPL_Entitled__c = entitlewrapper.entitled == 'Y'? true : false;
                                                             entitleTargetClass.ASI_NPL_Region__c = entitlewrapper.region_to_rc;//MT@202004
                                                         }else{
                                                             entitleTargetClass = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                                                             entitleTargetClass.ASI_CRM_CN_Channel_Strategy__c = channelStrategy.id;
                                                             entitleTargetClass.recordtypeid = channelStrategyRt.id;
                                                             entitleTargetClass.ASI_NPL_Version__c = channelStrategy.ASI_NPL_Vision__c;
                                                             entitleTargetClass.ASI_NPL_Type__c = entitlewrapper.channelType;
                                                             entitleTargetClass.ASI_NPL_Entitled__c = entitlewrapper.entitled == 'Y'? true : false;
                                                             entitleTargetClass.ASI_NPL_Sub_Channel__c = entitlewrapper.subChannel;
                                                             entitleTargetClass.ASI_NPL_Channel__c = entitlewrapper.channel;
                                                             entitleTargetClass.ASI_NPL_Region__c = entitlewrapper.region_to_rc;//MT@202004
                                                         }
                                                         
                                                         channelStrategyUpsertList.add(entitleTargetClass);
                                                     }
                                                     
                                                     if (channelStrategyUpsertList.size()>0)
                                                         upsert channelStrategyUpsertList;
                                                     
                                                 }
                                             }
  /*[End] Private Function*/
  
}