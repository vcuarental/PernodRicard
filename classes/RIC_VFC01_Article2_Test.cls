@istest 
public class RIC_VFC01_Article2_Test {
    public static testmethod void test(){
        user u=[select id from user where id=:UserInfo.getUserId() limit 1 ];
        system.runAs(u){   
            u.BypassVR__c=true;
            update u;
            
            RIC_Brand__c marque1= new RIC_Brand__c();
            marque1.Name='Test89';
            marque1.RIC_Prefixe__c='ab';
            insert marque1;
            
            Milestone1_Project__c projet1 = new Milestone1_Project__c(); 
            projet1.name='Test09';
            projet1.RIC_Brand__c=marque1.Id;
            projet1.Status__c='Validé';
            insert projet1;
            
            
            RIC_Article__c article1 =  new RIC_Article__c();
            article1.RIC_Project__c=projet1.id;
            article1.RIC_Statut__c='Créé';
            article1.Name='Test34';
            insert article1;
            
            RIC_Article2__c article2=new RIC_Article2__c();
            article2.name='Test67';
            article2.RIC_Article__c=article1.id;
            insert article2;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(article1);
            RIC_VFC01_Article2 testobj ;
            testobj =new RIC_VFC01_Article2(sc);
            testobj.getFields();  
            testobj.getFields3(); 
            testobj.getFields4(); 
            testobj.save();
            testobj.Cancel();
            testobj.Edit();  
            testobj.Edit();
            u.BypassVR__c=false; 
            
        }
    }
    
    
}