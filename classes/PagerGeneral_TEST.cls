/********************************************************************
* Company: Valuenet 
* Desarrollador: Pablo Rossi

* Nombre del pagina: PagerGeneral_TEST
* Descripcion: pagina de test de PagerGeneral
* Fecha: 06/09/2013 
*********************************************************************/

@isTest
public class PagerGeneral_TEST{
    static testmethod void test(){
        id idUser = UserInfo.getUserId();
        AggregateResult[] results = [SELECT count(id) total FROM User WHERE id=:idUser];
        Integer totalUsers = (Integer)results.get(0).get('total');
        PagerGeneral paginatedList = new PagerGeneral('SELECT id FROM User WHERE Id=\''+idUser+'\'',1);
         
        paginatedList.getRecords();
        paginatedList.getItemsDisplaying();
        paginatedList.setPageNumber(1);
        paginatedList.getTotalPages();
        paginatedList.getPageSize();
        system.assertEquals(totalUsers,paginatedList.getResultSize());
        system.assertEquals(1, paginatedList.getPageNumber());
        system.assertEquals(false,paginatedList.hasPrevious);
        if(totalUsers>1){
            system.assertEquals(true,paginatedList.hasNext);
            paginatedList.next();
            system.assertEquals(true,paginatedList.hasPrevious);
            system.assertEquals(2, paginatedList.getPageNumber());
            paginatedList.previous();
            system.assertEquals(1, paginatedList.getPageNumber());
            paginatedList.last();
            system.assertEquals(totalUsers,paginatedList.getPageNumber());
            system.assertEquals(false,paginatedList.hasNext);
            paginatedList.first();
            system.assertEquals(1, paginatedList.getPageNumber());
             
        }else{
            system.assertEquals(false, paginatedList.hasNext);
        }
    }
}