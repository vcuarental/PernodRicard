public class RIC_VFC01_Article2 {
    public boolean Edit {get;set;}
    public boolean Save {get;set;} 
    public boolean Cancel {get;set;} 
    public boolean BoutonEdit {get;set;} 
    public boolean Exist {get;set;} 
    //public boolean produitFini {get;set;}
    public RIC_Article__c article {get;set;}
    public ID articleID {get;set;}
    public RIC_Article__c articleRecord {get;set;}
    public RIC_Article2__c articles {get;set;}
    public RIC_Article2__c articl{get;set;}
    public RIC_VFC01_Article2 (ApexPages.StandardController ctrl) {
        
        Edit=False;
        BoutonEdit=True;
        Save=false; 
        Cancel=false; 
        //produitFini=false;
        articles = new RIC_Article2__c();
        this.articleRecord=(RIC_Article__c)ctrl.getrecord();
        //System.debug('##### paul articleRecord '+this.articleRecord);
        
        articleID =(String)ctrl.getRecord().get('Id');    
        list<RIC_Article2__c> listarticles=[select id,RIC_Article__c ,Typologie_Op_ration__c,RIC_Article__r.recordtype.name,RIC_Article__r.recordtype.id,RIC_Famille_de_peremption__c,RIC_Famille_de_stockage__c,  RIC_Type_de_kit__c,RIC_Type_article_OPP__c,RIC_Type_mati_re_OPP__c
                                            from RIC_Article2__c 
                                            where RIC_Article__c=: articleID limit 1 ];
        
       /* list<RIC_Article__c> listArticles1=[SELECT id,name,recordtypeid
                                           FROM RIC_Article__c
                                           where id =:this.articleRecord.id limit 1];*/
         /*System.debug('##### paul listArticles1 '+listArticles1);
         System.debug('##### paul listArticles1[0].recordtypeid '+listArticles1[0].recordtypeid);
        
        if(listArticles1[0].recordtypeid==Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini PERNOD').getRecordTypeId() 
           || listArticles1[0].recordtypeid==Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini RICARD').getRecordTypeId())
        {
            produitFini=true;
            
        }*/
        
        if(listarticles.size() >0){
            articles=listarticles.get(0);
            
        }
        else{
            articles.RIC_Article__c=articleID; 
        } 
        
    }
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.RIC_Article2__c.FieldSets.RIC_Article_Article2.getFields();
    }  
    public List<Schema.FieldSetMember> getFields3() {
        return SObjectType.RIC_Article2__c.FieldSets.RIC_Article_Article3.getFields();
    } 
    public List<Schema.FieldSetMember> getFields4() {
        return SObjectType.RIC_Article2__c.FieldSets.RIC_Article_Article4.getFields();
    } 
    public List<Schema.FieldSetMember> getFields5() {
        return SObjectType.RIC_Article2__c.FieldSets.RIC_Article_Article5.getFields();
    } 
    
    public pageReference save(){
        edit=false;
        Cancel=false; 
        Save=false;  
        BoutonEdit=False;   
        
        try{
            upsert articles; 
        }
        catch(exception e){
            
            edit=true;
            BoutonEdit=False; 
            Save=True;
            Cancel=True; 
        }
        return null;  
        
    }
    public PageReference Edit(){ 
        BoutonEdit=false;
        save=true; 
        edit=true; 
        Cancel=true;
        return null;
    }
    public PageReference Cancel(){
        save=false; 
        edit=false; 
        Cancel=false;
        return null;
        
    }   
    
}