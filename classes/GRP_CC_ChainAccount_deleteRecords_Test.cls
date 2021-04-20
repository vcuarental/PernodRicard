@isTest
public class GRP_CC_ChainAccount_deleteRecords_Test {
    
    @testSetup
    public static void createChainAccount(){
        GRP_CC_Group__c gr = new GRP_CC_Group__c(Name='Homol group', GRP_CC_Domain__c='homol domain', GRP_CC_GroupeResponsible__c='homol@invalid.com.invalid');
        insert gr;
        GRP_CC_Chain__c ch = new GRP_CC_Chain__c(Name='Test chain', GRP_CC_Group__c =gr.id);
        insert ch;
        CORE_Region__c re= new CORE_Region__c(name='Wonderland');
        
        
        insert re;
        CORE_Country__c cou = new CORE_Country__c(Name='Rabbit Hole', CORE_Region__c=re.Id);
        insert cou;
        GRP_CC_ChainAccount__c ca = new GRP_CC_ChainAccount__c(name ='Homol chain account test', 
                                                               GRP_CC_PRResponsible__c='0051i000001KHIPAA4', 
                                                               GRP_CC_PR_Responsible_Manager__c='0051i000001KHIPAA4', 
                                                               GRP_CC_Chain__c=ch.Id, 
                                                               GRP_CC_Region__c=re.Id, 
                                                               GRP_CC_Country__c=cou.Id, 
                                                               GRP_CC_ChainAccountResponsible__c='homol@invalid.com.invalid');
        insert ca;
        Date startdate = Date.today()+5;
        Date enddate = Date.today()+10;
        GRP_CC_Contract__c con = new GRP_CC_Contract__c(GRP_CC_Category__c='Spirits', 
                                                        Days_to_1st_Reminder_Chain_Acct_Resp__c=1, 
                                                        Days_to_2nd_Reminder_Chain_Acct_Resp__c=2, 
                                                        GRP_CC_Cycle__c=3, 
                                                        GRP_CC_Start_Date__c=startdate, 
                                                        GRP_cc_End_Date__c=enddate, 
                                                        GRP_CC_EndCollectOneDate__c=startdate);
        insert con;
        CORE_Brand__c brand = new CORE_Brand__c(Name='Test brand');
        insert brand;
        CORE_BrandQuality__c bq = new CORE_BrandQuality__c(Name='TestBQ', CORE_Brand__c=brand.Id);
        insert bq;
        
        CORE_Size__c si= new CORE_Size__c(Name='homol size', CORE_Value__c=1);
        insert si;
        CORE_BrandQualitySize__c bqs = new CORE_BrandQualitySize__c(name='homol bqs', CORE_BrandQuality__c=bq.Id, CORE_Size__c=si.Id);
        insert bqs;
        
        List<GRP_CC_Collect__c> massCollects = new List<GRP_CC_Collect__c>();
        List<GRP_CC_CollectBQ__c> massCollectsBQ = new List<GRP_CC_CollectBQ__c>();
        List<GRP_CC_CollectBQS__c> massCollectsBQS = new List<GRP_CC_CollectBQS__c>();
        for(integer i = 0;i<10;++i){ 
            GRP_CC_Collect__c col = new GRP_CC_Collect__c(GRP_CC_Contract__c=con.Id, 
                                                          GRP_CC_ChainAccount__c=ca.Id, 
                                                          GRP_CC_PeriodStart__c=startdate, 
                                                          GRP_CC_PeriodEnd__c=enddate, 
                                                          GRP_CC_State__c='New', 
                                                          GRP_CC_Status__c='New'); 
            massCollects.add(col);
        }
        insert massCollects;
        for(GRP_CC_Collect__c col : massCollects){
            for(integer i = 0;i<10;++i){ 
                GRP_CC_CollectBQ__c colBQ = new GRP_CC_CollectBQ__c(GRP_CC_Collect__c=col.Id, GRP_CC_BrandQuality__c=bq.Id); 
                GRP_CC_CollectBQS__c colBQS = new GRP_CC_CollectBQS__c(GRP_CC_Collect__c=col.Id, GRP_CC_BrandQualitySize__c=bqs.Id); 
                massCollectsBQ.add(colBQ); 
                massCollectsBQS.add(colBQS);
            }
        }
        insert massCollectsBQ;
        insert massCollectsBQS;
    }
    
    @isTest
    public static void testDeleteRelatedRecords(){
        GRP_CC_ChainAccount__c ca = [Select id, name, GRP_CC_Delete_related_records__c from GRP_CC_ChainAccount__c order by createddate desc LIMIT 1];
        List<GRP_CC_Collect__c> cols = [select id from GRP_CC_Collect__c where GRP_CC_ChainAccount__c=:ca.Id];
        System.assertEquals(10, cols.size());
        Test.startTest();
        
        ca.GRP_CC_Delete_related_records__c=true;
        update ca;
        
        Test.stopTest();
        cols = [select id from GRP_CC_Collect__c where GRP_CC_ChainAccount__c=:ca.Id];
        System.assertEquals(0, cols.size());
        
    }
}