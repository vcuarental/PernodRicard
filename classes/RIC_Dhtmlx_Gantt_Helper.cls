public class RIC_Dhtmlx_Gantt_Helper {
    
    public String myId {get;set;}
    
    public RIC_Dhtmlx_Gantt_Helper(ApexPages.StandardController stc){
        myId = stc.getId();
    }    
}