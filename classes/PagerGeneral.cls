/********************************************************************
* Company: Valuenet 
* Desarrollador: Pablo Rossi

* Nombre del pagina: PagerGeneral
* Descripcion: paginador
* Fecha: 06/09/2013 
*********************************************************************/

public with sharing class PagerGeneral{
     
    private ApexPages.StandardSetController controller {get;set;}
     
    public PagerGeneral(String query, Integer pageSize){
        this(Database.getQueryLocator( query ),pageSize);
    }
     
    public PagerGeneral(Database.QueryLocator queryLoc, Integer pageSize){
        controller = new ApexPages.StandardSetController(queryLoc);
        controller.setPageSize(pageSize);
    }
     
    public void previous() {
         controller.previous();
    }
 
    public void next() {
         controller.next();
    }
     
    public Boolean hasResult{
        get{ return getResultSize() > 0;}
    }         
 
    public Integer getResultSize() {
         return (Integer) controller.getResultSize();
    }
     
    public Integer getPageSize(){
      return (Integer)controller.getPageSize();
  }
     
    public Integer getTotalPages() {
        Integer cantPaginas = (getResultSize()/getPageSize());
        Integer resultSize = getResultSize();
        Integer pageSize = getPageSize();
         
        if(math.mod(resultSize,pageSize)!=0){
            cantPaginas++;
        }
         return cantPaginas;
    }
     
    public String getItemsDisplaying() {
        Integer pageSize = (Integer) controller.getPageSize();
        Integer pageNumber = (Integer)controller.getPageNumber();
        Integer total = controller.getResultSize();
        if(pageSize*pageNumber < total){
            return (((pageNumber-1)*pageSize)+1)+' - '+(pageNumber*pageSize);           
        }else{
            return (((pageNumber-1)*pageSize)+1)+' - '+total;
        }
    }
     
    public void setPageNumber(Integer pageNumber){
             
        controller.setPageNumber(pageNumber);
    }
 
    public Integer getPageNumber() {
         return (Integer) controller.getPageNumber();
    }
 
    public Boolean hasNext {
        get {return controller.getHasNext();}
    }
  
    public Boolean hasPrevious {
        get {return controller.getHasPrevious();}
    }
 
    public void first() {
        controller.first();
    }
 
    public void last() {
        controller.last();
    }
     
    public List<SObject> getRecords(){
        return controller.getRecords();
    }
     
    public Boolean getCompleteResult(){
        return controller.getCompleteResult();
    }
      
}