public class ASI_MFM_KR_ActSpendWrapClass {
    public Decimal ASI_MFM_Amount {get;set;}{ASI_MFM_Amount=0;}
    public String ASI_MFM_Message {get;set;}{ASI_MFM_Message='';}
    public ASI_MFM_KR_ActSpendWrapClass(Decimal InputAmount, String InputMesg){
        this.ASI_MFM_Amount=InputAmount;
        this.ASI_MFM_Message=InputMesg;
    }
    
    public  ASI_MFM_KR_ActSpendWrapClass(){}
}