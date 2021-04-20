public class  RIC_Weekly_Taux_Projet {
    
    private  List<Milestone1_Project__c> m_RicProjectList;
    public  List<Milestone1_Project__c> RicProjectList {
        get
        {
            system.debug('m_RicProjectList####'+m_RicProjectList);
            if(m_RicProjectList == null){
                m_RicProjectList = [  select id  ,name, RIC_ClosingRate__c, RIC_Brand__r.name, RIC_Code_article__c ,RIC_Date_MAD_previ__c,Total_Open_Task_Count__c, RIC_Status__c 
                                    from Milestone1_Project__c
                                    where RIC_Coordinateur__c = : UserId And  RIC_ClosingRate__c <100 and RIC_Status__c='En cours'
                                    order by RIC_ClosingRate__c asc];
           }
            system.debug('m_RicProjectList111####'+m_RicProjectList);
            return m_RicProjectList;
        }
    }
    
    public  string UserId {get; set;}
    
    public  RIC_Weekly_Taux_Projet() {
      //  m_RicProjectList = null;
        system.debug('###########UserIdUserId########### '+UserId);
        /*List<Milestone1_Project__c> RicProjectList = new  List<Milestone1_Project__c>();
        RicProjectList=[  select id  ,name, RIC_ClosingRate__c, RIC_Brand__r.name, RIC_Code_article__c ,RIC_Date_MAD_previ__c,Total_Open_Task_Count__c 
                        from Milestone1_Project__c
                        where RIC_Coordinateur__c = : UserId
                        order by name asc];*/
    }
}