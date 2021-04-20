public class ASI_MFM_PH_GLDate_SettingController {

    public List<ASI_MFM_GL_Date_Setting__c> Sett {get;set;}
    public List<ASI_MFM_GL_Date_Setting__c> Settupdate {get;set;}
    public Decimal currentMonth {set;get;}
    public List<GLDateProxy> SettGL {get;set;}
    List<ASI_MFM_GL_Date_Setting__c> setupdate =new List<ASI_MFM_GL_Date_Setting__c>();
    
    public ASI_MFM_PH_GLDate_SettingController() {// Get the custom setting 
        init();
        
    }
    public void init() {
        Sett=[SELECT Id, name,ASI_MFM_End_Date__c,ASI_MFM_G_L_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_Month__c  FROM ASI_MFM_GL_Date_Setting__c WHERE ASI_MFM_Country__c = 'PH' order by ASI_MFM_Month__c];

        SettGL=new List<GLDateProxy>();
        
        Date currentDate = Date.today();
        currentMonth = 1;
        
        List<String> sorting = new List<String>{};

        if(currentDate.month()>0 && currentDate.month()<7){   
             sorting = new List<String>{'1','2','3','4','5','6','7','8','9','10','11','12'}; //Cross Fiscal Year should be shown
        }else{
             sorting = new List<String>{'7','8','9','10','11','12','1','2','3','4','5','6'}; //New Fiscal Year should be shown
        }
        

        
        Map<String, GLDateProxy> needSortMap = new Map<String, GLDateProxy>();
        
        for(ASI_MFM_GL_Date_Setting__c GL:Sett){
   
            
            GLDateProxy temp=new GLDateProxy();
            temp.Id=GL.Id;
            temp.Month=GL.ASI_MFM_Month__c;
            temp.End_Date=GL.ASI_MFM_End_Date__c.format();
            temp.GL_Date=GL.ASI_MFM_G_L_Date__c.format();
            temp.Start_Date=GL.ASI_MFM_Start_Date__c.format();
            //Get Day and Month
            temp.Start_DD=GL.ASI_MFM_Start_Date__c.day();
            temp.Start_DM=GL.ASI_MFM_Start_Date__c.month();
            
            temp.End_DD=GL.ASI_MFM_End_Date__c.day();
            temp.End_DM=GL.ASI_MFM_End_Date__c.month();
            
            temp.GL_DD=GL.ASI_MFM_G_L_Date__c.day();
            temp.GL_DM=GL.ASI_MFM_G_L_Date__c.month();
            temp.period = temp.Start_DD + '/' + temp.Start_DM + ' - ' + temp.End_DD + '/' + temp.End_DM;
            temp.GLD = temp.GL_DD + '/' + temp.GL_DM;
    
             if(GL.ASI_MFM_Start_Date__c!=null && GL.ASI_MFM_Start_Date__c<=currentDate && GL.ASI_MFM_End_Date__c!=null && GL.ASI_MFM_End_Date__c>=currentDate){
                currentMonth = temp.Month;
            }
            
            
            SettGL.add(temp);
            needSortMap.put(String.valueOf(temp.Month), temp);
        }
        
        if(!needSortMap.isEmpty()){
            SettGL.clear();
            for(String sortNo : sorting){
                SettGL.add(needSortMap.get(sortNo));
            }
        }
        
        
    }
    public class GLDateProxy {  //Budget Setting
        public Id Id {get;set;}
        public Decimal Month {get;set;}
        public String End_Date {get;set;}
        public String GL_Date {get;set;}
        public String Start_Date {get;set;}
        
        
        public Integer Start_DD {get;set;} //Day
        public Integer Start_DM {get;set;} //Month
        
        public Integer End_DD {get;set;} //Day
        public Integer End_DM {get;set;} //Month
        
        public Integer GL_DD {get;set;} //Day
        public Integer GL_DM {get;set;} //Month
        public string period {get;set;}
        public string GLD {get;set;}
        
    }
    public PageReference refresh() {
        init();
        return null;
    }
    
    public void save(){
        Set<id> uid = new set<id>();
        for(ASI_MFM_GL_Date_Setting__c GL:Sett){
            for(GLDateProxy GLP:SettGL){
                
                if(GLP.id==GL.id &&( GLP.Start_DD!=GL.ASI_MFM_Start_Date__c.day() || GLP.Start_DM!=GL.ASI_MFM_Start_Date__c.month()|| GLP.End_DD!=GL.ASI_MFM_End_Date__c.day() || GLP.End_DM!=GL.ASI_MFM_End_Date__c.month() || GLP.GL_DD!=GL.ASI_MFM_G_L_Date__c.day() || GLP.GL_DD!=GL.ASI_MFM_G_L_Date__c.day() || GLP.GL_DM!=GL.ASI_MFM_G_L_Date__c.month() )){
                	date StartDate = date.newInstance(Date.today().year(),GLP.Start_DM,GLP.Start_DD);
                    date EndDate = date.newInstance(Date.today().year(),GLP.End_DM,GLP.End_DD);
					date GLDate = date.newInstance(Date.today().year(),GLP.GL_DM,GLP.GL_DD);                    
                    ASI_MFM_GL_Date_Setting__c glset= new ASI_MFM_GL_Date_Setting__c(id=GLP.id,ASI_MFM_Start_Date__c=StartDate,ASI_MFM_End_Date__c=EndDate,ASI_MFM_G_L_Date__c=GLDate);
                    if (!uid.contains(GLP.id)){
                    	setupdate.add(glset);
                        uid.add(GLP.id);
                    }
                }
            }
        }
        update setupdate;
        setupdate.clear();
        init();
    }
}