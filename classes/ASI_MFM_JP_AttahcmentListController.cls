public with sharing class ASI_MFM_JP_AttahcmentListController {
  
  public String parentID {set;get;}
  public List<Att> LAtt {set;get;}
  public string sObjectName {set;get;}
  public string Dummy {set;}
  
  public ASI_MFM_JP_AttahcmentListController (){
    init();
  }
  
  public string getDummy(){
    init();
    return '';
  }
  
  public void init(){
    LAtt = new list<Att>();
    System.debug(parentid);
    if(parentID != null){
      for(Attachment a : [Select name, Id from Attachment where parentid= :parentID ]){
        LAtt.add(new Att(a.name, a.id));        
      }
      /*if(sObjectName != null && sObjectName != ''){
        
        String queryString = 'SELECT Id, ContentFileName,RelatedRecordId  From ' + sObjectName + '__Feed where Type = \'ContentPost\' and ParentId =\'' + parentID + '\' and id != null order by ContentFileName';
        system.debug(queryString);
        system.debug(sObjectName);
        if(sObjectName == 'ASI_MFM_PO'){
          for(ASI_MFM_PO__Feed a : database.query(queryString)){
            LAtt.add(new Att(a.ContentFileName, a.RelatedRecordId ));
          }
        }
        else if(sObjectName == 'ASI_MFM_Payment'){
          for(ASI_MFM_Payment__Feed a : database.query(queryString)){
            LAtt.add(new Att(a.ContentFileName, a.RelatedRecordId ));
          }
        }
      }*/
    }
    System.debug(LAtt);
  }
  
  public class Att{
    public string filename {set;get;}
    public string link {set;get;}
    public att(string f, string Recid){
      filename = f;
      link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + Recid;
    }
  }

}