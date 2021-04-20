/*Created by Stella Li 07/01/2015*/
public without sharing class ASI_CRM_CN_CityOffcialMassEditCtrl{
    public List <ASI_CRM_City_Official__c> CityOfficial{get; set; }
    public ASI_CRM_City_Official__c datefield{get; set; } 
    public ASI_CRM_City_Official__c selectedCity{get; set; } 
    public list<ASI_CRM_City__c> defaultCity {get; set; }
    public List <ASI_MFM_Item_Group__c> requiredItems{get; set; }
    public boolean showButton {get; set; }
    public set<id> existItemId{get; set; }
    public ASI_CRM_CN_CustomSetting__c customSettingCN {get;set;}
    public string PRCCityOfficialReportID{get; set; }
    public string yearSelected {get; set; }
    public string monthSelected {get; set; }
    public string mapkey{get; set; }
    public map<string,ASI_CRM_City_Official__c>cityOfficialMap{get; set; }
    public map<id,decimal>itemIdSequenceMap{get; set; }
    public List<SelectOption> cityPicklist {set; get;} 
    public list< ASI_CRM_City__c> retrievedCity{get; set; }
    public map<id,string>itemIdChineseNameMap{get; set; }
    public string strTarget{get; set; }
    public map<id,string>CityMgrMap{get; set; }

   public ASI_CRM_CN_CityOffcialMassEditCtrl() { 
         
       datefield=new ASI_CRM_City_Official__c();
       /*for admin*/
       defaultCity = new list<ASI_CRM_City__c>();
       /*for City Mgr*/
       retrievedCity = new list<ASI_CRM_City__c>();
       selectedCity=new ASI_CRM_City_Official__c();
       CityMgrMap=new map<id,string>();
        
       /*Unlock Button & lookupfield for IT&HQ Admin, picklist for City Mgr*/   
       Id uid= UserInfo.getUserId();  
       List<GroupMember> getGroup = [SELECT UserOrGroupId FROM GroupMember WHERE UserOrGroupId =:uid AND group.name = 'ASI CRM CN Admin']; 
       if (getGroup.size()>0){
           showButton=true;
           defaultCity =[SELECT id,Name,ASI_CRM_CN_City_Manager__c FROM ASI_CRM_City__c WHERE recordtype.DeveloperName = 'ASI_CRM_CN_City' ];
           for(ASI_CRM_City__c d : defaultCity ){
               if(d.ASI_CRM_CN_City_Manager__c!=null){
                   CityMgrMap.put(d.id,d.ASI_CRM_CN_City_Manager__c);
               }
           }
        }else{
           showButton=false;
       }
       if(showButton==false){
           cityPicklist = new List<SelectOption>();
           retrievedCity= [SELECT id,Name,ASI_CRM_CN_City_Manager__c FROM ASI_CRM_City__c WHERE recordtype.DeveloperName = 'ASI_CRM_CN_City' AND ASI_CRM_CN_City_Manager__c= :UserInfo.getUserID()]; 
           if(!retrievedCity.isEmpty()){
               for(ASI_CRM_City__c city:retrievedCity){
                   cityPicklist.add(new SelectOption(city.Id, city.name));
               }
           } 
       } 
         /*default search value*/
         if(showButton==true && !defaultCity.isEmpty()){
             datefield.ASI_CRM_City__c=defaultCity[0].id;
         }
         if(showButton==false && !retrievedCity.isEmpty()){
             selectedCity.ASI_CRM_City__c=retrievedCity[0].id;
         }
           Date today=date.today();
           datefield.ASI_CRM_Depletion_Date__c=Date.newInstance(today.year(),today.month()-1,1);
           search();
    }

   public void search(){     
       existItemId=new set <id>();
       CityOfficial = new List <ASI_CRM_City_Official__c>();
       cityOfficialMap=new map<string,ASI_CRM_City_Official__c>();
       requiredItems=new List <ASI_MFM_Item_Group__c>();
       String cityMgrId;
       if(datefield.ASI_CRM_Depletion_Date__c!=null && (datefield.ASI_CRM_City__c!=null || selectedCity.ASI_CRM_City__c!=null)){  
           if(showButton==true){                         
               CityOfficial=[SELECT ASI_CRM_CN_Chinese_Names__c,ASI_CRM_City__r.ASI_CRM_CN_City_Manager__c,ASI_CRM_Item_Group__r.ASI_CRM_CN_Eng_Name__c, ASI_CRM_Item_Group__r.ASI_CRM_CN_Sequence_C__c, ASI_CRM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c,id, ASI_CRM_Item_Group__c, ASI_CRM_CN_Confirm__c, ASI_CRM_Official_Data__c FROM ASI_CRM_City_Official__c WHERE recordtype.DeveloperName  = 'ASI_CRM_CN_City_Official' AND CALENDAR_YEAR(ASI_CRM_Depletion_Date__c)=:datefield.ASI_CRM_Depletion_Date__c.year()AND CALENDAR_MONTH(ASI_CRM_Depletion_Date__c)=:datefield.ASI_CRM_Depletion_Date__c.month() AND ASI_CRM_City__c =:datefield.ASI_CRM_City__c AND ASI_CRM_Item_Group__r.ASI_CRM_Competitor__c='YES'];// AND ASI_CRM_City__r.ASI_CRM_CN_City_Manager__c =:UserInfo.getUserID()         
               cityMgrId=CityMgrMap.get(datefield.ASI_CRM_City__c);    
           }else{
               CityOfficial=[SELECT ASI_CRM_CN_Chinese_Names__c,ASI_CRM_City__r.ASI_CRM_CN_City_Manager__c,ASI_CRM_Item_Group__r.ASI_CRM_CN_Eng_Name__c, ASI_CRM_Item_Group__r.ASI_CRM_CN_Sequence_C__c, ASI_CRM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c,id, ASI_CRM_Item_Group__c, ASI_CRM_CN_Confirm__c, ASI_CRM_Official_Data__c FROM ASI_CRM_City_Official__c WHERE recordtype.DeveloperName  = 'ASI_CRM_CN_City_Official' AND CALENDAR_YEAR(ASI_CRM_Depletion_Date__c)=:datefield.ASI_CRM_Depletion_Date__c.year()AND CALENDAR_MONTH(ASI_CRM_Depletion_Date__c)=:datefield.ASI_CRM_Depletion_Date__c.month() AND ASI_CRM_City__c =:selectedCity.ASI_CRM_City__c AND ASI_CRM_Item_Group__r.ASI_CRM_Competitor__c='YES' AND ASI_CRM_City__r.ASI_CRM_CN_City_Manager__c =:UserInfo.getUserID() AND ownerID=:UserInfo.getUserID()];//                 
               cityMgrId=UserInfo.getUserID();   
           }
           for (ASI_CRM_City_Official__c o:CityOfficial){ 
               existItemId.add(o.ASI_CRM_Item_Group__c);             
            }    
           system.debug(CityOfficial);
              
           if(!existItemId.isEmpty()){
               requiredItems=[SELECT ASI_CRM_CN_Sequence_C__c,ASI_CRM_CN_Chinese_Name__c,ASI_CRM_CN_Eng_Name__c,id, Name FROM ASI_MFM_Item_Group__c WHERE recordtype.DeveloperName  ='ASI_CRM_CN_CRM_Item_Group' AND ASI_CRM_CN_City_Official_Input__c=true AND id NOT IN :existItemId AND ASI_CRM_Competitor__c='YES'];
           }else{
               requiredItems=[SELECT ASI_CRM_CN_Sequence_C__c,ASI_CRM_CN_Chinese_Name__c,ASI_CRM_CN_Eng_Name__c,id, Name FROM ASI_MFM_Item_Group__c WHERE recordtype.DeveloperName  ='ASI_CRM_CN_CRM_Item_Group' AND ASI_CRM_CN_City_Official_Input__c=true AND ASI_CRM_Competitor__c='YES'];
           }   
           system.debug(requiredItems);
           
           for(ASI_MFM_Item_Group__c r:requiredItems){
               ASI_CRM_City_Official__c newCityOfficial= new ASI_CRM_City_Official__c();
               newCityOfficial.ASI_CRM_Item_Group__c=r.id;
               newCityOfficial.RecordTypeId =Global_RecordTypeCache.getRtId('ASI_CRM_City_Official__cASI_CRM_CN_City_Official');               
               newCityOfficial.OwnerId=cityMgrId;               
               if(datefield.ASI_CRM_Depletion_Date__c!=null){
                   newCityOfficial.ASI_CRM_Depletion_Date__c=Date.newInstance(datefield.ASI_CRM_Depletion_Date__c.year(),datefield.ASI_CRM_Depletion_Date__c.month(),1);
               }
               if(showButton==true){
                   newCityOfficial.ASI_CRM_City__c=datefield.ASI_CRM_City__c;
               }else{
                   newCityOfficial.ASI_CRM_City__c=selectedCity.ASI_CRM_City__c;
               }          
               CityOfficial.add(newCityOfficial);
           }  
           system.debug(CityOfficial);
           sortList(CityOfficial);
       }                  
      // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'--'+newCityOfficial.ASI_CRM_CN_Chinese_Names__c);
      // ApexPages.addMessage(myMsg);
   }     
   
   public void sortList(List <ASI_CRM_City_Official__c> CityOfficial){
       /*list sorting*/
       cityOfficialMap=new map<string,ASI_CRM_City_Official__c>();
       itemIdSequenceMap=new map<id,decimal>(); 
       itemIdChineseNameMap=new map<id,string>(); 
       requiredItems=new list <ASI_MFM_Item_Group__c>();
       
       /*For Currently required items*/
       requiredItems=[SELECT ASI_CRM_CN_Sequence_C__c,id,ASI_CRM_CN_Chinese_Name__c,ASI_CRM_CN_Eng_Name__c, Name FROM ASI_MFM_Item_Group__c WHERE recordtype.DeveloperName  ='ASI_CRM_CN_CRM_Item_Group' AND ASI_CRM_CN_City_Official_Input__c=true AND ASI_CRM_Competitor__c='YES'];
       for(ASI_MFM_Item_Group__c  g : requiredItems){
           if(g.ASI_CRM_CN_Sequence_C__c==null){              
               g.ASI_CRM_CN_Sequence_C__c=99999999.00;              
               itemIdSequenceMap.put(g.id,g.ASI_CRM_CN_Sequence_C__c);              
           }else{
               itemIdSequenceMap.put(g.id,g.ASI_CRM_CN_Sequence_C__c);
           }
           if(g.ASI_CRM_CN_Chinese_Name__c==null && g.ASI_CRM_CN_Eng_Name__c==null){
               if(g.Name!=null){
                   itemIdChineseNameMap.put(g.id,g.name);
               }else{
                   itemIdChineseNameMap.put(g.id,' ');
               }
           }else if (g.ASI_CRM_CN_Chinese_Name__c !=null){
               if(g.ASI_CRM_CN_Eng_Name__c!=null){
                   itemIdChineseNameMap.put(g.id,g.ASI_CRM_CN_Chinese_Name__c+' '+g.ASI_CRM_CN_Eng_Name__c);
               }else{
                   itemIdChineseNameMap.put(g.id,g.ASI_CRM_CN_Chinese_Name__c);            
               }
           }else if (g.ASI_CRM_CN_Chinese_Name__c ==null && g.ASI_CRM_CN_Eng_Name__c!=null){
               itemIdChineseNameMap.put(g.id,g.ASI_CRM_CN_Eng_Name__c);
           }
       }
       /*For ever required items which are not required now*/
       for(ASI_CRM_City_Official__c c :CityOfficial){
           if(!itemIdSequenceMap.keyset().contains(c.ASI_CRM_Item_Group__c)){
               if(c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Sequence_C__c==null){
                   c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Sequence_C__c=99999999.00;
                   itemIdSequenceMap.put(c.ASI_CRM_Item_Group__c,c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Sequence_C__c);
               }else{
                   itemIdSequenceMap.put(c.ASI_CRM_Item_Group__c,c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Sequence_C__c);
               }
               if(c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c==null && c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Eng_Name__c==null){
                   if(c.ASI_CRM_Item_Group__r.Name!=null){
                       itemIdChineseNameMap.put(c.id, c.ASI_CRM_Item_Group__r.Name);
                   }else{
                       itemIdChineseNameMap.put(c.id, ' ');
                   }
               }else if(c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c!=null){
                   if(c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Eng_Name__c!=null){
                       itemIdChineseNameMap.put(c.id, c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c+' '+c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Eng_Name__c);
                   }else{
                       itemIdChineseNameMap.put(c.id, c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c);
                   }                  
               }else if(c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c==null && c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Eng_Name__c!=null){
                   itemIdChineseNameMap.put(c.id,c.ASI_CRM_Item_Group__r.ASI_CRM_CN_Eng_Name__c);
               }
           }
       }

       integer intLenth;
       string sequence;
       string itemId;
       string ChineseName;
       for(ASI_CRM_City_Official__c c :CityOfficial){
           sequence=string.valueof(itemIdSequenceMap.get(c.ASI_CRM_Item_Group__c));
           ChineseName=itemIdChineseNameMap.get(c.ASI_CRM_Item_Group__c);
           /*产品 Name referenced on visualforce*/
           c.ASI_CRM_CN_Chinese_Names__c=ChineseName;
           intLenth=sequence.length();
           /*Initial Length of Decimal:4*/
           if(intLenth!=null){
               if(intLenth==4){
                   sequence='0000000'+sequence;             
               }
               else if(intLenth==5){
                   sequence='000000'+sequence;              
               }
               else if(intLenth==6){
                   sequence='00000'+sequence;               
               }
               else if(intLenth==7){
                   sequence='0000'+sequence;               
               }  
               else if(intLenth==8){
                   sequence='000'+sequence;               
               }
               else if(intLenth==9){
                   sequence='00'+sequence;              
               }
               else if(intLenth==10){
                   sequence='0'+sequence;               
               }
               else if(intLenth==11){
                   sequence=sequence;               
               }
           }
              
           itemId=c.ASI_CRM_Item_Group__c;
           mapkey=sequence+itemId;
           cityOfficialMap.put(mapkey,c); 
       }   
      
   }
   
    public void confirm(){
       List <ASI_CRM_City_Official__c> ConfirmResult=new List <ASI_CRM_City_Official__c>();
       for (ASI_CRM_City_Official__c c:CityOfficial){
           if(c.id ==null){
               if(c.ASI_CRM_Official_Data__c!=null){
                   c.ASI_CRM_CN_Confirm__c=true;     
                   ConfirmResult.add(c);  
               }
           }
           if(c.id !=null){
               if(c.ASI_CRM_Official_Data__c==null){
                   c.ASI_CRM_Official_Data__c=0;
                   c.ASI_CRM_CN_Confirm__c=true;    
                   ConfirmResult.add(c);
               }else{            
                   c.ASI_CRM_CN_Confirm__c=true; 
                   ConfirmResult.add(c);          
               }
          }
       }
       system.debug(ConfirmResult);
       if(ConfirmResult!=null && ConfirmResult.size()>0){
           upsert ConfirmResult;    
        }
        sortList(CityOfficial);
   }
   
   public void save(){
       List <ASI_CRM_City_Official__c> saveResult=new List <ASI_CRM_City_Official__c>();    
       for (ASI_CRM_City_Official__c f:CityOfficial){
           if(f.id ==null){
               if(f.ASI_CRM_Official_Data__c!=null){
                   saveResult.add(f);
               }             
            }
            if(f.id !=null){
                if(f.ASI_CRM_Official_Data__c==null){
                    f.ASI_CRM_Official_Data__c=0;
                    saveResult.add(f);
                }else{    
                    saveResult.add(f);
                }           
            }
       }
       if(saveResult!=null && saveResult.size()>0){
           upsert saveResult;    
       }
       sortList(CityOfficial);
   }

   public void unlock(){
       List <ASI_CRM_City_Official__c> unlocklist=new List <ASI_CRM_City_Official__c>();    
       for (ASI_CRM_City_Official__c c:CityOfficial){
           if(c.ASI_CRM_Official_Data__c!=null){
               c.ASI_CRM_CN_Confirm__c=false; 
               unlocklist.add(c);
           }
       }
       if(unlocklist!=null && unlocklist.size()>0){
           upsert unlocklist;
       }       
       sortList(CityOfficial); 
   }
  
   public pagereference redirectToReport(){
       /*Report button*/
       customSettingCN = [SELECT id, ASI_CRM_CN_PRCCityOfficialReportID__c FROM ASI_CRM_CN_CustomSetting__c];       
       if(customSettingCN != null && datefield.ASI_CRM_Depletion_Date__c!=null ){              
           PRCCityOfficialReportID = customSettingCN.ASI_CRM_CN_PRCCityOfficialReportID__c;
           yearSelected = String.valueof(datefield.ASI_CRM_Depletion_Date__c.Year());
           monthSelected = String.valueof(datefield.ASI_CRM_Depletion_Date__c.Month());
           pagereference ref = new pagereference('/'+PRCCityOfficialReportID+'?pv0='+yearSelected+'&pv1='+monthSelected);
           ref.setRedirect(true);           
           return ref;        
        }else if(customSettingCN != null && datefield.ASI_CRM_Depletion_Date__c==null){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'请填写日期');
           ApexPages.addMessage(myMsg);
           return null;
        }
       return null;     
   }
}