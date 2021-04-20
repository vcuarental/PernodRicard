public class IntranetRedirect{
    public PageReference redirect(){
        return new PageReference('/apex/cms__Main?sname=InSite');
    }
}